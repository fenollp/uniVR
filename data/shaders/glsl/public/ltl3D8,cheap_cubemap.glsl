// Shader downloaded from https://www.shadertoy.com/view/ltl3D8
// written by shadertoy user iq
//
// Name: Cheap Cubemap
// Description: A cheap cube map texturing method for 2D textures, without branches.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// How to do cubemapping when you don't have access to textureCube() or when you want to do it in the CPU.
// This is a very cheap version without seam filtering or anything.
//
// The point of this rutine was to do be super cheap and do the indexing without branches/conditionals.


vec3 cubemap( sampler2D sam, in vec3 d )
{
    vec3 n = abs(d);

#if 0
    // sort components (small to big)    
    float mi = min(min(n.x,n.y),n.z);
    float ma = max(max(n.x,n.y),n.z);
    vec3 o = vec3( mi, n.x+n.y+n.z-mi-ma, ma );
    return texture2D( sam, .1*o.xy/o.z ).xyz;
#else
    vec2 uv = (n.x>n.y && n.x>n.z) ? d.yz/d.x: 
              (n.y>n.x && n.y>n.z) ? d.zx/d.y:
                                     d.xy/d.z;
    return texture2D( sam, uv ).xyz;
    
#endif    
}

    
//===============================================================================================

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;

     // camera movement	
	float an = 0.2*iGlobalTime;
	vec3 ro = vec3( 2.5*sin(an), 1.0, 2.5*cos(an) );
    vec3 ta = vec3( 0.0, 1.0, 0.0 );
    // camera matrix
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	// create view ray
	vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

    // sphere center	
	vec3 sc = vec3(0.0,1.0,0.0);

    vec3 col = vec3(0.0);
    
	// raytrace-plane
	float h = (0.0-ro.y)/rd.y;
	if( h>0.0 ) 
	{ 
		vec3 pos = ro + h*rd;
		vec3 nor = vec3(0.0,1.0,0.0); 
		vec3 di = sc - pos;
		float l = length(di);
		float occ = 1.0 - dot(nor,di/l)*1.0*1.0/(l*l); 

        col = texture2D( iChannel0, 0.5*pos.xz ).xyz;
        col *= occ;
        col *= exp(-0.1*h);
	}

	// raytrace-sphere
	vec3  ce = ro - sc;
	float b = dot( rd, ce );
	float c = dot( ce, ce ) - 1.0;
	h = b*b - c;
	if( h>0.0 )
	{
		h = -b - sqrt(h);
        vec3 pos = ro + h*rd;
        vec3 nor = normalize(ro+h*rd-sc); 
        float occ = 0.5 + 0.5*nor.y;
        
        col = cubemap( iChannel0, nor );
        col *= occ;
    }

	col = sqrt( col );
	
	fragColor = vec4( col, 1.0 );
}