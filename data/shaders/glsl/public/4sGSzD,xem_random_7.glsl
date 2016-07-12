// Shader downloaded from https://www.shadertoy.com/view/4sGSzD
// written by shadertoy user xem
//
// Name: xem random 7
// Description: random
void mainImage(out vec4 fragColor, in vec2 fragCoord){fragColor = reflect(mod(sin(exp(mod(vec4(float(iFrame), 1.7, 1.9, 1.8), pow(vec4(pow(0.3, 0.7), 0.9, (gl_FragCoord.x / iResolution.x), 0.5), vec4(0.8, float(iFrame), 0.9, ceil(0.8)))))), vec4(float(iFrame), ((max(((gl_FragCoord.y / iResolution.y) * 0.1), 0.2) / exp2(0.5)) + 0.1), 1.1, 1.6)), cos(vec4((gl_FragCoord.y / iResolution.y), 0.8, max(1.1, 0.5), (((1.5 * mod(atan((iGlobalTime / (gl_FragCoord.y / iResolution.y)), ((gl_FragCoord.y / iResolution.y) / 0.9)), 0.7)) - (float(iFrame) / (gl_FragCoord.x / iResolution.x))) + 1.6))));}