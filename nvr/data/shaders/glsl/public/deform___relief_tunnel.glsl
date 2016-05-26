// Shader downloaded from https://www.shadertoy.com/view/4sXGRn
// written by shadertoy user iq
//
// Name: Deform - relief tunnel
// Description: A 2D tunnel with fake relief
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    vec2 uv;

    float r = sqrt( dot(p,p) );
	
    float a = atan(p.y,p.x) + 0.75*sin(0.5*r-0.5*iGlobalTime );
	
	float h = (0.5 + 0.5*cos(9.0*a));

	float s = smoothstep(0.4,0.5,h);

    uv.x = iGlobalTime + 1.0/( r + .1*s);
    uv.y = 3.0*a/3.1416;

    vec3 col = texture2D(iChannel0,uv).xyz;
//	col *= 1.25;

    float ao = smoothstep(0.0,0.3,h)-smoothstep(0.5,1.0,h);
    col *= 1.0-0.6*ao*r;
	col *= r*r;

    fragColor = vec4(col,1.0);
}