// Shader downloaded from https://www.shadertoy.com/view/ldG3Dw
// written by shadertoy user FabriceNeyret2
//
// Name: shortest binary count - 101 char
// Description: can it be smaller ? :-)
// NB: iDate.w*10eN and iGlobalTime  have same length. 1st livelier, 2nd easy debug.

// 101

void mainImage( out vec4 O, vec2 U )
{   O = mod( floor( iDate.w*2e1 / exp2(ceil(16.*U.xxxx/iResolution.x))) ,2.);  

//  O = mod( floor( iDate.w*2e1 / exp2(ceil(16.-16.*U.xxxx/iResolution.x))) ,2.); // right to left
}
/**/



/* // 102

void mainImage( out vec4 O, vec2 U )
{   O += mod( floor( iDate.w*1e1 / exp2(floor(16.*U.x/iResolution.x))) ,2.) -O;  }

/**/



/* // variant with dots // 129
void mainImage( out vec4 O, vec2 U )
{   U *= 16./iResolution.x;
    O += mod( floor( iDate.w*1e1 / exp2(floor(U.x))) ,2.)/length(fract(U)-.5)/2e1 -O;  
}
/**/



/* // 109 

void mainImage( out vec4 O, vec2 U )
{
    int v = int( iGlobalTime / exp2(floor(16.*U.x/iResolution.x)) );
    O = vec4(v-v/2*2);
}
/**/