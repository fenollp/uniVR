// Shader downloaded from https://www.shadertoy.com/view/lt23DR
// written by shadertoy user jocopa3
//
// Name: FastBlur &amp; Gamma
// Description: Just a really terrible fast blur function with options for adding gamma.
/*
 * Not supposed to be anything fancy, just a demonstration of a horrible
 * blur function with and without using gamma.
 */

// Set useGamma to 1 to use gamma, and 0 to not use gamma
#define useGamma 1
#define gammaAmount 2.2

vec2 p = vec2(1.0 / iResolution.x, 1.0 / iResolution.y); // Size of 1 pixel
const float s = 0.8660254037844; // sqrt(3)/2

// Basic gamma correction function
vec3 gamma(vec3 color, float amount)
{
    return pow(color, vec3(1.0 / amount));
}

// Creates the image on the screen
vec3 map(vec2 pos)
{
    // I'm too lazy to change the coordinates, so I just invert the position
    pos.y = 1.0 - pos.y;
    
    // Using some hacky dot-product magic to drop the costly sqrt for speed gains
    vec2 aa = vec2(pos.x - 0.5, pos.y + 0.54);
    float a = dot(aa, aa);
    vec2 bb = vec2(pos.x - (-s + 0.5), pos.y - (1.0 - s));
    float b = dot(bb, bb);
    vec2 cc = vec2(pos.x - (s + 0.5), pos.y - (1.0 - s));
    float c = dot(cc, cc);
    
    // Next three lines detect which region the given pos falls in
    vec2 abc = max(sign(vec2(a, a) - vec2(b, c)), 0.0);
    vec2 bac = max(sign(vec2(b, b) - vec2(a, c)), 0.0);
    vec2 cab = max(sign(vec2(c, c) - vec2(a, b)), 0.0);
    
    // Returns blue, red, or green depending on the region the given pos falls in
    return abc.x * abc.y * vec3(0.0, 0.0, 1.0) + 
        bac.x * bac.y * vec3(1.0, 0.0, 0.0) + 
        cab.x * cab.y * vec3(0.0, 1.0, 0.0);
}

/* 
 * An un-wrapped horizontal/vertical blur method
 * The reason I have it un-wrapped is because normal blurring with a
 * for-loop runs at 1 FPS on my PC, whereas this runs at a more respectible 17 FPS
 * (My GPU is very old, from about 2009; recently saving up for a newer rig)
 *
 * My lazyness is apparent here too, as this function is adapted from this
 * article: 
 * http://xissburg.com/faster-gaussian-blur-in-glsl/
 */
vec3 blur(vec2 uv, float scale)
{
    vec3 Color = vec3(0.0);
    
    // Horizontal Blur
    Color += map(vec2(uv.x - 7.0 * scale * p.x, uv.y)) * 0.0044299121055113265;
	Color += map(vec2(uv.x - 6.0 * scale * p.x, uv.y)) * 0.00895781211794;
	Color += map(vec2(uv.x - 5.0 * scale * p.x, uv.y)) * 0.0215963866053;
	Color += map(vec2(uv.x - 4.0 * scale * p.x, uv.y)) * 0.0443683338718;
	Color += map(vec2(uv.x - 3.0 * scale * p.x, uv.y)) * 0.0776744219933;
	Color += map(vec2(uv.x - 2.0 * scale * p.x, uv.y)) * 0.115876621105;
	Color += map(vec2(uv.x - 1.0 * scale * p.x, uv.y)) * 0.147308056121;
	Color += map(uv) * 0.159576912161;
	Color += map(vec2(uv.x + 1.0 * scale * p.x, uv.y)) * 0.147308056121;
	Color += map(vec2(uv.x + 2.0 * scale * p.x, uv.y)) * 0.115876621105;
	Color += map(vec2(uv.x + 3.0 * scale * p.x, uv.y)) * 0.0776744219933;
	Color += map(vec2(uv.x + 4.0 * scale * p.x, uv.y)) * 0.0443683338718;
	Color += map(vec2(uv.x + 5.0 * scale * p.x, uv.y)) * 0.0215963866053;
	Color += map(vec2(uv.x + 6.0 * scale * p.x, uv.y)) * 0.00895781211794;
	Color += map(vec2(uv.x + 7.0 * scale * p.x, uv.y)) * 0.0044299121055113265;
    
    // Vertical Blur
    Color += map(vec2(uv.x, uv.y - 7.0 * scale * p.y)) * 0.0044299121055113265;
	Color += map(vec2(uv.x, uv.y - 6.0 * scale * p.y)) * 0.00895781211794;
	Color += map(vec2(uv.x, uv.y - 5.0 * scale * p.y)) * 0.0215963866053;
	Color += map(vec2(uv.x, uv.y - 4.0 * scale * p.y)) * 0.0443683338718;
	Color += map(vec2(uv.x, uv.y - 3.0 * scale * p.y)) * 0.0776744219933;
	Color += map(vec2(uv.x, uv.y - 2.0 * scale * p.y)) * 0.115876621105;
	Color += map(vec2(uv.x, uv.y - 1.0 * scale * p.y)) * 0.147308056121;
	Color += map(uv) * 0.159576912161;
	Color += map(vec2(uv.x, uv.y + 1.0 * scale * p.y)) * 0.147308056121;
	Color += map(vec2(uv.x, uv.y + 2.0 * scale * p.y)) * 0.115876621105;
	Color += map(vec2(uv.x, uv.y + 3.0 * scale * p.y)) * 0.0776744219933;
	Color += map(vec2(uv.x, uv.y + 4.0 * scale * p.y)) * 0.0443683338718;
	Color += map(vec2(uv.x, uv.y + 5.0 * scale * p.y)) * 0.0215963866053;
	Color += map(vec2(uv.x, uv.y + 6.0 * scale * p.y)) * 0.00895781211794;
	Color += map(vec2(uv.x, uv.y + 7.0 * scale * p.y)) * 0.0044299121055113265;

	return Color;

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float sc = abs(sin(iGlobalTime)) * 15.0; // Scale for the blur

#if (useGamma == 1)
    fragColor.rgb = gamma(blur(uv, sc), gammaAmount);
#else
	fragColor.rgb = blur(uv, sc);
#endif
}