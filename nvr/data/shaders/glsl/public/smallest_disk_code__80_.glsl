// Shader downloaded from https://www.shadertoy.com/view/XddGR8
// written by shadertoy user FabriceNeyret2
//
// Name: smallest disk code (80)
// Description: what is the smallest code for disk ? (scaling with window resolution).
void mainImage( out vec4 o,  vec2 u )
{ 
    
   
// smallest disk code
    
       o.xyz = iResolution;    o -=   o.y + 2.*length( u+u - o.xy ); // 80 red by 834144373
    // o = iResolution.xxxy; o -= 2.*length(u+u - o.zw) + o.w;       // 81 by AntoineC
    // o.xyz = iResolution;    o -=o- o.y + 2.*length( u+u - o.xy);  // 82 revised by 834144373
    // o.xyz = iResolution*.5; o -=o- o.y + 2.*length(u-o.xy);       // 83 by rcread  
    
// vec2 R = iResolution.xy; 
    // o-=o- .5*R.y + length(u+u-R);         // 83 by FabriceNeyret2
    // o-=o- R.y+dot(u+=u-R,u)/90.;          // 84 by AntoineC
	// o-=o- 1./( .5-length(u+u-R)/R.y );    // 88
	// o-=o- 1e3*( .5-length(u+u-R)/R.y );   // 89
    // o-=o- step( length(u+u-R)/R.y, .5 );  // 89
    // o-=o; length(u+u-R)/R.y < .5 ? o++:o; // 89
    
    
    
// smallest circle code
    
    // o-=o- 1./(.5*R.y-length(u+u-R));      // 88 by FabriceNeyret2
    // o-=o- abs(.5*R.y-length(u+u-R));      // 89
    // o-=o- step( abs(.5-length(u+u-R)/R.y), .01); // 98
    
    

}