// Shader downloaded from https://www.shadertoy.com/view/4dt3WB
// written by shadertoy user hughsk
//
// Name: 2016/01/06
// Description: Could still use some polish, but fun all the same ✨
#define SAMPLES 30
#define DENSITY 0.365
#define WEIGHT 0.95
#define DECAY 0.84

float random(vec2 co) {
   return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 pass = texture2D(iChannel0, uv);
    vec3 color = pass.rgb + pass.a;
    vec2 glowOrigin = vec2(0.0);
    
    vec2 dUV = (uv * 2.0 - 1.0) - glowOrigin;
    dUV *= 1.0 / float(SAMPLES) * DENSITY;
    
    vec2 sUV = uv;
    float decay = 1.0;
    float glow = 0.0;
    float amp = max(
        texture2D(iChannel1, vec2(0.6, 0.25)).r,
        texture2D(iChannel1, vec2(0.2, 0.25)).r
    );
    
    for (int i = 0; i < SAMPLES; i++) {
      sUV -= dUV;
      float data = texture2D(iChannel0, sUV).a;
      data *= decay * WEIGHT;
      glow += data * mix(0.4, 1.0, random(sUV + sin(iGlobalTime)));
      decay *= DECAY;
    }
    
    color += amp * glow * vec3(1.3, 1.2, 1);
    color = pow(color, vec3(1.1));
    color += vec3(0.05 + uv.x * 0.11, 0.08, 0.11);
    color.r = smoothstep(0.0, 0.9, color.r);
    color.b = smoothstep(-0.1, 0.9, color.b);
    color *= 1.0 - dot(uv = uv * 2. - 1., uv) * vec3(0.05, 0.15, -0.05);
    color += (random(uv + sin(iGlobalTime)) * 2.0 - 1.0) * 0.01;
	fragColor = vec4(color, 1);
}