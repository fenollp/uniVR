// Shader downloaded from https://www.shadertoy.com/view/4lS3Dt
// written by shadertoy user spacegoo
//
// Name: 121chars
// Description: zou
//    
void mainImage(out vec4 o, vec2 i)
{
    o.gb=i*mod(ceil(iDate.w-pow(length(i/=iResolution.xy),cos(iDate.w)*4.)*(i.x+i.y)),4.);
}// #shadertoy