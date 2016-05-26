// Shader downloaded from https://www.shadertoy.com/view/4dK3DG
// written by shadertoy user jackdavenport
//
// Name: Basic Blend Modes
// Description: Different modes of blending. Change BLEND_MODE to change the blend technique.
// 0 = Multiply
// 1 = Screen
// 2 = Overlay
#define BLEND_MODE 0

vec3 blend(vec3 a, vec3 b) {
 
    #if BLEND_MODE == 1
    return 1. - ((1. - a) * (1. - b));
    #elif BLEND_MODE == 0
    return a * b;
    #elif BLEND_MODE == 2
    if(a.x < .5 && a.y < .5 && a.z < .5){
        return 2. * a * b;
    }
    return 1. - 2.*(1.-a)*(1. - b);
    #endif
    
    return a;
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3  a = texture2D(iChannel0, uv).xyz;
    vec3  b = texture2D(iChannel1, uv).xyz;
    
    fragColor.xyz = blend(a,b);
}