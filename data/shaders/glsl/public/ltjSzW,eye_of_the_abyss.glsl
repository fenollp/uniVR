// Shader downloaded from https://www.shadertoy.com/view/ltjSzW
// written by shadertoy user tsherif
//
// Name: Eye of the Abyss
// Description: Playing around with the space inversion function from here: https://www.shadertoy.com/view/4dsGD7
float time;

float mapSphere(in vec3 pos) {
    float r = 1.7;
   
   	float a = sin(time * 0.1);
    float cosa = cos(a);
    float sina = sin(a);
    mat3 rotz = mat3(
        cosa, -sina, 0.0,
        sina, cosa, 0.0,
        0.0, 0.0, 1.0
    );
    
    pos = rotz * pos;
    float d = length(pos) - r;

    d += 0.1 * (sin(pos.x * 10.0 + time) + cos(pos.y * 10.0 + time)  + sin(pos.z * 10.0 + time));
    d = d / (dot(pos, pos) * 2.0);
    
    return d;
}

float map(in vec3 pos) {
    return mapSphere(pos);
}

vec3 calcNormal(in vec3 pos) {
    vec3 nor;
    vec2 e = vec2(0.01, 0.0);
    
    nor.x = map(pos + e.xyy) - map(pos - e.xyy);
    nor.y = map(pos + e.yxy) - map(pos - e.yxy);
    nor.z = map(pos + e.yyx) - map(pos - e.yyx);
    
    return normalize(nor);
}

vec3 getColor(in vec3 pos, in vec3 rd) {
    vec3 light = normalize(vec3(1.0,1.0,0.5));
    
    float ri = length(pos.xy * vec2(12.0, 2.2));
    float ro = length(pos);
    float a = atan(pos.y, pos.x);
    
    vec3 nor = calcNormal(pos);
    vec3 refl = textureCube(iChannel0, reflect(rd, nor)).rgb;
    vec3 mat = mix(vec3(0.0), vec3(0.5, 0.0, 0.0), smoothstep(0.4, 1.2, ri  + sin(a * 40.0) * 0.15));
    mat = mix(mat, vec3(0.8), smoothstep(1.8, 3.0, ri  + sin((a + time * 0.1) * 10.0) * 0.2));
    mat = mix(mat, vec3(0.05), smoothstep(3.0, 3.5, ro));
    vec3 spec = vec3(1.0) * pow(max(dot(-rd, reflect(-light, nor)), 0.0), 100.0);
    vec3 diff = max(0.0, dot(light, nor)) * vec3(1.0);
    vec3 color = mat * (refl * diff + spec + 0.4);
    
    return color;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 p = fragCoord.xy / iResolution.xy;
    vec2 pos = p * 2.0 - 1.0;
    pos.x *= iResolution.x / iResolution.y;
    time = mod(iGlobalTime, 3000.0);
    
    float r = length(pos);
    float a = atan(pos.y, pos.x);
            
    vec3 ro = vec3(0.0, 0.0, 3.0);
    vec3 rd = vec3(pos, -1.0);
    
    rd = normalize(rd);
    
    vec3 color = textureCube(iChannel0, rd).rgb;
    
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
    }
    
    color = sqrt(color);
    fragColor = vec4(color, 1.0);
}