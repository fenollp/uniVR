// Shader downloaded from https://www.shadertoy.com/view/4st3Rj
// written by shadertoy user BiiG
//
// Name: Procedural noise generator
// Description: A fast way to generate a screen space procedural noise
//
// Example implementation of a fast procedural noise
// https://oneoverzerosite.wordpress.com/2015/12/23/procedural-noise-generation-in-a-pixel-shader/
//
// Created by Guillaume Carrez
//

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    const float cZoomFactor = 1.0;
    
    fragCoord.xy = floor(fragCoord.xy/cZoomFactor)*cZoomFactor;
    // Seed will be based on pixel coord, works pretty well for 1080p
	float seed = (fragCoord.x+0.5) * (fragCoord.y+1.0);

    
    // Compute 2 frequency perturbations
    float noise = seed * (1.0-(1.0/127.0));			// 1st octave
	noise *= fract ( noise * (1.0/127.0) );			// 2nd
	noise = fract ( noise );
    
    
    seed = (fragCoord.x+0.5) * (fragCoord.y+1.0);
    noise = fract ( sin(seed) * 43758.5453123);

    // Add some time update
	//noise = fract(noise+iGlobalTime);
    
    
    

    // Output result as a grey scale value
	fragColor = vec4(noise,noise,noise,1.0);
}