// Shader downloaded from https://www.shadertoy.com/view/XstXz7
// written by shadertoy user Flyguy
//
// Name: Spirograph Distance
// Description: Cumulatively generating a distance field texture for a spirograph figure.
#define EPS 1e-3
#define LINE_COLOR vec3(0.1, 0.3, 1.0)
#define LINE_BRIGHTNESS 0.008
#define LINE_WIDTH 0.005

//#define VIEW_DISTANCE
//#define VIEW_SPEED

float pi = atan(1.0)*4.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    
    float dist = texture2D(iChannel0, uv / res).x;
    float spd = texture2D(iChannel0, uv / res).y;
    
    float brightness = LINE_BRIGHTNESS / max(EPS, abs(dist - LINE_WIDTH));
    
    vec3 col = mix(vec3(0), LINE_COLOR, brightness);
    
    col *= pow(spd * 0.5, 2.0);
    
    #ifdef VIEW_DISTANCE
    	col = vec3(log(1.0 + dist * 10.0) / log(10.0));
    #endif
    #ifdef VIEW_SPEED
    	col = vec3(spd * 0.5);
    #endif
    
	fragColor = vec4(col, 1.0);
}