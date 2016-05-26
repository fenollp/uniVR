// Shader downloaded from https://www.shadertoy.com/view/4lXXzH
// written by shadertoy user FabriceNeyret2
//
// Name: Micro Shader: pulses
// Description: .
void mainImage(out vec4 o,vec2 i) {o=(mat2(sin(iDate.wyyw))*sin(.1*i.xy)).xyxy;}
