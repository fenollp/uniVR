// Shader downloaded from https://www.shadertoy.com/view/4ddSWl
// written by shadertoy user jackdavenport
//
// Name: Sewer Pipe
// Description: A ride down a sewer pipe, following a floating light.
#define BLOOM_THRESHOLD .7
#define BLOOM_INTENSITY 2.5
#define LENS_DIRT
#define DIRT_INTENSITY 2.5
//#define BLOOM_ONLY

#define BLUR_ITERATIONS 3
#define BLUR_SIZE .025
#define BLUR_SUBDIVISIONS 32

vec3 getHDR(vec3 tex) {
 
    return max((tex - BLOOM_THRESHOLD) * BLOOM_INTENSITY, 0.);
    
}

vec3 gaussian(sampler2D sampler, vec2 uv) {
 
    vec3 sum = vec3(0.);
    
    for(int i = 1; i <= BLUR_ITERATIONS; i++) {
     
        float angle = 360. / float(BLUR_SUBDIVISIONS);
        
        for(int j = 0; j < BLUR_SUBDIVISIONS; j++) {
         
            float dist = BLUR_SIZE * (float(i+1) / float(BLUR_ITERATIONS));
            float s    = sin(angle * float(j));
            float c	   = cos(angle * float(j));
            
#ifndef LENS_DIRT
            sum += getHDR(texture2D(sampler, uv + vec2(c,s)*dist).xyz);
#else
            vec3 dirt = texture2D(iChannel1, uv).rgb * DIRT_INTENSITY;
    		sum += getHDR(texture2D(sampler, uv+vec2(c,s)*dist).xyz) * dirt;   
#endif
            
        }
        
    }
    
    sum /= float(BLUR_ITERATIONS * BLUR_SUBDIVISIONS);
    return clamp(sum * BLOOM_INTENSITY, 0., 1.);
    
}

vec3 blend(vec3 a, vec3 b) {
 
    return 1. - (1. - a)*(1. - b);
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec4 tx = texture2D(iChannel0, uv);
    
    fragColor.xyz = gaussian(iChannel0, uv);
    fragColor.a   = tx.a;
#ifndef BLOOM_ONLY    
    fragColor.xyz = blend(tx.xyz, fragColor.xyz);
#endif
    fragColor.xyz = clamp(fragColor.xyz, 0., 1.);
}