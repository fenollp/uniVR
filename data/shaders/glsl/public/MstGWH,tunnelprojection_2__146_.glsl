// Shader downloaded from https://www.shadertoy.com/view/MstGWH
// written by shadertoy user FabriceNeyret2
//
// Name: TunnelProjection 2 (146)
// Description: a variant from jt's https://www.shadertoy.com/view/ldtGD8
// a variant from jt's https://www.shadertoy.com/view/ldtGD8

// -5 ( 146 ) by coyote

void mainImage( out vec4 o, vec2 I ) {
    I -= o.zw=iResolution.xy/2.;
    o = 1. - vec4(.5,1,9,0) *
        ( sin(atan(I.y,I.x)/.1) * sin(20.*(o.w/=length(I))+iDate.w) - 1. + o.w );
}





/* // 151 

void mainImage( out vec4 o, vec2 I ) {
    I -= o.zw=iResolution.xy/2.;
    o -=o-- - sin(10.*atan(I.y,I.x)) *  sin(20.*(o.w/=length(I))+iDate.w) -o.w;
 // o *= vec4(.5,1,9,0);
    o = 1.- o*vec4(.5,1,9,0);
}
/**/