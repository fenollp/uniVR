// Shader downloaded from https://www.shadertoy.com/view/Md3GDH
// written by shadertoy user FabriceNeyret2
//
// Name: XOR Pattern - expanded (215)
// Description: playing around 104 shader https://www.shadertoy.com/view/Ms3GW8
//    ( at some time it's xor pattern :-p )
// playing around 104 shader https://www.shadertoy.com/view/Ms3GW8


// 185 chars (anim #1) + 30 =215 with the new animation #3
void mainImage(out vec4 o, vec2 I)
{
 // float t = iDate.w;                                   // #1
 // float t = iDate.w  + I.y/9e1;                        // #2 fancy variant
    float t = iDate.w; t += max(0.,sin(-.3*t))* I.y/9e1; // #3
    
    o-=o; I*= 3.;
    for (float i=0.;i<8.;++i) {
        vec2 C=cos(I/=2.),S=sin(I);
        o.xyz += i/32.*step( vec3( C.x*C.y, S.x*S.y, S.x+S.y ),  // S.x*S.y < 0. = xor
                                   sin( t + vec3(1.6, 0, t) ) ); // c(t), s(t), s(2t)
    }
}
/**/





/* // 195 chars
void mainImage(out vec4 o, vec2 I)
{
    float t = iDate.w;
 // float t = iDate.w  + I.y/9e1; // fancy variant

    o-=o; I*= 3.;
    for (float i=0.;i<8.;++i) {
        I/=2.;
        vec2 C=cos(I),S=sin(I);
     // S.x*S.y < 0. ? o += i/32. : o;   // xor code-golfed
        o.xyz += i/32.*step( vec3( C.x*C.y, S.x*S.y, S.x+S.y  ),                                   sin(t + vec3(1.6,0,t)) );
                             vec3( cos(t) , sin(t) , sin(t+t) ) ); 
    }
}
/**/





/* // 208 chars
void mainImage(out vec4 o, vec2 I)
{
    float t = iDate.w;
 // float t = iDate.w  + I.y/9e1; // fancy variant

    o-=o; I*= 3.;
    for (float i=0.;i<8.;++i) 
        I/=2., 
     // sin(I.x)*sin(I.y) < 0. ? o += i/32. : o;   // xor code-golfed
        cos(I.x)*cos(I.y) < cos(t)   ? o.r += i/32. : i,  
        sin(I.x)*sin(I.y) < sin(t)   ? o.g += i/32. : i, 
        sin(I.x)+sin(I.y) < sin(t+t) ? o.b += i/32. : i; 
}
/**/