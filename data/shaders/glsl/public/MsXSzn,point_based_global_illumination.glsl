// Shader downloaded from https://www.shadertoy.com/view/MsXSzn
// written by shadertoy user XT95
//
// Name: Point Based Global Illumination
// Description: An approximation of global illumination (noise free) by a disk to disk approach.
//    Distance field is only used to show the cornell box, not to compute the GI.
//    
// Created by anatole duprat - XT95/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Papers :
// http://http.developer.nvidia.com/GPUGems2/gpugems2_chapter14.html
// http://graphics.pixar.com/library/PointBasedColorBleeding/paper.pdf
// http://graphics.pixar.com/library/PointBasedGlobalIlluminationForMovieProduction/paper.pdf



struct Surfel
{
	vec3 pos,n,col;
	float area;
};
	
#define NBSURFEL 18
Surfel surfel[NBSURFEL];
void generateSurfelsList();



//Maths
const float PI = 3.14159265359;
mat3 rotate( in vec3 v, in float angle)
{
	float c = cos(radians(angle));
	float s = sin(radians(angle));
	
	return mat3(c + (1.0 - c) * v.x * v.x, (1.0 - c) * v.x * v.y - s * v.z, (1.0 - c) * v.x * v.z + s * v.y,
		(1.0 - c) * v.x * v.y + s * v.z, c + (1.0 - c) * v.y * v.y, (1.0 - c) * v.y * v.z - s * v.x,
		(1.0 - c) * v.x * v.z - s * v.y, (1.0 - c) * v.y * v.z + s * v.x, c + (1.0 - c) * v.z * v.z
		);
}
mat3 lookat( in vec3 fw, in vec3 up )
{
	fw = normalize(fw);
	vec3 rt = normalize( cross(fw, normalize(up)) );
	return mat3( rt, cross(rt, fw), fw );
}
float occ( float cosE, float cosR, float a, float d) // Element to element occlusion
{
	return ( clamp(cosE,0.,1.) * clamp(4.*cosR,0.,1.) ) / sqrt( a/PI + d*d );
}
float radiance( float cosE, float cosR, float a, float d) // Element to element radiance transfer
{
	return (a * max(cosE,0.) * max(cosR,0.) ) / ( PI*d*d + a );
}

//Raymarching 
float map( in vec3 p );
float box( in vec3 p, in vec3 data )
{
    return max(max(abs(p.x)-data.x,abs(p.y)-data.y),abs(p.z)-data.z);
}
vec4 raymarche( in vec3 org, in vec3 dir, in vec2 nfplane )
{
	float d = 1.0, g = 0.0, t = 0.0;
	vec3 p = org+dir*nfplane.x;
	
	for(int i=0; i<64; i++)
	{
		if( d > 0.001 && t < nfplane.y )
		{
			d = map(p);
			t += d;
			p += d * dir;
			g += 1./64.;
		}
	}
	
	return vec4(p,g);
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



//Geometry
float map( in vec3 p )
{
	float d = -box(p-vec3(0.,10.,0.),vec3(10.));
	d = min(d, box(rotate(vec3(0.,1.,0.), 0.)*(p-vec3(4.,5.,6.)), vec3(3.,5.,3.)) );
	d = min(d, box(rotate(vec3(0.,1.,0.), 0.)*(p-vec3(-4.,2.,0.)), vec3(2.)) );
	d = max(d, -p.z-9.);
	
	return d;
}



//Shading
vec3 shade( in vec4 p, in vec3 n, in vec3 org, in vec3 dir )
{		
	//wall color
	vec3 amb = vec3(.5);
	if(p.x<-9.999)
		amb = vec3(1.,0.,0.);
	else if(p.x>9.999)
		amb = vec3(.0,0.,1.);
	else
		amb = vec3(1);
		
	
	//computing GI and ambient occlusion with the surfels
	vec3 gi = vec3(0.);
	vec3 glossy = vec3(0.);
	float ao = 0.;
	for(int i=0; i<NBSURFEL; i++)
	{
		vec3 v = surfel[i].pos - p.xyz; // recever to emitter vector
		float d = length( v );
		v = normalize( v );
		
		float cosE = dot( -v, surfel[i].n );
		float cosR = dot( v, n );
		float cosR2 = dot( v, reflect(dir,n));
		
		gi += surfel[i].col * radiance( cosE, cosR, surfel[i].area, d);
		glossy += surfel[i].col * radiance( cosE, cosR2, surfel[i].area, d);
		
		ao += occ( cosE, cosR, surfel[i].area, d);
	}
    ao = exp(-ao)*ao;
	vec3 col = ( amb*ao + gi + glossy ) ;
	
	return col;
}

//Main
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	generateSurfelsList();
	

	//screen coords
	vec2 q = fragCoord.xy/iResolution.xy;
	vec2 v = -1.0+2.0*q;
	v.x *= iResolution.x/iResolution.y;
	
	//camera ray
	float ctime = (iGlobalTime)*.25;
	vec3 org = vec3( cos(ctime)*5.,10.+cos(ctime*.5)*3.,-13.+sin(ctime) );
	vec3 dir = normalize( vec3(v.x, v.y, 1.5) );
	dir = lookat( -org + vec3(0., 5., 0.), vec3(0., 1., 0.) ) * dir;
	
	//classic raymarching by distance field
	vec4 p = raymarche(org, dir, vec2(1., 30.) );
	vec3 n = normal(p.xyz);
	vec3 col = shade(p, n, org, dir);
	
	
	fragColor = vec4( col, 1. );
}



