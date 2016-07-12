// Shader downloaded from https://www.shadertoy.com/view/Ms3GzS
// written by shadertoy user masaki
//
// Name: dot to grid
// Description: dot to grid
#define PI 3.141592
#define STROKE 0.3
#define t iGlobalTime

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 12.0* ((fragCoord.xy / iResolution.xy)-0.5);
    uv.x *= iResolution.x / iResolution.y;
    float freq1 =  0.5 * sin(t + uv.x*.125 + uv.y * .2) + 0.5;
    float circle = smoothstep(freq1-STROKE, freq1, cos(uv.x * 2.0 *PI) *  cos(uv.y * 2.0 *PI))-
        smoothstep(freq1,freq1+STROKE, cos(uv.x * 2.0 *PI) *  cos(uv.y * 2.0 *PI));  
	fragColor = vec4(circle*0.2, circle*0.3, circle,1.0);
}