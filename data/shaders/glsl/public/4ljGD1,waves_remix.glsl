// Shader downloaded from https://www.shadertoy.com/view/4ljGD1
// written by shadertoy user ADOB
//
// Name: Waves Remix
// Description: simple audio visualizer (also pretty without audio) based upon &quot;waves&quot; by bonniem, with added travelling pulse effect, color cycling, and of course, the requested audio sensitivity. Each wave is particularly responsive to a specific range of frequencies.
float squared(float value) { return value * value; }

float getAmp(float frequency) { return texture2D(iChannel0, vec2(frequency / 512.0, 0)).x; }

float getWeight(float f) {
    return (+ getAmp(f-2.0) + getAmp(f-1.0) + getAmp(f+2.0) + getAmp(f+1.0) + getAmp(f)) / 5.0; }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
	vec2 uvTrue = fragCoord.xy / iResolution.xy;
    vec2 uv = -1.0 + 2.0 * uvTrue;
    
	float lineIntensity;
    float glowWidth;
    vec3 color = vec3(0.0);
    
	for(float i = 0.0; i < 5.0; i++) {
        
		uv.y += (0.2 * sin(uv.x + i/7.0 - iGlobalTime * 0.6));
        float Y = uv.y + getWeight(squared(i) * 20.0) *
            (texture2D(iChannel0, vec2(uvTrue.x, 1)).x - 0.5);
        lineIntensity = 0.4 + squared(1.6 * abs(mod(uvTrue.x + i / 1.3 + iGlobalTime,2.0) - 1.0));
		glowWidth = abs(lineIntensity / (150.0 * Y));
		color += vec3(glowWidth * (2.0 + sin(iGlobalTime * 0.13)),
                      glowWidth * (2.0 - sin(iGlobalTime * 0.23)),
                      glowWidth * (2.0 - cos(iGlobalTime * 0.19)));
	}	
	
	fragColor = vec4(color, 1.0);
}