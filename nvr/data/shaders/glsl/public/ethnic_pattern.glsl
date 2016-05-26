// Shader downloaded from https://www.shadertoy.com/view/XsG3WK
// written by shadertoy user FabriceNeyret2
//
// Name: ethnic pattern
// Description: a variant of https://www.shadertoy.com/view/4dG3WK
void mainImage( out vec4 O,  vec2 U )
{
	U /= iResolution.y; U.x -= .5*iDate.w;
    
    O =vec4(.5,.2,0,0);
    
    for (int i=0; i<3; i++) 
      O -=  floor(mod(10.*(U.x + sign(sin(2.*U.x))* abs(U.y-.5)),2.)), 
      U *= 3., U.y = fract(U.y);        // try other multipliers. e.g. , 10.
    

}