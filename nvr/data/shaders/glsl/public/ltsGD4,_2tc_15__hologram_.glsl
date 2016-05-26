// Shader downloaded from https://www.shadertoy.com/view/ltsGD4
// written by shadertoy user baldand
//
// Name: [2TC 15] Hologram 
// Description: Another 1 tweet (133 chars) shader.
//    Some multiscale iteration &amp; clock within the noise generator make it a bit more interesting.
//    The colour scheme and behaviour reminded me of credit card holograms.
// [2TC 15] Hologram
// 133 chars (without white space and comments)
// by Andrew Baldwin.
// This work is licensed under a Creative Commons Attribution 4.0 International License.

void mainImage( out vec4 f, in vec2 w )
{
	vec4 c = vec4(w,0.,1.),d=c*.0,e;
    for (int i=9;i>0;i--) {
        e=floor(c);
        d+=(sin(e*e.yxyx+sin(e+iDate.w)));
       	c*=.5;
    }
	f = d/9.;
}