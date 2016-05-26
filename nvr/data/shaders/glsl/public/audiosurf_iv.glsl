// Shader downloaded from https://www.shadertoy.com/view/lllGz4
// written by shadertoy user 4rknova
//
// Name: Audiosurf IV
// Description: Yet another audio visualization.
// by Nikos Papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
#define L   vec2(.1,.003)                                     // Amplitude scale, Line weight
#define C   (p.xy/iResolution.xy)			   			      // UV coordinates
#define F(k)(L.x*texture2D(iChannel0,vec2(.2*(k+C.x),.25)).y) // Sample
#define P(k)(floor(L.y/abs((C.y-F(k)-(1.+k*2.)*.1))))         // Distance field
void mainImage(out vec4 c, vec2 p) { c = vec4(vec3(P(0.)+P(1.)+P(2.)+P(3.)+P(4.)),1); }