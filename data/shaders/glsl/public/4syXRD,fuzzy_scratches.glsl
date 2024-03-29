// Shader downloaded from https://www.shadertoy.com/view/4syXRD
// written by shadertoy user Daedelus
//
// Name: Fuzzy scratches
// Description: Fuzzy scratches mask
// uniform float uWavyness;
// uniform vec2 uScale;
// uniform vec2 uOffset;
// uniform int uLayers;
// uniform vec2 uBaseFrequency;
// uniform vec2 uFrequencyStep;
#define uWavyness 0.1
#define uScale vec2(3.0, 3.0)
#define uOffset vec2(iGlobalTime, 0.0)
#define uLayers 4
#define uBaseFrequency vec2(0.5, 0.5)
#define uFrequencyStep vec2(0.25, 0.25)

void pR(inout vec2 p, float a)
{
    float sa = sin(a);
    float ca = cos(a);
    p *= mat2(ca, sa, -sa, ca);
}

float scratch(vec2 uv, vec2 seed)
{
    seed.x = floor(sin(seed.x * 51024.0) * 3104.0);
    seed.y = floor(sin(seed.y * 1324.0) * 554.0);
 
    uv = uv * 2.0 - 1.0;
    pR(uv, seed.x + seed.y);
    uv += sin(seed.x - seed.y);
    uv = clamp(uv * 0.5 + 0.5, 0.0, 1.0);
    
    float s1 = sin(seed.x + uv.y * 3.1415) * uWavyness;
    float s2 = sin(seed.y + uv.y * 3.1415) * uWavyness;
    
    float x = sign(0.01 - abs(uv.x - 0.5 + s2 + s1));
    return clamp(((1.0 - pow(uv.y, 2.0)) * uv.y) * 2.5 * x, 0.0, 1.0);
}

float layer(vec2 uv, vec2 frequency, vec2 offset, float angle)
{
    pR(uv, angle);
    uv = uv * frequency + offset;
    return scratch(fract(uv), floor(uv));
}

float scratches(vec2 uv)
{
    uv *= uScale;
    uv += uOffset;
    vec2 frequency = uBaseFrequency;
    float scratches = 0.0;
    for(int i = 0; i < uLayers; ++i)
    {
        float fi = float(i);
    	scratches += layer(uv, frequency, vec2(fi, fi), fi * 3145.0);
        frequency += uFrequencyStep;
    }
    return scratches;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = (2.0 * fragCoord.xy - iResolution.xy) / iResolution.y;
    
    // using AA by Shane:
    // https://www.shadertoy.com/view/4d3SWf
    const float AA = 4.; // Antialias level. Set to 1 for a standard, aliased scene.
    const int AA2 = int(AA*AA);
    float col = 0.0;
    vec2 pix = 2.0/iResolution.yy/AA; // or iResolution.xy
    for (int i=0; i<AA2; i++){ 

        float k = float(i);
        vec2 uvOffs = uv + vec2(floor(k/AA), mod(k, AA)) * pix;
        col += scratches(uvOffs);
    }
    col /= (AA*AA);
	
	fragColor = vec4(col);
}