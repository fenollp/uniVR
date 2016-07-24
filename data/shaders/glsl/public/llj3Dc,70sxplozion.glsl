// Shader downloaded from https://www.shadertoy.com/view/llj3Dc
// written by shadertoy user spacegoo
//
// Name: 70sXplozion
// Description: zou
#define c mod(floor(a+t-i.x*p)+floor(a+t-i.y*p),2.)

void mainImage( out vec4 o, vec2 i )
{
    float t = iDate.w, a, p = pow(length(i = i / iResolution.xy - .3),-cos(t)*2.);
    o.r = c;
    a = .3; o.g = c;
    a = .6; o.b = c;
}