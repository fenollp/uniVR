// Shader downloaded from https://www.shadertoy.com/view/Xdd3Ds
// written by shadertoy user aiekick
//
// Name: Another Cloudy Tunnel 4
// Description: let the time to the time
void mainImage( out vec4 f, in vec2 g )
{
	vec2 q = g/iResolution.xy;
    f = texture2D(iChannel0, q);
    f.rgb *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.25 ); // vignette
}
