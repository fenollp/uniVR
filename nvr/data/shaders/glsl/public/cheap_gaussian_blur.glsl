// Shader downloaded from https://www.shadertoy.com/view/lljXDD
// written by shadertoy user jackdavenport
//
// Name: Cheap Gaussian Blur
// Description: A cheap (but crappy) gaussian blur
#define ITERATIONS 128
#define RADIUS .3

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 sum = texture2D(iChannel0, uv).xyz;
    
    for(int i = 0; i < ITERATIONS / 4; i++) {
     
        sum += texture2D(iChannel0, uv + vec2(float(i) / iResolution.x, 0.) * RADIUS).xyz;
        
    }
    
    for(int i = 0; i < ITERATIONS / 4; i++) {
     
        sum += texture2D(iChannel0, uv - vec2(float(i) / iResolution.x, 0.) * RADIUS).xyz;
        
    }
    
    for(int i = 0; i < ITERATIONS / 4; i++) {
     
        sum += texture2D(iChannel0, uv + vec2(0., float(i) / iResolution.y) * RADIUS).xyz;
        
    }
    
    for(int i = 0; i < ITERATIONS / 4; i++) {
     
        sum += texture2D(iChannel0, uv - vec2(0., float(i) / iResolution.y) * RADIUS).xyz;
        
    }
    
    fragColor = vec4(sum / float(ITERATIONS + 1), 1.);
    
}