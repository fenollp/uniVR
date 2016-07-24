// Shader downloaded from https://www.shadertoy.com/view/lsVSR1
// written by shadertoy user xem
//
// Name: innovati random 2
// Description: random
// Paste this code in shadertoy.com/new

void mainImage(out vec4 fragColor, in vec2 fragCoord){
  fragColor = vec4((mod(max(radians((iMouse.y / iResolution.y)), float(iFrame)), ((gl_FragCoord.x / iResolution.x) - atan(1.6, 0.7))) * (0.2 - 1.4)), 1.9, float(iFrame), 0.9);
}