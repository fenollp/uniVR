// Shader downloaded from https://www.shadertoy.com/view/XsKGzK
// written by shadertoy user kzy
//
// Name: Ripple shader
// Description: Press W + click and drag to draw walls.
//    Press Q to reset.
#define BUFFER_U iChannel0

#define LIGHT vec3(3.0, 2.0, -2.0)
#define DEPTH 0.5

#define USE_BACKGROUND

float unpack(const in vec4 value)
{
    return value.a;
}

float get(in sampler2D tex, in vec2 uv)
{
    return unpack(texture2D(tex, uv));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 p = 1.0 / iResolution.xy;
    
    float p0 = get(BUFFER_U, uv + p * vec2(-1, 0));
    float p1 = get(BUFFER_U, uv + p * vec2( 1, 0));
    float p2 = get(BUFFER_U, uv + p * vec2( 0,-1));
    float p3 = get(BUFFER_U, uv + p * vec2( 0, 1));
	
    vec3 n = normalize(vec3(2.0 * (p0 - p1), 1.0, 2.0 * (p2 - p3)));

#ifdef USE_BACKGROUND
    vec3 c = texture2D(iChannel1,uv + n.xz * DEPTH).xyz;
#else
    vec3 c = vec3(dot(n, normalize(LIGHT)));
#endif
    if (texture2D(iChannel2, uv).a > 0.0)
    	c = texture2D(iChannel3, uv).xyz;
    
    fragColor = vec4(c, 1);
}