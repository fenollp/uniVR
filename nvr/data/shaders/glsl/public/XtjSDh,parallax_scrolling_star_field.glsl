// Shader downloaded from https://www.shadertoy.com/view/XtjSDh
// written by shadertoy user AxleMike
//
// Name: Parallax Scrolling Star Field
// Description: A rough parallax scrolling star field.
// By Alexander Lemke, 2015
// Voronoi and fractal noise functions based on iq's https://www.shadertoy.com/view/MslGD8

float Hash(in vec2 p)
{
	float h = dot(p, vec2(12.9898, 78.233));
    return -1.0 + 2.0 * fract(sin(h) * 43758.5453);
}

vec2 Hash2D(in vec2 p)
{
	float h = dot(p, vec2(12.9898, 78.233));
    float h2 = dot(p, vec2(37.271, 377.632));
    return -1.0 + 2.0 * vec2(fract(sin(h) * 43758.5453), fract(sin(h2) * 43758.5453));
}

float Noise(in vec2 p)
{
    vec2 n = floor(p);
    vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(mix(Hash(n), Hash(n + vec2(1.0, 0.0)), u.x),
               mix(Hash(n + vec2(0.0, 1.0)), Hash(n + vec2(1.0)), u.x), u.y);
}

float FractalNoise(in vec2 p)
{
    p *= 5.0;
    mat2 m = mat2(1.6,  1.2, -1.2,  1.6);
	float f = 0.5000 * Noise(p); p = m * p;
	f += 0.2500 * Noise(p); p = m * p;
	f += 0.1250 * Noise(p); p = m * p;
	f += 0.0625 * Noise(p); p = m * p;
    
    return f;
}

vec3 Voronoi(in vec2 p)
{
    vec2 n = floor(p);
    vec2 f = fract(p);

	vec2 mg, mr;

    float md = 8.0;
    for(int j = -1; j <= 1; ++j)
    {
        for(int i = -1; i <= 1; ++i)
        {
            vec2 g = vec2(float(i), float(j));
            vec2 o = Hash2D(n + g);

            vec2 r = g + o - f;
            float d = dot(r, r);

            if(d < md)
            {
                md = d;
                mr = r;
                mg = g;
            }
        }
    }
	return vec3(md, mr);
}

vec3 ApplyFog(in vec2 texCoord)
{
    vec3 finalColor = vec3(0.0);
    
    vec2 samplePosition = (4.0 * texCoord.xy / iResolution.xy) + vec2(0.0, iGlobalTime * 0.0025);
    float fogAmount = FractalNoise(samplePosition) * 0.175;
        
    vec3 fogColor = vec3(texCoord.xy / iResolution.xy + vec2(0.5, 0.0), sin(iGlobalTime) * 0.25 + 0.5);
    finalColor = fogColor * fogAmount * vec3(sin(iGlobalTime) * 0.00125 + 0.75);  
    
    return finalColor;
}

vec3 AddStarField(vec2 samplePosition, float threshold)
{
    vec3 starValue = Voronoi(samplePosition);
    if(starValue.x < threshold)
    {
        float power = 1.0 - (starValue.x / threshold);
        return vec3(power * power * power);
    }
    return vec3(0.0);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float maxResolution = max(iResolution.x, iResolution.y);
    
	vec3 finalColor = ApplyFog(fragCoord.xy);
    
    // Add Star Fields
    vec2 samplePosition = (fragCoord.xy / maxResolution) + vec2(0.0, iGlobalTime * 0.01);
    finalColor += AddStarField(samplePosition * 16.0, 0.00125);
    
    samplePosition = (fragCoord.xy / maxResolution) + vec2(0.0, iGlobalTime * 0.004);
    finalColor += AddStarField(samplePosition * 20.0, 0.00125);
    
    samplePosition = (fragCoord.xy / maxResolution) + vec2(0.0, iGlobalTime * 0.0005 + 0.5);
    finalColor += AddStarField(samplePosition * 8.0, 0.0007);
    
    fragColor = vec4(finalColor, 1.0);
}