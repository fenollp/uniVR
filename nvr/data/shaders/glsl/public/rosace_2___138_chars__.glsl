// Shader downloaded from https://www.shadertoy.com/view/Md3XWM
// written by shadertoy user FabriceNeyret2
//
// Name: rosace 2 ( 138 chars )
// Description: rosace
void mainImage( out vec4 O, vec2 U )
{
      
    O = .3 / abs( 3.*length(U+=U-(O.xy=iResolution.xy))/O.y 
                 - sin ( 7.*atan(U.y,U.x)  - iGlobalTime ) 
                 - .5*vec4(1,2,3,4) );
} 