// Shader downloaded from https://www.shadertoy.com/view/4tXSRN
// written by shadertoy user iq
//
// Name: Deform - waves
// Description: 2D deformation plus color trickery. Similar to [url]https://www.shadertoy.com/view/Mdl3RH[/url] and  [url]https://www.shadertoy.com/view/4ssSRX[/url] (but in 2D), and clearly this: [url]https://www.shadertoy.com/view/llsSzH[/url]
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage(out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;
    vec2 p = q;
    
    p += .2*cos( 1.5*p.yx + 1.0*iGlobalTime + vec2(0.1,1.1) );
	p += .2*cos( 2.4*p.yx + 1.6*iGlobalTime + vec2(4.5,2.6) );
	p += .2*cos( 3.3*p.yx + 1.2*iGlobalTime + vec2(3.2,3.4) );
	p += .2*cos( 4.2*p.yx + 1.7*iGlobalTime + vec2(1.8,5.2) );
	p += .2*cos( 9.1*p.yx + 1.1*iGlobalTime + vec2(6.3,3.9) );

	float r = length( p );
    
    vec3 col1 = texture2D( iChannel0, vec2(r,     0.0), 0.0 ).zyx;
    vec3 col2 = texture2D( iChannel0, vec2(r+0.04,0.0), 0.0 ).zyx;

    vec3 col = col1;
    col += 0.1;
    col *= 1.0 + 0.4*sin(r+vec3(0.0,3.0,3.0));
    col -= 4.0*max(vec3(0.0),col1-col2).x;
    col += 1.0*max(vec3(0.0),col2-col1).x - 0.1;
    col *= 1.7 - 0.5*length(q);

    fragColor = vec4( col, 1.0 );
}