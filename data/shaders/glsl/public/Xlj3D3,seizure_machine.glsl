// Shader downloaded from https://www.shadertoy.com/view/Xlj3D3
// written by shadertoy user jackdavenport
//
// Name: Seizure Machine
// Description: If you are prone to seizures, please watch in fullscreen
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float x = 1. * abs(sin(iGlobalTime * 1000.));
    fragColor = vec4(x);
    
}