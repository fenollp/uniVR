// Shader downloaded from https://www.shadertoy.com/view/Xtj3zD
// written by shadertoy user macbooktall
//
// Name: hue party
// Description: can i have my birthday party here?
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
    float cheebatime = iGlobalTime*0.5;
	vec2 uv = fragCoord.xy / iResolution.xy;
    float ok = 1.0 + (2.0 + 2.0*sin(cheebatime));
    uv = abs(ok/2.0*uv - ok/4.0)+ ok/8.0;
    mat2 r = mat2 (-sin(uv.x*ok), uv.y*cos(cheebatime), uv.x*sin(cheebatime), sin(uv.y*ok));
	uv *= r/2.0;   
    float d = length(uv);
    vec3 e = vec3(uv.x*2.0, d, uv.y*2.25)+cheebatime;
    e.rgb = abs(mod(e+d,1.0)-0.5)*2.0;
    e.rgb = rgb2hsv(e.rgb);
    e.r += sin(iGlobalTime);
    
	fragColor = vec4(hsv2rgb(e.rgb), 1.0);
}