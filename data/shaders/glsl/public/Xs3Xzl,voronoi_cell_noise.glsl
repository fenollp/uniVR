// Shader downloaded from https://www.shadertoy.com/view/Xs3Xzl
// written by shadertoy user zenex
//
// Name: Voronoi cell noise
// Description: Voronoi noise function with random solid cell colors and cell distance calculation
// Voronoi cell noise function visualizer
// MIT license

vec2 rand2(vec2 p)
{
	vec2 q = vec2(dot(p, vec2(120.0, 300.0)), dot(p, vec2(270.0, 401.0)));
	return fract(sin(q) * 46111.1111);
}

float rand(vec2 p)
{
	return fract(sin(dot(p, vec2(445.5, 360.535))) * 812787.111);
}

// distortion [0..1], where 0.0 == squares, and 1.0 == irregular shapes
vec2 voronoi(in vec2 pos, float distortion)
{
	vec2 cell = floor(pos);
	vec2 cellOffset = fract(pos);
    float borderDist = 8.0;
    float color;
    
	// sample nearby cells
	for (int x=-1; x<=1; x++)
    {
        for (int y=-1; y<=1; y++)
        {
            vec2 samplePos = vec2(float(y), float(x));
            vec2 center = rand2(cell + samplePos) * distortion;
            vec2 r = samplePos - cellOffset + center;
            float d = dot(r, r);
            float col = rand(cell + samplePos);

            if (d < borderDist)
            {
                borderDist = d;
                color = col;
            }
        }
    }
    
    // calc border distance
    borderDist = 8.0;
    for (int j=-1; j<=1; j++)
    {
        for (int i=-1; i<=1; i++)
        {
            vec2 samplePos = vec2(float(i),float(j));
            vec2 center = rand2(cell + samplePos) * distortion;
            vec2 r = samplePos + center - cellOffset;

            if (dot(r, r) > 0.000001)
            {
                borderDist = min(borderDist, dot(0.5 * r, normalize(r)));
            }
        }
    }
    return vec2(color, borderDist);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xx;
	vec2 noise = voronoi(8.0 * uv, 1.0);
    fragColor = vec4(noise.y, noise.y, noise.x, 1.0);
}