// Shader downloaded from https://www.shadertoy.com/view/XdySzD
// written by shadertoy user xem
//
// Name: xem random 8
// Description: random
void mainImage(out vec4 fragColor, in vec2 fragCoord){fragColor = reflect(reflect(sign(vec4((pow(1.9, 0.6) - 0.5), (1.8 * 1.7), 0.0, 1.8)), abs(vec4(0.4, (gl_FragCoord.x / iResolution.x), 1.4, 0.1))), vec4(iGlobalTime, ((((gl_FragCoord.x / iResolution.x) - 0.4) + (0.2 - atan(1.0, ((gl_FragCoord.x / iResolution.x) / 0.3)))) + (0.7 - (gl_FragCoord.y / iResolution.y))), 1.1, 0.7));}