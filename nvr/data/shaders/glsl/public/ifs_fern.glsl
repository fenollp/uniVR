// Shader downloaded from https://www.shadertoy.com/view/lst3zf
// written by shadertoy user iq
//
// Name: IFS Fern
// Description: This must have been one of the first fractals I coded (copied from a magazine) in 1994. We couldn't make these in Shadertoy [url]https://www.shadertoy.com/view/lss3zs[/url]. We cannot make them properly yet, but it's better now.
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = fragCoord/iResolution.xy;
    
    vec4 data = texture2D( iChannel0, p );
    
    float f = data.x;
    float e = data.y / data.w;
    
    vec3 col = vec3(1.0-f) * (1.0-vec3(0.2,0.3,0.6)*e);
    
    col *= 0.5 + 0.5*pow( 16.0*p.x*p.y*(1.0-p.x)*(1.0-p.y), 0.2 );
    
    fragColor = vec4( col, 1.0 );
}