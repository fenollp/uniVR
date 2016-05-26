// Shader downloaded from https://www.shadertoy.com/view/lsyGR1
// written by shadertoy user sixstring982
//
// Name: Mouse Julia
// Description: Julia fractal. Use your mouse to change how it renders! Uses orbit trapping for coloring. Mandelbrot is rendered in the background to aid in finding interesting Julia constants.
#define ITERS 32

struct Window {
    float x;
    float y;
    float w;
    float h;
};

vec2 complexFromUv(in Window win, in vec2 uv) {
    return vec2(uv.x * win.w + win.x,
                uv.y * win.h + win.y);
}

vec3 palette(in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d) {
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 juliaPalette(in float t) {
    return palette(t, vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5, 0.5), 
                      vec3(1.0, 1.0, 0.5), vec3(0.80, 0.90, 0.30));
}

vec3 mbrotPalette(in float t) {
    return palette(t, vec3(0.5, 0.5, 0.5), vec3(0.5, 0.5, 0.5), 
                      vec3(1.0, 1.0, 0.5), vec3(0.80, 0.90, 0.30));
}

float julia(in vec2 c, in vec2 z, in vec2 target) {
    float x;
    float d = 1e20;
    for (int j = 0; j < ITERS; j++) {
        if (z.x * z.x + z.y * z.y > 4.0) {
            return d;
        }
        
        x = z.x * z.x - z.y * z.y + c.x;
        z.y = 2.0 * z.x * z.y + c.y;
        z.x = x;
        
        d = min(d, length(z - target));
    }
    return d;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    Window win = Window(-2.0, -1.0, 3.0, 2.0);
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 z = complexFromUv(win, uv);
    vec2 c = complexFromUv(win, iMouse.xy / iResolution.xy);
    
    vec2 t = vec2(sin(iGlobalTime) + 0.1 * sin(iGlobalTime * 2.0), 
                  cos(iGlobalTime) + 0.1 * cos(iGlobalTime * 2.0));
    
    t *= sin(iGlobalTime * 0.1) * 0.5;

    vec3 j = juliaPalette(pow(julia(c, z, t), 0.3));
    vec3 m = mbrotPalette(pow(julia(z, z, t), 0.7));
    float amt = 0.75 + 0.25 * sin(iGlobalTime * 0.1);
    fragColor = vec4(mix(m, j, amt), 1.0);
}