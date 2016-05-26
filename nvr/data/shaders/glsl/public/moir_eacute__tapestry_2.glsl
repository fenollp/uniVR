// Shader downloaded from https://www.shadertoy.com/view/ltjSDV
// written by shadertoy user FabriceNeyret2
//
// Name: Moir&eacute; tapestry 2
// Description: variant of https://www.shadertoy.com/view/ll2XWV
void mainImage(out vec4 o,  vec2 U)  {   o= sin(iDate.wwww + U.x*U.y/45.);   }



// {    o+= sin(iDate.w + U.x*U.y/45. + vec4(1,2,3,0));   } // with colors
