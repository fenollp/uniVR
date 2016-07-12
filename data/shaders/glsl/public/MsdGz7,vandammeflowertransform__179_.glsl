// Shader downloaded from https://www.shadertoy.com/view/MsdGz7
// written by shadertoy user FabriceNeyret2
//
// Name: vanDammeflowerTransform (179)
// Description: direct application of jt's transform https://www.shadertoy.com/view/Mdd3R7#
// direct application of jt's transform https://www.shadertoy.com/view/Mdd3R7#

void mainImage( out vec4 O, vec2 I )
{
	vec2 R = iResolution.xy; 
    I = 8.* (I+I-R)/R.y;

    I = vec2(0, length(I)) + atan(I.y,I.x)/6.283;
    I.x = ceil(I.y) - I.x;
    I.x *= I.x * 2.472;                     // (sqrt(5.)-1.)*2.;

    O = texture2D(iChannel0,fract(I));
 // O = texture2D(iChannel0,fract(-I.yx));  // variant
 // O += length(fract(I)-.5);               // dots
}
