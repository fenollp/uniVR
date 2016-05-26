// Shader downloaded from https://www.shadertoy.com/view/4ddSWs
// written by shadertoy user Olivier
//
// Name: Spiralys
// Description: Spiral made of basic trigonometry
#define PI 3.14159265359

float velocity = 1.0;
bool perspective = true;
float smoothThreshold = 0.5;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	float x = iGlobalTime * velocity;

	vec2 uv = (gl_FragCoord.xy + 0.5 * min(vec2(0.0), vec2(iResolution.y - iResolution.x, iResolution.x - iResolution.y))) / iResolution.xy * vec2(iResolution.x / iResolution.y, 1.0);
   
	vec2 dir = -(uv * 2.0 - 1.0);

    float dist = length(dir);
    float deformedDist = perspective ? pow(dist * 5.0E17, 0.075) : dist * 5.0;
    
	float angle = atan(dir.y, dir.x) + PI + 2.0 * PI * (deformedDist / PI) - x;
    float modAngle = mod(angle, PI);

	vec3 color = vec3(modAngle, 1.0 - 1.0 / modAngle, 0.5 - modAngle);
    
    float threshold = smoothThreshold / sqrt(dist);
    color *= smoothstep(0.0, 1.0, 1.0 - (modAngle - (PI - threshold)) / threshold);
    color *= smoothstep(0.0, 1.0, 1.0 - (threshold - modAngle) / threshold);
    
	fragColor = vec4(color, 1.0);
}