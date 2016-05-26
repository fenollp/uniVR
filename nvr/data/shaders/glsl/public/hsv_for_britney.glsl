// Shader downloaded from https://www.shadertoy.com/view/Xlf3zs
// written by shadertoy user LukasPukenis
//
// Name: HSV for Britney
// Description: HSV For Britney!
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 pixel = texture2D(iChannel0, uv);
    
    float koef1 = 0.5*(1.0 + sin(iGlobalTime*3.0));  // hue. top left
    float koef2 = 0.5*(1.0 + sin(iGlobalTime*2.5));  // sat. bottom right
    float koef3 = 0.5*(1.0 + sin(iGlobalTime*2.0)); // lit. top right
    
    vec3 hsvPixel = rgb2hsv(vec3(pixel.rgb));
    
    vec4 HuePixel   = vec4(hsv2rgb(vec3(hsvPixel.r*koef1, hsvPixel.gb)), pixel.a);
    vec4 SatPixel   = vec4(hsv2rgb(vec3(hsvPixel.r, hsvPixel.g*koef2, hsvPixel.b)), pixel.a);    
    vec4 LightPixel = vec4(hsv2rgb(vec3(hsvPixel.rg, hsvPixel.b*koef3)), pixel.a);
    
    
	fragColor = mix(
        mix(pixel, HuePixel, step(0.5, uv.y)),
        mix(SatPixel, LightPixel, step(0.5, uv.y)),
        step(0.5, uv.x)
    );
}