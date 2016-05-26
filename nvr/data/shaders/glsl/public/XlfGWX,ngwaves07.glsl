// Shader downloaded from https://www.shadertoy.com/view/XlfGWX
// written by shadertoy user netgrind
//
// Name: ngWaves07
// Description: great weight presses down upon your eyes
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
	vec2 uv = fragCoord.xy / iResolution.xy*12.0-6.0;
    vec4 c = vec4(1.0);
    mat2 m = mat2(sin(length(uv+iMouse.xx*.1)+i),cos(uv.x-i*.5),sin(uv.x*uv.y),sin(cos(uv.x+iMouse.y*.01)+uv.y));
    c.rg = atan(sin(uv.xy*m+i)*8.0)*m;
    c.rb-=sin(uv*m+iMouse.yx*.02)*.4;
    c.rgb = hue(normalize(c)*1.5,i*.3).rgb;
	fragColor = c;
}