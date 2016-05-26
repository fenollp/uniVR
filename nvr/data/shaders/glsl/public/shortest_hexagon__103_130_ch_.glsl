// Shader downloaded from https://www.shadertoy.com/view/4scXWS
// written by shadertoy user FabriceNeyret2
//
// Name: shortest hexagon (103/130 ch)
// Description: 103 in aliased version, 130 in antialiased version.
//    Will you find shorter ? :-)  ( same shape, scalable).
/**/
void mainImage( out vec4 O, vec2 U )
{
    U = abs(U+U - (O.xy=iResolution.xy)) / O.y;
    O = vec4 ( U.x < .5&&U.x + U.y*1.7 < 1. );                       // 103 aliased - Greg idea
  //O = vec4(max(U.x, U.x*.5+U.y*.87) < .5);                         // 107 aliased - Fab
    
  //U = smoothstep(.51,.5,U*mat2(1,0,.5,.87)); O += min(U.x,U.y) -O; // 130 smooth
  //U *= mat2(2,0,1,1.7); U=1./U/U/U/U; O += min(U.x,U.y) -O;        // 122 blurry
  //U *= mat2(2,0,1,1.7); O += 1./max(U.x,U.y) -O;                   // 112 blurry2
  // see also a more stary version here: https://www.shadertoy.com/view/Md3SDS
    
  //O += sin(1e2*max(U.x, U.x*.5+U.y*.87))-O;                        // 110 concentric
}
/**/




/**     // --- rotating flares version  by Shane // 157
void mainImage( out vec4 O, vec2 U )
{
    U = abs( (U+U - (O.xy=iResolution.xy))/O.y 
             * mat2(O.zw = sin(vec2(0, 1.57) + iDate.w), -O.w, O.z)
           )* mat2(2,0,1,1.7); 
    O += 1./max(U.x,U.y) -O; 
}
/**/
