// Shader downloaded from https://www.shadertoy.com/view/MsV3zR
// written by shadertoy user FabriceNeyret2
//
// Name: pyramid op
// Description: cascading operations on image, e.g., for normalization of the video values.
//    NB: draft. I should align pixels to video size.
void mainImage( out vec4 O,  vec2 U )
{
    vec4 sol = texture2D(iChannel0, vec2(1));                 // ultimate cascaded value
    
	O = texture2D(iChannel0, U /= iResolution.xy);

    // --- your normalization operation here
    if (U.y>U.x)  O /= sol;     // using max
 // if (U.y>U.x)  O *= .5/sol;  // using mean

    
    
    if (max(U.x,1.-U.y)<.1) O = texture2D(iChannel0, vec2(1)); // display measured value
}