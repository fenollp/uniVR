// Shader downloaded from https://www.shadertoy.com/view/ltlGzf
// written by shadertoy user ChronosDragon
//
// Name: Things
// Description: kinda cool

#define t iGlobalTime
#define res iResolution
#define PI 3.141592654
#define octaves 5

float noise(vec2 uv)
{
    return texture2D(iChannel0, uv).r;
}

float perlin(vec2 uv)
{
    float n = 0.;
	for (int i = 0; i < octaves; ++i)
    {
        float a = 1. / pow(2., float(i));
        float f = pow(2., float(i - 4));
    	n += a * noise(uv * f);
    }
    
    return n / 2.;
}

float stars(vec2 uv)
{
    return pow(noise(uv), res.x / 100.0);
}

vec2 polar(vec2 rect)
{
 	float r = sqrt(dot(rect, rect));
    float th = atan(rect.y / rect.x);
    return vec2(r, th);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	vec2 uv = fragCoord.xy / res.yy;
    float aspect = res.x / res.y;
    vec2 uvc = (uv * 2.0) - vec2(aspect, 1.0);
    
	float n = stars(polar(uvc) + vec2(t, 0.0));
    n *= dot(uvc, uvc);
    
	fragColor = vec4(n, n, n, 1.0);
}