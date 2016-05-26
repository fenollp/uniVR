// Shader downloaded from https://www.shadertoy.com/view/XdXGzn
// written by shadertoy user iq
//
// Name: Deform - square tunnel II
// Description: A 2D square tunnel, kind of.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    vec2 uv;

    float r = pow( pow(p.x*p.x,16.0) + pow(p.y*p.y,16.0), 1.0/32.0 );
    uv.x = .5*iGlobalTime + 0.5/r;
    uv.y = atan(p.y,p.x)/3.1416;
	
	float h = sin(32.0*uv.y);
    uv.x += 0.85*smoothstep( -0.1,0.1,h);
    vec3 col = texture2D( iChannel1, 2.0*uv ).xyz;
    col = mix( col, texture2D( iChannel0, uv ).xyz, smoothstep(0.9,1.1,abs(p.x/p.y) ) );
	
    r *= 1.0 - 0.3*(smoothstep( 0.0, 0.3, h ) - smoothstep( 0.3, 0.96, h ));
	
    fragColor = vec4( col*r*r*1.2,1.0);
}