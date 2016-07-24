// Shader downloaded from https://www.shadertoy.com/view/Ms3GD2
// written by shadertoy user aiekick
//
// Name: Sound Experiment 6
// Description: MB 3
void mainImage( out vec4 f, in vec2 g )
{
    vec2 s = iResolution.xy;
    vec2 q = g/s;
    f = texture2D(iChannel0, g / s);
   	f *= 0.5 + 0.5*pow( 10.* q.x * q.y * (1.0-q.x) * (1.0-q.y), 0.5 ); 
}