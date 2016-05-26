// Shader downloaded from https://www.shadertoy.com/view/llsGD4
// written by shadertoy user baldand
//
// Name: [2TC 15] Pixelfire
// Description: Another 1 tweet (140 char) shader based on my earlier &quot;[2TC 15] Hologram&quot; https://www.shadertoy.com/view/ltsGD4
// [2TC 15] Pixelfire
// 140 chars (without white space and comments)
// by Andrew Baldwin.
// This work is licensed under a Creative Commons Attribution 4.0 International License.

void mainImage( out vec4 f, in vec2 p )
{
	vec4 c = vec4(p,0.,1.),d=c*.0,e;
    for (int i=9;i>0;i--) {
        e=floor(c);
        d+=abs(sin(e*e.yxyx+e*iDate.w))/9.;
       	c*=.5;
    }
    d.x+=d.y;
	f = d;
}