// Shader downloaded from https://www.shadertoy.com/view/MdcGWS
// written by shadertoy user aiekick
//
// Name: 2D Multi Pass Motion Blur 2
// Description: 2D Multi Pass Motion Blur 2
void mainImage( out vec4 f, in vec2 g )
{
    vec2 s = iResolution.xy;
    
    f = texture2D(iChannel0, g / s);
    //f = 1.-smoothstep(f,f+0.01, vec4(1));
}