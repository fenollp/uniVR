// Shader downloaded from https://www.shadertoy.com/view/4dG3WK
// written by shadertoy user FabriceNeyret2
//
// Name: &lt;&lt;&lt;now&gt;you&lt;can&gt;&gt;&gt; :-)
// Description: just to celebrate the end of this so annoying bug when copy-pasting code containing both &lt; and &gt;  was interpreted as html comments and thus deleted big chunks at random. 
void mainImage( out vec4 O,  vec2 U )
{
	U /= iResolution.y; U.x-= iDate.w;
    O =  O-O + floor(mod(10.*(U.x + sign(sin(2.*U.x))* abs(U.y-.5)),10.)-8.);
}






/*    // variant 
void mainImage( out vec4 O,  vec2 U )
{
	U /= iResolution.y; U.x -= .5*iDate.w;
    
    O-=O;
    
    for (int i=0; i<3; i++) 
      O +=  .5*step(8.,floor(mod(10.*(U.x + sign(sin(2.*U.x))* abs(U.y-.5)),10.))), 
      U *= 3., U.x -= .5*iDate.w+floor(U.y), U.y = fract(U.y), O*=1.5;
}
*/