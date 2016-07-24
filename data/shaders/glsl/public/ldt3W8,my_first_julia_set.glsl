// Shader downloaded from https://www.shadertoy.com/view/ldt3W8
// written by shadertoy user kylefeng28
//
// Name: My First Julia Set
// Description: My first attempt at using GLSL/Shadertoy.
// Inspired by http://nuclear.mutantstargoat.com/articles/sdr_fract/

// Define new coordinate system ranges
vec2 xRange = vec2(-1.5, 1.5);
vec2 yRange = vec2(-1.5, 1.5);

// Define Julia set constants
const int nIter = 100; // Number of iterations
vec2 c = vec2(-0.4, 0.6); // c = a + bi


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Transform to new coordinate system
    vec2 z = fragCoord.xy / iResolution.xy;
    z.x = z.x * (xRange[1] - xRange[0]) + xRange[0];
    z.y = z.y * (yRange[1] - yRange[0]) + yRange[0];
    
    // Define r, g, b components
    float r, g, b, a = 1.0;
    
    // Transform c somehow
    c.x = -0.4 + 0.1 * cos(iGlobalTime / 2.0);
    c.y = 0.6 + 0.1 * sin(iGlobalTime + 0.5);
   
    // Iterate
    int i;
    for (int i_ = 0; i_ < nIter; i_++) {
        float x = (z.x * z.x - z.y * z.y) + c.x;
        float y = (z.y * z.x + z.x * z.y) + c.y;

        if ((z.x * z.x + z.y * z.y) > 4.0) break;
        z.x = x;
        z.y = y;
        
        i = i_;
    }
 
    r = g = b = float(i) / float(nIter);
    
    // Set color
	fragColor = vec4(r, g, b, a);
}