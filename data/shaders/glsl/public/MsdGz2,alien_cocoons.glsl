// Shader downloaded from https://www.shadertoy.com/view/MsdGz2
// written by shadertoy user XT95
//
// Name: Alien cocoons
// Description: Trying to implement &quot;Approximating Translucency for a Fast, Cheap and Convincing Subsurface Scattering Look&quot; by Colin Barr&eacute; Brisebois!
//    
// Created by anatole duprat - XT95/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// Approximating Translucency for a Fast, Cheap and Convincing Subsurface Scattering Look :
// http://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/

const float PI = 3.14159265359;

vec3 raymarche( in vec3 ro, in vec3 rd, in vec2 nfplane );
vec3 normal( in vec3 p );
float map( in vec3 p );
mat3 lookat( in vec3 fw, in vec3 up );
mat3 rotate( in vec3 v, in float angle);
float thickness( in vec3 p, in vec3 n, float maxDist, float falloff );
float ambientOcclusion( in vec3 p, in vec3 n, float maxDist, float falloff );
float noise(vec3 p);
float smin( float a, float b, float k );


vec3 lpos1,lpos2,lpos3;



//Map
float map( in vec3 p )
{
	p.xz = mod(p.xz+100., 200.)-100.;
	float d = p.y+texture2D(iChannel0, p.xz*.05).r*1.5;
    d = min(d, length(p-lpos1)-1.);
    d = min(d, length(p-lpos2)-1.);

	vec2 id = floor(p.xz/60.);
	p.xz = mod(p.xz, 60.)-30.;
	p = rotate(vec3(0.,1.,0.), p.y*.05*cos(iGlobalTime+sin(iGlobalTime*1.5+id.x*5.)+id.y*42.))*p;
	d = min(d, smin(length(p-vec3(0.,12.,0.))-3.-noise(p*.3)*3., length(p-vec3(0.,7.,0.))-3.,4.)+texture2D(iChannel0, p.xz*.2).r*.25);

	float branch = length( (rotate(vec3(.5,0.,.5), 1.2)*p-vec3(6.,0.,-6.)).xz)-.5;
	branch = smin(branch, length( (rotate(vec3(-.5,0.,.5), 1.2)*p-vec3(6.,0.,6.)).xz)-.5,1.);
	branch = smin(branch, length( (rotate(vec3(.5,0.,-.5), 1.2)*p-vec3(-6.,0.,-6.)).xz)-.5,1.);
	branch = smin(branch, length( (rotate(vec3(-.5,0.,-.5), 1.2)*p-vec3(-6.,0.,6.)).xz)-.5,1.);
	branch = max(branch, p.y-10.);
	branch = branch-texture2D(iChannel0, p.xz*.1).r*.25;
	return smin(d, branch, 5.) ;
}


vec3 skyColor( in vec3 rd )
{
    vec3 sundir = normalize( vec3(.0, .1, 1.) );
    
    float yd = min(rd.y, 0.);
    rd.y = max(rd.y, 0.);
    
    vec3 col = vec3(0.);
    
    col += vec3(.4, .4 - exp( -rd.y*20. )*.3, .0) * exp(-rd.y*9.); // Red / Green 
    col += vec3(.3, .5, .6) * (1. - exp(-rd.y*8.) ) * exp(-rd.y*.9) ; // Blue
    
    col = mix(col*1.2, vec3(.3),  1.-exp(yd*100.)); // Fog
    
    return clamp(col,vec3(0.),vec3(1.));
}

