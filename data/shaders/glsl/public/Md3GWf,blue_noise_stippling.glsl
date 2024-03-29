// Shader downloaded from https://www.shadertoy.com/view/Md3GWf
// written by shadertoy user joeedh
//
// Name: Blue Noise Stippling
// Description: Attempt at a procedurally generated blue noise mask.  Note that I apply a sharpening filter to the input data.
//checkerboard noise
vec2 stepnoise(vec2 p, float size) {
    p += 10.0;
    float x = floor(p.x/size)*size;
    float y = floor(p.y/size)*size;
    
    x = fract(x*0.1) + 1.0 + x*0.0002;
    y = fract(y*0.1) + 1.0 + y*0.0003;
    
    float a = fract(1.0 / (0.000001*x*y + 0.00001));
    a = fract(1.0 / (0.000001234*a + 0.00001));
    
    float b = fract(1.0 / (0.000002*(x*y+x) + 0.00001));
    b = fract(1.0 / (0.0000235*b + 0.00001));
    
    return vec2(a, b);
    
}
float tent(float f) {
    return 1.0 - abs(fract(f)-0.5)*2.0;
}

#define SEED1 (1.705)
#define SEED2 (1.379)
#define DMUL 8.12235325

float poly(float a, float b, float c, float ta, float tb, float tc) {
    return (a*ta + b*tb + c*tc) / (ta+tb+tc);
}
float mask(vec2 p) {
    vec2 r = stepnoise(p, 5.5)-0.5;
    p[0] += r[0]*DMUL;
    p[1] += r[1]*DMUL;
    
    float f = fract(p[0]*SEED1 + p[1]/(SEED1+0.15555))*1.03;
    return poly(pow(f, 150.0), f*f, f, 1.0, 0.0, 1.3);
}

float s(float x, float y, vec2 uv) {
    vec4 clr = texture2D(iChannel0, vec2(x, y)/iResolution.xy + uv);
    float f = clr[0]*0.3 + clr[1]*0.6 + clr[1]*0.1;
    
    return f;
}

mat3 normalize(mat3 mat) {
    float sum = mat[0][0]+mat[0][1]+mat[0][2]
              + mat[1][0]+mat[1][1]+mat[1][2]
              + mat[2][0]+mat[2][1]+mat[2][2];
    return mat / sum;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy;
    vec2 uv2 = fragCoord.xy / iResolution.x;
    
    vec2 r = stepnoise(uv, 6.0);
    
    vec4 clr = texture2D(iChannel0, fragCoord.xy / iResolution.xy);
    float slide = tent(-0.0*iGlobalTime+uv2[0]*0.5);
    
    float f = clr[0]*0.3 + clr[1]*0.6 + clr[1]*0.1;
    
    //sharpen input.  this is necassary for stochastic
    //ordered dither methods.
    vec2 uv3 = fragCoord.xy / iResolution.xy;
    float d = 0.5;
    mat3 mat = mat3(
        vec3(d, d,   d),
        vec3(d, 2.0, d),
        vec3(d, d,   d)
    );
    
    float f1 = s(0.0, 0.0, uv3);
    
    mat = normalize(mat)*1.0;
    f = s(-1.0, -1.0, uv3)*mat[0][0] + s(-1.0, 0.0, uv3)*mat[0][1] + s(-1.0, 1.0, uv3)*mat[0][2]
      + s( 0.0, -1.0, uv3)*mat[1][0] + s( 0.0, 0.0, uv3)*mat[1][1] + s( 0.0, 1.0, uv3)*mat[1][2]
      + s( 1.0, -1.0, uv3)*mat[2][0] + s( 1.0, 0.0, uv3)*mat[2][1] + s( 1.0, 1.0, uv3)*mat[2][2];
    
    f = (f-s(0.0, 0.0, uv3));
    f *= 40.0;
    f = f1 - f;
    
    float c = mask(uv);
    
    if (uv2[1] < 0.05) {
        c = float(slide >= c);
    } else {
	    c = float(f >= c);
    }
    
	fragColor = vec4(c, c, c, 1.0);
}