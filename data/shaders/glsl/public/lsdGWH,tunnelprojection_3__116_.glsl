// Shader downloaded from https://www.shadertoy.com/view/lsdGWH
// written by shadertoy user FabriceNeyret2
//
// Name: TunnelProjection 3 (116)
// Description: another variant from jt's https://www.shadertoy.com/view/ldtGD8
// a variant from jt's https://www.shadertoy.com/view/ldtGD8

void mainImage( out vec4 o, vec2 I ) {
    o = iResolution.xyzy/2.; 
    o = sin( 2.*o/length(I-=o.xy) +iDate.w ) * sin( 10.*atan(I.y,I.x) )  ;
// try replace  2. by 1, 4, 8, sin(.3*iDate.w)
}