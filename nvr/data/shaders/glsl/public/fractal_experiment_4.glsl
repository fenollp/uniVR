// Shader downloaded from https://www.shadertoy.com/view/4tSGWd
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 4
// Description: Base on formula from Kali =&gt; 
//    [url=very-simple-formula-for-fractal-patterns]http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns/[/url]
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float t = sin(iGlobalTime*.1)*.5+.5;
    
    vec2 s = iResolution.xy;
    vec2 g = fragCoord.xy;
    vec2 uv = (2.*g-s)/s.y;
    
    vec2 mo = s / 2. * vec2(0.98, t);
    mo = (2.*mo-s)/s.y;
        
    float 
    	x=uv.x,
        y=uv.y,
        m=0.;
        
        
	for (int i=0;i<50;i++)
    {
        // kali formula 
        // from http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns
     	x=abs(x);
        y=abs(y);
        m=x*x+y*y;
        x=x/m+mo.x;
        y=y/m+mo.y;
    }
         
    vec2 res = abs(vec2(x,y))/(x*y)+uv;
        
    float d = dot(res,res.yx);
        
    float tt = sin(3.15);
        
    float rr = mix(1./d, d, abs(tt));
    float gg = mix(rr, d, abs(tt));
    float bb = mix(gg, d, abs(tt));
    vec3 c = vec3(rr,gg,bb);
    
    fragColor.rgb = c;
}