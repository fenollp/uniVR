// Shader downloaded from https://www.shadertoy.com/view/XlB3Wd
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 5
// Description: the same as 4 but with another coloration attempt
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float t = sin(iGlobalTime*.1)*.5+.5;
    
    vec2 s = iResolution.xy;
    vec2 g = fragCoord.xy;
    vec2 uv = (2.*g-s)/s.y;
    
    vec2 mo = s / 2. * vec2(0.986, t);
    mo = (2.*mo-s)/s.y;
        
    float 
    	x=uv.x,
        y=uv.y,
        m=0.;
       
    vec3 col = vec3(0.);
	vec2 res = col.xy;
    
    for (int i=0;i<49;i++)
    {
        // kali formula 
        // from http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns
     	x=abs(x);
        y=abs(y);
        m=x*x+y*y;
        x=x/m+mo.x;
        y=y/m+mo.y;
        
        col = mix(col, vec3(x,y,m), fract(length(col)));
    	col = smoothstep(min(x,y), max(x,y), fract(col));
    }
         
        
        
    
    
    fragColor.rgb = col;
}