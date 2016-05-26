// Shader downloaded from https://www.shadertoy.com/view/4lsGWN
// written by shadertoy user baldand
//
// Name: [2TC 15] Gas giant
// Description: Something big squeezed into 1 tweet
// [2TC 15] Gas giant
// by Andrew Baldwin.
// This work is licensed under a Creative Commons Attribution 4.0 International License.

void mainImage( out vec4 f, in vec2 w )
{
	vec4 u = .5-vec4(w,0.,1.)/iResolution.xyzz;
    u.x+=.3*cos(u.y);
	f = texture2D(iChannel0,.3*(u.yw/u.x+iDate.xw))*step(.1,u.x);
}