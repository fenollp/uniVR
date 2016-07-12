// Shader downloaded from https://www.shadertoy.com/view/XljXDV
// written by shadertoy user hughsk
//
// Name: 2015/11/07
// Description: Expanding on 2015/11/04: https://www.shadertoy.com/view/Xt2SDV
//    
//    This adds multiple colored point lights, makes the circles a little more disorderly and blobs them in from the edges.
#define STEPS 80

#define sr(a) (a * 2.0 - 1.0)
#define rs(a) (a * 0.5 + 0.5)
#define sq(a) (a * vec2(1, iResolution.y / iResolution.x))

float random(vec2 co) {
   return fract(sin(dot(co.xy,vec2(12.9898,78.233))) * 43758.5453);
}

float smin(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

float sdBox( vec2 p, vec2 b )
{
  vec2 d = abs(p) - b;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float t = iGlobalTime * 1.;

float map(vec2 p, vec4 ro) {
    vec2 P = p;
    
    float w = 0.15;
    float r = 0.03125;
    float a = t;
    float d = 0.0;
    
    p.y += iGlobalTime * 0.15;
    
    vec2 idx = floor(p / w * 0.5 + 0.5);
    
    r += sin((idx.x + idx.y) * 2. + t * 5.) * 0.009;
    a += sin((idx.x + idx.y) * 2.);
    a += random(idx) * 5.;
    
    p = mod(p + w, w * 2.) - w;
    d = length(p - 0.095 * vec2(sin(a), cos(a))) - r;
    d = smin(d, length(P) - 0.25, 0.05);
    
    // "push" away any surfaces close to the lights
    d = -smin(-d, length(P - ro.xy) - 0.05, 0.05);
    d = -smin(-d, length(P - ro.zw) - 0.075, 0.05);
    d = smin(d, -sdBox(P, sq(vec2(1))), 0.065);
    
	return d;
}

float shadow(vec2 uv, vec2 ro, vec2 rd, vec4 lights) {
    float lim = 0.0005;
    float res = -1.0;
    float inc = lim * 2.0;
    float t = inc;
    float maxt = length(ro - uv);
    
    if (map(uv, lights) < 0.0) return 0.0;
    
    for (int i = 0; i < STEPS; i++) {
        if (t >= maxt) return -1.0;
        float d = map(uv - rd * t, lights);
        if (d <= 0.0) return 0.0;
        
        t = min(t + d * 0.2, maxt);
        res = t;
    }
    
    return res;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = sq(sr(fragCoord.xy / iResolution.xy));
    vec2 ro1 = (iMouse.z > 0.
        ? sq(sr(iMouse.xy / iResolution.xy))
        : 0.5 * vec2(
            sin(iGlobalTime),
            cos(iGlobalTime)
        ));
    
    vec2 ro2 = (sin(iGlobalTime * 0.2) + 2.5) * 0.15 * vec2(cos(iGlobalTime), sin(iGlobalTime));
    vec4 lights = vec4(ro1, ro2);
    
    vec2 rd1 = normalize(uv - ro1);
    vec2 rd2 = normalize(uv - ro2);
    float s1 = shadow(uv, ro1, rd1, lights) > -0.5 ? 0.35 : 1.0;
    float s2 = shadow(uv, ro2, rd2, lights) > -0.5 ? 0.35 : 1.0;
    float l1 = s1 * pow(max(0.0, 1.0 - length(ro1 - uv) * 0.8), 2.5);
    float l2 = s2 * pow(max(0.0, 1.0 - length(ro2 - uv) * 0.8), 2.5);
    float d = map(uv, lights);
    
    vec3 lcol1 = vec3(1, 0.5, 0.3);
    vec3 lcol2 = vec3(0, 1, 1);
    
    bool inside = d < 0.0;
    bool stroke = d > -0.005 && inside; 
    vec3 m = inside ? vec3(stroke ? 0 : 5) : vec3(1, 0.9, 0.7);
    
	fragColor = vec4(m * (l1 * lcol1 + l2 * lcol2), 1);
}