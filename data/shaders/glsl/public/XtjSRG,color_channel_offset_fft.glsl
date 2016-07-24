// Shader downloaded from https://www.shadertoy.com/view/XtjSRG
// written by shadertoy user Macint
//
// Name: Color channel offset fft
// Description: A simple method to get old video tape effect with missmatched color channels. The effected is matched to the intensity of a frequency interval in the music.
#define freqStart -1.0
#define freqInterval 0.1
#define sampleSize 0.02           // How accurately to sample spectrum, must be a factor of 1.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 xy = fragCoord.xy / iResolution.xy;    
    
   	// first texture row is frequency data
    // sample intensities in frequency interval.
    
    float intensity = 0.0;
	for(float s = 0.0; s < freqInterval; s += freqInterval * sampleSize) {
		intensity += texture2D(iChannel1, vec2(freqStart + s, 0.0)).r;
	}
    intensity = abs(intensity);
    intensity = pow((intensity*sampleSize),3.0)*4.0;
    
    
    //set offsets
    vec2 rOffset = vec2(-0.02,0)*intensity;
    vec2 gOffset = vec2(0.0,0)*intensity;
    vec2 bOffset = vec2(0.04,0)*intensity;
    
    vec4 rValue = texture2D(iChannel0, xy - rOffset);
    vec4 gValue = texture2D(iChannel0, xy - gOffset);
    vec4 bValue = texture2D(iChannel0, xy - bOffset);

    fragColor = vec4(rValue.r, gValue.g, bValue.b, 1.0);
}