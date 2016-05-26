// Shader downloaded from https://www.shadertoy.com/view/XtsXRn
// written by shadertoy user dgreensp
//
// Name: Cheap Fractal Noise
// Description: Cheap, simple, fractal noise based on iq's https://www.shadertoy.com/view/4sfGzS
float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.-2.*f);
	
    float n = p.x + p.y*157. + 113.*p.z;
    
    vec4 v1 = fract(753.5453123*sin(n + vec4(0., 1., 157., 158.)));
    vec4 v2 = fract(753.5453123*sin(n + vec4(113., 114., 270., 271.)));
    vec4 v3 = mix(v1, v2, f.z);
    vec2 v4 = mix(v3.xy, v3.zw, f.y);
    return mix(v4.x, v4.y, f.x);
}

float fnoise(vec3 p) {
  // random rotation reduces artifacts
  p = mat3(0.28862355854826727, 0.6997227302779844, 0.6535170557707412,
           0.06997493955670424, 0.6653237235314099, -0.7432683571499161,
           -0.9548821651308448, 0.26025457467376617, 0.14306504491456504)*p;
  return dot(vec4(noise(p), noise(p*2.), noise(p*4.), noise(p*8.)),
             vec4(0.5, 0.25, 0.125, 0.06));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.yy;
    vec3 p = vec3(uv*16., 0.);
    float result = fnoise(p);
	fragColor = vec4(vec3(result),1.0);
}