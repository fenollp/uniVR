// Shader downloaded from https://www.shadertoy.com/view/4lSSRy
// written by shadertoy user 4rknova
//
// Name: Fractals: MRS
// Description: A simple fractal.
// by Nikos Papadopoulos, 4rknova / 2015
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage(out vec4 c, vec2 p)
{
	vec2 uv = .275 * p.xy / iResolution.y;
    float t = iGlobalTime*.03, k = cos(t), l = sin(t);        
    
    float s = .2;
    for(int i=0; i<64; ++i) {
        uv  = abs(uv) - s;    // Mirror
        uv *= mat2(k,-l,l,k); // Rotate
        s  *= .95156;         // Scale
    }
    
    float x = .5 + .5*cos(6.28318*(40.*length(uv)));
    c = vec4(vec3(x),1);
}