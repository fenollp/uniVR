// Shader downloaded from https://www.shadertoy.com/view/MdVSzR
// written by shadertoy user weyland
//
// Name: Audio Feedback Landscape
// Description: Tweaked version of my feedback shader, just messing around to fit the audio, feel free to use your own audio in iChannel0 of buf A ..
//    
//    Note: 'frame dependent effect': 60fps vsync pls, also: 'feedback' errors show up as cyan squares, awesome
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0, uv);
}