// Shader downloaded from https://www.shadertoy.com/view/llSGDh
// written by shadertoy user iq
//
// Name: Input - Microphone
// Description: Testing the Sound Input (microphone).
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // create pixel coordinates
	vec2 uv = fragCoord.xy / iResolution.xy;

	// first texture row is frequency data
	float fft  = texture2D( iChannel0, vec2(uv.x,0.25) ).x; 
	    
    // second texture row is the sound wave
	float wave = texture2D( iChannel0, vec2(uv.x,0.75) ).x;
	
	// convert frequency to colors
	vec3 col = vec3(1.0)*fft;

    // add wave form on top	
	col += 1.0 -  smoothstep( 0.0, 0.01, abs(wave - uv.y) );

    col = pow( col, vec3(1.0,0.5,2.0) );

	// output final color
	fragColor = vec4(col,1.0);
}