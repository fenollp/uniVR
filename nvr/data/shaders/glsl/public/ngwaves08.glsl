// Shader downloaded from https://www.shadertoy.com/view/4lsGDX
// written by shadertoy user netgrind
//
// Name: ngWaves08
// Description: mouse x is
//    r a d
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

vec2 rotate(vec2 v, float a){
	float t = atan(v.y,v.x)+a;
    float d = length(v);
    v.x = cos(t)*d;
    v.y = sin(t)*d;
    return v;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = 4.0;
    float i= iGlobalTime;
	vec2 uv = fragCoord.xy / iResolution.xy*scale - scale*.5;
    vec4 c = vec4(1.0,0.0,1.0,1.0);
    uv = rotate(uv,sin(length(uv.yx)+iMouse.x*.02+i));
    mat2 m = mat2(
    	uv.x*uv.y,
        uv.y,
        dot(uv.y,uv.x+iMouse.y*.02),
        sin(uv.y*6.0+cos(uv.x)*5.0)
    );
    m[0] = rotate(m[0],length(uv));
    c.rb= mod(uv*m+i,1.0)*.5+.5;
    c.rb = pow(c.rb,vec2(9.0));
    c.rgb = hue(c,i).rgb;
	fragColor = c;
}