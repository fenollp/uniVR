// Shader downloaded from https://www.shadertoy.com/view/XsdXRl
// written by shadertoy user FabriceNeyret2
//
// Name: Moon 2 (171 chars)
// Description: more explaination here: https://www.shadertoy.com/view/XstXzs
void mainImage( out vec4 O, vec2 U )
{ 	U /= iResolution.y; vec2 V = U+U-1. ,W = asin(V/=.8); W.x = acos(V.x/cos(W.y))-iGlobalTime;
    O = vec4(texture2D(iChannel0,.5+.5*W).x < U.x
             &&dot(V,V)<1.);    // -1 by Coyote
}