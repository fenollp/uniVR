// Shader downloaded from https://www.shadertoy.com/view/ltsGzN
// written by shadertoy user 4rknova
//
// Name: XOR Texture
// Description: A xor texture.
// by Nikos Papadopoulos, 4rknova / 2014
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Use anything in the range of [1, 24]
#define RES 24

float xor(vec2 p)
{
    float r = 0.;
   	for (float i = 1.; i <= 32.; ++i) {
        float d = pow(2., i);
    	vec2  s = floor(mod(p / d, 2.));
        r += ((s.x == s.y) ? 0. : 1.) * d;
	}    
    return r;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float r = pow(2., float(RES));
    vec2  p = floor(fragCoord.xy / iResolution.xy * r);
    fragColor = vec4(vec3(xor(p) / r), 1);
}