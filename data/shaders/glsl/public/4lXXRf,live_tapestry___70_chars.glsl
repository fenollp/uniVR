// Shader downloaded from https://www.shadertoy.com/view/4lXXRf
// written by shadertoy user FabriceNeyret2
//
// Name: live tapestry - 70 chars
// Description: .
void mainImage(out vec4 o, vec2 i) { o = fract(length(sin(i)) - iDate.wwww); }

// void mainImage(inout vec4 o, vec2 i) { o += fract(length(i)/1e2 - iDate.w); }