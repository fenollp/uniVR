// Shader downloaded from https://www.shadertoy.com/view/Msc3WN
// written by shadertoy user FabriceNeyret2
//
// Name: TunnelProjection 3b (150)
// Description: a variant of https://www.shadertoy.com/view/lsdGWH
// a variant of https://www.shadertoy.com/view/lsdGWH

void mainImage( out vec4 o, vec2 I ) {
    o = iResolution.xyzy/2.; 
    float l = length(I-=o.xy),   // *.5 maybe better
          t = iDate.w;
    o = sin( sin(.3*t)*(o/=l) + t ) * sin( 10.*atan(I.y,I.x) + l*.1 + 3.*t )  ;
}