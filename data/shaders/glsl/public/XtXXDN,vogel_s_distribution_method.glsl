// Shader downloaded from https://www.shadertoy.com/view/XtXXDN
// written by shadertoy user 4rknova
//
// Name: Vogel's Distribution Method
// Description: Vogel's distribution of points on a disk.
//    Based on [url=http://blog.marmakoide.org/?p=1	]Marmakoide's article[/url]
// by Nikos Papadopoulos, 4rknova / 2015
// WTFPL

#define E  5e-5
#define GA 2.39996322972865332
#define PI 3.14159265359
#define NS 512

vec2 sample(vec2 uv, float a, float i, float n)
{
    // The disk is divided to NS rings of equal areas
    // and each point is placed on the corresponding ring 
    // with a theta-offset by the golden angle.
    // Note that in the article quoted in the description,
    // r is calculated as sqrt(i / n). This spreads a few 
    // of the initial points unevenly. The method used 
    // below seems to produce better results.
    float r = sqrt((i+.5) / n)
        , t = i * a;
    // Convert from polar coordinates to cartesian.
    return r * vec2(cos(t), sin(t));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
    uv *= 1.1 * vec2(iResolution.x / iResolution.y, 1);
    
    vec3 col = vec3(0);
        
    for (int i = 0; i < NS; ++i)
    {
        vec2 p = sample(uv, GA, float(i), float(NS))
           , d = (p - uv);
        float x =  E / dot(d,d);
        col += vec3(x*x*x);
    }
    
	fragColor = vec4(col,1);
}