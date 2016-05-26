// Shader downloaded from https://www.shadertoy.com/view/MtXXzr
// written by shadertoy user aiekick
//
// Name: Weird Fractal 5
// Description: Weird Fractal 5
// Created by Stephane Cuillerdier - Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//based on my Weird Fractal 4 : https://www.shadertoy.com/view/MtsGzB

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    
	fragColor = texture2D(iChannel0, fragCoord / iResolution.xy);
}