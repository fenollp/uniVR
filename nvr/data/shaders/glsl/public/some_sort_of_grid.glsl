// Shader downloaded from https://www.shadertoy.com/view/llXGD2
// written by shadertoy user germangb
//
// Name: Some sort of grid
// Description: Raymarching experiment #1
#define MAX_STEPS 150

float smin( float a, float b, float k ) {
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
}

float scene (vec3 pos) {
    vec3 old = pos;
    pos.y += sin(1.0*pos.x/6.0 * 6.283 + iGlobalTime) * 0.125;
    pos.y += sin(1.0*pos.z/6.0 * 6.283 + iGlobalTime) * 0.25;
    pos.x += sin(2.0*pos.y/6.0 * 6.283 + iGlobalTime) * 0.125;
    pos = mod(pos, vec3(6.0));
    float thick = 0.5;
    vec3 d =  abs(pos - vec3(3.0, 3.0, 3.0)) - vec3(thick, 3.2, thick);
    vec3 de = abs(pos - vec3(3.0, 3.0, 3.0)) - vec3(3.2, thick, thick);
    vec3 dee = abs(pos - vec3(3.0, 3.0, 3.0)) - vec3(thick, thick, 3.2);
    
    float a = min(max(d.x,max(d.y,d.z)),0.0) +
         	length(max(d,0.0));
    
    float b = min(max(de.x,max(de.y,de.z)),0.0) +
         	length(max(de,0.0));
    
    float c = min(max(dee.x,max(dee.y,dee.z)),0.0) +
         	length(max(dee,0.0));
    
   
    return smin(smin(a, smin(abs(old.x - 9.0), abs(old.x + 15.0), 2.75), 2.75), smin(b, c, 1.75), 1.75);
}

vec3 normal (vec3 pos) {
    vec2 r = vec2(0.001, 0.0);
    return normalize(vec3(
    	scene(pos-r.xyy) - scene(pos+r.xyy),
        scene(pos-r.yxy) - scene(pos+r.yxy),
        scene(pos-r.yyx) - scene(pos+r.yyx)
    ));
}

vec2 castRay (vec3 ro, vec3 rd) {
    float inte = 0.0;
    for (int i = 0; i < MAX_STEPS; ++i) {
        vec3 pos = ro + rd*inte;
        float t = scene(pos);
        if (t < 0.0)
            return vec2(t, inte);
        inte += max(0.01, t);
    }
    return vec2(1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    //uv.xy = floor(uv.xy*32.0)/32.0;
    
    vec4 music = texture2D(iChannel0, vec2(0.0, 0.0)) * 0.75 +
        		 texture2D(iChannel0, vec2(1.0/256.0, 0.0)) * 0.25;
   
    vec3 fog = vec3(1.0, 0.4, 0.8);
    vec3 color = vec3(fog);

    vec3 ro = vec3(uv, iGlobalTime*2.0);
    vec3 rd = normalize(vec3(uv, 1.0)+vec3(sin(iGlobalTime*0.5)*0.5, cos(iGlobalTime*0.5)*0.25, 0.0));
    vec2 ca = castRay(ro, rd);
    
    if (ca.x < 0.0) {
        	vec3 pos = ro+ca.y*rd;
    	    vec3 n = normal(pos);
        	vec3 cm = textureCube(iChannel1, n).rgb;
            float direct = mix(0.25, 1.0, max(0.0, dot(n, normalize(vec3(0.0, -2.0, 1.0)) )));
            float direct2 = mix(0.25, 1.0, max(0.0, dot(n, normalize(vec3(0.0, -2.0, 1.0)) )));
            float direct3 = mix(0.25, 1.0, max(0.0, dot(n, vec3(0.0, -1.0, 0.0) )));
            color = vec3(1.0) * direct + vec3(0.75, 0.75, 1.0) * direct2 * 0.5 + vec3(1.0, 0.0, 1.0)*direct3*0.25;
            float spec = clamp(dot(n, normalize(vec3(pos-ro))), 0.0, 1.0);
            spec = pow(spec, 16.0);
            color += vec3(1.0, 0.0, 1.0) * spec;
            spec = pow(spec, 1.0);
            color += vec3(1.0) * spec * exp(-length(pos) * 0.01);
        color += cm*0.25;
            color = mix(fog, color, exp(-max(length(pos-ro) - 4.0, 0.0)*0.1));  
    }
    
    vec2 uv2 = fragCoord.xy / iResolution.xy;
    uv2 = uv2 * 2.0 - 1.0;
    color *= smoothstep(1.5, 1.5 - 0.75, length(uv2));
    color = mix(vec3(dot(color, vec3(1.0/3.0))), color, music.r);
	fragColor = vec4(sqrt(color), 1.0);
}