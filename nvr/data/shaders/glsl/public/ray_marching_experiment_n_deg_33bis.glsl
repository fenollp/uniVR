// Shader downloaded from https://www.shadertoy.com/view/MljSRD
// written by shadertoy user aiekick
//
// Name: Ray Marching Experiment n&deg;33bis
// Description: Another arrangement
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
Space Body 
my goal was to introduce some sub-surface scattering with hot color but the result is not as expected
normaly less thnkness is more cold than big thickness. here this is the inverse ^^ its not wanted
mouse axis X for control the rock expansion
*/

#define BLOB

#define shape(p) length(p)-2.8

float dstepf = 0.0;
    
const vec2 RMPrec = vec2(.3, 0.01); 
const vec3 DPrec = vec3(1e-5, 12., 1e-6); 

// by shane : https://www.shadertoy.com/view/4lSXzh
float Voronesque( in vec3 p )
{
    vec3 i  = floor(p + dot(p, vec3(0.333333)) );  p -= i - dot(i, vec3(0.166666)) ;
    vec3 i1 = step(0., p-p.yzx), i2 = max(i1, 1.0-i1.zxy); i1 = min(i1, 1.0-i1.zxy);    
    vec3 p1 = p - i1 + 0.166666, p2 = p - i2 + 0.333333, p3 = p - 0.5;
    vec3 rnd = vec3(7, 157, 113); // I use this combination to pay homage to Shadertoy.com. :)
    vec4 v = max(0.5 - vec4(dot(p, p), dot(p1, p1), dot(p2, p2), dot(p3, p3)), 0.);
    vec4 d = vec4( dot(i, rnd), dot(i + i1, rnd), dot(i + i2, rnd), dot(i + 1., rnd) ); 
    d = fract(sin(d)*262144.)*v*2.; 
    v.x = max(d.x, d.y), v.y = max(d.z, d.w), v.z = max(min(d.x, d.y), min(d.z, d.w)), v.w = min(v.x, v.y); 
#ifdef BLOB
    return  max(v.x, v.y) - max(v.z, v.w); // Maximum minus second order, for that beveled Voronoi look. Range [0, 1].
#else
    return max(v.x, v.y); // Maximum, or regular value for the regular Voronoi aesthetic.  Range [0, 1].
#endif
}

///////////////////////////////////
vec2 map(vec3 p)
{
    dstepf += 0.003;

    vec2 res = vec2(0.);
	
	float voro = Voronesque(p);
	
 	float sp = shape(p);
    float spo = sp - voro;
    float spi = sp + voro * .5;
    
	float e = sin(iGlobalTime*.5)*.4 +.35;
	
   	float dist = max(-spi, spo + e);
               
	res = vec2(dist, 1.);
	
	float kernel = sp + 1.;
	if (kernel < res.x ) 
		res = vec2(kernel, 2.);
	
	return res;
}

vec3 nor( vec3 pos, float prec )
{
    vec2 e = vec2( prec, 0. );
    vec3 n = vec3(
    map(pos+e.xyy).x - map(pos-e.xyy).x,
    map(pos+e.yxy).x - map(pos-e.yxy).x,
    map(pos+e.yyx).x - map(pos-e.yyx).x );
    return normalize(n);
}

vec3 cam(vec2 uv, vec3 ro, vec3 cu, vec3 cv)
{
	vec3 rov = normalize(cv-ro);
    vec3 u =  normalize(cross(cu, rov));
    vec3 v =  normalize(cross(rov, u));
    vec3 rd = normalize(rov + u*uv.x + v*uv.y);
    return rd;
}

// return color from temperature 
//http://www.physics.sfasu.edu/astro/color/blackbody.html
//http://www.vendian.org/mncharity/dir3/blackbody/
//http://www.vendian.org/mncharity/dir3/blackbody/UnstableURLs/bbr_color.html
vec3 blackbody(float Temp)
{
	vec3 col = vec3(255.);
    col.x = 561e5 * pow(Temp,(-3. / 2.)) + 148.;
   	col.y = 100.04 * log(Temp) - 623.6;
   	if (Temp > 6500.) col.y = 352e5 * pow(Temp,(-3. / 2.)) + 184.;
   	col.z = 194.18 * log(Temp) - 1448.6;
   	col = clamp(col, 0., 255.)/255.;
    if (Temp < 1000.) col *= Temp/1000.;
   	return col;
}

const vec3 RockColor = vec3(.2,.4,.58);
const vec3 DeepSpaceColor = vec3(0,.02,.15);
        
void mainImage( out vec4 f, in vec2 g )
{
    vec2 si = iResolution.xy;
	float t = iGlobalTime;
    
    float ca = t*.2; // angle z
    float ce = 2.; // elevation
    float cd = 4.; // distance to origin axis
   	
    vec3 cu=vec3(0,1,0);//Change camere up vector here
    vec3 cv=vec3(0,0,0); //Change camere view here
    vec2 uv = (g+g-si)/min(si.x, si.y);
    vec3 ro = vec3(sin(ca)*cd, ce+1., cos(ca)*cd); //
    vec3 rd = cam(uv, ro, cu, cv);

    vec3 d = vec3(0.);
    vec3 p = ro+rd*d.x;
	vec2 s = vec2(DPrec.y, 0.);
    for(int i=0;i<200;i++)
    {      
		if(s.x<DPrec.x||s.x>DPrec.y) break;
        s = map(p);
		s.x *= (s.x>DPrec.x?RMPrec.x:RMPrec.y);
		d.x += s.x;
        p = ro+rd*d.x;
   	}

	if (d.x<DPrec.y)
    {
		vec3 n = nor(p, .1);
		if ( s.y < 1.5) // icy color
        {
			rd = reflect(rd, n);
			p += rd*d.x;		
			d.x += map(p).x * .001;
			f.rgb = exp(-d.x / RockColor / 15.);
		}
		else if( s.y < 2.5) // kernel
		{
			float b = dot(n,normalize(ro-p))*0.9;
            f = (b*vec4(blackbody(2000.),0.9)+pow(b,0.2))*(1.0-d.x*.01);
		}	
   	}
    
    f = mix( f, vec4(DeepSpaceColor, 1.), 1.0 - exp( -d.x*dstepf) ); 
}

