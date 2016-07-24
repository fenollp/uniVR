// Shader downloaded from https://www.shadertoy.com/view/MdVXzh
// written by shadertoy user xem
//
// Name: xem random 2
// Description: random
void mainImage(out vec4 fragColor, in vec2 fragCoord){
  fragColor = vec4(mod((1.8 - (gl_FragCoord.y / iResolution.y)), (gl_FragCoord.y / iResolution.y)), 1.0, 0.4, 1.1);
}