// Shader downloaded from https://www.shadertoy.com/view/4sc3WB
// written by shadertoy user elias
//
// Name: Draw Stuff!
// Description: Controls:
//    
//    1 = toggle brush (try different textures in Buf A)
//    i = toggle color pipette
//    r = reset
//    f = fill entire canvas
const vec2 bufB_mouse_uv  = vec2(0,0);
const vec2 bufB_col_uv    = vec2(1,0);
const vec2 bufB_hue_uv    = vec2(2,0);
const vec2 bufB_size_uv   = vec2(3,0);
const vec2 bufB_picker_uv = vec2(4,0);
const vec2 bufB_soft_uv   = vec2(5,0);

#define load(a,b) texture2D(b,(a+0.5)/iResolution.xy)

// http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
vec3 hsv2rgb(vec3 c)
{
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float udBox(vec2 p,vec2 s)
{
    return length(max(abs(p)-s,0.));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 uv = fragCoord.xy/iResolution.xy;
    fragColor = texture2D(iChannel0,uv);
    
    vec2  bufB_picker = load(bufB_picker_uv, iChannel1).xy;
    vec3  bufB_col    = load(bufB_col_uv,    iChannel1).rgb;
    vec4  bufB_mouse  = load(bufB_mouse_uv,  iChannel1);
    float bufB_size   = load(bufB_size_uv,   iChannel1).x;
    float bufB_hue    = load(bufB_hue_uv,    iChannel1).x;
    float bufB_soft   = load(bufB_soft_uv,   iChannel1).x;
    
    vec2 uva = (2.*fragCoord.xy-iResolution.xy)/iResolution.yy;
    vec2 mouse_aspect = (2.*iMouse.xy-iResolution.xy)/iResolution.yy;
    float a = iResolution.x/iResolution.y;
   
    vec2 p;
    
    // Toolbox Border
    p = uva-vec2(a-0.31,0);
    if (udBox(p,vec2(0.3,1))==0.0) fragColor.rgb = vec3(0);
    
    // Toolbox Background
    p = uva-vec2(a-0.3,0);
    if (udBox(p,vec2(0.3,1))==0.0) fragColor.rgb = vec3(1);
    
    // Spectrum
    p = uva-vec2(a-0.25-0.1,1.0-0.25);
    if (udBox(p,vec2(0.25))==0.0) fragColor.rgb = hsv2rgb(vec3(bufB_hue,p/(0.25*2.0)+0.5));
    
    // Hue slider background
    p = uva-vec2(a-0.05,1.0-0.25);
    if (udBox(p,vec2(0.05,0.25))==0.0) fragColor.rgb = hsv2rgb(vec3(p.y/(0.25*2.0)+0.5,1.0,1.0));

    // Hue slider
    p = uva-vec2(a-0.05,1.0-0.005-0.5*(1.-bufB_hue));
    if (udBox(p,vec2(0.05,0.01))==0.0) fragColor.rgb = vec3(0);
    
    // Indicator
    float d = length(uva-bufB_picker);
    if (step(d,0.03)*step(0.02,d)>0.0) { fragColor.rgb = 1.0-bufB_col; }
    
    // Brush size background
    p = uva-vec2(a-0.28-0.03,-1.0+0.06);
    float t = (p.x+0.28)/0.56; p.y += 0.03*(1.-t);
    if (udBox(p,vec2(0.28,0.03*t))==0.0) fragColor.rgb = vec3(0.5);
    
    // Brush size slider
    p = uva-vec2(a-0.03-0.56*(1.-bufB_size),-1.0+0.03+0.03);
    if (udBox(p,vec2(0.005,0.03))==0.0) fragColor.rgb = vec3(1,0,0);
    
    // Brush softness background
    p = uva-vec2(a-0.28-0.02,-1.0+0.+0.14);
    if (udBox(p,vec2(0.27,0.02))==0.0) fragColor.rgb = vec3(pow(p.x/(0.28*2.0)+0.5,0.2));
    
    // Brush softness slider
    p = uva-vec2(a-0.05-0.5*(1.-bufB_soft),-1.0+0.14);
    if (udBox(p,vec2(0.01))==0.0) fragColor.rgb = vec3(1,0,0);
}