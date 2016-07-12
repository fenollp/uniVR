// Shader downloaded from https://www.shadertoy.com/view/4stSRN
// written by shadertoy user FabriceNeyret2
//
// Name: glsl &amp;amp; gamma correction
// Description: The central checker should appear as the same average grey than the grey around.
//    If not, try GAMMA = 1 instead of 2.2. I understand that it's shader's responsibility to do the final color correction. Or does it depend of  OS/driver/browser ? :-( 
// The central checker should appear as the same average grey than the grey around.
// If not, try with GAMMA = 1 instead of 2.2 . 
// I understand that it's shader's responsibility to do the final color correction. 
// Or does it depend of  OS/driver/browser ? :-(
    
    
// Of course the test makes sense only if your monitor is reasonnably qualibrated,
// and you didn't changed randomly the settings in your preferences + on your monitor.


// #define GAMMA 2.2   //   1.  or  2.2 (expected)
#define GAMMA (2.2 * (  U.y/R.y>.5 ? 1. : iMouse.x/R.x ) )

void mainImage( out vec4 O,  vec2 U )
{
    U -= .5;
    vec2 R = iResolution.xy;
    
    O = vec4 (
               length(U+U-R)/R.y  > .7
                  ? pow(.5,1./GAMMA)
	              : mod(U.x+U.y,2.)
        );
}