// -- Must be pre-computed on CPU with more precision --
void generateSurfelsList()
{
	//cornell box
	surfel[0].pos = vec3( 10., 10.,  0.); surfel[0].n = vec3(-1., 0., 0.); surfel[0].area = 100.; surfel[0].col = vec3(.0,.0,2.);
	surfel[1].pos = vec3(-10., 10.,  0.); surfel[1].n = vec3( 1., 0., 0.); surfel[1].area = 100.; surfel[1].col = vec3(2.,.0,0.);
	surfel[2].pos = vec3(  0., 10., 10.); surfel[2].n = vec3( 0., 0.,-1.); surfel[2].area = 100.; surfel[2].col = vec3(.0);
	surfel[3].pos = vec3(  0., 20.,  0.); surfel[3].n = vec3( 0.,-1., 0.); surfel[3].area = 100.; surfel[3].col = vec3(.0);
	surfel[4].pos = vec3(  0.,  0.,  0.); surfel[4].n = vec3( 0., 1., 0.); surfel[4].area = 100.; surfel[4].col = vec3(.0);
	surfel[5].pos = vec3(  0., 10.,-10.); surfel[5].n = vec3( 0., 0., 1.); surfel[5].area = 100.; surfel[5].col = vec3(.0);
	
	//big cube
	surfel[6].pos = vec3(  4.,  0., 6.); surfel[6].n = vec3( 0., 1., 0.); surfel[6].area = 9.; surfel[6].col = vec3(.0);
	surfel[7].pos = vec3(  4., 10., 6.); surfel[7].n = vec3( 0.,-1., 0.); surfel[7].area = 9.; surfel[7].col = vec3(.0);
	surfel[8].pos = vec3(  7.,  5., 6.); surfel[8].n = vec3( 1., 0., 0.); surfel[8].area = 9.; surfel[8].col = vec3(.0);
	surfel[9].pos = vec3(  1.,  5., 6.); surfel[9].n = vec3(-1., 0., 0.); surfel[9].area = 9.; surfel[9].col = vec3(.0);
	surfel[10].pos = vec3(  4.,  5., 3.); surfel[10].n = vec3( 0., 0., -1); surfel[10].area = 9.; surfel[10].col = vec3(.0);
	surfel[11].pos = vec3(  4.,  5., 9.); surfel[11].n = vec3( 0., 0.,  1); surfel[11].area = 9.; surfel[11].col = vec3(.0);
	
	//small cube
	surfel[12].pos = vec3( -4.,  0., 0.); surfel[12].n = vec3( 0., 1., 0.); surfel[12].area = 4.; surfel[12].col = vec3(.0);
	surfel[13].pos = vec3( -4., 2., 0.); surfel[13].n = vec3( 0.,-1., 0.); surfel[13].area = 4.; surfel[13].col = vec3(.0);
	surfel[14].pos = vec3( -2.,  1., 0.); surfel[14].n = vec3( 1., 0., 0.); surfel[14].area = 4.; surfel[14].col = vec3(.0);
	surfel[15].pos = vec3( -6.,  1., 0.); surfel[15].n = vec3(-1., 0., 0.); surfel[15].area = 4.; surfel[15].col = vec3(.0);
	surfel[16].pos = vec3( -4.,  1., -2.); surfel[16].n = vec3( 0., 0., -1); surfel[16].area = 4.; surfel[16].col = vec3(.0);
	surfel[17].pos = vec3( -4.,  1., 2.); surfel[17].n = vec3( 0., 0.,  1); surfel[17].area = 4.; surfel[17].col = vec3(.0);
	

}	
