// Shader downloaded from https://www.shadertoy.com/view/MtfXzr
// written by shadertoy user dgreensp
//
// Name: Cheap Noise
// Description: This is just iq's procedural noise (see e.g. https://www.shadertoy.com/view/4sfGzS) with slight syntactic alterations.  Slower than sampling a texture, but nice and simple and pretty darn fast.
float noise(vec3 x)
{
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.-2.*f);
	
    float n = p.x + p.y*157. + 113.*p.z;
    
    vec4 v1 = fract(753.5453123*sin(n + vec4(0., 1., 157., 158.)));
    vec4 v2 = fract(753.5453123*sin(n + vec4(113., 114., 270., 271.)));
    vec4 v3 = mix(v1, v2, f.z);
    vec2 v4 = mix(v3.xy, v3.zw, f.y);
    return mix(v4.x, v4.y, f.x);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.yy;
    float result = noise(vec3(uv*16., iGlobalTime));
	fragColor = vec4(vec3(result),1.0);
}