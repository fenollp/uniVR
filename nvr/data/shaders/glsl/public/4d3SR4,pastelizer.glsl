// Shader downloaded from https://www.shadertoy.com/view/4d3SR4
// written by shadertoy user paniq
//
// Name: Pastelizer
// Description: This is a pastel hue function, extracted from the YCoCg colorspace at Y'=0.5, S=0.5, designed to provide a pleasing albedo basis for materials blended in linear colorspace, particularly when using filmic tonemapping.
//---------------------------------------------------------------------------------

vec3 pastelizer(float h) {
    h = fract(h + 0.92620819117478) * 6.2831853071796;
    vec2 cocg = 0.25 * vec2(cos(h), sin(h));
    vec2 br = vec2(-cocg.x,cocg.x) - cocg.y;
    vec3 c = 0.729 + vec3(br.y, cocg.y, br.x);
    return c * c;
}

//---------------------------------------------------------------------------------

// filmic without sRGB conversion

// shoulder strength
const float A = 0.22;
// linear strength
const float B = 0.3;
// linear angle
const float C = 0.1;
// toe strength
const float D = 0.20;
// toe numerator
const float E = 0.01;
// toe denominator
const float F = 0.30;
// linear white point
const float W = 11.2;
float filmic_curve(float x) {
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}
float inverse_filmic_curve(float x) {
    float q = B*(F*(C-x) - E);
    float d = A*(F*(x - 1.0) + E);
    return (q -sqrt(q*q - 4.0*D*F*F*x*d)) / (2.0*d);
}
vec3 filmic(vec3 x) {
    float w = filmic_curve(W);
    return vec3(
        filmic_curve(x.r),
        filmic_curve(x.g),
        filmic_curve(x.b)) / w;
}
vec3 inverse_filmic(vec3 x) {
    x *= filmic_curve(W);
    return vec3(
        inverse_filmic_curve(x.r),
        inverse_filmic_curve(x.g),
        inverse_filmic_curve(x.b));
}

// taken from https://www.shadertoy.com/view/lsdGzN
float sRGB(float t){ return mix(1.055*pow(t, 1./2.4) - 0.055, 12.92*t, step(t, 0.0031308)); }
vec3 sRGB(in vec3 c) { return vec3 (sRGB(c.x), sRGB(c.y), sRGB(c.z)); }

//---------------------------------------------------------------------------------

vec2 uvcoords(vec2 p) {
	vec2 uv = p / iResolution.xy;
    uv = uv * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    return uv;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = uvcoords(fragCoord);
    
    float h = (fragCoord.x / iResolution.x) + iGlobalTime * 0.5; 
    vec3 color1 = pastelizer(h);    
    color1 *= exp2(((fragCoord.y / iResolution.y)*2.0-1.0)*4.0);
    
    vec2 n = normalize(uv);
    vec3 color2 = pastelizer(atan(n.y,n.x) / 6.2831853071796);
    color2 *= 1.0 / (0.01 + dot(uv,uv) * 10.0);
    
    float s = clamp(-atan(sin(iGlobalTime*0.49)*100.0)*0.5/1.5 + 0.5,0.0,1.0);
    vec3 color = pow(color1, vec3(1.0-s)) * pow(color2, vec3(s));

    color = filmic(color);
	fragColor = vec4(sRGB(color),1.0);
}