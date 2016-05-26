// Shader downloaded from https://www.shadertoy.com/view/4sK3RD
// written by shadertoy user Flexi
//
// Name: Rock-Paper-Scissor-4D
// Description: Multi-scale &quot;Milkdrop2&quot; Gaussian blur diffusion, mouse drag and drop vortex pair plane deformation, cyclic rgba reaction, gradient lookups for expansive flow and edgy color map
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

vec2 GradientA(vec2 uv, vec2 d, vec4 selector, int level){
    vec4 dX = 0.5*BlurA(uv + vec2(1.,0.)*d, level) - 0.5*BlurA(uv - vec2(1.,0.)*d, level);
    vec4 dY = 0.5*BlurA(uv + vec2(0.,1.)*d, level) - 0.5*BlurA(uv - vec2(0.,1.)*d, level);
    return vec2( dot(dX, selector), dot(dY, selector) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pixelSize = 1. / iResolution.xy;
    vec2 aspect = vec2(1.,iResolution.y/iResolution.x);

    vec2 d = pixelSize*2.;
    vec4 dx = (BlurA(uv + vec2(1,0)*d, 1) - BlurA(uv - vec2(1,0)*d, 1))*0.5;
    vec4 dy = (BlurA(uv + vec2(0,1)*d, 1) - BlurA(uv - vec2(0,1)*d, 1))*0.5;

    d = pixelSize*1.;
    dx += BlurA(uv + vec2(1,0)*d, 0) - BlurA(uv - vec2(1,0)*d, 0);
    dy += BlurA(uv + vec2(0,1)*d, 0) - BlurA(uv - vec2(0,1)*d, 0);
    vec2 lightSize=vec2(0.5);

    fragColor = BlurA(uv+vec2(dx.x,dy.x)*pixelSize*8., 0).x * vec4(0.7,1.66,2.0,1.0) - vec4(0.3,1.0,1.0,1.0);
    fragColor = mix(fragColor,vec4(8.0,6.,2.,1.), BlurA(uv + vec2(dx.x,dy.x)*lightSize, 3).y*0.4*0.75*vec4(1.-BlurA(uv+vec2(dx.x,dy.x)*pixelSize*8., 0).x)); 
    fragColor = mix(fragColor, vec4(0.1,0.,0.4,0.), BlurA(uv, 1).a*length(GradientA(uv, pixelSize*2., vec4(0.,0.,0.,1.), 0))*5.);
    fragColor = mix(fragColor, vec4(1.25,1.35,1.4,0.), BlurA(uv, 0).x*BlurA(uv + GradientA(uv, pixelSize*2.5, vec4(-256.,32.,-128.,32.), 1)*pixelSize, 2).y);
    fragColor = mix(fragColor, vec4(0.25,0.75,1.,0.), BlurA(uv, 1).x*length(GradientA(uv+GradientA(uv, pixelSize*2., vec4(0.,0.,128.,0.), 1)*pixelSize, pixelSize*2., vec4(0.,0.,0.,1.), 0))*5.);
    fragColor = mix(fragColor, vec4(1.,1.25,1.5,0.), 0.5*(1.-BlurA(uv, 0)*1.).a*length(GradientA(uv+GradientA(uv, pixelSize*2., vec4(0.,128.,0.,0.), 1)*pixelSize, pixelSize*1.5, vec4(0.,0.,16.,0.), 0)));

    //    fragColor = BlurA(uv, 0); // simple bypass
    //    fragColor = BlurB(uv, 0); // simple bypass
    //    fragColor = texture2D(iChannel3, uv); // raw Gaussian pyramid

}