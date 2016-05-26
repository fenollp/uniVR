// Shader downloaded from https://www.shadertoy.com/view/MtsGWH
// written by shadertoy user iq
//
// Name: Boxmapping
// Description: Boxmapping (called also &quot;rounded cube&quot; in some places). Useful to texture 3D geometry when you don't have UV maps nor you want to pay the cost of 3D/solid texturing.
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// How to do cubemapping when you don't have access to textureCube() or when you want to do it in the CPU.
// This is a very cheap version without seam filtering or anything.
//
// The point of this rutine was to do be super cheap and do the indexing without branches/conditionals.


vec4 boxmap( sampler2D sam, in vec3 p, in vec3 n, in float k )
{
    vec3 m = pow( abs(n), vec3(k) );
	vec4 x = texture2D( sam, p.yz );
	vec4 y = texture2D( sam, p.zx );
	vec4 z = texture2D( sam, p.xy );
	return (x*m.x + y*m.y + z*m.z)/(m.x+m.y+m.z);
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

        col = texture2D( iChannel0, 0.25*pos.xz ).xyz;
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
        
        col = boxmap( iChannel0, pos, nor, 32.0 ).xyz;
        col *= occ;
    }

	col = sqrt( col );
	
	fragColor = vec4( col, 1.0 );
}