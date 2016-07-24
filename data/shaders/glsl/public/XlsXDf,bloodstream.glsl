// Shader downloaded from https://www.shadertoy.com/view/XlsXDf
// written by shadertoy user tsherif
//
// Name: Bloodstream
// Description: Flowing blood cells.
float map(in vec3 pos) {
    pos.z += iGlobalTime * 2.0;
    float a = sin(floor(pos.z / 12.0)) * 0.6;
    float cosa = cos(a);
    float sina = sin(a);
    mat2 m2 = mat2(cosa, -sina, sina, cosa);
    pos.xy = m2 * pos.xy;
    
    if (abs(pos.x) > 25.0 || abs(pos.y) > 25.0) {
       return 200.0;
    }
    
    vec3 c = mod(pos, 12.0) - 5.0;
    c.y += sin(c.z) * 1.5;
    
    float r = 2.0;
    r += 0.5 * sin(-pos.z + 0.1 * pos.x + 0.1 * pos.y + iGlobalTime * 4.0);
    
    float d = length(c) - r;
    
    
    return d;
}

vec3 calcNormal(in vec3 pos) {
    vec3 nor;
    vec2 e = vec2(0.01, 0.0);
    
    nor.x = map(pos + e.xyy) - map(pos - e.xyy);
    nor.y = map(pos + e.yxy) - map(pos - e.yxy);
    nor.z = map(pos + e.yyx) - map(pos - e.yyx);
    
    return normalize(nor);
}

vec3 getRefl(in vec3 ro, in vec3 rd) {
    float tmax = 20.0; 
    float t = 0.1;
    
    for (int i = 0; i < 32; i++) {
        vec3 pos = ro + t * rd;
        float h = map(pos);        
       
        if (t > tmax || h < 0.01) {
        	break;
        };
        
        t += h * 0.5;
    }
    
    vec3 pos = ro + t * rd;
    
    if (t > tmax) {
        return textureCube(iChannel1, rd).rgb;
    }
    
    vec3 light = normalize(vec3(1.0,1.0,0.5));
    
    vec3 nor = calcNormal(pos);
        
    vec3 mat = vec3(0.7, 0.0, 0.0);
    vec3 spec = vec3(1.0) * pow(max(dot(-rd, reflect(-light, nor)), 0.0), 100.0);
    vec3 diff = max(0.0, dot(light, nor)) * vec3(1.0);
    
    return mat * (diff + spec + 0.05) + 0.3;
}

vec3 getColor(in vec3 pos, in vec3 rd) {
    vec3 light = normalize(vec3(1.0,1.0,0.5));
    
    vec3 nor = calcNormal(pos);
        
    vec3 mat = vec3(0.7, 0.0, 0.0);
    vec3 refld = reflect(rd, nor);
    vec3 refl = getRefl(pos, refld) + 1.0;
    mat *= refl;   
    vec3 spec = vec3(1.0) * pow(max(dot(-rd, reflect(-light, nor)), 0.0), 100.0);
    vec3 diff = max(0.0, dot(light, nor)) * vec3(1.0);
    vec3 color = mat * (diff + spec + 0.05);
    
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = fragCoord.xy / iResolution.xy;
    
    vec2 pos = p * 2.0 - 1.0;
    
    pos.x *= iResolution.x / iResolution.y;
    
    float r = length(pos);
    float a = atan(pos.y, pos.x) + 0.3 * iGlobalTime;
    
    vec3 color = texture2D(iChannel0, vec2(1.0 / r + 0.8 * iGlobalTime + max(0.04 * sin(iGlobalTime * 4.0), 0.0), a)).rgb;
    color *= vec3(100.0, 0.2, 0.2);
    color = clamp(color, 0.0, 0.5);
    color = mix(vec3(0.0), color, smoothstep(0.1, 0.4, r)); 
        
    vec3 ro = vec3(0.0, 0.0, 0.0);
    a = 0.2 * sin(iGlobalTime * 0.2);
    float cosa = cos(a);
    float sina = sin(a);
    mat2 m2 = mat2(cosa, -sina, sina, cosa);
    vec3 rd = vec3(m2 * pos, -1.0);
    
    rd = normalize(rd);
    
    float tmax = 240.0;
    float t = 0.0;
    for (int i = 0; i < 256; i++) {
      	vec3 pos = ro + rd * t;
        
        float h = map(pos);
        if (h < 0.001 || t > tmax) break;
        t += h * 0.5;
    }
    
    
    
    if (t < tmax) {
        vec3 pos = ro + rd * t;
        color = getColor(pos, rd);
        float fog = exp(-0.00015 * t * t);
    	color = mix(vec3(0.0), color, fog);
    }
    
    color = sqrt(color);
    fragColor = vec4(color, 1.0);
}