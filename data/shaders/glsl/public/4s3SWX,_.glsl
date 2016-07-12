// Shader downloaded from https://www.shadertoy.com/view/4s3SWX
// written by shadertoy user piotrekli
//
// Name: ☃
// Description: RGB waves
//    You can change the image in Buffer D
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(texture2D(iChannel0, uv).x, texture2D(iChannel1, uv).x, texture2D(iChannel2, uv).x, 1.0);
}