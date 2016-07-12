// Shader downloaded from https://www.shadertoy.com/view/ldX3Rr
// written by shadertoy user iq
//
// Name: Yin Yang
// Description: The Yin Yan symbol.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = 1.2 * (2.0*fragCoord.xy-iResolution.xy)/min(iResolution.y,iResolution.x);

    float h = dot(p,p);
    float d = abs(p.y)-h;
    float a = d-0.23;
    float b = h-1.00;
    float c = sign(a*b*(p.y+p.x + (p.y-p.x)*sign(d)));
		
    c = mix( c, 0.0, smoothstep(0.98,1.00,h) );
    c = mix( c, 0.6, smoothstep(1.00,1.02,h) );
    
	fragColor = vec4( c,c,c, 1.0 );
}

