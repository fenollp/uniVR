// Shader downloaded from https://www.shadertoy.com/view/lscGz4
// written by shadertoy user FabriceNeyret2
//
// Name: glsl bug on mac ?
// Description: Mac users, do you see all grey or something else ?
void mainImage( out vec4 o,  vec2 u )
{
	u /= iResolution.xy;
    
     if     (u.x<.4)   o -= o -.5;
    else if (u.x<.8)   o += .5 - o;
    else             { o -= o ; o+= .5; }
}