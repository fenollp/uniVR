// Shader downloaded from https://www.shadertoy.com/view/MlsXD8
// written by shadertoy user FabriceNeyret2
//
// Name: Micro Shader: pulses2
// Description: sort of programming haiku ;-p
void mainImage(out vec4 o,vec2 i) { o.xy = mat2(sin(iDate)) * sin(i*25.);  }



// Notes:
//    -  cos(iDate) gives a different look 
//    -  i*24 or 26 is very different