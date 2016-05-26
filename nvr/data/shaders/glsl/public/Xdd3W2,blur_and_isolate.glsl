// Shader downloaded from https://www.shadertoy.com/view/Xdd3W2
// written by shadertoy user iq
//
// Name: Blur and Isolate
// Description: Repeated box blurring (2x2 kernel) and isolating a band of values with an exponential around 0.2 leads to a pretty long lasting transitory dynamics.  
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float c = texture2D( iChannel0, fragCoord / iResolution.xy ).x;
    
    fragColor = vec4(c,c,c,1.0);
}