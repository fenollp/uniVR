// Shader downloaded from https://www.shadertoy.com/view/MtlXWj
// written by shadertoy user tsherif
//
// Name: Attack of the Space Slugs
// Description: Took the terrain from the SIGGRAPH 2015 Shadertoy workshop and added some flying slugs to it.
//    
//    Click and drag to look around.
float sinNoise(in vec2 pos) {
  return 0.5 * (sin(pos.x) + sin(pos.y));
}

const mat2 m2 = mat2(0.8, -0.6, 0.6, 0.8);

float mapH(in vec3 pos) {
    float h = 0.0;
    vec2 q = pos.xz * 0.5;
    float s = 0.5;
    for (int i = 0; i < 12; i++){
        h += s * sinNoise(q);
        s *= 0.49;
        q = m2 * q * 1.7;
    }
    
    return pos.y - h * 3.0;
}

float mapS(in vec3 pos) {
    pos.z -= iGlobalTime * 2.0;
    vec3 c = mod(pos, 10.0) - 4.0;
    c.y = pos.y - 6.0 + sin(iGlobalTime * 2.0 + pos.z * 2.5 + pos.x);
    float r = 1.0;
    float d = length(c) - r;
    
    d += 0.1 * sin(pos.x * 10.0 + iGlobalTime) * sin(pos.y * 10.0 + iGlobalTime) * sin(pos.z * 10.0 + iGlobalTime);
    
    return d;
}

float map(in vec3 pos) {
    return min(mapH(pos), mapS(pos));   
}

vec3 calcNormal(in vec3 pos) {
    vec3 nor;
    vec2 e = vec2(0.01, 0.0);
    
    nor.x = map(pos + e.xyy) - map(pos - e.xyy);
    nor.y = map(pos + e.yxy) - map(pos - e.yxy);
    nor.z = map(pos + e.yyx) - map(pos - e.yyx);
    
    return normalize(nor);
}

float calcShadow(vec3 ro, vec3 rd) {
    float res = 1.0;
    
    float t = 0.1;
    
    for (int i = 0; i < 16; i++) {
        vec3 pos = ro + t * rd;
        float h = map(pos);
        res = min(res, 10.0 * max(h, 0.0) / t);
        
        if (res < 0.1) break;
        
        t += h;
    }
    
    return max(res, 0.1);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pos = fragCoord.xy / iResolution.xy;
    vec2 mouse = iMouse.xy / iResolution.xy;
    
    pos = pos * 2.0 - 1.0;
    mouse = mouse * 2.0 - 1.0;
    
    pos.x *= iResolution.x / iResolution.y;
    mouse.x *= iResolution.x / iResolution.y;
    
    vec3 color = vec3(0.7, 0.8, 0.9);    
    vec3 ro = vec3(0.0, 2.0, 1.0 * -iGlobalTime);
    vec3 rd = vec3(pos, -1.0);
    
    if (iMouse.x > 0.0) {
    	rd.xy += mouse;
    }
    
    rd = normalize(rd);
    
    color *= 1.0 - 0.5 * rd.y;

    
    float tmax = 80.0;
    float t = 0.0;
    
    for (int i = 0; i < 256; i++) {
      vec3 pos = ro + rd * t;
        float h = map(pos);
        if (h < 0.001 || t > tmax) break;
        t += h * 0.5;
    }
    
    vec3 light = normalize(vec3(1.0,1.0,0.5));
    
    if (t < tmax) {
        vec3 pos = ro + rd * t;
        vec3 nor = calcNormal(pos);
        float sha = calcShadow(pos + nor * 0.1, light);
        vec3 spec = vec3(0.0);
        
        vec3 mat;
        if (pos.y > 3.0) {
            mat = vec3(1.0, 0.7, 0.6);
            spec = vec3(1.0) * pow(max(dot(-rd, reflect(-light, nor)), 0.0), 100.0);
        } else {
            mat = vec3(0.5, 0.2, 0.1);
        	mat = mix(mat, vec3(0.2, 0.5, 0.1), smoothstep(0.7, 0.9, nor.y));
        }
        
        vec3 diff = max(0.0, dot(light, nor)) * vec3(1.0) * sha;
        color = mat * (diff + spec);
        
        float fog = exp(-0.001 * t * t);
        color = mix(vec3(0.6, 0.7, 0.8), color, fog);
    }
    
    color = sqrt(color);
    
    fragColor = vec4(color, 1.0);
}