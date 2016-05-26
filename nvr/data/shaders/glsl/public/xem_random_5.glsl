// Shader downloaded from https://www.shadertoy.com/view/ldKSR1
// written by shadertoy user xem
//
// Name: xem random 5
// Description: random
// Paste this code in shadertoy.com/new

void mainImage(out vec4 fragColor, in vec2 fragCoord){
  fragColor = vec4(((0.6 - atan((max(0.6, 0.0) * 1.6), 1.4)) + (iMouse.y / iResolution.y)), 0.1, 0.3, (0.2 - (iMouse.y / iResolution.y)));
}