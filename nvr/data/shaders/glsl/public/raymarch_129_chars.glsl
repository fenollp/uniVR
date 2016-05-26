// Shader downloaded from https://www.shadertoy.com/view/XtXXR4
// written by shadertoy user GregRostami
//
// Name: Raymarch 129 chars
// Description: Based on coyote's SUPER short Raymarch 199 chars: https://www.shadertoy.com/view/llfSzH
//    Thanks to coyote, FabriceNeyert2 and Nrx we finally got a raymarcher in less than ONE TWEET!
//Once again, the brilliant Fabrice, shrunk the un-shrinkable!
//By replacing the fract with a sin and moving the .1 multiplier this raymarcher
//is now an ASTOUNDING 132 CHARS!!!

void mainImage (out vec4 f, vec2 u)
{
    f = iDate.yyww*.1;
    for (int n=0; n<99; n++)
	    f += .02*vec4(u/iResolution.y,1,1) * (length(cos(30.*f))-.2);
}


/*
//Here's a (135 chars) version combining FabriceNeyret2 and Nrx optimizations
//This version eliminates the conditional if statement!!
void mainImage (out vec4 f, vec2 u)
{
    f = iDate.yyww;
    for (int n=0; n<80; n++)
	    f += .4*vec4(u/iResolution.y-.5,1,1) * (length (fract (f)-.5)-.1);
    f *= .1;
}
*/

/*
//Here's a 150 chars version by Nrx
void mainImage (out vec4 f, vec2 u)
{
    f = iDate.yyww;
    for (int i = 90; i > 0; --i)
        if ((f.a = length (fract (f.rgb) - .5)) > .2)
            f += .2 * vec4 (u / iResolution.y - .5, 1, 0) * f.a;
    f *= .1;
}
*/

/*
//This is the original version at 157 chars
void mainImage (out vec4 f, vec2 u)
{
    vec3 r = iDate.yyw;
    for (float i = 9. ; i > 0. ; i -= .1)
        if ((f.a = length (fract (r) - .5)) > .2)
	        f.rgb = i / (r += .2 * vec3 (u / iResolution.y - .5, 1) * f.a);
}
*/