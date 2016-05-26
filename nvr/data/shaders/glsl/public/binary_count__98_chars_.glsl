// Shader downloaded from https://www.shadertoy.com/view/XdKXWh
// written by shadertoy user FabriceNeyret2
//
// Name: binary count (98 chars)
// Description: binary count
//    
//    could you make it smaller ? :-)
void mainImage( out vec4 O,  vec2 U )
{
    U/=8.; O += mod( ceil( (U.x+8.*iGlobalTime) / exp2(floor(U.y)) ) ,2.) -O;  

 // O += mod( (U.x/8.+8.*iGlobalTime) / exp2(floor(U.y/8.)) , 2.) -O;        // 92, funny
 // O += cos( 3.14*( (U.x/8.+8.*iGlobalTime) / exp2(floor(U.y/8.)) )) -O;    // 96, funny

 // U = floor(U/8.); O += mod( ceil( (U.x+8.*iGlobalTime) / exp2(U.y) ), 2.) -O;  // 99.
 // U = floor(U/8.); O += mod( vec4( (int(U.x)+iFrame) / int(exp2(U.y) ) ), 2.);  // variant
}