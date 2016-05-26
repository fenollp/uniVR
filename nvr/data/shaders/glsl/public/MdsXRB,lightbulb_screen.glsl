// Shader downloaded from https://www.shadertoy.com/view/MdsXRB
// written by shadertoy user FabriceNeyret2
//
// Name: lightbulb screen
// Description: inspired from https://www.shadertoy.com/view/MslSRB
void mainImage( out vec4 o, vec2 u )  {
    vec2 R = iResolution.xy;	u /= R;
	o = texture2D(iChannel0,u);
	u *= R/R.y;
	u.x -= .5*floor(mod(32.*u.y+.5,2.))/32.;
	vec2 u0 = floor(u*32.+.5)/32.; 
	float d = length(u-u0)*32.;
	o = smoothstep(o, vec4(0), vec4(d));
}