// Shader downloaded from https://www.shadertoy.com/view/lsVSWz
// written by shadertoy user Zavie
//
// Name: Another Voronoi
// Description: A Voronoi / Worley implementation, based upon the legions of experiments by IQ and Fabrice Neyret.
//
// A Voronoi implementation, featuring some of the tricks seen
// in other shaders.
//

float hash(float x) { return fract(sin(x) * 43758.5453); }
float hash(vec2 xy) { return fract(sin(dot(xy, vec2(12.9898, 78.233))) * 43758.5453); }
vec2 hash2(vec2 xy) { return fract(sin(vec2(dot(xy, vec2(127.1,311.7)), dot(xy, vec2(269.5,183.3)))) * 43758.5453); }

struct VoronoiInfo
{
    float f1;
    float f2;
    float id;
    vec2 pos;
};

VoronoiInfo Voronoi(vec2 uv, float randomness, float norm)
{
    vec2 iuv = floor(uv);
    float f1 = 1e30;
    float f2 = 1e30;
    float id = -1.;
    vec2 pos = vec2(0.);

    for (int j = -1; j <= 1; ++j)
    for (int i = -1; i <= 1; ++i)
    {
        vec2 cell = iuv + vec2(float(i), float(j));
        vec2 p = cell + mix(vec2(0.5), hash2(cell), randomness);
        float cellId = hash(cell);

        vec2 delta = abs(p - uv);
        float d1 = delta.x + delta.y;				// Manhattan
        float d2 = length(delta);					// Euclid
        float dInfinite = max(delta.x, delta.y);	// Chebychev

        float d = 0.;
        if (norm <= 1.)      d = mix(d1, d2, norm);
        else if (norm <= 2.) d = mix(d2, dInfinite, norm - 1.);
        else if (norm <= 3.) d = mix(dInfinite, d1, norm - 2.);

        if (d < f1)
        {
            f2 = f1;
            f1 = d;
            id = cellId;
            pos = p;
        }
        else if (d < f2)
        {
            f2 = d;
        }
    }
	return VoronoiInfo(f1, f2, id, pos);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    float randomness = mix(0.2, 1., smoothstep(0., 1., abs(2. * fract(0.2*iGlobalTime - 0.5*uv.x) - 1.)));
    VoronoiInfo vi = Voronoi(10.*uv, randomness, 3.*fract(0.25*iGlobalTime));
    
    vec3 baseColor = mix(vec3(0.19, 0.53, 0.11), vec3(0.66, 0.15, 0.2), hash(vi.id));
    float cellDot = smoothstep(0.05, 0.1, length(10.*uv - vi.pos));

    fragColor = vec4(mix(vec3(1.), baseColor, pow(vi.f2 - vi.f1, 0.2)) * cellDot, 1.0);
}