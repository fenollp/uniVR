// Shader downloaded from https://www.shadertoy.com/view/MdcXz8
// written by shadertoy user paniq
//
// Name: Decal Blending
// Description: experimenting with blending a decal in linear colorspace; left side is logarithmic alpha blending (multiplicative effect). right side is linear alpha blending (additive effect). Exposure &amp; lambert is simulated on the result, followed by a HDR mixdown.
// attention: not an exponent, but a factor
#define EXPOSURE 1.0

float m; 

float sRGB(float t){ return mix(1.055*pow(t, 1./2.4) - 0.055, 12.92*t, step(t, 0.0031308)); }
vec3 sRGB(in vec3 c) { return vec3 (sRGB(c.x), sRGB(c.y), sRGB(c.z)); }

vec3 srgb2lin(vec3 color) {
    return color * (color * (
        color * 0.305306011 + 0.682171111) + 0.012522878);
}

vec3 lin2srgb(vec3 color) {
    vec3 S1 = sqrt(color);
    vec3 S2 = sqrt(S1);
    vec3 S3 = sqrt(S2);
    return 0.585122381 * S1 + 0.783140355 * S2 - 0.368262736 * S3;
}

const float whitepoint = 398.0 / 335.0 + 0.004;

vec3 ff_filmic_gamma3(vec3 linear) {
    vec3 x = max(vec3(0.0), linear-0.004);
    return (x*(x*6.2+0.5))/(x*(x*6.2+1.7)+0.06);
}

vec3 inverse_filmic_sRGB(vec3 srgb) {
    vec3 x = srgb;
    return (-85.0*x - sqrt(5.0*x*(701.0*x - 106.0) + 625.0) + 25.0)/ 
        (620.0*(x - 1.0)) + 0.004;
}

vec3 hue2rgb(float hue) {
    return clamp( 
        abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
        0.0, 1.0);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}


float decal(float d, float r) {
    return smoothstep(0.0, 1.0, (r - d) / r);
}

void blend(inout vec3 color, vec2 p, vec2 s, float ph) {
    float r = min(s.x, s.y);
    float d = -sdBox(vec3(p,0.0), vec3(s-r,1.0))+r;
    
    d /= r * (0.1 + (sin(iGlobalTime)*0.5+0.5)*0.9);
    
    d = smoothstep(0.0, 1.0, d);
    //d = clamp(d, 0.0, 1.0);
    
    // defined in srgb
    vec3 albedo = min(hue2rgb(iGlobalTime * 0.01 + ph) + 0.1, 1.0);
    albedo = mix(albedo,vec3(1.0),0.5);
    albedo = srgb2lin(albedo);
    
    if (p.x < m) {
        float eps = 0.001;
        color = pow(color, vec3(1.0 - d)) * pow(albedo, vec3(d));
    } else {
        color = mix(color, albedo, d);
    }
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    m = (((iMouse.z < 0.5)?0.5:iMouse.x / iResolution.x));
    m = m * 2.0 - 1.0;
    m *= iResolution.x / iResolution.y;
    
    // defined in srgb
    vec3 background = min(hue2rgb(iGlobalTime * 0.017 + 0.5) + 0.1, 1.0);
    background = mix(background,vec3(1.0),0.5);
    background = srgb2lin(background);
    
    vec3 color = background;
    
    blend(color, uv, vec2(0.5,0.9), 0.333);
    blend(color, uv, vec2(0.9,0.5), 0.0);
    blend(color, uv, vec2(0.30,0.30), 0.8);
    blend(color, uv, vec2(0.25,0.25), 0.0);
    blend(color, uv, vec2(0.20,0.20), 0.8);
    
    color = color*(0.05 + max(cos((uv.y-1.0)*1.57),0.0));
    
    color *= EXPOSURE * whitepoint;
    	
    fragColor = vec4(ff_filmic_gamma3(color) * min(1.0, abs(uv.x - m)*80.0),1.0);
    
}