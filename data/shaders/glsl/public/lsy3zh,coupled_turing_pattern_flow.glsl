// Shader downloaded from https://www.shadertoy.com/view/lsy3zh
// written by shadertoy user Flexi
//
// Name: Coupled Turing Pattern Flow
// Description: remake of http://www.cake23.de/reaction-diffusion-fish-soup.html - drag with the mouse
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

vec2 GradientA(vec2 uv, vec2 d, vec4 selector, int level){
    vec4 dX = 0.5*BlurA(uv + vec2(1.,0.)*d, level) - 0.5*BlurA(uv - vec2(1.,0.)*d, level);
    vec4 dY = 0.5*BlurA(uv + vec2(0.,1.)*d, level) - 0.5*BlurA(uv - vec2(0.,1.)*d, level);
    return vec2( dot(dX, selector), dot(dY, selector) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pixelSize = 1. /  iResolution.xy;
    vec2 uv = fragCoord.xy * pixelSize;
    fragColor = texture2D(iChannel0, uv);

    vec2 uv_bg = uv	+ (	
        GradientA(uv, pixelSize * 1.5, vec4(0.5, 1, 0, 0), 0)
        + GradientA(uv, pixelSize * 3., vec4(1, 1, 0, 0), 1)
    ) * pixelSize * 384.;

    fragColor = mix(vec4(0), vec4(0.25,0.33,0.66,0), BlurA(uv_bg, 2).b*1.6);

    fragColor = mix(fragColor, vec4(0.5,0.4,0.5,0), BlurA(uv, 0).r * (1.- BlurA(uv, 0).g));

    fragColor = mix(fragColor, 
                    mix(vec4(2,2,0,0), vec4(1.,0,0.,0), pow(1.-BlurA(uv, 0).r,2.)), 
                    BlurA(uv + GradientA(uv, pixelSize * 2., vec4(0, 1, 0, 0), 0)*pixelSize*4., 0).g);
    
    //fragColor = BlurA(uv, 0); // simple bypass
    
    //fragColor = texture2D(iChannel3, uv); // raw Gaussian pyramid

}