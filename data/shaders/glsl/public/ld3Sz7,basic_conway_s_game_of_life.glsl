// Shader downloaded from https://www.shadertoy.com/view/ld3Sz7
// written by shadertoy user matthewwachter
//
// Name: Basic Conway's Game of Life
// Description: This is pretty much just a rip off of other people's work. I just wanted to post a very simple, legible, and well commented example for the purpose of education.
//    
//    R - Reset
//    Mouse - Interact
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	fragColor = texture2D(iChannel0,fragCoord/iResolution.xy);
}