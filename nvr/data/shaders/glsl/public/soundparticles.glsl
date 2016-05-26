// Shader downloaded from https://www.shadertoy.com/view/XdcSWS
// written by shadertoy user chazbg
//
// Name: SoundParticles
// Description: Scale and transform particles based on the low frequency sound value
vec3 drawCircle(vec2 pos, float r, vec3 color, vec2 uv)
{
    float t = r - length(uv - pos);
    return mix(vec3(0), color, smoothstep(0.0, 0.08, t)); 
}

float rand(float val, float seed){
	return cos(val*sin(val*seed)*seed);	
}

vec2 getParticlePos(float t, float phase, float freq, float r)
{
    float time = (t + phase) * freq;
    return vec2(sin(time), cos(time)) * r / 2.0 + 0.5;
}
     
vec3 drawParticle(vec2 pos, vec3 color, float time, float timelength)
{
	vec3 col= vec3(0.0);
    float seed = 1.0;
    vec2 pp = vec2(1.0,0.0);
    for(float i=1.0;i<=128.0;i++){
        float d=rand(i, seed);
        float fade=(i/128.0)*time;
        vec2 particpos = vec2(0.5) + time*pp*d;
        //pp = rr*pp;
        col = mix(color/fade, col, smoothstep(0.0, 0.0001, 0.1 - length(particpos - pos)));
    }
    col*=smoothstep(0.0,1.0,(timelength-time)/timelength);
	
    return col; 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float bass = texture2D(iChannel0, vec2(0, 0)).y;
    
    vec2 uv = fragCoord.xy / iResolution.xy;
	uv.x *= iResolution.x / iResolution.y;
    uv.x -= 0.5;

    fragColor = vec4(0,0,0,1);
	fragColor += vec4(drawCircle(getParticlePos(iGlobalTime, 0.0 + 0.3 * bass, 0.75, 0.2), 0.12 * bass, vec3(0.1, 0.5, 0.2), uv),1.0);
    fragColor += vec4(drawCircle(getParticlePos(iGlobalTime, 0.4 + 0.3 * bass, 0.5 , 0.5), 0.17 * bass, vec3(0.1, 0.5, 0.2), uv),1.0);
    fragColor += vec4(drawCircle(getParticlePos(iGlobalTime, 0.8 + 0.3 * bass, 0.25, 0.7), 0.15 * bass, vec3(0.1, 0.5, 0.2), uv),1.0);
    fragColor += vec4(drawCircle(getParticlePos(iGlobalTime, 1.2 + 0.3 * bass, 0.40, 0.8), 0.10 * bass, vec3(0.1, 0.5, 0.2), uv),1.0);
	fragColor += vec4(drawParticle(uv, vec3(0.1, 0.5, 0.2), mod(iGlobalTime, 3.0), 2.0), 1.0);
}