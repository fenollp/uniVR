// Shader downloaded from https://www.shadertoy.com/view/MlfXRS
// written by shadertoy user FabriceNeyret2
//
// Name: Twindragon - 129 chars
// Description: compaction inspired from of  NinjaKoala's shader https://www.shadertoy.com/view/4lX3zB
//    
//    motion: uncomment line 8
// compaction inspired from of  NinjaKoala's shader https://www.shadertoy.com/view/4lX3zB
// more accurate compaction: https://www.shadertoy.com/view/ltlXW7



 // 129 col
void mainImage( out vec4 o, vec2 i ){
    // i*=mat2(sin(iDate.w+vec4(1,2,0,1)*1.6));  if you want motion (+58 chars)
    o = vec4(0.0);    
    vec4 p = i.xxxy + i.y;

    for (float k=17.; k>0.; k--)
        p.yz += p.w = -2.*floor(p=p.yzwx/=2.).y,
        o += p/exp2(k);
}





/* // 131 col
void mainImage( inout vec4 o, vec2 i ){
    i.x += i.y;
    vec4 p = i.xxyy;

	for (float k=17.; k>0.; k--)
        p = p.yzxw -= 2.*(p.x= floor(p.y/2.)),
        o += p/exp2(k);
}
*/


/* // 131 col
void mainImage( inout vec4 o, vec2 i ){
    vec4 p = i.xyyy + i.y;

	for (float k=17.; k>0.; k--)
        p.xy  += p.z = -2.*floor(p/=2.).x,
        o += p/exp2(k),
        p = p.yzxw;
}
*/


/*  // 129 N&B 
void mainImage( inout vec4 o, vec2 i ){
    i += i.y;
	float f;

	for (float k=17.; k>0.; k--)
        i += f = -2.*floor(i/=2.).x,
        o += i.x/exp2(k),
        i.x = f, i = i.yx;   // i  = vec2(i.y,-f);
}
*/

/*  // 128 N&B 
void mainImage( inout vec4 o, vec2 i ){
    vec4 p = i.xxxy + i.y;

    for (float k=17.; k>0.; k--)
        o+= ( p.z += p.w = -2.*floor(p=p.yzwx/=2.).y )/exp2(k);
}
*/