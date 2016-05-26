// Shader downloaded from https://www.shadertoy.com/view/XdcXzH
// written by shadertoy user bleedingtiger2
//
// Name: Simple Perlin 2D 
// Description: Simple Perlin-like noise in 2D, homemade custom algorithm. Not perfect but easy to understand for learning.
#define _PerlinPrecision 8.0
#define _PerlinOctaves 8.0
#define _PerlinSeed 0.0


float rnd(vec2 xy)
{
    return fract(sin(dot(xy, vec2(12.9898-_PerlinSeed, 78.233+_PerlinSeed)))* (43758.5453+_PerlinSeed));
}
float inter(float a, float b, float x)
{
    //return a*(1.0-x) + b*x; // Linear interpolation

    float f = (1.0 - cos(x * 3.1415927)) * 0.5; // Cosine interpolation
    return a*(1.0-f) + b*f;
}
float perlin(vec2 uv)
{
    float a,b,c,d, coef1,coef2, t, p;

    t = _PerlinPrecision;					// Precision
    p = 0.0;								// Final heightmap value
    uv.x += sin(iGlobalTime*0.2)*0.4 + 3.0;	// Used for camera movement
    uv.y += iGlobalTime*0.1;

    for(float i=0.0; i<_PerlinOctaves; i++)
    {
        a = rnd(vec2(floor(t*uv.x)/t, floor(t*uv.y)/t));	//	a----b
        b = rnd(vec2(ceil(t*uv.x)/t, floor(t*uv.y)/t));		//	|    |
        c = rnd(vec2(floor(t*uv.x)/t, ceil(t*uv.y)/t));		//	c----d
        d = rnd(vec2(ceil(t*uv.x)/t, ceil(t*uv.y)/t));

        if((ceil(t*uv.x)/t) == 1.0)
        {
            b = rnd(vec2(0.0, floor(t*uv.y)/t));
            d = rnd(vec2(0.0, ceil(t*uv.y)/t));
        }

        coef1 = fract(t*uv.x);
        coef2 = fract(t*uv.y);
        p += inter(inter(a,b,coef1), inter(c,d,coef1), coef2) * (1.0/pow(2.0,(i+0.6)));
        t *= 2.0;
    }
    return p;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.x;
    
    float p = perlin(uv * (0.6+cos(iGlobalTime*0.4)*0.15)); // Zoom animation
    
    if(p<0.4) // Water
        fragColor = vec4(0.05, 0.75, 1.0, 1.0);
    else if(p<0.45) // Sand
        fragColor = vec4(0.870588, 0.721569, 0.529412, 1.0) + p*0.5;
    else if(p<0.85) // Grass
        fragColor = vec4(0.13333, 0.5451, 0.13333, 1.0) + p*0.25;
    else if(p<0.999) // Rock
        fragColor = vec4(0.5, 0.5, 0.5, 1.0) * ((p-0.75)*7.0);
    else // Snow
        fragColor = vec4(0.9, 0.95, 0.95, 1.0) + p*0.2;
}