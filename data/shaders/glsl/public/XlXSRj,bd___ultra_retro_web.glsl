// Shader downloaded from https://www.shadertoy.com/view/XlXSRj
// written by shadertoy user brunonDEV
//
// Name: bD - Ultra Retro WEB
// Description: Shader is the future.
//    bD is the future.
//    You are the future.
void mainImage( inout vec4 f, vec2 c )
{
    c.y/=.26;
    f.brg=cross(mod(c.xxy,.3),c.yxx*sin(iDate.w));
}