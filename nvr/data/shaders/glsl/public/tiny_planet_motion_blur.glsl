// Shader downloaded from https://www.shadertoy.com/view/XsdGDB
// written by shadertoy user aiekick
//
// Name: Tiny Planet Motion Blur
// Description: Motion Blurred version of [url=https://www.shadertoy.com/view/4ljGRh][NV15] Tiny Cutting Planet[/url]
//    
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0, uv);;
}