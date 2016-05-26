// Shader downloaded from https://www.shadertoy.com/view/4sGGRR
// written by shadertoy user Flexi
//
// Name: Simple Turing Pattern Mix
// Description: &quot;Milkdrop2&quot; Gaussian blur pyramid pipeline as sketched here: https://twitter.com/Flexi23/status/686583437814317057
//    8 blur levels for 8 channels
//    make Turing patterns easy
//    The composite is also pretty simple: Texture B inverts texture A
vec2 lower_left(vec2 uv)
{
    return fract(uv * 0.5);
}

vec2 lower_right(vec2 uv)
{
    return fract((uv - vec2(1, 0.)) * 0.5);
}

vec2 upper_left(vec2 uv)
{
    return fract((uv - vec2(0., 1)) * 0.5);
}

vec2 upper_right(vec2 uv)
{
    return fract((uv - 1.) * 0.5);
}

vec4 BlurA(vec2 uv, int level)
{
    if(level <= 0)
    {
        return texture2D(iChannel0, fract(uv));
    }
    
    uv = upper_left(uv);
    for(int depth = 1; depth < 8; depth++)
    {
        if(depth >= level)
        {
            break;
        }
        uv = lower_right(uv);
    }
    
    return texture2D(iChannel3, uv);
}

vec4 BlurB(vec2 uv, int level)
{
    if(level <= 0)
    {
        return texture2D(iChannel1, fract(uv));
    }
    
    uv = lower_left(uv);
    for(int depth = 1; depth < 8; depth++)
    {
        if(depth >= level)
        {
            break;
        }
        uv = lower_right(uv);
    }
    
    return texture2D(iChannel3, uv);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
    vec4 A = BlurA(uv, 0);
    vec4 B = BlurB(uv, 1);
        
    fragColor = mix( A, 1.- A, B);
    
//    fragColor = texture2D(iChannel3, uv); // raw Gaussian pyramid
    
}