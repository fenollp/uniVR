// Shader downloaded from https://www.shadertoy.com/view/MsdGDs
// written by shadertoy user FabriceNeyret2
//
// Name: vortex simulation
// Description: red/blue = vortices +/-, intensity = strenght      white = passive markers    2 steps pipeliined in 1 buffer:
//     NB1: I'm not 100% sure my semi-Newton integration is bug-free     NB2: The costliest is rendering :-(
// inspired from http://evasion.imag.fr/~Fabrice.Neyret/demos/JS/Vort.html


void mainImage( out vec4 O,  vec2 U )
{
	O = texture2D(iChannel0,U/iResolution.xy);   
}