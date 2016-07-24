// Shader downloaded from https://www.shadertoy.com/view/XlBGRt
// written by shadertoy user SmartPointer
//
// Name: JuliaSet3000
// Description: The awesome JuliaSet
const int maxIt = 300;
vec2 c = vec2(-0.73, 0.27015);
//vec2 c = vec2(0.39, 0.1);

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    c.x += sin(c.y * 2.0 + iGlobalTime * 0.2) / 20.0;
    vec2 z, oldz;
    z.x = 2.0 * (fragCoord.x - iResolution.x / 2.0) / (0.55 * iResolution.x);
    z.y = (fragCoord.y - iResolution.y / 2.0) / (0.55 * iResolution.y);

    int k = 0;
	for (int i = 0; i < maxIt; i++)
	{
		oldz.x = z.x;		// x = real
		oldz.y = z.y;		// y = imaginary

		z.x = (oldz.x * oldz.x) - (oldz.y * oldz.y) + c.x;
		z.y = (2.0 * oldz.x * oldz.y) + c.y;

		if ((z.x * z.x + z.y * z.y) > 4.0)
        {
            k = i;
            break;
        }
	}

	float h = (1.0 / float(maxIt)) * float(k);

	fragColor = vec4(hsv2rgb(vec3(h, 1.0, 1.0)), 1.0);
}
