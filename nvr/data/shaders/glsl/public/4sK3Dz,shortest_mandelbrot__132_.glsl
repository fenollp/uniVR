// Shader downloaded from https://www.shadertoy.com/view/4sK3Dz
// written by shadertoy user FabriceNeyret2
//
// Name: shortest Mandelbrot (132)
// Description: can you get it shorter ? ;-)
/* // 95 by Fabrice, buy violating all rules :-)

void mainImage( out vec4 O, vec2 c ) 
{
    for (int i=0; i < 99; i++) 
       O.xy = c/2e2-1. -mat2(O.xy,-O.y,O.x)*O.xy ;    
}
/**/


// 132 chars by GregRostami
    
void mainImage( out vec4 O, vec2 c )
{
    O-=O; 
    vec2 R = iResolution.xy,  z = c-c;

    for (int i=0; i < 99; i++) 
       O += dot(z= mat2(z,-z.y,z.x)*z + (c+c-R)/R.y, z);  
    // O += length(z= mat2(z,-z.y,z.x)*z + (c+c-R)/R.y);  // +1, without the spot at 0
}

/**/




/* // 139 by Fabrice - but adds a central spot + reverse video
void mainImage( out vec4 O, vec2 c )
{
    vec2 R = iResolution.xy;
    O -= O;
    vec2 z = c-c;

    for (int i=0; i < 99; i++) 
    { O += dot(z= mat2(z,-z.y,z.x)*z + (c+c-R)/R.y, z); }
}
/**/




/* // 148 by Fabrice

void mainImage( out vec4 O,  vec2 c )
{
    O.xyz = iResolution;
    c = (c+c-O.xy)/O.y;
    O -= O;
    vec2 z = c-c;
    
    for (int i=0; i<99; i++) 
    {  dot(z= mat2(z,-z.y,z.x)*z + c,  z) < 4. ?  O : O++; }
}
/**/




// the game started here : https://www.shadertoy.com/view/4sVGWz  around 269 chars