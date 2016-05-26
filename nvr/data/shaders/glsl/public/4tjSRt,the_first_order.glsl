// Shader downloaded from https://www.shadertoy.com/view/4tjSRt
// written by shadertoy user germangb
//
// Name: The First Order
// Description: Logo of the First Order.
//#define SIMPLE
#define INVERTED

#define SPIKES 15
#define SIDES 3

mat2 rot2 (float i) {
 	return mat2(cos(i), sin(i), -sin(i), cos(i));   
}

float logo (vec2 uv, float time) {
    float sh = 0.0;
    vec3 pol = vec3(0.0);
        
    float apear = clamp((-time+0.5+1.0), 0.0, 10.0);
    for (int i = 0; i < SIDES; i++) {
        vec2 uvRot = rot2(float(i)*3.14159/float(SIDES))*uv;
        pol.x = mix(1.0, pol.x, smoothstep(0.0, 0.035, 0.5256-uvRot.x*uvRot.x));
        pol.y = mix(1.0, pol.y, smoothstep(0.0, 0.035, 0.64-uvRot.x*uvRot.x));
        pol.z = mix(1.0, pol.z, smoothstep(0.0, 0.035, 0.77-uvRot.x*uvRot.x));
    }
    
    float p = pol.x-pol.y;
    #ifdef INVERTED
    p+=pol.z;
    #endif
    sh = mix(sh, 1.0, p);
    
    float r = length(uv);
    sh = mix(1.0, sh, smoothstep(0.0, 0.03, abs(r - 0.6 + apear*0.4) - 0.02));
    if (r < 0.6) {
        for (int i = 0; i < SPIKES; i++) {
            float r = texture2D(iChannel0, vec2(float(i)*(0.385+0.72))).r;
            float apear = clamp(-((time-0.5-r + 0.8)*0.5)+1.0, 0.0, 10.0);
            vec2 uvRot = rot2(float(i)*6.283/float(SPIKES))*uv;
        	float a = atan(uvRot.x, uvRot.y - 0.325 - apear);
    		sh = mix(1.0, sh, smoothstep(-0.0, 0.1, abs(a)-0.15));
        }
    }
    
    #ifdef INVERTED
    sh = 1.0-sh;
    #endif
    
    return sh;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float masterTime = mod(iGlobalTime, 8.0);
    vec2 uv3 = fragCoord.xy / iResolution.xy*2.-1.;
	vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
	uv.x *= iResolution.x/iResolution.y;
    uv *= clamp(masterTime, 0.0, 1.5);
    uv = rot2(exp(-masterTime*0.25) - 0.4) * uv;
    
    float tt = 1.45;
    float shake = exp(-masterTime+tt);
    if (masterTime < tt) shake = 0.0;
    uv.x += sin(masterTime*32.0)*0.0125 * shake;
    uv.y += cos(masterTime*48.0)*0.0125 * shake;
            
    uv += (texture2D(iChannel0, uv + floor(masterTime/0.05)*0.05).rg * 2.0 - 1.0) * 0.005;
    
    float t = masterTime * 6.0; 
    float sh = logo(uv, masterTime);
    
    #ifdef SIMPLE
    fragColor.rgb = mix(vec3(0.0), vec3(1.0), (1.0-sh));
    #else
    vec2 uv2 = uv+vec2(-1.0,1.0)*0.035;
    vec3 base = vec3(0.5, 0.0667, 0.1725);base *= 1.1;
    
    t = 0.0;
    float n = texture2D(iChannel0, uv*0.1+t * 0.0012).r;
    n += texture2D(iChannel0, uv*0.05-t * 0.0012).r;
    n += texture2D(iChannel0, uv*0.025-t * 0.0012).r;
    n += texture2D(iChannel0, uv*0.0125+t * 0.00012+2.).r;
    n += texture2D(iChannel0, uv+t * 0.00012+4.).r;
    n/=4.5;
    n += texture2D(iChannel0, uv+t * 0.0001).r*0.6;
    n = clamp(n, 0.0, 1.0);
    
    sh *= mix(0.75, 1.0, n);
    fragColor.rgb = mix(vec3(base*0.25), base, (1.0-sh));
    
    fragColor.rgb *= mix(0.825, 1.0, smoothstep(0.85, 0.9, n));
    fragColor.rgb = mix(mix(fragColor.rgb, vec3(0.5, 0.0667, 0.1725), 0.5), fragColor.rgb, smoothstep(0.75, 0.9, n*sh));
    
    fragColor.rgb *= mix(1.0, 0.5, smoothstep(0.8, 1.75, length(fragCoord/iResolution.xy*2.0-1.0)));
    #endif
    
    fragColor.rgb = mix(fragColor.rgb, vec3(0.), smoothstep(6.0, 7.0, masterTime));
    fragColor.rgb = mix(fragColor.rgb, vec3(0.), smoothstep(0.5, 4.5, length(uv3)));
}