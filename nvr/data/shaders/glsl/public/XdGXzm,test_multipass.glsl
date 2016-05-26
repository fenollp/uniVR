// Shader downloaded from https://www.shadertoy.com/view/XdGXzm
// written by shadertoy user yasuo
//
// Name: Test multipass
// Description: This is my first multipass shader attempt.
//    Here is c++ based multipass shader sample.
//    https://github.com/yasuohasegawa/OpenGL-Multipass-Shader-Sample
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    vec2 position = ( fragCoord.xy / iResolution.xy );
    position.y += (sin((position.x + (iGlobalTime * 0.5)) * 6.0) * 0.1) + (sin((position.x + (iGlobalTime * 0.2)) * 6.0) * 0.01);
    vec4 col = texture2D(iChannel0, position);
    fragColor = col+vec4(position,1.0,1.0);
}