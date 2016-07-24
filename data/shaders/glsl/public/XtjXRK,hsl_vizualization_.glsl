// Shader downloaded from https://www.shadertoy.com/view/XtjXRK
// written by shadertoy user acterhd
//
// Name: HSL vizualization 
// Description: This need for compare for HCG color model.
const float PI = 3.14159265359;

vec3 hsv2rgb( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
	
    return c.z * mix( vec3(1.0), rgb, c.y);
}

vec3 hsl2rgb( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );

    return c.z + c.y * (rgb-0.5)*(1.0-abs(2.0*c.z-1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
    vec3 xyz = vec3(uv, 0.0);
    float angle = atan(xyz.x, xyz.z);
    vec3 color = hsl2rgb(vec3((angle + iGlobalTime / 2.0) / (PI * 2.0), abs(uv.x), uv.y * 0.5 + 0.5));
    fragColor = vec4(vec3(color), 1.0);
}