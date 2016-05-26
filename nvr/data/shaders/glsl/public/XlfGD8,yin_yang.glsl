// Shader downloaded from https://www.shadertoy.com/view/XlfGD8
// written by shadertoy user 4rknova
//
// Name: Yin-Yang
// Description: Yin Yang
// by Nikos Papadopoulos, 4rknova / 2015
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define AA 4.                  // Anti-aliasing
#define OL .075                // The outline width
#define SC 1.1                 // Scale
#define BG vec3(.15, .20, .25) // Background Color
#define S0 vec3(1)             // Dark Color
#define S1 vec3(0)             // Light Color
#define S3 vec3(0)             // Ring Color

// 0.0 : Outside the shape
// 0.5 : Inside the shape, dark area
// 1.0 : Inside the shape, light area
// 2.0 : Ring
float yinyang(vec2 p)
{
    vec4 c = vec4(.0, .03125, .25, .5);
    vec4 s = p.xyxy + c.xwxx - c.xxxw;
    vec3 d = vec3(dot(p,p), dot(s.xy, s.xy), dot(s.zw, s.zw));
    
    float r = step(step(d.y, c.z) - step(d.z, c.z) + ceil(p.x), c.w)
                 + step(d.y, c.y) - step(d.z, c.y);

    return
#ifdef OL       
          step(d.x, 1.) - step(d.x, 1. + OL) < 0. ? 2. :
#endif /* OL */
          step(d.x, 1.) * c.w * (1. + ceil(r));
}

vec3 sample(vec2 p)
{
    float c = yinyang(p);
    
    if      (c == 2.) return S3;
    else if (c == 1.) return S0;
    else if (c == .5) return S1;
	return BG;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.)
            * vec2(iResolution.x / iResolution.y, 1.)
        	* SC;
    
    vec3 c = vec3(0);
    
#ifdef AA
    // Antialiasing via supersampling
    float e = 1. / min(iResolution.y , iResolution.x);
    for (float i = -AA; i < AA; ++i) {
        for (float j = -AA; j < AA; ++j) {
            c += sample(uv + vec2(i, j) * (e/AA)) / (4.*AA*AA);
        }
    }
#else
    c = sample(uv);

#endif /* AA */
    
    fragColor = vec4(c, 1);
}