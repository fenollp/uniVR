// Shader downloaded from https://www.shadertoy.com/view/XsdSWs
// written by shadertoy user Olivier
//
// Name: Solarys
// Description: Star made with a spherical projection
#define PI 3.14159265359

float scale = 1.5;
float coreIntensity = 4.0;
float haloIntensity = 4.5;

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	float t = iGlobalTime * 0.05;

	vec2 uv = (gl_FragCoord.xy + 0.5 * min(vec2(0.0), vec2(iResolution.y - iResolution.x, iResolution.x - iResolution.y))) / iResolution.xy * vec2(iResolution.x / iResolution.y, 1.0);
   
	vec2 dir = -(uv * 2.0 - 1.0) * scale;
    
	float z = sqrt(max(0.0, 1.0 - dir.x * dir.x - dir.y * dir.y));
	float dist = length(dir);

	vec2 sphereUv = vec2(atan(dir.x, z) / PI + t,
		         		 asin(dir.y) / PI);

	float disc = max(0.0, sqrt(max(0.0, z)));        
	float corona = min(1.0 / pow(dist, 3.0), 1.0);

	vec3 sun = texture2D(iChannel0, sphereUv).rgb;
	float lum = dot(sun, vec3(0.25, 0.6, 0.15));
	float med = mod(t * 1.0, 1.0);

	float offset = abs(med - lum);
	float sup = step(offset, 0.5);
	offset = sup * offset + (1.0 - sup) * (1.0 - offset);

	vec3 color = max(vec3(0.0), 0.7 * pow(vec3(0.5 * offset, 0.15 * offset, offset) * disc, vec3(1.0 / coreIntensity)));	
	color += 0.65 * vec3(0.65, 0.35, 0.1) * corona * haloIntensity;
    
	fragColor = vec4(color, 1.0);
}