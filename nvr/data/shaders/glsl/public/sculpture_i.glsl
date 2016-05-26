// Shader downloaded from https://www.shadertoy.com/view/XssGRl
// written by shadertoy user iq
//
// Name: Sculpture I
// Description: Some weird sculpture. It's made of three spheres distorted with noise.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// define this for higher quality nosie
//#define HQ_NOISE

// Uncomment the following for 3D!
//#define STEREO 


vec3 hash3( float n )
{
    return fract(sin(vec3(n,n+1.0,n+2.0))*vec3(43758.5453123,22578.1459123,19642.3490423));
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
#ifndef HQ_NOISE
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
#else
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z);
	vec2 rg = mix( mix( texture2D( iChannel0, (uv+ vec2(0.5,0.5))/256.0, -100.0 ).yx,
				        texture2D( iChannel0, (uv+ vec2(1.5,0.5))/256.0, -100.0 ).yx, f.x ),
				   mix( texture2D( iChannel0, (uv+ vec2(0.5,1.5))/256.0, -100.0 ).yx,
				        texture2D( iChannel0, (uv+ vec2(1.5,1.5))/256.0, -100.0 ).yx, f.x ), f.y );

#endif	
	return mix( rg.x, rg.y, f.z );
}

//=====================================================

vec3 texturize( sampler2D sa, vec3 p, vec3 n )
{
	vec3 x = texture2D( sa, p.yz ).xyz;
	vec3 y = texture2D( sa, p.zx ).xyz;
	vec3 z = texture2D( sa, p.xy ).xyz;
	return x*abs(n.x) + y*abs(n.y) + z*abs(n.z);
}

//----------------------------------------------------------------


vec2 map( vec3 p )
{
	p.y -= 1.5;
	
	vec3 q = p;

    vec2 res = vec2( 1e10, 0.0 );
	
	float it = floor( iGlobalTime/6.0 );
	float ft = fract( iGlobalTime/6.0 );
	float tt = it + 1.0 - pow(1.0-ft,5.0);
	float id = 0.0;
	for( int k=0; k<3; k++ )
	{
	    vec3 off = -1.0*tt*sin( float(k)*vec3(11.0,3.1,5.5)+vec3(0.0,1.0,2.0));

		p.xz += 2.0*(-1.0 + 2.0*noise( p  + off));
		p.y += 0.2;

		float d = length( p ) - 1.8;

		if( d<res.x ) res=vec2(d,1.0+float(k));
		
		p = p.yzx;
	}
	
	res.x *= 0.1*0.5;

	float di = sin(30.0*q.x)*sin(30.0*q.y)*sin(30.0*q.z);
	di = di*di;
	res.x += 0.005*di;

	return res;
}

float map2( in vec3 p )
{
	return min( map(p).x, p.y );
}

vec2 intersect( in vec3 ro, in vec3 rd )
{
	float maxd = 8.0;
	vec2 res = vec2(1e10,-1.0);

    // intersect ground plane	
	float tp = (0.0-ro.y)/rd.y;
    if( tp>0.0 ) {res = vec2(tp,0.0), maxd=min(maxd,tp); }

    // intersect sculpture	
	float precis = 0.001;
    float h = 1.0;
    float t = 1.0;
    float m = -1.0;
    for( int i=0; i<256; i++ )
    {
        if( h<precis||t>maxd ) break;
	    vec2 res = map( ro+rd*t );
        h = res.x;
		m = res.y;
        t += h;
    }
	if( t<maxd && t<res.x ) res=vec2(t,m);

	return res;
}

vec3 calcNormal( in vec3 pos )
{
    vec3 eps = vec3(0.01,0.0,0.0);

	return normalize( vec3(
           map(pos+eps.xyy).x - map(pos-eps.xyy).x,
           map(pos+eps.yxy).x - map(pos-eps.yxy).x,
           map(pos+eps.yyx).x - map(pos-eps.yyx).x ) );
}

float softshadow( in vec3 ro, in vec3 rd, float k )
{
    float res = 1.0;
    float t = 0.01;
	float h = 1.0;
    for( int i=0; i<64; i++ )
    {
        h = map(ro + rd*t).x;
        res = min( res, max(k*h/t,0.0) );
		t += clamp( h, 0.02, 0.1 );
		if( h<0.0001 ) break;
    }
    return clamp(res,0.0,1.0);
}

float calcAO( in vec3 pos, in vec3 nor, in vec2 pix )
{
	float off = 0.1*dot( pix, vec2(1.2,5.3) );
	float totao = 0.0;
    for( int aoi=0; aoi<16; aoi++ )
    {
		vec3 aopos = -1.0+2.0*hash3(float(aoi)*213.47 + off);
		aopos = aopos*aopos*aopos;
		aopos *= sign( dot(aopos,nor) );
        float dd = clamp( map2( pos + nor*0.05 + aopos )*48.0, 0.0, 1.0 );
        totao += dd;
    }
	totao /= 16.0;
	
    return clamp( totao*totao*1.0, 0.0, 1.0 );
}

