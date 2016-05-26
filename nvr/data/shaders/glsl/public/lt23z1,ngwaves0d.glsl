// Shader downloaded from https://www.shadertoy.com/view/lt23z1
// written by shadertoy user netgrind
//
// Name: ngWaves0D
// Description: plasm
#define PI 3.1415

vec4 hue(vec4 color, float shift) {

    const vec4  kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
    const vec4  kRGBToI     = vec4 (0.596, -0.275, -0.321, 0.0);
    const vec4  kRGBToQ     = vec4 (0.212, -0.523, 0.311, 0.0);

    const vec4  kYIQToR   = vec4 (1.0, 0.956, 0.621, 0.0);
    const vec4  kYIQToG   = vec4 (1.0, -0.272, -0.647, 0.0);
    const vec4  kYIQToB   = vec4 (1.0, -1.107, 1.704, 0.0);

    // Convert to YIQ
    float   YPrime  = dot (color, kRGBToYPrime);
    float   I      = dot (color, kRGBToI);
    float   Q      = dot (color, kRGBToQ);

    // Calculate the hue and chroma
    float   hue     = atan (Q, I);
    float   chroma  = sqrt (I * I + Q * Q);

    // Make the user's adjustments
    hue += shift;

    // Convert back to YIQ
    Q = chroma * sin (hue);
    I = chroma * cos (hue);

    // Convert back to RGB
    vec4    yIQ   = vec4 (YPrime, I, Q, 0.0);
    color.r = dot (yIQ, kYIQToR);
    color.g = dot (yIQ, kYIQToG);
    color.b = dot (yIQ, kYIQToB);

    return color;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime;
    float scale = 4.0;
	vec2 uv = fragCoord.xy / iResolution.yy*scale-scale*.5;
    vec4 c = vec4(1.0);
    float a = atan(uv.y,uv.x);
    mat2 m = mat2(sin(a+PI*.75),cos(a+sin(i*.2)-1.),-sin(a+PI),cos(a));
    uv*=m;   
    
    float d = length(uv);    
    a+=+sin(d*4.-i*2.)*.4;
    a+= (iMouse.y/iResolution.y)*5.;
    d+= sin(a*6.0+i)*d;
    
    c.g = mod(d*.5-i,1.0);
    c.g -= mod(c.g,.5);
    c.r = mod(a/PI*6.0,1.0);
    c.r -= mod(c.r,.5);
    c.b = length(c.rg);
    c.rgb +=.5;
    c.rgb = mix(vec3(0.), c.rgb, clamp(d+sin(a*4.0+i)*.1-.3,0.0,1.0));
	fragColor = hue(c,2.0+iMouse.x*.01);
}