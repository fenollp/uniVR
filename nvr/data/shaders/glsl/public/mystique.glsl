// Shader downloaded from https://www.shadertoy.com/view/Xdd3RS
// written by shadertoy user Harha
//
// Name: Mystique
// Description: Circles bouncing around on my screen turned into this weirdness.
//    
//    Just a short playaround session. Music is a module by a soundcloud user called &quot;Chiptune&quot;, who is apparently ReZ now that I did a bit of research.
#define PI 3.14159265359
#define t iGlobalTime

bool circle(in float r, in vec2 o, in vec2 v)
{
    return (length(o - v) <= r) ? true : false;
}

vec4 freq(in float f){
	float fft  = texture2D(iChannel0, vec2(f, 0.25)).x; 
	vec3 col = vec3(fft, 4.0 * fft * (1.0 - fft), 1.0 - fft) * fft;
    return max(vec4(col, 1.0), 0.0);
}

void mainImage(out vec4 c, in vec2 f)
{
	vec2 uv = (f.xy / iResolution.xy - 0.5);
    uv.x *= iResolution.x / iResolution.y;
    c = vec4(0.0);
    vec2 o = vec2(cos(PI * t) * 0.2, sin(PI * t * 0.33) * 0.2);
    for (float w = 0.0; w < 1.0; w += 0.1)
    {
    	float a = 0.25 + freq(length(uv) * 0.25).r * 0.25;
		c += smoothstep(0.0, 1.0, a * abs(sin(PI * t + 1.0)) * vec4(cos(PI * w * t), sin(w), tan(w), 1.0) * vec4(circle(a, o, uv / w)));
    }
}