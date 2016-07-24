// Shader downloaded from https://www.shadertoy.com/view/4dG3zd
// written by shadertoy user FabriceNeyret2
//
// Name: electric flare
// Description:  application of Fourier workflow  https://www.shadertoy.com/view/4dGGz1
//    Look in full screen ! 
// application of https://www.shadertoy.com/view/4dGGz1


#define SIZE (iResolution.x/2.-30.) //Size must be changed in each tab.

void mainImage( out vec4 O,  vec2 U )
{    
    vec2 R = iResolution.xy;
    U = ( U - R/2.);
    vec2 uv = mod(U,SIZE)/ R;
    O = length(texture2D(iChannel2, uv).xy) *vec4(1.3,.5,.3,0); // indeed, is abs(texture.x)
    O /= length (U/R.y);
}