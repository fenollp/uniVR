// Shader downloaded from https://www.shadertoy.com/view/ldSGzR
// written by shadertoy user iq
//
// Name: Screen space bump mapping
// Description: Mikkelsen's technique for Bump Mapping Unparametrized Surfaces  (pretty much copy &amp; pasted).
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Mikkelsen's technique for Bump Mapping Unparametrized Surfaces 
// https://dl.dropboxusercontent.com/u/55891920/papers/mm_sfgrad_bump.pdf
// Pretty much copy & pasted, with minor changes. It aliases quite a bit :(
	

//===============================================================================================
//===============================================================================================
//===============================================================================================
//===============================================================================================
//===============================================================================================

vec3 doBump( in vec3 pos, in vec3 nor, in float signal, in float scale )
{
    // build frame	
    vec3  s = dFdx( pos );
    vec3  t = dFdy( pos );
    vec3  u = cross( t, nor );
    vec3  v = cross( nor, s );
    float d = dot( s, u );

    // compute bump	
    float bs = dFdx( signal );
    float bt = dFdy( signal );
	
    // offset normal	
#if 1
	return normalize( nor - scale*(bs*u + bt*v)/d );
#else
    // if you cannot ensure the frame is not null	
	vec3 vSurfGrad = sign( d ) * ( bs * u + bt * v );
    return normalize( abs(d)*nor - scale*vSurfGrad );
#endif
}

//===============================================================================================
//===============================================================================================
//===============================================================================================
//===============================================================================================
//===============================================================================================
float softShadowSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
    vec3 oc = sph.xyz - ro;
    float b = dot( oc, rd );
	
    float res = 1.0;
    if( b>0.0 )
    {
        float h = dot(oc,oc) - b*b - sph.w*sph.w;
        res = clamp( 2.0 * h / b, 0.0, 1.0 );
    }
    return res;
}

vec4 texcube( sampler2D sam, in vec3 p, in vec3 n )
{
	vec4 x = texture2D( sam, p.yz );
	vec4 y = texture2D( sam, p.zx );
	vec4 z = texture2D( sam, p.xy );
	return x*abs(n.x) + y*abs(n.y) + z*abs(n.z);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;

	float bump = smoothstep( -0.9, -0.6, cos( 0.5*iGlobalTime ) );
	
     // camera movement	
	float an = 3.1 + 0.25*iGlobalTime + iMouse.x/200.0;
	vec3 ro = vec3( 2.5*cos(an), 1.0, 2.5*sin(an) );
    vec3 ta = vec3( 0.0, 1.0, 0.0 );
    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

    // sphere center	
	vec3 sc = vec3(0.0,1.0,0.0);

	vec3 mate = vec3(0.0);
	
    // raytrace
	float tmin = 10000.0;
	vec3  nor = vec3(0.0);
	float occ = 1.0;
	vec3  pos = vec3(0.0);
	
	// raytrace-plane
	float h = (0.0-ro.y)/rd.y;
	if( h>0.0 ) 
	{ 
		tmin = h; 
		nor = vec3(0.0,1.0,0.0); 
		pos = ro + h*rd;
		
		vec3 di = sc - pos;
		float l = length(di);
		occ = 1.0 - dot(nor,di/l)*1.0*1.0/(l*l); 
		
		
		mate = texture2D( iChannel0, 0.25*pos.zx, .3*l ).xyz;
		nor = doBump( pos, nor, dot(mate,vec3(0.33)), 0.1*bump );
	}

	// raytrace-sphere
	vec3  ce = ro - sc;
	float b = dot( rd, ce );
	float c = dot( ce, ce ) - 1.0;
	h = b*b - c;
	if( h>0.0 )
	{
		h = -b - sqrt(h);
		if( h<tmin ) 
		{ 
			tmin=h; 
            pos = ro + tmin*rd;
			nor = normalize(ro+h*rd-sc); 
			mate = texcube( iChannel0, 0.25*pos, nor ).xyz;
		    nor = doBump( pos, nor, dot(mate,vec3(0.33)), 0.025*bump );

			occ = 0.5 + 0.5*nor.y;
		}
	}

    // shading/lighting	
	vec3 col = vec3(0.9);
	if( tmin<100.0 )
	{
	    pos = ro + tmin*rd;
		
		float sh = softShadowSphere( pos, vec3(0.57703), vec4(sc,1.0) );
        vec3 lin = vec3(0.8,0.7,0.6)*sh * clamp(dot(nor,vec3(0.57703)),0.0,1.0);
		     lin += occ*vec3(0.2,0.3,0.4);
		     lin += sh*0.5*pow(clamp(dot(reflect(rd,nor),vec3(0.57703)),0.0,1.0),12.0);
		col = mate * lin;
		col = mix( col, vec3(0.9), 1.0-exp( -0.003*tmin*tmin ) );
	}
	
	col = sqrt( col );
	
	fragColor = vec4( col, 1.0 );
}