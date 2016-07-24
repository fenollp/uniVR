// Shader downloaded from https://www.shadertoy.com/view/MtjGRh
// written by shadertoy user macbooktall
//
// Name: philips huey
// Description: broke edge at a frozen french fries factory in Michigan 

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

float hash( float n )
{
    return fract(sin(n)*43758.5453123);
}

float noise( in vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*157.0;

    return mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
               mix( hash(n+157.0), hash(n+158.0),f.x),f.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float x = fragCoord.x / iResolution.x;
    float y = fragCoord.y / iResolution.y;
    x = abs(x*2.0-1.0);
    y = abs(y*2.0-1.0) ;

    vec2 v1 = vec2((sin(x)*12.0)+iGlobalTime, (sin(x)*24.0)+iGlobalTime);
    vec2 v2 = vec2((x*y*120.0)+iGlobalTime, (x*24.0)+iGlobalTime);
    
    float b = noise(v1);
    float r = noise(v2);

    vec3 h = rgb2hsv(vec3(r/b, 0.8 - r*b*x, b/r*1.6-r));
    h.x += sin(iGlobalTime)*0.25;
    vec3 o = hsv2rgb(h);
    
    fragColor = vec4(o.x, o.y, o.z, 1.0);
}
