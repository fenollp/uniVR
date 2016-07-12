// Shader downloaded from https://www.shadertoy.com/view/4sdGWN
// written by shadertoy user XT95
//
// Name: Hemispherical SDF AO
// Description: Mixing the &quot;classical SDF AO&quot; with random hemisphere directions instead of the normal.
//    Good result, but that need more iterations and that have some self occlusion problems..
//    
//    Use the mouse to compare
//    
//    Any idea :) ?
//    
// Created by anatole duprat - XT95/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//More details here http://www.aduprat.com/portfolio/?page=articles/hemisphericalSDFAO

const float PI = 3.14159265359;

vec3 raymarche( in vec3 ro, in vec3 rd, in vec2 nfplane );
vec3 normal( in vec3 p );
float box( in vec3 p, in vec3 data );
float map( in vec3 p );

mat3 lookat( in vec3 fw, in vec3 up );
mat3 rotate( in vec3 v, in float angle);


float hash( float n )//->0:1
{
    return fract(sin(n)*3538.5453);
}
vec3 randomSphereDir(vec2 rnd)
{
	float s = rnd.x*PI*2.;
	float t = rnd.y*2.-1.;
	return vec3(sin(s), cos(s), t) / sqrt(1.0 + t * t);
}
vec3 randomHemisphereDir(vec3 dir, float i)
{
	vec3 v = randomSphereDir( vec2(hash(i+1.), hash(i+2.)) );
	return v * sign(dot(v, dir));
}

float ambientOcclusion( in vec3 p, in vec3 n, float maxDist, float falloff )
{
	const int nbIte = 32;
    const float nbIteInv = 1./float(nbIte);
    const float rad = 1.-1.*nbIteInv; //Hemispherical factor (self occlusion correction)
    
	float ao = 0.0;
    
    for( int i=0; i<nbIte; i++ )
    {
        float l = hash(float(i))*maxDist;
        vec3 rd = normalize(n+randomHemisphereDir(n, l )*rad)*l; // mix direction with the normal
        													    // for self occlusion problems!
        
        ao += (l - map( p + rd )) / pow(1.+l, falloff);
    }
	
    return clamp( 1.-ao*nbIteInv, 0., 1.);
}


float classicAmbientOcclusion( in vec3 p, in vec3 n, float maxDist, float falloff )
{
	float ao = 0.0;
	const int nbIte = 6;
    for( int i=0; i<nbIte; i++ )
    {
        float l = hash(float(i))*maxDist;
        vec3 rd = n*l;
        
        ao += (l - map( p + rd )) / pow(1.+l, falloff);
    }
	
    return clamp( 1.-ao/float(nbIte), 0., 1.);
}


//Shading
vec3 shade( in vec3 p, in vec3 n, in vec3 org, in vec3 dir, vec2 v )
{		
    vec3 col = vec3(1.);
	
    float a = ambientOcclusion(p,n, 5., .9);
    float b = classicAmbientOcclusion(p,n, 5., .9);
    
    if( iMouse.z > .5 ) 
    {
        if( v.x-iMouse.x/iResolution.x >0. )
			col *= a;
        else
            col *= b;
    }
    else
    {
        if( v.x > 0.5 )
			col *= a;
        else
            col *= b;
    }
        
	return col;
}

//Main
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//screen coords
	vec2 q = fragCoord.xy/iResolution.xy;
	vec2 v = -1.0+2.0*q;
	v.x *= iResolution.x/iResolution.y;
	
	//camera ray
	float ctime = (iGlobalTime)*.25;
	vec3 ro = vec3( cos(ctime)*5.,10.+cos(ctime*.5)*3.,-13.+sin(ctime) );
	vec3 rd = normalize( vec3(v.x, v.y, 1.5) );
	rd = lookat( -ro + vec3(0., 5., 0.), vec3(0., 1., 0.) ) * rd;
	
	//classic raymarching by distance field
	vec3 p = raymarche(ro, rd, vec2(1., 30.) );
	vec3 n = normal(p.xyz);
	vec3 col = shade(p, n, ro, rd, q);
	
	//Gamma correction
    col = pow(col, vec3(1./2.2));
    
    if( iMouse.z > .5 ) 
    {
    	if( abs(q.x-iMouse.x/iResolution.x) < 1./iResolution.x )
        	col = vec3(0.);
    }
    else if( abs(q.x-.5) < 1./iResolution.x)
        col = vec3(0.);
        
	fragColor = vec4( col, 1. );
}




    
float map( in vec3 p )
{
	float d = -box(p-vec3(0.,10.,0.),vec3(10.));
	d = min(d, box(rotate(vec3(0.,1.,0.), 1.)*(p-vec3(4.,5.,6.)), vec3(3.,5.,3.)) );
	d = min(d, box(rotate(vec3(0.,1.,0.),-1.)*(p-vec3(-4.,2.,0.)), vec3(2.)) );
	d = max(d, -p.z-9.);
	
	return d;
}


vec3 raymarche( in vec3 ro, in vec3 rd, in vec2 nfplane )
{
	vec3 p = ro+rd*nfplane.x;
	float t = 0.;
	for(int i=0; i<64; i++)
	{
        float d = map(p);
        t += d;
        p += rd*d;
		if( d < 0.001 || t > nfplane.y )
            break;
            
	}
	
	return p;
}
vec3 normal( in vec3 p )
{
	vec3 eps = vec3(0.001, 0.0, 0.0);
	return normalize( vec3(
		map(p+eps.xyy)-map(p-eps.xyy),
		map(p+eps.yxy)-map(p-eps.yxy),
		map(p+eps.yyx)-map(p-eps.yyx)
	) );
}

float box( in vec3 p, in vec3 data )
{
    return max(max(abs(p.x)-data.x,abs(p.y)-data.y),abs(p.z)-data.z);
}


mat3 lookat( in vec3 fw, in vec3 up )
{
	fw = normalize(fw);
	vec3 rt = normalize( cross(fw, normalize(up)) );
	return mat3( rt, cross(rt, fw), fw );
}

mat3 rotate( in vec3 v, in float angle)
{
	float c = cos(angle);
	float s = sin(angle);
	
	return mat3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
		(1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
		(1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z
		);
}


