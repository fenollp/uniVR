// Shader downloaded from https://www.shadertoy.com/view/MdKSR1
// written by shadertoy user xem
//
// Name: xem random 6
// Description: random
// Paste this code in shadertoy.com/new

void mainImage(out vec4 fragColor, in vec2 fragCoord){
  fragColor = vec4((iMouse.y / iResolution.y), ((iMouse.x / iResolution.x) * (gl_FragCoord.y / iResolution.y)), 0.9, ((0.1 - mod(0.1, (0.7 / 1.9))) * 0.6));
}