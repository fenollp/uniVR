// Shader downloaded from https://www.shadertoy.com/view/Mdd3Rs
// written by shadertoy user iq
//
// Name: Pixel Structure
// Description: If you don't see the pixel checkerboard pattern and the isolated pixel, then you are working on a retina display or some other distorted image processor.
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = floor( fragCoord );
    vec2 m = floor( iResolution.xy/2.0 ) + 0.5;
    
    float f = mod( p.x + p.y, 2.0 );
    
    f *= step( fragCoord.x, floor(3.0*m.x/4.0) );
    
    f +=  step( abs(fragCoord.x-m.x), 0.5 )
         *step( abs(fragCoord.y-m.y), 0.5 );

    
	fragColor = vec4( f, f, f, 1.0 );
}