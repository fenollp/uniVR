// Shader downloaded from https://www.shadertoy.com/view/ltj3Wh
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 8 bis
// Description: Fractal Experiment 8
// Created by Stephane Cuillerdier - Aiekick/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define Iterations 150

// https://www.shadertoy.com/view/XdsXWN
vec2 dMul( vec2 a, vec2 b )
{
	vec2 c;
	c.y = a.y*b.y; // smallest part
	float l = a.x*b.x; // largest part
	float r = a.x*b.y + a.y*b.x; // part in-between.
	c.x = l;
	c.y += r;
	return c;
}



float getJulia(vec2 coord, int iter, float time, float seuilInf, float seuilSup)
{ 
    vec2 uvt = coord;
    float lX = -0.78;//-0.74;
    float lY = time*0.115;//0.11
    float julia = 0., x = 0., y = 0., j=0.;
	for(int i=0; i<Iterations; i++) 
    {
        if ( i == iter ) break;
        x = (uvt.x * uvt.x - uvt.y * uvt.y) + lX;
        y = (uvt.y * uvt.x + uvt.x * uvt.y) + lY;
        uvt.x = x;
        uvt.y = y;
       	j = mix(julia, length(uvt)/dot(x,y), 1.);
        if ( j >= seuilInf && j <= seuilSup ) julia = j;
    }
    return julia;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    // vars / time
    float speed = 0.5;
    float t0 = iGlobalTime*speed;
    float t1 = sin(t0);
    float t2 = 0.5*t1+0.5;
    float t3 = 0.5*sin(iGlobalTime*0.1)+0.5;
    float zoom = iGlobalTime*pow(2., iGlobalTime);
    
    // uv
    float ratio = iResolution.x/iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.xy*2.-1.;uv.x*=ratio;uv/=zoom;
    vec2 mo = iMouse.xy / iResolution.xy*2.-1.;mo.x*=ratio;mo/=zoom;

    // map
    vec2 uvt = uv;
    
    // julia
    float ratioIter = 1.;
    float ratioTime = t1;
    if ( iMouse.z > 0. ) 
    {
        ratioIter = iMouse.y/iResolution.y;
        ratioTime = iMouse.x/iResolution.x*2.-1.;
    }
    
    int nIter = int(floor(float(Iterations)*ratioIter));
    float julia = getJulia(uvt+vec2(0.3,0.1), nIter, 1., 0.2, 8.5); // default => 0.2 / 6.5
    
    // color
    float d0 = julia;
    float d = smoothstep(d0-45.,d0+4.,1.);
    float r = mix(1./d, d, 1.);
    float g = mix(1./d, d, 3.);
    float b = mix(1./d, d, 5.);
    vec3 c = vec3(r,g,b);
    
    fragColor.rgb = c;
}