// Shader downloaded from https://www.shadertoy.com/view/MsK3Wt
// written by shadertoy user Edward
//
// Name: Geometric wallpaper
// Description: Inspired by one of the wallpaper types generated by the Android app &quot;Tapet&quot;. Could do with a better palette generation algorithm to avoid so many ugly combos. Loads of inefficiency, esp. the AA, but there's only so many new wallpapers you need per second.
// License: http://unlicense.org/

#define VIGNETTE
#define DITHER
#define ROTATE
#define ANTIALIAS 8
#define FRAME_CALC int(iGlobalTime)
#define GRID_MIN 20.
#define GRID_MAX 200.
#define GRID_SEED 1237.
#define COLOUR_MIN 2.
#define COLOUR_MAX 6.
#define COLOUR_SEED 2356.
#define ORIENTATION_SEED 3456.

// http://byteblacksmith.com/improvements-to-the-canonical-one-liner-glsl-rand-for-opengl-es-2-0/
highp float hash(vec2 co) {
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

// http://glslsandbox.com/e#18922.0
vec2 rotate(vec2 p, float a) {
    return vec2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
}

vec4 calcValue(in vec2 fragCoord) {
    vec4 fragColor;
    int frame = FRAME_CALC;
    float gridSize = floor((GRID_MAX - GRID_MIN + 1.) * hash(vec2(frame, GRID_SEED)) + GRID_MIN); 
    float numColours = floor((COLOUR_MAX - COLOUR_MIN + 1.) * hash(vec2(frame, COLOUR_SEED)) + COLOUR_MIN);
    vec2 square = floor(fragCoord / gridSize); 
    int orientation = int(2. * hash(square + ORIENTATION_SEED + float(frame)));
    vec2 innerCoord = mod(fragCoord, gridSize);
    if(orientation == 1) {innerCoord.y = gridSize - innerCoord.y;}
    vec2 triangle = square * vec2(1.,2.);
    if(innerCoord.x > innerCoord.y) {triangle.y += 1.;}
    float colorIndex = floor(hash(triangle + COLOUR_SEED) * numColours);
    fragColor.r = hash(vec2(colorIndex + COLOUR_SEED, frame));
    fragColor.g = hash(vec2(colorIndex + COLOUR_SEED, frame + 1000));
    fragColor.b = hash(vec2(colorIndex + COLOUR_SEED, frame + 2000));
    fragColor.a = 1.;
    return fragColor;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    
    vec2 coord = fragCoord;
    
    #ifdef ROTATE
        coord = rotate(coord, float(FRAME_CALC) + .5);
    #endif
    
    fragColor = vec4(0.,0.,0.,1.);
    
    for(int i = 0; i < ANTIALIAS; i++) {
        for(int j = 0; j < ANTIALIAS; j++) {
            fragColor += calcValue(coord + vec2(float(i) / float(ANTIALIAS), float(j) / float(ANTIALIAS)));
        }
    }
    
    fragColor /= float(ANTIALIAS*ANTIALIAS);

    #ifdef VIGNETTE
    	float vignette = 1. - .85 * length(iResolution.xy / 2. - fragCoord) / length(iResolution.xy / 2.);
    	fragColor.rgb *= pow(vignette,.4);
    #endif

    #ifdef DITHER
        float ditherOffset = mod(mod(fragCoord.x,2.)+mod(fragCoord.y,2.)*2.+2.,4.)/4.-.375;
        vec3 scaledColour = fragColor.xyz * 256.;
        fragColor.xyz = floor(scaledColour+ditherOffset)/(vec3(255));
    #endif
}