// Shader downloaded from https://www.shadertoy.com/view/Xdd3DB
// written by shadertoy user iq
//
// Name: Deformation Feedback
// Description: The old-school effect from the PC demos of the 90s [url]http://iquilezles.org/www/articles/feedbackfx/feedbackfx.htm[/url]
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0


// The old school demoscene effect, deformation feedback. An article from 2002
// describing it: http://iquilezles.org/www/articles/feedbackfx/feedbackfx.htm

const float th = 0.06;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord/iResolution.xy;
    vec2 p = (-iResolution.xy + 2.0*fragCoord) / iResolution.y;

    vec3 col = texture2D( iChannel0, 0.5+(q-0.5)*(1.0-2.0*th) ).xyz;
    
    col *= 1.5*length(p);
    
	fragColor = vec4(col,1.0);
}