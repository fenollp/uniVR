// Shader downloaded from https://www.shadertoy.com/view/lllXz4
// written by shadertoy user iq
//
// Name: Inverse Spherical Fibonacci
// Description: Spherical Fibonacci points, as described by this paper [url=http://lgdv.cs.fau.de/uploads/publications/spherical_fibonacci_mapping_opt.pdf]http://lgdv.cs.fau.de/uploads/publications/spherical_fibonacci_mapping_opt.pdf[/url]
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.



// Spherical Fibonnacci points, as described by Benjamin Keinert, Matthias Innmann, 
// Michael Sanger and Marc Stamminger in their paper (below)


//=================================================================================================
// http://lgdv.cs.fau.de/uploads/publications/spherical_fibonacci_mapping_opt.pdf
//=================================================================================================
const float PI  = 3.14159265359;
const float PHI = 1.61803398875;

float round( float x ) { return floor(x+0.5); }

vec2 inverseSF( vec3 p, float n ) 
{
    float m = 1.0 - 1.0/n;
    
    float phi = min(atan(p.y, p.x), PI), cosTheta = p.z;
    
    float k  = max(2.0, floor( log(n * PI * sqrt(5.0) * (1.0 - cosTheta*cosTheta))/ log(PHI+1.0)));
    float Fk = pow(PHI, k)/sqrt(5.0);
    vec2  F  = vec2( round(Fk), round(Fk * PHI) ); // k, k+1

    vec2 ka = 2.0*F/n;
    vec2 kb = 2.0*PI*( fract((F+1.0)*PHI) - (PHI-1.0) );    
    
    mat2 iB = mat2( ka.y, -ka.x, 
                    kb.y, -kb.x ) / (ka.y*kb.x - ka.x*kb.y);
    
    vec2 c = floor( iB * vec2(phi, cosTheta - m));
    float d = 8.0;
    float j = 0.0;
    for( int s=0; s<4; s++ ) 
    {
        vec2 uv = vec2( float(s-2*(s/2)), float(s/2) );
        
        float i = dot(F, uv + c); // all quantities are ingeters (can take a round() for extra safety)
        
        float phi = 2.0*PI*fract(i*PHI);
        float cosTheta = m - 2.0*i/n;
        float sinTheta = sqrt(1.0 - cosTheta*cosTheta);
        
        vec3 q = vec3( cos(phi)*sinTheta, sin(phi)*sinTheta, cosTheta );
        float squaredDistance = dot(q-p, q-p);
        if (squaredDistance < d) 
        {
            d = squaredDistance;
            j = i;
        }
    }
    return vec2( j, sqrt(d) );
}


//=================================================================================================
// iq code starts here
//=================================================================================================

float hash1( float n ) { return fract(sin(n)*158.5453123); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;

     // camera movement	
	float an = 0.5*iGlobalTime;
	vec3 ro = vec3( 2.5*cos(an), 1.0, 2.5*sin(an) );
    vec3 ta = vec3( 0.0, 1.0, 0.0 );
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

    // sphere center	
	vec3 sc = vec3(0.0,1.0,0.0);
    
    vec3 col = vec3(1.0);

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
        col = vec3(1.0);
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
			nor = normalize(ro+h*rd-sc); 
			occ = 0.5 + 0.5*nor.y;
		}
        
        const float precis = 150.0;
        vec2 fi = inverseSF(nor, precis);
        col = 0.5 + 0.5*sin( hash1(fi.x*13.0)*3.0 + 1.0 + vec3(0.0,1.0,1.0));
        col *= smoothstep(0.02, 0.03, fi.y);
        col *= mix( 1.0, 1.0 - smoothstep(0.12, 0.125, fi.y), smoothstep(-0.1,0.1,sin(iGlobalTime) )) ;
        col *= 1.0 + 0.1*sin(250.0*fi.y);
        col *= 1.5;
	}

	if( tmin<100.0 )
	{
	    pos = ro + tmin*rd;
		col *= occ;
		col = mix( col, vec3(1.0), 1.0-exp( -0.003*tmin*tmin ) );
	}
	
	col = sqrt( col );
	
	fragColor = vec4( col, 1.0 );
}