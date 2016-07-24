// Shader downloaded from https://www.shadertoy.com/view/4s3XR2
// written by shadertoy user FabriceNeyret2
//
// Name: MIPmap wrapping bug
// Description: it's not really a bug since u does jump even if the texture content is cyclical. 
//    But not all browsers/drivers/OS react the same.
//    
//    I must say I'm far of having all answers here, or be sure in which situations it works or not, with or without correction
/* sometime one can see a strange line in textures, due to MIPmapping huge LOD
   just at this location.
   It's not really a bug since u does jump, even if the texture content is cyclical, 
   so dUdX derivative (controling the MIPmap LOD)  is huge. 
   But not all browsers/drivers/OS react the same: some manage to mask the artifact and some not.

   This probably means than the MIPmap LOD and derivatives are not computed the same way.
   Or, depending on the resolution on different displays, if might simply be that the 
   u jump occurs inside the 2x2 fix neighborhood on which derivatives are computed (in the default approximation)
   or betwen two neighborhood (and thus invisible).
   Note that derivatives might be computed on "smart" or approx (2x2 fix neighborhood) way.
   Or some dedicated trick might occur in some implementations.


   Here,
   - we map polar coordinates (a classical situation of textcoord wrap).

   - The disk at center indicates when we try a correction or not.
        ( it's not clear too me which correction to do. for me:
          I expected 1/R.y or 2/R.y, but it doesn't work, while .01 does... in some conditions), 

   - The classical bug is a grey horizontal line at the left of the disk.
     It might occurs only for some resolutions (fullscreen, intermediate size, icon...).
     I also see different behavior when zooming the browser display (ctrl+)

   - I subdivided the left into 4 parts: (marked with the white dots)
     - closest to center : no offset in the image
     - 3 next zones on left: vertical offset by .5 , 1, 1.5 pixel

   - BTW, note also the strange colors close to the white dots: 
     dots cause derivative errors around because tex coords are not evaluated there    

   Note also than R/2 is not always even, with can impact this kind of things at centering.
   (red disk at bottom left corner).

*/
    
void mainImage( out vec4 O, vec2 U ){

	vec2 R = iResolution.xy; 
    // R = 4.*floor(R/4.);  // this could be the solution
    if (fract(R.y/2.)!=0. && length(U)<30.) { O=vec4(1,0,0,1); return;}
    U = (U+U-R)/R.y; 
                               if (length(U-vec2(-.0 ,-.05))<6./R.y) {O=vec4(1); return;}
    if (U.x<-.5 ) U.y+=1./R.y; if (length(U-vec2(-.5 ,-.05))<6./R.y) {O=vec4(1); return;}
    if (U.x<-.9 ) U.y+=1./R.y; if (length(U-vec2(-.9 ,-.05))<6./R.y) {O=vec4(1); return;}
    if (U.x<-1.4) U.y+=1./R.y; if (length(U-vec2(-1.4,-.05))<6./R.y) {O=vec4(1); return;}
    
    float  t = iGlobalTime, eps = mod(ceil(2.*t),2.)*.01, // 1./R.y, .01
           r = length(U), a = atan(U.y+eps, U.x);

    //if (U.y==1./R.y && U.x<0. &&a>0.) return;//a = -3.14159265359;
    O = (texture2D(iChannel0,vec2(a/6.28318530718,r),6.)-.5)*30.+.5;
    
    if (eps>0. && r<30./R.y) O=vec4(.6);
   
}