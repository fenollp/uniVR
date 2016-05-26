// Shader downloaded from https://www.shadertoy.com/view/Mdt3Dj
// written by shadertoy user knighty
//
// Name: Instability
// Description: Trying to implement DLA.
//    Update: hit Space bar to reinit. Useful when in full screen.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	//vec2 p = (fragCoord.xy - 0.5*iResolution.xy) / iResolution.y;
    vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0,uv).xywz;
    fragColor.y = sin(0.01*fragColor.w-0.5)*0.5+0.5;
}