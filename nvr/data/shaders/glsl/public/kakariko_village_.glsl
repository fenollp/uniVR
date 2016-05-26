// Shader downloaded from https://www.shadertoy.com/view/XddGDX
// written by shadertoy user elias
//
// Name: Kakariko Village 
// Description: Attempt to render an image using 3 seperate audio inputs, one for each color channel.
//    Reset the time once each channel has loaded.
//    
//    One of the channels is a little too long, that's why it doesn't repeat seamlessly.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    fragColor = vec4(texture2D(iChannel0, uv).rgb,1);
}