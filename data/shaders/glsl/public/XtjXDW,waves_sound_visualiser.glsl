// Shader downloaded from https://www.shadertoy.com/view/XtjXDW
// written by shadertoy user ChazMeister
//
// Name: Waves Sound Visualiser
// Description: This is a remix of ADOB's remix of 'waves' by bonniem. In my version, the waves pulse to the sound, most easily seen with microphone input or the song called 'Most Geometric Person'.
// Original by bonniem, remixed by ADOB then ChazMeister

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
    
    float i = 0.0;
    
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
	
	fragColor = vec4((color / 2.0) * (getWeight(squared(i) * 20.0) * 2.5), 1.0);
}