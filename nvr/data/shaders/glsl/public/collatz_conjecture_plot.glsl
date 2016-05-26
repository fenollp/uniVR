// Shader downloaded from https://www.shadertoy.com/view/MlsXRN
// written by shadertoy user krazykylep
//
// Name: Collatz Conjecture Plot
// Description: This is a plot of the Collatz Conjecture. Each &quot;tower&quot; of pixels represents the journey that value took to get to 1. (The x pixel value defines the starting number.) The heat of the color (sort of) defines how close the number is to 1.
#define LIMIT 800

vec3 hsv2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float cam(float f) {
    float tt = mod(f, 25.0) * 4.0;
	float go = smoothstep(10.0, 45.0, tt) - smoothstep(60.0, 95.0, tt);
    return go * 100000.0;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float t = iGlobalTime;
    float x = floor(fragCoord.x) + floor(cam(t));
    float y = floor(fragCoord.y);
    //float wtf = 2.0 * floor(mod(t*10.0, x*tan(t/y))) + 1.0;
    //float wtf = 2.0 * floor(mod(t*2.0, 10.0)) + 1.0;
    float wtf = 1.0;
    float c = 0.0;
    //float maxx = 0.0;
    float bgOff = 1.0;
    //x = x * x;
    for (int k = 0; k < LIMIT; k++) {
        c++;
        if (x <= 1.0) {
            c = 0.0;
            //maxx = 0.0;
            bgOff = 0.0;
        	break;   
        }
        if (c >= y / (0.0025 * iResolution.y)) {
        	break;   
        }
        if (mod(x,  2.0) == 0.0) {
            x = x / 2.0;
        } else {
            x = x * 3.0 + wtf;
            if (x <= wtf * 4.0) {
            	x = 1.0;   
            }
        }
        //maxx = max(maxx, x);
    }
    float bgOn = (1.0 - bgOff);
    float bg1 = sin(t)*bgOn*0.1;
    float bg2 = sin(t + (3.14159) / 2.0)*bgOn*0.1;
    fragColor = vec4(hsv2rgb(vec3(mod(x/10.0, 360.0) / 360.0, 1.0, 0.5 * bgOff)), 1.0) + vec4(bg1, bg2, (0.1-bg1-bg2)*bgOn, 0.0);
}