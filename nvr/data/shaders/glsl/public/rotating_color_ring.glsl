// Shader downloaded from https://www.shadertoy.com/view/lsG3zm
// written by shadertoy user Sima214
//
// Name: Rotating Color Ring
// Description: My first public shadertoy!!!
//    Nothing complicated. Just a few circles and vectors.
//You could say it's speed
#define LOOP_TIME 20.0
//No i couldn't think of a more unique name
#define LOOPS 0.5
//Whether to use iq's suggestion
#define IQ
//Circle constants
const vec2 pK = vec2(0.5, 0.5);
const float r1 = 0.25;
const float r2 = 0.48;
//PI constants
const float PI = 3.14159265359;
const float PI2 = PI * 2.0;
const float PI_HALF = PI / 2.0;

//Based of http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
const vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
vec3 hue2rgb(float hue){
    vec3 p = abs(fract(hue + K.xyz) * 6.0 - K.www);
    return clamp(p - K.xxx, 0.0, 1.0);
}

float getRingMult(vec2 va){
  return smoothstep(r1, r2, length(va));
}
vec2 genUV(in vec2 fragCoord){
    vec2 uv = fragCoord;
    uv.x -= (iResolution.x - iResolution.y)/2.0;
    uv /= iResolution.y;
    return uv;
}
vec3 getBackground(){
    return vec3(0.2);
}
#ifndef IQ
vec2 getStartVec(){
    float angle = (iGlobalTime/LOOP_TIME) * PI2;
    return vec2(cos(angle), sin(angle));
}
#endif
vec3 genColor(vec2 vKA){
    #ifdef IQ
    float angle = (iGlobalTime/LOOP_TIME) * PI2 + atan(vKA.x, vKA.y) - PI_HALF;
    #else
    float angle = dot(getStartVec(), normalize(vKA));
    angle = acos(angle);
    #endif
    return hue2rgb(angle / PI * LOOPS);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 pA = genUV(fragCoord);
    vec2 vKA = pA - pK;
    float dist = getRingMult(vKA);
    vec3 final = getBackground();
    if(dist!=0.0 && dist!=1.0){
        final = mix(genColor(vKA), final, dist);
    }
	fragColor = vec4(final, 1.0);
}