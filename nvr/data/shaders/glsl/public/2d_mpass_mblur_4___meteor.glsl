// Shader downloaded from https://www.shadertoy.com/view/Xdy3RR
// written by shadertoy user aiekick
//
// Name: 2D MPass MBlur 4 : Meteor
// Description: use mouse x for decrease the particle number
//    use mouse y for control zoom
void mainImage( out vec4 f, in vec2 g )
{
    f = texture2D(iChannel0, g / iResolution.xy);
}