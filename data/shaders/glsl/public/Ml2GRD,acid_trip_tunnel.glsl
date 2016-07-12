// Shader downloaded from https://www.shadertoy.com/view/Ml2GRD
// written by shadertoy user kow
//
// Name: Acid trip tunnel
// Description: Forked from:
//    https://www.shadertoy.com/view/XlXGW2
//    
//    Play with top variables
float time = iGlobalTime;

float divisions = 2.;
float modulationDepth = 2.;

vec4 gradient(float f)
{
    vec4 c = vec4(0);
	f = mod(f, 1.5);
    for (int i = 0; i < 3; ++i)
        c[i] = pow(.5 + .5 * tan(2.0 * (f +  .2*float(i))), 10.0);
    return c;
}

float offset(float th)
{
    return modulationDepth * sin(divisions * th)*sin(time);
}

vec4 tunnel(float th, float radius)
{
	return gradient(offset(th + .25*time) + 3.*log(3.*radius) - time);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -0.5 + fragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;
	fragColor = tunnel(atan(p.y, p.x), length(p));
}