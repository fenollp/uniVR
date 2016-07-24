// Shader downloaded from https://www.shadertoy.com/view/lds3Wl
// written by shadertoy user Mx7f
//
// Name: Rotation through Translation
// Description: Quick mockup of a shader to generate gifs like those found in http://mathgifs.blogspot.co.uk/2013/10/rotations-through-translations.html
//    All the circles translate in a straight line, but the entire shape rotates.
// Tweak these to get different results
const int   NUM_CIRCLES 	= 37;
const float TIME_MULTIPLIER = 3.0;
const float CIRCLE_RADIUS   = 0.04;
const float CONSTANT_N	    = 3.0;

// Uncomment to let N vary wildly instead of be CONSTANT_N 
// I recommend you use a large NUM_CIRCLES with this
//#define LET_N_GO_NUTS

// Uncomment to make the circles have color
//#define COLORIZE 

// Comment out to get rid of the lines
#define SHOW_LINES


#ifdef LET_N_GO_NUTS
	float N               = sin(iGlobalTime)*2.0 + 3.0; 
#else
	const float N = CONSTANT_N;
#endif

// Actual code below

#define TWO_PI 6.28318530718
#define TWO_THIRDS_PI 2.09439510239

vec3 drawCircle(vec2 p, vec2 center, float radius, float edgeWidth, vec3 color) {
	return color*(1.0-smoothstep(radius, radius+edgeWidth, length(p-center)));
}

vec3 drawLine(vec2 p, float angle, float thickness, float edgeWidth, vec3 color) {
	return color*(1.0-smoothstep(thickness, thickness + edgeWidth, 
								 abs(sin(angle)*p.x+cos(angle)*p.y)));	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// Map coordinates into a small window around [-1, 1]
	vec2 uv = (fragCoord.xy*2.0 - iResolution.xy) / iResolution.y;
	uv *= 1.2;
	
	vec3 color = vec3(0.0);
	float angleIncrement = TWO_PI / float(NUM_CIRCLES);
	for (int i = 0; i < NUM_CIRCLES; ++i) {
		float t = angleIncrement*(float(i));
		float r = sin(float(N)*t+iGlobalTime*TIME_MULTIPLIER);
		vec2 p = vec2(r*cos(t), r*sin(t));
#ifdef COLORIZE
		vec3 circleColor = vec3(sin(t),
								sin(t+TWO_THIRDS_PI),
								sin(t+2.0*TWO_THIRDS_PI))*0.5+0.5;
#else
		vec3 circleColor = vec3(1.0);
		
#endif
		color += drawCircle(uv, p, CIRCLE_RADIUS, 0.01, circleColor);
		
#ifdef SHOW_LINES 
		color += drawLine(uv, t, 0.000, 0.01, vec3(1.0,0.0,0.0));
#endif
	}
	
	
	fragColor = vec4(color,1.0);
}