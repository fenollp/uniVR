// Shader downloaded from https://www.shadertoy.com/view/XsVXRh
// written by shadertoy user GregRostami
//
// Name: Pac-Man 149 chars
// Description: I was working on another shader and this idea came to me ... Please help me make it shorter (One-Tweet) - Thank you.
// 149 chars - Just when we thought it's over, LaBodilsen strikes back by removing 2 chars!
// Is Fabrice down for the count?!
/**/
void mainImage(out vec4 o,vec2 u)
{
    float t = iDate.w/.1,
          l = length(u=u/.1/iResolution.y-5.);
    o = vec4(l<3.&&u.x/l<.9+.1*sin(t));
    o.ab = sin(u.x>0. ? l+t: 0.) - u*u;
}
/**/

// 151 chars - As Fabrice and LaBodilsen battle, Fabrice strikes back with this ...
// LaBodilsen throws a jab by removing a char from the blue dots.
/*
void mainImage(out vec4 o,vec2 u)
{
    float t = iDate.w/.1, 
          l = length(u=u/iResolution.y-.5); u/=.1;
    o = vec4(l<.3&&u.x/l<9.+sin(t));
    o.ab = sin(u.x>0. ? u.x+t: 0.) - u*u;
}
*/

// 139 chars - a little cheating, but it still looks good:
// Using optimizations from Fabrice and LaBodilsen (Thank you)
/*
void mainImage(out vec4 o,vec2 u)
{
    float t = iDate.w/.1,
          l = length(u=u/.1/iResolution.y-4.);
    o = vec4(l<4.&&u.x/l<.9+.1*sin(t));
    o.ab = sin(l+t) - u*u;
}
*/

// 156 chars - My Amiga brother LaBodilsen, replaced the square dots with circles.
/*
void mainImage(out vec4 o,vec2 u)
{
    float t = iDate.w/.1, 
          l = length(u=u/iResolution.y-.5);
    o = vec4(l<.3&&u.x/l<.9+.1*sin(t));
    o.b = sin(u.x>.0 ?l /.1+t:0.)-abs(u.y)/.1;
}
*/

// 161 chars - Fabrice reduced sin(atan(u.x,u.y))= u.x/length(u)
/*
void mainImage(out vec4 o,vec2 u)
{
    float t = iDate.w/.1, 
          l = length(u=u/iResolution.y-.5);
    o = vec4(l<.3&&u.x/l<.9+.1*sin(t));
    o.b = u.x>0.&&abs(u.y)<.05 ? sin(u.x/.05 + t):0.;
}
*/

// 150 chars - B&W Pac-Man
// Thanks to LaBodilsen, saved another 2 chars 
/*
void mainImage(out vec4 o,vec2 u)
{
    float a = .1,
        t = iDate.w/a,
        l = length(u=u/iResolution.y-.4);
    o = vec4(l < .5&&u.x / l < .9+a*sin(t)||abs(u.y) < a&&sin(u.x/a + t) >.5);
}
*/

// 159 chars, LaBodilsen's version
/*
void mainImage(out vec4 o,vec2 u)
{
    float f = .1,
        t = iDate.w/f,
        l = length(u = u/iResolution.y-.5);
    o = vec4(l<.5&&u.x/l<.9+f*sin(t));
    o.b = u.x>f&&abs(u.y)<f ? sin(u.x/f + t):0.;
}
*/

// I got him eating dots in 173 chars but it's not one-tweet :(
// Please help me make this shader better/shorter.
/*
void mainImage(out vec4 o,vec2 u)
{
    float t = 15.*iDate.w;
    o = vec4(length(u=u/iResolution.y-.5)<.3&&sin(atan(u.x,u.y))<.9+.1*sin(t));
    o.b = u.x>.0 && abs(u.y)<.05 ? sin(u.x/.05 + t):0.;
}
*/

// 126 chars - Original shader - no dots
/*
void mainImage(out vec4 o,vec2 u)
{
    o-=o;
    o.rg = vec2(length(u=u/iResolution.y-.5)<.3&&sin(atan(u.x,u.y))<.9+.1*sin(15.*iDate.w));
}
*/