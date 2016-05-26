// Shader downloaded from https://www.shadertoy.com/view/XdS3Rt
// written by shadertoy user iq
//
// Name: Sphere - visibility
// Description: Analytical sphere visibility. Can be used for occlusion culling!  White: spheres don't touch.   Yellow: spheres touch (partial occlusion).   Red: spheres completely occlude each other. I'm expecting the &quot;Yellow is gay&quot; joke.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Analytical sphere visibility, which can be used of occlusion culling, based on this
//
// Aarticle I wrote in 2008: http://iquilezles.org/www/articles/sphereocc/sphereocc.htm
//
// Related info: http://iquilezles.org/www/articles/spherefunctions/spherefunctions.htm

//-----------------------------------------------------------------

// 1: spheres don't overlap
// 2: spheres overlap partially
// 3: spheres overlap completely

int sphereVisibility( in vec4 sA, in vec4 sB, in vec3 c )
{
    vec3 ac = sA.xyz - c;
    vec3 bc = sB.xyz - c;

    float ia = 1.0/length(ac);
    float ib = 1.0/length(bc);

    float k0 = dot(ac,bc)*ia*ib;
    float k1 = sA.w*ia;
    float k2 = sB.w*ib;

	     if( k0*k0 + k1*k1 + k2*k2 + 2.0*k0*k1*k2 - 1.0 < 0.0 ) return 1;
	else if( k0*k0 + k1*k1 + k2*k2 - 2.0*k0*k1*k2 - 1.0 < 0.0 ) return 2;

	return 3;
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

float oSphere( in vec3 pos, in vec3 nor, in vec4 sph )
{
    vec3 di = sph.xyz - pos;
    float l = length(di);
    return 1.0 - max(0.0,dot(nor,di/l))*sph.w*sph.w/(l*l); 
}

//-----------------------------------------------------------------

vec3 hash3( float n ) { return fract(sin(vec3(n,n+1.0,n+2.0))*43758.5453123); }

//-----------------------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;
	
	float an = 0.6 - 0.5*iGlobalTime + 10.0*iMouse.x/iResolution.x;
	vec3 ro = vec3( 3.5*cos(an), 0.0, 3.5*sin(an) );
    vec3 ta = vec3( 0.0, 0.0, 0.0 );
	vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

	vec4 sph1 = vec4(-1.2,0.7,0.0,1.0);
	vec4 sph2 = vec4( 1.2,0.0,0.0,1.0);

    int vis = sphereVisibility( sph1, sph2, ro );

	float tmin = 10000.0;
	vec3  nor = vec3(0.0);
	float occ = 1.0;
	vec3  pos = vec3(0.0);
	
	float h = iSphere( ro, rd, sph1 );
	if( h>0.0 && h<tmin ) 
	{ 
		tmin = h; 
		pos = ro + h*rd;
		nor = normalize(pos-sph1.xyz); 
		occ = oSphere( pos, nor, sph2 );
		occ *= smoothstep(-0.6,-0.2,sin(20.0*(pos.x-sph1.x)));
	}
	h = iSphere( ro, rd, sph2 );
	if( h>0.0 && h<tmin ) 
	{ 
		tmin = h; 
		pos = ro + h*rd;
		nor = normalize(pos-sph2.xyz); 
		occ = oSphere( pos, nor, sph1 );
		occ *= smoothstep(-0.6,-0.2,sin(20.0*(pos.z-sph1.z)));
	}

	vec3 col = vec3(0.02)*clamp(1.0-0.5*length(p),0.0,1.0);
	if( tmin<100.0 )
	{
	    pos = ro + tmin*rd;
        col = vec3(0.5);
		if( vis==1 ) col = vec3(1.0,1.0,1.0);
		if( vis==2 ) col = vec3(1.0,1.0,0.0);
		if( vis==3 ) col = vec3(1.0,0.0,0.0);
		col *= occ;
		col *= 0.7 + 0.3*nor.y;
		col *= exp(-0.5*max(0.0,tmin-2.0));
	}

	col = pow( col, vec3(0.45) );

    col += (1.0/255.0)*hash3(p.x+13.0*p.y);

	fragColor = vec4( col, 1.0 );
}