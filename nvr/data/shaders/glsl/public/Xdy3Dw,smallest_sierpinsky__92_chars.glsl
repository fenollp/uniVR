// Shader downloaded from https://www.shadertoy.com/view/Xdy3Dw
// written by shadertoy user FabriceNeyret2
//
// Name: smallest Sierpinsky. 92 chars
// Description: can you do better ? :-)
void mainImage( out vec4 o, vec2 u )
{
    o-=o;  // u*=iGlobalTime;
    for (int i=0; i<8; i++)     
        fract(u/=2.).x > fract(u.y) ? o++ : o;
 
    
    
    
     // o.zw  = fract(u/=2.), o.z > o.w ? o++ : o;  // with colors, same cost

     // o+= fract(u/=2.).x - fract(u.y);            // another fractal , -3
     // o.xy += (o.zw=fract(u/=2.)) - o.wz;         // in colors
    
     // o.r > o.g ? u : o.rg = fract(u /=2.);       // very nice color variant by 834144373 , -4
    
}