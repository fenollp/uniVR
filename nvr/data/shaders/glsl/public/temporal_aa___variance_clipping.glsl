// Shader downloaded from https://www.shadertoy.com/view/MscSD7
// written by shadertoy user Vil
//
// Name: Temporal AA + Variance Clipping
// Description: A temporal AA implementation using Marco Salvi's Variance Clipping algorithm for temporal antialiasing. Variance Clipping is described here: https://www.dropbox.com/sh/dmye840y307lbpx/AAAQpC0MxMbuOsjm6XmTPgFJa
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 fragUV = fragCoord / iResolution.xy;
    fragColor = texture2D(iChannel0, fragUV);
}
