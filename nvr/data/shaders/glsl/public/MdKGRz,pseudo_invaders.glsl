// Shader downloaded from https://www.shadertoy.com/view/MdKGRz
// written by shadertoy user aiekick
//
// Name: Pseudo Invaders
// Description: Based on https://www.shadertoy.com/view/4s33Rn from movAX13h 
//    
// Created by Stephane Cuillerdier - @Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/*
Based on https://www.shadertoy.com/view/4s33Rn from movAX13h 
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord / iResolution.xy;
  
	fragColor = texture2D(iChannel0, uv);
}