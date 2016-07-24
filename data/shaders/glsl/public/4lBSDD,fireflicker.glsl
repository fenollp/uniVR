// Shader downloaded from https://www.shadertoy.com/view/4lBSDD
// written by shadertoy user jherico
//
// Name: FireFlicker
// Description: testing a flickering light algorithm. 
const float UPDATE_INTERVAL = 1.0 / 30.0; // 30fps
const float MINIMUM_LIGHT_INTENSITY = 0.75;
const float MAXIMUM_LIGHT_INTENSITY = 2.75;
const float LIGHT_INTENSITY_RANDOMNESS = 0.3;
const float MAXIMUM_LIGHT = MINIMUM_LIGHT_INTENSITY + 2.0 * MAXIMUM_LIGHT_INTENSITY + LIGHT_INTENSITY_RANDOMNESS;
const vec3 color = vec3(255, 100, 28) / 255.0;
const float UPDATE_RATE = 30.0;

// *** Use these for integer ranges, ie Value-Noise/Perlin functions.
//#define MOD3 vec3(.0631,.07369,.08787)
//#define MOD4 vec4(.0631,.07369,.08787, .09987)

// This set suits the coords of of 0-1.0 ranges..
#define MOD3 vec3(443.8975,397.2973, 491.1871)
#define MOD4 vec4(443.8975,397.2973, 491.1871, 470.7827)


//----------------------------------------------------------------------------------------
//  1 out, 1 in...
float hash11(float p)
{
	vec3 p3  = fract(vec3(p) * MOD3);
    p3 += dot(p3, p3.yzx + 19.19);
    return fract(p3.x * p3.y * p3.z);
}


    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float t = iGlobalTime;
    t *= UPDATE_RATE;
    t -= fract(t);
    t /= UPDATE_RATE;
    float intensity = (MINIMUM_LIGHT_INTENSITY + (MAXIMUM_LIGHT_INTENSITY + (sin(t) * MAXIMUM_LIGHT_INTENSITY)));
    intensity += LIGHT_INTENSITY_RANDOMNESS + (hash11(t) * 2.0) - 1.0;
    intensity /= MAXIMUM_LIGHT;
	fragColor = vec4( color* intensity,1.0);
}
