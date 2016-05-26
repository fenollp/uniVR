// Shader downloaded from https://www.shadertoy.com/view/lsy3zR
// written by shadertoy user FabriceNeyret2
//
// Name: vortex simulation 2
// Description: red/blue = vortices +/-, intensity = strenght      white = passive markers.     2 buffers instead of pipelined in one.
// inspired from http://evasion.imag.fr/~Fabrice.Neyret/demos/JS/Vort.html


void mainImage( out vec4 O,  vec2 U )
{
	O = texture2D(iChannel0,U/iResolution.xy);   
}