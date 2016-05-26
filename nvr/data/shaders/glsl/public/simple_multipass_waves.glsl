// Shader downloaded from https://www.shadertoy.com/view/MdKGzt
// written by shadertoy user piotrekli
//
// Name: Simple multipass waves
// Description: simple waves (move your mouse!), not physically accurate
#define DS 0.05

float sampleLightX(sampler2D channel, vec2 fragCoord)
{
    float light;
#   define S(DX, DY, WEIGHT) light += texture2D(channel, (fragCoord+vec2(DX, DY))/iResolution.xy).x*WEIGHT;
    S( 0,  1, -0.2)
    S( 0, -1,  0.2)
    S( 1,  0,  0.2)
    S(-1,  0, -0.2)
#   undef S
    return light;
}

vec2 gradientX(sampler2D channel, vec2 fragCoord)
{
    vec2 grad;
#   define S(DX, DY) grad += texture2D(channel, (fragCoord+vec2(DX, DY))/iResolution.xy).x*vec2(DX, DY);
    S( 0,  1)
    S( 0, -1)
    S( 1,  0)
    S(-1,  0)
#   undef S
    return grad;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 grad = gradientX(iChannel0, fragCoord);
    float light = sampleLightX(iChannel0, fragCoord)*20.0;
	fragColor = vec4(texture2D(iChannel1, uv+grad*DS).xyz+light*DS, 1.0);
}