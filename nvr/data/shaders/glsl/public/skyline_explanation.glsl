// Shader downloaded from https://www.shadertoy.com/view/4tXSRM
// written by shadertoy user gsingh93
//
// Name: Skyline Explanation
// Description: A fully commented version of this shader: http://glslsandbox.com/e#22564.0
#define MAX_DEPTH 20

// Magic noise function, described here:
// https://stackoverflow.com/questions/12964279/whats-the-origin-of-this-glsl-rand-one-liner
float noise(vec2 p) {
	return fract(sin(dot(p.xy ,vec2(12.9898,78.233))) * 456367.5453);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    // Scale coordinates to [0, 1]
	vec2 p = fragCoord.xy / iResolution.xy;
    
    float col = 0.;
    // Start from the back buildings and work forward, so buildings in the front cover the ones in the back
	for (int i = 1; i < MAX_DEPTH; i++) {
        // This is really "inverse" depth since we start from the back
		float depth = float(i);
        
        // Create a step function where the width of each step is constant at each depth, but increases as
        // the depth increases (as we move forward). We will get the same step value for multiple p.x
        // values, which will give our building width. iGlobalTime creates the scrolling effect.
		float step = floor(200. * p.x / depth + 50. * depth + iGlobalTime);
        
        // Use the noise function to get the y coordinate of the top of the building, and decrease this
        // height the closer we are to the front. If our pixel is below this height, we set it's color
        // depending on it's depth. 
		if (p.y < noise(vec2(step)) - depth * .04) {
			col = depth / 20.;
		}
	}
    
    fragColor = vec4(vec3(col), 1.);
}