// Shader downloaded from https://www.shadertoy.com/view/XtB3WD
// written by shadertoy user aiekick
//
// Name: Mod Experiment 1
// Description: used in Ray Marching Experiment 16 : https://www.shadertoy.com/view/ll23Wh
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 s = iResolution.xy;
	vec2 uv = (2.*fragCoord.xy -s)/s.y;
    
    float t = sin(iGlobalTime)*.5+1.;
    
    uv *= 4.*t;
    
    vec2 pm = vec2(.9);

    mat2 rot = mat2(cos(uv.x), sin(uv.y), -sin(uv.x), cos(uv.y));
    
    uv = mod(uv*rot, pm) - .5*pm;
    
    float mb = .1/dot(uv,uv);
    
    fragColor = vec4(mb);
}