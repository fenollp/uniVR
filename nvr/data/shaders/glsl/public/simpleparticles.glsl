// Shader downloaded from https://www.shadertoy.com/view/4stSWS
// written by shadertoy user chazbg
//
// Name: SimpleParticles
// Description: Particle emitter + fading
float dist2(vec2 a, vec2 b)
{
    return dot(a - b, a - b);
}

vec2 getDir(vec2 uv)
{
    float delta = 0.01;
    float n = texture2D(iChannel0, vec2(uv.x, uv.y + delta)).r;
    float s = texture2D(iChannel0, vec2(uv.x, uv.y - delta)).r;
    float e = texture2D(iChannel0, vec2(uv.x + delta, uv.y)).r;
    float w = texture2D(iChannel0, vec2(uv.x - delta, uv.y)).r;
    vec2 dir = normalize(vec2(e - w, n - s));
    return dir;
}

vec3 drawParticles(vec2 uv, vec2 ePos, vec2 dir, float time, float duration)
{
    vec3 col = vec3(0.0);
   	
    float r = 0.001;
    const int particleCount = 5;
    float delta = 3.0 / (duration * float(particleCount));
    
    
    for (int i = 0; i < particleCount; i++)
    {
        float offset = float(i) / float(particleCount);
        
        vec2 pPos = ePos + mod(offset + delta * time, 1.0) * dir;
    	float fade = (1.0 - dist2(pPos, ePos));
   		col += mix(vec3(0.2, 0.5, 0.1), vec3(0.0), smoothstep(0.0, r, dist2(uv, pPos))) * fade;
    }

    
    return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
	uv.x *= iResolution.x / iResolution.y;
    uv.x -= 0.4;
    
    fragColor = vec4(0.0);
	fragColor += vec4(drawParticles(uv, vec2(0.5, 0.0), vec2(0.0, 1.0),  mod(iGlobalTime, 3.0), 3.0),1.0);
    fragColor += vec4(drawParticles(uv, vec2(0.5, 0.0), vec2(1.0, 1.0),  mod(iGlobalTime, 4.0), 2.0),1.0);
    fragColor += vec4(drawParticles(uv, vec2(0.5, 0.0), vec2(-1.0, 1.0), mod(iGlobalTime, 3.0), 1.5),1.0);
}