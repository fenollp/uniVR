// Shader downloaded from https://www.shadertoy.com/view/4dtXWN
// written by shadertoy user Lawliet
//
// Name: Noise Effect
// Description: reference:http://blog.csdn.net/stalendp/article/details/30989295
//#define COLOR vec4(0.0,0.8,0.4,1.0);
#define COLOR vec4(0.0,0.737,1.0,1.0);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec4 noise = texture2D(iChannel1,uv + iGlobalTime / 10.0);
    
    vec4 col = texture2D(iChannel0,uv + noise.xy * 0.01);
    
    //float gray = col.r*0.299 + col.g*0.587 + col.b*0.114;
    
    fragColor = col * 1.5 * COLOR;
}