// Shader downloaded from https://www.shadertoy.com/view/4d3SRr
// written by shadertoy user NoxWings
//
// Name: Simple distortion shader
// Description: Hey this is my first shader here and one of my first shaders ever.
//    
//    I've tried to implement a height to normalmap function and I've created some kind waterlike distortion effect. 
//    You can uncomment the debug define to see the computed normalmap.
//#define DEBUG

#define time 				0.06 * iGlobalTime
#define normalStrength		5.0
#define normalChannel		iChannel1
#define normalSampling		iChannelResolution[1]
#define backgroundChannel	iChannel0
#define distortionStrength	.12
#define waterTint			vec4(.8, .8, 1., 1.)


vec4 heightToNormal(sampler2D height, vec3 samplingResolution, vec2 uv, float normalMultiplier) {

    vec2 s = 1.0/samplingResolution.xy;
    
    float p = texture2D(height, uv).x;
    float h1 = texture2D(height, uv + s * vec2(1,0)).x;
    float v1 = texture2D(height, uv + s * vec2(0,1)).x;
       
   	vec2 xy = (p - vec2(h1, v1)) * normalMultiplier;
   
    return vec4(xy + .5, 1., 1.);
}
vec4 normalMap(vec2 uv) { return heightToNormal(normalChannel, normalSampling, uv, normalStrength); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec4 normal = normalMap(uv + time);
    vec2 displacement = clamp((normal.xy - .5) * distortionStrength, -1., 1.);
    vec4 background = texture2D(backgroundChannel, uv + time/6. + displacement.xy);
    
    #ifdef DEBUG 
    	fragColor = normal;
    #else
    	fragColor = background * waterTint;
    #endif
}