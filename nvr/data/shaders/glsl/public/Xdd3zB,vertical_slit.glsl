// Shader downloaded from https://www.shadertoy.com/view/Xdd3zB
// written by shadertoy user masaki
//
// Name: vertical slit
// Description: vertical slit
#define PI 3.141592
#define STROKE 0.05
#define t iGlobalTime

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 12.0* ((fragCoord.xy / iResolution.xy)-0.5);
    uv.x *= iResolution.x / iResolution.y;
    float freq1 =  0.5 * sin(.5 * t + uv.x*.5) + 0.5;
    float circle = smoothstep(freq1-STROKE, freq1, 0.5 * cos(uv.x * 2.0 *PI)+0.5 );  
	fragColor = vec4(vec3(circle*0.2,circle*0.8,circle*0.9),1.0);
}