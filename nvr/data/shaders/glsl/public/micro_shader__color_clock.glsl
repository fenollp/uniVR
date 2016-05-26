// Shader downloaded from https://www.shadertoy.com/view/MtfSz8
// written by shadertoy user FabriceNeyret2
//
// Name: Micro Shader: color clock
// Description: blue cycles by 5 seconds between R+G strips,
//    green cycles by 1 minute between red strips;
//    red  cycles by 1 hour.
void mainImage(out vec4 o,vec2 i) { o=sin(length(.1*i-25.)+iDate.w/vec4(36e2,10,.78,1)); }