// Shader downloaded from https://www.shadertoy.com/view/MscXDn
// written by shadertoy user Vil
//
// Name: Distance Field Painter
// Description: Use the mouse to draw a seed region and watch the distance field grow. Use the rewind button to start over
/*
 * Draw the distance field.
 */

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float dist = texture2D(iChannel0, fragCoord / iResolution.xy).r;
    float level = clamp(dist / 256.0, 0.0, 1.0);
    fragColor = vec4(level, level, level, 1.0);
}