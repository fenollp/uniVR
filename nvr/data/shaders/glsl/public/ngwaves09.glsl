// Shader downloaded from https://www.shadertoy.com/view/XtXGDl
// written by shadertoy user netgrind
//
// Name: ngWaves09
// Description: simple spiral
vec2 rotate(vec2 v, float a){
	float t = atan(v.y,v.x)+a;
    float d = length(v);
    v.x = cos(t)*d;
    v.y = sin(t)*d;
    return v;
}

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

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float i = iGlobalTime;
    float scale = 5.0;
	vec2 uv = ( fragCoord.xy / iResolution.xy )*scale-scale*.5;
    uv = rotate(uv,sin(length(uv)+i));
    vec3 color = vec3(1.0);
    float d = length(uv)*20.0+500.0;
    float a = atan(uv.y,uv.x);
    uv *= mat2(cos(d*sin(a*.01)),sin(-d*cos(a*.2)+i),-sin(d+tan(a*.01)+i),sin(i-d+a*5.0+cos(i+uv.x*3.0*a)));
    color.gb = uv;
    color.r = length(uv);
    color.rgb = mod(color.rgb*.1,vec3(1.0));
    color = normalize(color);
	fragColor = hue(vec4( color, 1.0 ),i);
}