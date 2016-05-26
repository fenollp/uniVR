// Shader downloaded from https://www.shadertoy.com/view/4tjGRm
// written by shadertoy user GregRostami
//
// Name: Rainbow Draw
// Description: Use the mouse to draw on the screen.
//    Inspired by klk's brilliant use of the discard command in this shader:
//    https://www.shadertoy.com/view/Xt23Rw
void mainImage(out vec4 o,vec2 n)
{
    float t = iDate.w,s = 8.+5.*sin(t);
    vec2 m = iMouse.xy;
    if(length(n-(iResolution.xy-m))>2.*s && length(n-m)>s)
        discard;
	o.rgb = clamp(abs(fract(t + vec3(1., .6, .3)) * 6. - 3.) - 1., 0., 1.);
}

/*
//Here's a super simple draw shader with only 75 chars!?
void mainImage(vec4 o,vec2 n)
{
    if(length(n-iMouse.xy)>9.)
        discard;
	o=vec4(1);
}
*/