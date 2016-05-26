// Shader downloaded from https://www.shadertoy.com/view/XlXGW2
// written by shadertoy user mpcomplete
//
// Name: Acid Tunnel
// Description: Playing with tunnel effects.
//    
//    Based on https://www.shadertoy.com/view/lslGRj .
float time = iGlobalTime;

vec4 gradient(float f)
{
    vec4 c = vec4(0);
	f = mod(f, 1.5);
    for (int i = 0; i < 3; ++i)
        c[i] = pow(.5 + .5 * sin(2.0 * (f +  .2*float(i))), 10.0);
    return c;
}

float offset(float th)
{
    return .5*sin(25.*th)*sin(time);
}

vec4 tunnel(float th, float radius)
{
	return gradient(offset(th + .25*time) + 3.*log(3.*radius) - time);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;
	fragColor = tunnel(atan(p.y, p.x), 2.0 * length(p));
}