vec3 lig = normalize(vec3(0.8,0.4,0.2));

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.5);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;

	#ifdef STEREO
	float eyeID = mod(fragCoord.x + mod(fragCoord.y,2.0),2.0);
    #endif

    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
	
	float an = 10.5 + 0.12*iGlobalTime - 7.0*m.x;

	vec3 ro = vec3(4.5*sin(an),2.0,4.5*cos(an));
    vec3 ta = vec3(0.0,1.9,0.0);
    float cr = 0.2*cos(0.1*an);
    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(cr),cos(cr),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

	#ifdef STEREO
	vec3 fo = ro + rd*7.0; // put focus plane behind Mike
	ro -= 0.1*uu*eyeID;    // eye separation
	rd = normalize(fo-ro);
    #endif

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------
    float sun = clamp( dot(rd,lig), 0.0, 1.0 );
	vec3 bg = mix( 0.6*vec3(0.98,0.99,0.8), 0.8*vec3(0.8,0.6,0.3), pow(1.0-max(0.0,rd.y),4.0) );
	vec3 col = bg;
	col += vec3(1.0,0.8,0.4)*1.0*pow( sun, 50.0 );

	// raymarch
    vec2 tmat = intersect(ro,rd);
    if( tmat.y>-0.5 )
    {
        // geometry
        vec3 pos = ro + tmat.x*rd;
        vec3 nor = calcNormal(pos);
		vec3 ref = reflect( rd, nor );
        vec3 tex = vec3(0.0);
		
        float di = sin(30.0*pos.x)*sin(30.0*(pos.y-1.5))*sin(30.0*pos.z);

        // materials
		vec4 mate = vec4(0.0);
		vec2 mate2 = vec2(0.0,1.0);
		if( tmat.y<0.5 )
		{
			mate.xyz = vec3(0.5,0.3,0.1);
			mate.xyz = 1.2*vec3(0.8,0.65,0.2);
			
			mate2.x = 1.0;
            mate2.y = 1.0 - 0.75*(5.0/(5.0+dot(pos.xz,pos.xz)));
			nor = vec3(0.0,1.0,0.0);
			
			tex = texture2D( iChannel3, pos.xz*0.15 ).xyz;
		    mate.xyz *= tex;
			
		}
		else
		{
            mate2.x = 1.0;
			mate = vec4(0.3,0.3,0.3,0.8);
			mate.xyz = 0.5 + 0.5*cos( tmat.y*vec3(1.0) + 2.0 + vec3(0.0,0.5,0.8) );
			
		    tex = texturize( iChannel3, 0.2*pos*vec3(1.0,4.0,1.0), nor ).xyz;
		    mate.xyz *= tex.xyz;

		    mate.xyz = mix( mate.xyz, vec3(0.2,0.2,0.1)*0.5, 0.6*smoothstep(0.0,1.0,nor.y) );
			
			float hh = sin(30.0*pos.y);
			
			mate.xyz += 0.1*(1.0-smoothstep(-0.8,-0.5,hh))*(1.0-clamp((tmat.y-1.0)*4.0,0.0,1.0));
            mate2.y *= 1.0-0.85*di*di;		
			
		}

		// lighting
		float occ = mate2.y  * calcAO( pos, nor, fragCoord );
		
		
        float sky = 0.6 + 0.4*nor.y;
		float bou = clamp(-nor.y,0.0,1.0)*1.0*clamp(1.0-pos.y/8.0,0.0,1.0);
		float dif = max(dot(nor,lig),0.0);
        float bac = max(0.3 + 0.7*dot(nor,normalize(vec3(-lig.x,0.0,-lig.z))),0.0);
		float sha = 0.0; if( dif>0.01 ) sha=softshadow( pos+0.01*nor, lig, 256.0 );
        float fre = pow( clamp( 1.0 + dot(nor,rd), 0.0, 1.0 ), 2.0 );
        float spe = tex.x*max( 0.0, pow( clamp( dot(lig,reflect(rd,nor)), 0.0, 1.0), mate2.x*tex.x*2.0 ) );

		// lights
		vec3 lin  = 2.9*dif*vec3(1.0,0.90,0.70)*sha*(0.8+0.2*occ);
		     lin += 0.6*bac*vec3(0.5,0.40,0.25)*occ;
		     lin += 0.6*sky*vec3(0.6,1.00,1.50)*occ;
		     lin += 0.6*bou*vec3(0.5,0.45,0.25)*occ;
             lin += 0.6*fre*vec3(1.0,0.95,0.70)*2.0*mate.w*(0.1+0.9*occ*dif*sha);
             lin += 4.0*spe*vec3(1.0,1.00,1.00)*occ*(0.2+0.8*fre);
		
		// surface-light interacion
		col = mate.xyz * lin;
		col += pow(spe,8.0)*0.25*sha*occ;
		
		col = mix( col, bg, 1.0-exp(-0.002*tmat.x*tmat.x) );
	}

	// sun glow
    col += vec3(1.0,0.6,0.2)*0.15*pow( sun, 4.0 );

	
	//-----------------------------------------------------
	// postprocessing
    //-----------------------------------------------------
    // gamma
	col = pow( clamp(col,0.0,1.0), vec3(0.45) );
	// contrast
	col = col*0.6 + 0.4*col*col*(3.0-2.0*col);

	// vigneting
    col *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.1 );

    #ifdef STEREO	
    col *= vec3( eyeID, 1.0-eyeID, 1.0-eyeID );	
	#endif

    fragColor = vec4( col, 1.0 );
}
