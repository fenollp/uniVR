// Shader downloaded from https://www.shadertoy.com/view/4tlGDr
// written by shadertoy user wonko_rt
//
// Name: timefunc plotter
// Description: a simple plotter for timefunctions with a grid and something like a frame
// Created by wonko_rt/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// a simple plotter for timefunctions with a grid and something like a frame
// maybe the maths suck, but it seems to work

const float PI2 = 1.5707963267948966192313216916398;
const float PI = 3.1415926535897932384626433832795;
const float TWOPI = 6.283185307179586476925286766559;


float func(float x)
{
    const float t=4.;
    float tm = abs(mod(iGlobalTime, t)-t/2.);
    tm *= tm;
    return sin(x*(1.+tm));
}

float falloff(float d, float mx)
{
    return min(mx,1./(d*d*d*d*10000000000.+.00001));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy *2. - 1.;
    uv*=1.06;
    
    vec2 uvf = uv;
    uvf.x *= TWOPI;
	
    vec3 iy = vec3(0.);
    
    // grid
    const int gx=4;
    const int gy=4;
    vec2 vgxy = vec2(1./float(gx), 1./float(gy));
    for (int i=-gx; i<=gx; i++)
    	for (int j=-gy; j<=gy; j++)
        {
            vec2 iuv = vec2(i, j) * vgxy;

            float auxy = uv.x*uv.x*uv.y*uv.y*100.;
            float gi = clamp(1.-auxy, .4, .9);
            iy = max(iy, falloff(abs(iuv.x-uv.x), gi));
            iy = max(iy, falloff(abs(iuv.y-uv.y), gi));
        }

    // func
    vec3 f1col = vec3(.4, .6, .8);
    float y = func(uvf.x);
    float d = (y - uvf.y)/2.;
    float f = falloff(d, 1.);
    iy = vec3(mix(iy.x,f*f1col.x,f), mix(iy.y,f*f1col.y,f), mix(iy.z,f*f1col.z,f));
    
    // border
    vec3 bcol = vec3(.2,.6,.2);
    const float br1=.9;
    const float bw=1.4;
    float dd = abs(pow(log(abs(uv.x*br1))*log(abs(uv.y*br1)), .13)*1.6);
    float b = clamp(0.,1.,bw-pow(dd,8.));
    iy = max(iy, vec3(bcol*b));
    
    fragColor = vec4(vec3(iy),1.);
}
