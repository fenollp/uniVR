// Shader downloaded from https://www.shadertoy.com/view/XsXGzn
// written by shadertoy user iq
//
// Name: Clover
// Description: A 2D procedural clover [url]https://www.youtube.com/watch?v=-z8zLVFCJv4[/url] and [url]http://iquilezles.org/live/index.htm[/url]
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Tutorial here: 
// * https://www.youtube.com/watch?v=-z8zLVFCJv4
// * http://iquilezles.org/live/index.htm


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = 0.6 * (2.0*fragCoord.xy-iResolution.xy)/min(iResolution.y,iResolution.x);

    float a = atan(q.x,q.y);
    float r = length(q);
    float s = 0.5 + 0.5*sin(3.0*a + iGlobalTime);
    float g = sin(1.57+3.0*a+iGlobalTime);
    float d = 0.15 + 0.3*sqrt(s) + 0.15*g*g;
    float h = clamp(r/d,0.0,1.0);
    float f = 1.0-smoothstep( 0.95, 1.0, h );
    h *= 1.0-0.5*(1.0-h)*smoothstep(0.95+0.05*h,1.0,sin(3.0*a+iGlobalTime));
	
	vec3 bcol = vec3(0.9+0.1*q.y,1.0,0.9-0.1*q.y);
	bcol *= 1.0 - 0.5*r;
	h = 0.1 + h;
    vec3 col = mix( bcol, 1.2*vec3(0.6*h,0.2+0.5*h,0.0), f );

    fragColor = vec4( col, 1.0 );
}