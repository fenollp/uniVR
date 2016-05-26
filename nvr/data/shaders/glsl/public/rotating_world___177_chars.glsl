// Shader downloaded from https://www.shadertoy.com/view/XlsSz2
// written by shadertoy user FabriceNeyret2
//
// Name: Rotating world - 177 chars
// Description: compact version of farious shader https://www.shadertoy.com/view/XlsXRj
// compact version of colorless variant of farious shader https://www.shadertoy.com/view/XlsXRj
// with the help of coyote.

void mainImage( out vec4 o, vec2 p ) {

 vec3 S = sin(iDate.w+1.6*o.xwx), R = iResolution/4.;
    o += dot( normalize( S+S+o.xwx*S   ) , 
              normalize( vec3( sqrt(abs( R*R -dot( p -= (R+R+160.*S).xy,p) ).y)  ,p) )
            );
 
    
    // --- try one of these ! :-)
    // o = sin(40.*o); 
    // o -= o-step(texture2D(iChannel0, p/8.), o).r ;
    // o -= o-step(pow(texture2D(iChannel0, p/8.).r, .45) , o.r);
}






/* // 181

void mainImage( inout vec4 o, vec2 p ) {

    vec2 S = sin(iDate.w+1.6*o.xw), R = iResolution.xy/4.;
    o += dot( normalize( (2.+o.xxw)*S.yxx   ) , 
              normalize( vec3(p -= R+R+160.*S, sqrt(abs( R.y*R.y -dot(p,p) ))) ) 
            );

    // o = sin(40.*o); // try this !
}
*/