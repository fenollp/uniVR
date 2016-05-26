// Shader downloaded from https://www.shadertoy.com/view/4tS3W3
// written by shadertoy user uNiversal
//
// Name: Pulse waves - Visualiser
// Description: A simpler multiple waveform type visualiser based on Waves Remix by: ADOB
//    
//    Made to work with Kodi Shadertoy https://github.com/topfs2/visualization.shadertoy
/*
Pulse waves - Visualiser - https://www.shadertoy.com/view/4tS3W3
Based on Waves Remix by: ADOB - 10th April, 2015 https://www.shadertoy.com/view/4ljGD1
Pulse waves by: uNiversal - 28th May, 2015
Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
*/

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

    for(float i = 0.0; i < 5.0; ++i) {

        uv.y += (0.3 * sin(uv.y + i - 5.0 - iGlobalTime * 0.0));
        float Y = uv.y + getWeight((i) * 20.0) *
            (texture2D(iChannel0, vec2(uvTrue.x, 1)).x - 0.5);
        lineIntensity = 0.5 + squared(0.6 * abs(mod(uvTrue.x + i / 4.3 + iGlobalTime,2.0) - 1.0));
        glowWidth = abs(lineIntensity / (150.0 * Y));
        color += vec3(glowWidth * (1.5 + sin(iGlobalTime * 0.13)),
                      glowWidth * (1.5 - sin(iGlobalTime * 0.23)),
                      glowWidth * (1.5 - cos(iGlobalTime * 0.19)));
    }    

    fragColor = vec4(color, 1.0);
}