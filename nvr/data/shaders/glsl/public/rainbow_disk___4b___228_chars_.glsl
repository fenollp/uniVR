// Shader downloaded from https://www.shadertoy.com/view/4scXDr
// written by shadertoy user FabriceNeyret2
//
// Name: rainbow disk - 4b ( 228 chars)
// Description: compaction of https://www.shadertoy.com/view/XtjSWD
// compaction of https://www.shadertoy.com/view/XtjSWD (see variants)

void mainImage( out vec4 o, vec2 u )
{
    float t=iDate.w/5e2, C=cos(t), S=sin(t);
 	u = 36.3* ( u+u - (o.xy=iResolution.xy) ) / o.y;
    o-=o;
    
#define B(k)   cos( u = u*mat2(C,-S,S,C)+ k ).x  * cos(k) / 6.
   
    for (float a=0.; a<6.3; a+=.1)
        o += vec4( B(a), B(a+2.1), B(a-2.1), 1) ;

}