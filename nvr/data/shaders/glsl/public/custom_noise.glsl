// Shader downloaded from https://www.shadertoy.com/view/4sdSzN
// written by shadertoy user pixartist
//
// Name: Custom Noise
// Description: A combination of two widely used noise algorithms, with a custom seed algorithm. No idea about the mathematical value of this, but I have used it for quite long path-tracing implementations and it proved to produce nearly zero randomization artefacts.

float seed = 0.0;
void init(vec2 uv)
{
    seed = (uv.y + iGlobalTime * 0.523413187) * sqrt(uv.x * 0.77777777 * iGlobalTime);
}

float rand(vec2 s) 
{ 
    float n = fract(sin(seed+=1.0)*43758.5453123);
    return fract(n + fract(sin(dot(vec2(n * s.y, s.x)*0.123,vec2(12.9898,78.233))) * 43758.5453));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    init(uv);
    
	fragColor = vec4(rand(uv));
}