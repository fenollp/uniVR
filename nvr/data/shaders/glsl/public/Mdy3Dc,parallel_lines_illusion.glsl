// Shader downloaded from https://www.shadertoy.com/view/Mdy3Dc
// written by shadertoy user FabriceNeyret2
//
// Name: parallel lines illusion
// Description: does everyone see lines woobly, or is it only my eyes ? :-) or subtil screen distortions ?
//    (worst in full screen) 
void mainImage( out vec4 O,  vec2 U )
{
    vec2 V = U/iResolution.xy;
    float r = V.x<.5 ? 4. : 6.;
    
    O = O-O+  1.- mod(U.x+U.y, r);
    
  //U = (U-iResolution.xy/2.)*mat2(sin(iGlobalTime+1.57*vec4(1,2,0,1))); // with rotation
    if (V.y<.5) 
      O = O-O+  .5-.5*sin(6.28*(U.x+U.y)/r);

}