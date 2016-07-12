// Shader downloaded from https://www.shadertoy.com/view/ldKSDh
// written by shadertoy user skyrising
//
// Name: Circular Audio Spectrum Mk2
// Description: Original by [url=https://www.shadertoy.com/view/lsKSzm]vochsel[/url]
//Created by Ben Skinner - @vochsel
//Modified by @skyrising
//Song: XENOX - Arcade

#define PI 3.141592

#define rgb(r, g, b) vec3(float(r)/255., float(g)/255., float(b)/255.)

#define COL_A rgb(251,184,132)
#define COL_B rgb(213,50,98) 
#define COL_C rgb(79,202,241)


//HSV convertors http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 rgb2hsv(vec3 c)
{
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = c.g < c.b ? vec4(c.bg, K.wz) : vec4(c.gb, K.xy);
    vec4 q = c.r < p.x ? vec4(p.xyw, c.r) : vec4(c.r, p.yzx);

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

vec3 spec(float time, float y)
{
    return texture2D(iChannel0, vec2(time, y)).rgb;
}

vec3 freq(float time, float y) {
    return spec(time, y)
        - spec(time, y*2.0)
        - spec(time, y*4.0)
        - spec(time, y*8.0)
        //- spec(time, y*16.0)
        ;
}

vec2 beat(float q)
{
    return (
        spec(q, 0.0).xy
        +spec(q, 0.05).xy/1.5
        +spec(q, 0.1).xy/4.0
        +spec(q, 0.2).xy/8.0
        //+spec(q, 0.4).xy/16.0
        )/1.8;
}

float circle(vec2 q, vec2 p, float rad)
{
    float l = length(q - p);
    
    return smoothstep(rad, rad - 0.005, l);
}

vec3 rand(float x)
{
    return texture2D(iChannel1, vec2(x, 0.0)).xyz;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 sc = fragCoord.xy / iResolution.xy;
    vec2 uv = sc * 2.0 - 1.0;
    float aspect = iResolution.x/iResolution.y;
    uv.x *= aspect;
    
    float t = iGlobalTime;
    
    vec3 col = vec3(0.12);
   
    float cRad = 0.75;
    const float res = 80.0;
    
    for(float i = PI*1.99; i > 0.0; i-=PI/res*2.0)
    {
        float x = sin(i) * cRad;
        float y = cos(i) * cRad;
        
        float t = float(i)/res * 2.;
        
        vec2 s = beat(t);
        
        float r = pow(s.x, 3.0)*0.025 + 0.005;
        r *= (PI*2.75-i)*0.3;
        
        float c = circle(uv, vec2(x,y), r);
    	       
        //vec3 cCol = mix(COL_C, COL_B, smoothstep(0.0, 0.072, r));
        //cCol = mix(cCol, COL_A, smoothstep(0.072, 0.172, r));
        vec3 cCol = hsv2rgb(vec3(s.y*750.0, 0.3, .85)) - rand(s.y).x*0.2;    
        
    	col = mix(col, cCol, c);
    }
    vec2 f = (fragCoord/iResolution.xy).yx;
    float y = f.y;
    float time = f.x < .1 ? 0.0 : (f.x-.1)*.1;
    float bg = pow(.6+mix(spec(time, y).b, spec(time, y).r*.5, .3), 100.0);
    vec3 c = texture2D(iChannel0, fragCoord/iResolution.xy).rgb;
    vec3 bgColor = bg*hsv2rgb(vec3(time-iGlobalTime*.1, .7, .1*pow(.8-time*0.8, 4.0)));
    vec3 col1 = col + texture2D(iChannel1, uv*2.).x*.04;
    vec3 mixed = col != vec3(0.12) ? col1 : mix(bgColor, col1, .9);
	fragColor = vec4(mixed,1.0);
}