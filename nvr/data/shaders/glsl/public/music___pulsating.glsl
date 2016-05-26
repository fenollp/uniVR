// Shader downloaded from https://www.shadertoy.com/view/XdfXWS
// written by shadertoy user iq
//
// Name: Music - Pulsating
// Description: An example of how to make basic procedural music in the GPU with Shadertoy!
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy+2.0*fragCoord.xy)/iResolution.y;
	
    vec3 col = vec3( 0.0 );
	
    float noteA = fract( iGlobalTime/4.00 );
    float noteB = fract( iGlobalTime/0.50 );
    float noteC = fract( iGlobalTime/0.50 );
	
    col = mix( col, vec3(1.0,1.0,0.5), (1.0-noteA)*(1.0-smoothstep( 0.0, 0.5, length(p-vec2( 0.8,0.0)))));
    col = mix( col, vec3(0.5,1.0,0.5),      noteB *(1.0-smoothstep( 0.0, 0.2, length(p-vec2( 0.0,0.0)))));
    col = mix( col, vec3(0.5,0.5,1.0), (1.0-noteC)*(1.0-smoothstep( 0.0, 0.2, length(p-vec2(-0.8,0.0)))));

	fragColor = vec4( col, 1.0 );
}