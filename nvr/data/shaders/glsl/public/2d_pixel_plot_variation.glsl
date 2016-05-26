// Shader downloaded from https://www.shadertoy.com/view/llsSWH
// written by shadertoy user aiekick
//
// Name: 2D Pixel Plot Variation
// Description: 2D Pixel Plot Variation of https://www.shadertoy.com/view/MtsSWH
void mainImage( out vec4 f, in vec2 g )
{
    vec2 
        s = iResolution.xy,
        v = floor(30.*(2.*g-s)/s.y);
    v.y+=v.x*cos(v.x+=v.x-=iDate.w*.5);
    f.xy = v;
}