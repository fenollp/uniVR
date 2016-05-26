// Shader downloaded from https://www.shadertoy.com/view/Xst3RS
// written by shadertoy user masaki
//
// Name: transition from dot to square
// Description: transition from dot to square
#define PI 3.141592
#define STROKE 0.1
#define t iGlobalTime

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 12.0* ((fragCoord.xy / iResolution.xy)-0.5);
    uv.x *= iResolution.x / iResolution.y;
    float freq1 =  0.5 * sin(.5 * t + uv.x*.125) + 0.5;
    float circle = smoothstep(freq1-STROKE, freq1, cos(uv.x * 2.0 *PI) *  cos(uv.y * 2.0 *PI));  
	fragColor = vec4(vec3(circle),1.0);
}