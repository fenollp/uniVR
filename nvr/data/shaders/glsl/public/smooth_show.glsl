// Shader downloaded from https://www.shadertoy.com/view/4dtGWl
// written by shadertoy user DeMaCia
//
// Name: smooth show
// Description: smooth show obj

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float speed = iGlobalTime * .5;
    float dp = .2;
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    float op = smoothstep(max(1.-speed-dp,-dp),
                          max(1.-speed,0.),
                          1.-uv.y);
    
    vec4 clr = op * texture2D(iChannel0,uv);
    
	fragColor = clr;
}