//Shading
vec3 shade( in vec3 p, in vec3 n, in vec3 ro, in vec3 rd )
{		
    float fog = pow(min( length(p-ro)/450., 1.),200.);
	p.xz = mod(p.xz+100., 200.)-100.;
    
    vec3 skyCol = skyColor(rd);
    
	vec3 ldir1 = normalize(lpos1-p);	
	vec3 ldir2 =  normalize(lpos2-p);	
	vec3 ldir3 =  normalize(lpos3-p);		
	float latt1 = pow( length(lpos1-p)*.15, 3. ) / (pow(texture2D( iChannel1, vec2(64./256.,0.25) ).x,2.)*2.+.1);
	float latt2 = pow( length(lpos2-p)*.15, 3. ) / (pow(texture2D(iChannel1, vec2(20./256.,0.25)).r*1.2,2.)*3.+.1);
	float latt3 = pow( length(lpos3-p)*.15, 2.5 ) / (pow(texture2D( iChannel1, vec2(128./256.,0.25) ).x,2.)*5.+.1);

	float thi = thickness(p,n, 10., 1.);
	float occ = pow( ambientOcclusion(p,n, 10., 1.), 5.);

	vec3 diff1 = vec3(.0,.5,1.) * (max(dot(n,ldir1),0.) ) / latt1;
	vec3 diff2 = vec3(.5,1.,.1) * (max(dot(n,ldir2),0.) ) / latt2;
	vec3 diff3 = vec3(1.,1.,1.) * (max(dot(n,ldir3),0.) ) / latt3;

    vec3 col =  diff1*3. + diff2 + diff3;

	float trans1 =  pow( clamp( dot(-rd, -ldir1+n), 0., 1.), 1.) + 1.;
	float trans2 =  pow( clamp( dot(-rd, -ldir2+n), 0., 1.), 1.) + 1. ;
	float trans3 =  pow( clamp( dot(-rd, -ldir3+n), 0., 1.), 1.) + 1. ;

	col += vec3(1.,.2,.05) * (trans1/latt1 + trans2/latt2 + trans3/latt3)*thi + skyColor(vec3(0.,1.,0.))*(occ*.05) ;

    col = mix(col, skyCol*.1, fog );

	return col;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy/iResolution.xy;
	vec2 v = -1.0+2.0*q;
	v.x *= iResolution.x/iResolution.y;
    
	//define lights pos
    lpos1 = vec3( cos(iGlobalTime*.25)*30., 12., 30.);
	lpos2 = vec3( cos(iGlobalTime*.4)*35., 15.+cos(iGlobalTime*.3)*5., sin(iGlobalTime*.5)*35.);
	lpos3 = vec3( 30., 12., -30.);
    
	//camera ray
    vec3 ro = vec3(cos(-iGlobalTime*.1+.75)*50.,13.+cos(iGlobalTime*.2+1.5)*5.,sin(-iGlobalTime*.1+.75)*50.);
	vec3 rd = normalize( vec3(v.x, v.y, 1.5-length(q*2.-1.)) );
	rd = lookat( vec3(0.)-ro, vec3(0.,1.,0.))*rd;
    
	//classic raymarching by distance field
	vec3 p = raymarche(ro, rd, vec2(1., 500.) );
	vec3 n = normal(p.xyz);
	vec3 col = shade(p, n, ro, rd);
	
	//Gamma correction
    col = pow(col, vec3(1./2.2));
    col = clamp(col,0.,1.) * (.5 + .5*pow( q.x*q.y*(1.-q.x)*(1.-q.y)*50., .5));
    
        
    
	fragColor = vec4(col,1.0)*min(iGlobalTime*.25,1.);
}


    

vec3 raymarche( in vec3 ro, in vec3 rd, in vec2 nfplane )
{
	vec3 p = ro+rd*nfplane.x;
	float t = 0.;
	for(int i=0; i<128; i++)
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

float noise(vec3 p) //Thx to Las^Mercury
{
	vec3 i = floor(p);
	vec4 a = dot(i, vec3(1., 57., 21.)) + vec4(0., 57., 21., 78.);
	vec3 f = cos((p-i)*acos(-1.))*(-.5)+.5;
	a = mix(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
	a.xy = mix(a.xz, a.yw, f.y);
	return mix(a.x, a.y, f.z)*.5+.5;
}
float smin( float a, float b, float k ) //Thx to iq^rgba
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}


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


float thickness( in vec3 p, in vec3 n, float maxDist, float falloff )
{
	const int nbIte = 6;
    const float nbIteInv = 1./float(nbIte);    
	float ao = 0.0;
    
    for( int i=0; i<nbIte; i++ )
    {
        float l = hash(float(i))*maxDist;
        vec3 rd = normalize(-n)*l;
        ao += (l + map( p + rd )) / pow(1.+l, falloff);
    }
	
    return clamp( 1.-ao*nbIteInv, 0., 1.);
}
