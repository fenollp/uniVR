// Shader downloaded from https://www.shadertoy.com/view/llXSD8
// written by shadertoy user FabriceNeyret2
//
// Name: array of threads - 129 chars
// Description: a 1 tweet variant of https://www.shadertoy.com/view/llsXWr
 // 129 chars
void mainImage(out vec4 f, vec2 u) {
    f = vec4(0.0);
    u *= 3./iResolution.y; 
    
    for (float i=-2.; i<=1.; i+=.1)
        f += (i*i+i+1.)/3e2/abs(i*(u.y-u.x-i)-u.x+2.) ;   
                         // abs(cos(iDate.w)*    //  +13 char for animation
          // (i*i*tan(iDate.w) //  +13 char for animation variant

    // f*= abs(sin(u.y*1e2)); f.rb*=0.;   // old raster-screen fashion 
} 



/* // 132 chars
void mainImage(inout vec4 f, vec2 u) {

    u *= 3./iResolution.y; 

    for (float i=-1.; i<=2.; i+=.1)
        f += (i*i-i+1.)/3e2/abs(i*(u.y-u.x-i+2.)-u.y+.6) ; // i*i-i+.5 for thin lines

} 
*/



/*  // 139 chars

void mainImage(inout vec4 f, vec2 u) {

    u = 3.*u/iResolution.y -vec2(2,1); 

    for (float i=-1.; i<=2.; i+=.1)
        f += (i*i-i+1.)/3e2/abs(i*(u.y-u.x-i)+i-u.y) ; 
} 
*/