// Shader downloaded from https://www.shadertoy.com/view/XdK3Dh
// written by shadertoy user EntityBlack
//
// Name: Save numbers in texture
// Description: How to use texture to store numbers. This can be used for example to store positions that are not just in 0;255 interval. 
// Buffer is used as simple memory to store float numbers

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy/iResolution.xy;
    fragColor = texture2D(iChannel0, q);
}