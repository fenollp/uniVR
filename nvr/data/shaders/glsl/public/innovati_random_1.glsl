// Shader downloaded from https://www.shadertoy.com/view/MdVSR1
// written by shadertoy user xem
//
// Name: innovati random 1
// Description: random
void mainImage(out vec4 fragColor, in vec2 fragCoord){ fragColor = atan(cos(((atan(vec4((gl_FragCoord.x / iResolution.x), 1.9, float(iFrame), (gl_FragCoord.x / iResolution.x)), vec4(0.5, (gl_FragCoord.x / iResolution.x), sin((iMouse.y / iResolution.y)), 1.2)) * exp2(pow((0.7 - iGlobalTime), (gl_FragCoord.x / iResolution.x)))) * 1.7))); }