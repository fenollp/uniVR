// Shader downloaded from https://www.shadertoy.com/view/ll2SRd
// written by shadertoy user macbooktall
//
// Name: webcam mush
// Description: ∆
#define PI 3.14159265359

// hue by cale
 vec4 hue_shift( vec4 color, float shift) {
     
     const vec4 kRGBToYPrime = vec4 (0.299, 0.587, 0.114, 0.0);
     const vec4 kRGBToI     = vec4 (0.596, -0.275, -0.321, 0.0);
     const vec4 kRGBToQ     = vec4 (0.212, -0.523, 0.311, 0.0);
     
     const vec4 kYIQToR   = vec4 (1.0, 0.956, 0.621, 0.0);
     const vec4 kYIQToG   = vec4 (1.0, -0.272, -0.647, 0.0);
     const vec4 kYIQToB   = vec4 (1.0, -1.107, 1.704, 0.0);
     float   YPrime  = dot (color, kRGBToYPrime);
     float   I      = dot (color, kRGBToI);
     float   Q      = dot (color, kRGBToQ);
     float   hue     = atan (Q, I);
     float   chroma  = sqrt (I * I + Q * Q);
     hue += shift;
     Q = chroma * sin (hue);
     I = chroma * cos (hue);
     vec4    yIQ   = vec4 (YPrime, I, Q, 0.0);
     color.r = dot (yIQ, kYIQToR);
     color.g = dot (yIQ, kYIQToG);
     color.b = dot (yIQ, kYIQToB);
     
     return color;
 }

// noise by iq
 highp float hash(highp float n )
{
    return fract(sin(n)*43758.5453123);
}
 
 highp float noise( highp vec2 x )
{
    highp vec2 p = floor(x);
    highp vec2 f = fract(x);
    
    f = f*f*(3.0-2.0*f);
    
    highp float n = p.x + p.y*157.0;
    
    return mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
               mix( hash(n+157.0), hash(n+158.0),f.x),f.y);
}

vec4 blend_avg_invert_b(vec4 colorA, vec4 colorB) {
    return (colorA + (1.0-colorB)) / 2.0;
}

vec4 blend_divide(vec4 a, vec4 b) {
    return a / b;
}

vec4 blend_weird(vec4 a, vec4 b, vec2 uv) {
 	return smoothstep(a, b, vec4(noise(uv+iGlobalTime)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )    
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float slow_time = iGlobalTime * 0.5;
          
    uv = abs(uv*2.0-1.0);
 
    vec2 red_uv = uv + 0.25*noise(uv+iGlobalTime);
    vec2 green_uv = uv -0.25*noise(uv+iGlobalTime);
    
    vec4 regular_pixel_color   = texture2D(iChannel0, uv );
    vec4 red_shift_pixel_color = texture2D(iChannel0, red_uv );
    vec4 green_shift_pixel_color = texture2D(iChannel0, green_uv );
    vec4 blue_shift_pixel_color = regular_pixel_color;
    
    vec4 result_color = vec4(red_shift_pixel_color.r, green_shift_pixel_color.g, blue_shift_pixel_color.b, regular_pixel_color.a);	    
    result_color = hue_shift(result_color, iGlobalTime*4.0);
    
   	float scanline = sin(uv.y*600.0)*0.05;
	result_color -= scanline;
 
    result_color = blend_divide(result_color, regular_pixel_color);
    result_color = blend_avg_invert_b(result_color, regular_pixel_color);
    result_color = blend_weird(result_color, regular_pixel_color, uv);
    
    // Set the resulting pixel color
    fragColor = result_color;

    
}