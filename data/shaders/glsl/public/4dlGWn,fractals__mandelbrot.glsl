// Shader downloaded from https://www.shadertoy.com/view/4dlGWn
// written by shadertoy user 4rknova
//
// Name: Fractals: Mandelbrot
// Description: A simple Mandelbrot fractal shader.
// by Nikos Papadopoulos, 4rknova / 2013
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define AA	    2.
#define ITER    128 // Max number of iterations
#define COL_IN  vec3(0)

vec3 fractal(vec2 p)
{    
	vec2 z = vec2(0);  

	for (int i = 0; i < ITER; ++i) {  
		z = vec2(z.x * z.x - z.y * z.y, 2. * z.x * z.y) + p; 

		if (dot(z,z) > 4.) {
			float s = .125662 * float(i);
			return vec3(vec3(cos(s + .9), cos(s + .3), cos(s + .2)) * .4 + .6);
		}  
	}

    return COL_IN;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 c = (fragCoord.xy / iResolution.xy * 2. - 1.)
		   * vec2(iResolution.x / iResolution.y, 1)
		   * 1.2 - vec2(.5,0.);

    vec3 col = vec3(0);
    
#ifdef AA
    // Antialiasing via supersampling
    float e = 1. / min(iResolution.y , iResolution.x);    
    for (float i = -AA; i < AA; ++i) {
        for (float j = -AA; j < AA; ++j) {
    		col += fractal(c + vec2(i, j) * (e/AA)) / (4.*AA*AA);
        }
    }
#else
    col = fractal(c);
#endif /* AA */

	fragColor = vec4(col, 1);
}