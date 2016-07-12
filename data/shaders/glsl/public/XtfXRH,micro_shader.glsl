// Shader downloaded from https://www.shadertoy.com/view/XtfXRH
// written by shadertoy user iq
//
// Name: Micro Shader
// Description: In the spirit of [url=https://www.shadertoy.com/view/4tXXRH]rcread's shader[/url], a haf-tweet characters shader (66 characters in this case). Resolution, and date of the year dependent :)
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// A smaller than 70 characters (half tweet) shader

void mainImage( out vec4 o, vec2 i )
{
    o = sin(length(.1*i)+iDate.wwzx);
}