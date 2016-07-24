// Shader downloaded from https://www.shadertoy.com/view/4dBGR1
// written by shadertoy user BeRo
//
// Name: Pixelizer from fr-minus-017
// Description: The 80x25 fake-text-mode pixelizer postprocess effect from fr-minus-017 by BeRo from farbrausch
// The pixelizer postprocess effect from fr-minus-017 by BeRo from farbrausch
// License Creative Commons Attribution-ShareAlike 3.0 Unported License.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv=floor(uv*vec2(80.0,25.0))/vec2(80.0,25.0);
	vec4 c=texture2D(iChannel0,uv);
	c.x=float(int((c.x*8.0)+0.5))/8.0;
	c.y=float(int((c.y*8.0)+0.5))/8.0;
	c.z=float(int((c.z*8.0)+0.5))/8.0;
	fragColor=vec4(c);
}