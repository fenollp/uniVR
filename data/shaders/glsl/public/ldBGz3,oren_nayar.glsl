// Shader downloaded from https://www.shadertoy.com/view/ldBGz3
// written by shadertoy user iq
//
// Name: Oren-Nayar
// Description: Oren-Nayar diffuse model, compared to regular Lambert
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//-----------------------------------------------------------------

float Lambert( in vec3 l, in vec3 n )
{
    float nl = dot(n, l);
	
    return max(0.0,nl);
}

float OrenNayar( in vec3 l, in vec3 n, in vec3 v, float r )
{
	
    float r2 = r*r;
    float a = 1.0 - 0.5*(r2/(r2+0.57));
    float b = 0.45*(r2/(r2+0.09));

    float nl = dot(n, l);
    float nv = dot(n, v);

    float ga = dot(v-n*nv,n-n*nl);

	return max(0.0,nl) * (a + b*max(0.0,ga) * sqrt((1.0-nv*nv)*(1.0-nl*nl)) / max(nl, nv));
}

//-----------------------------------------------------------------

float iSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
	return -b - sqrt( h );
}

float ssSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
    vec3 oc = sph.xyz - ro;
    float b = dot( oc, rd );
	
    float res = 1.0;
    if( b>0.0 ) // este branch se puede quitar seguramente
    {
        float h = dot(oc,oc) - b*b - sph.w*sph.w;
        res = clamp( 16.0 * h / b, 0.0, 1.0 );
    }
    return res;
}


float oSphere( in vec3 pos, in vec3 nor, in vec4 sph )
{
    vec3 di = sph.xyz - pos;
    float l = length(di);
    return 1.0 - max(0.0,dot(nor,di/l))*sph.w*sph.w/(l*l); 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;

	vec3 lig = normalize( vec3( 0.6, 0.5, 0.4) );
	vec3 bac = normalize( vec3(-0.6, 0.0,-0.4) );
	vec3 bou = normalize( vec3( 0.0,-1.0, 0.0) );
	
     // camera movement	
	float an = 0.6 - 0.5*iGlobalTime;
	vec3 ro = vec3( 3.5*cos(an), 1.0, 3.5*sin(an) );
    vec3 ta = vec3( 0.0, 1.0, 0.0 );
    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

    // sphere center	
	vec4 sph1 = vec4(-1.2,1.0,0.0,1.0);
	vec4 sph2 = vec4( 1.2,1.0,0.0,1.0);

    // raytrace
	float tmin = 10000.0;
	vec3  nor = vec3(0.0);
	float occ = 1.0;
	vec3  pos = vec3(0.0);
	float obj = 0.0;
	
	// raytrace-plane
	float h = (0.0-ro.y)/rd.y;
	if( h>0.0 ) 
	{ 
		tmin = h; 
		nor = vec3(0.0,1.0,0.0); 
		pos = ro + h*rd;
		occ = oSphere( pos, nor, sph1 ) *
			  oSphere( pos, nor, sph2 );
	    obj = 0.0;
	}

	// raytrace-sphere
	h = iSphere( ro, rd, sph1 );
	if( h>0.0 && h<tmin ) 
	{ 
		tmin = h; 
		pos = ro + h*rd;
		nor = normalize(pos-sph1.xyz); 
		occ = (0.5 + 0.5*nor.y) *
			  oSphere( pos, nor, sph2 );
	    obj = 1.0;
	}
	h = iSphere( ro, rd, sph2 );
	if( h>0.0 && h<tmin ) 
	{ 
		tmin = h; 
		pos = ro + h*rd;
		nor = normalize(pos-sph2.xyz); 
		occ = (0.5 + 0.5*nor.y) *
			  oSphere( pos, nor, sph1 );
	    obj = 2.0;
	}

    // shading/lighting	
	vec3 col = vec3(0.93);
	if( tmin<100.0 )
	{
	    pos = ro + tmin*rd;
		
        // shadows
		float sha = 1.0;
		sha *= ssSphere( pos, lig, sph1 );
		sha *= ssSphere( pos, lig, sph2 );

		vec3 lin = vec3(0.0);
		
		// integrate irradiance with brdf times visibility
		vec3 diffColor = vec3(0.18);
		if( obj>1.5 )
		{
            lin += vec3(0.5,0.7,1.0)*diffColor*occ;
	        lin += vec3(5.0,4.5,4.0)*diffColor*OrenNayar( lig, nor, rd, 1.0 )*sha;
	        lin += vec3(1.5,1.5,1.5)*diffColor*OrenNayar( bac, nor, rd, 1.0 )*occ;
	        lin += vec3(1.0,1.0,1.0)*diffColor*OrenNayar( bou, nor, rd, 1.0 )*occ;
		}
		else
		{
            lin += vec3(0.5,0.7,1.0)*diffColor*occ;
	        lin += vec3(5.0,4.5,4.0)*diffColor*Lambert( lig, nor )*sha;
	        lin += vec3(1.5,1.5,1.5)*diffColor*Lambert( bac, nor )*occ;
			lin += vec3(1.0,1.0,1.0)*diffColor*Lambert( bou, nor )*occ;
		}

		col = lin;
		
		// participating media
		col = mix( col, vec3(0.93), 1.0-exp( -0.002*tmin*tmin ) );
	}
	
    // gamma	
	col = pow( col, vec3(0.45) );
	
	fragColor = vec4( col, 1.0 );
}