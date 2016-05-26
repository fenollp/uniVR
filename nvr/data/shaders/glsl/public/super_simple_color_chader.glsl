// Shader downloaded from https://www.shadertoy.com/view/XtsXW2
// written by shadertoy user keenanwoodall
//
// Name: Super Simple Color Chader
// Description: My first shader
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    fragColor = vec4(sin(iMouse.x / iResolution.x), sin(iMouse.y / iResolution.y), sin(iMouse.z / iResolution.x), 1);
}