// Shader downloaded from https://www.shadertoy.com/view/4ddGR8
// written by shadertoy user FabriceNeyret2
//
// Name: smallest square code (94)
// Description: what is the smallest code for square ? (scaling with window resolution).
void mainImage( out vec4 o,  vec2 u )
{ 
    
    
// smallest square code
    
     u = step(.5,abs( u+u-(o.xy = iResolution.xy)) / o.y ); o -=o- u.x-u.y;       // 94 by 834144373
  // u = step(-.5, -abs( u+u- (o.xyz = iResolution).xy ) / o.y ); o *= u.x*u.y;   // 95 rcread + FabriceNeyret2 
  // o.xyz = iResolution; u = step( -.5, -abs( u+u - o.xy) / o.y ); o *= u.x*u.y; // 95 by rcread

 // vec3 R=iResolution;

    // u = 1.-step(.5,abs(u+u-R.xy)/R.y); o-=o- u.x*u.y;     //  99  by FabriceNeyret2 
    // u = .5-abs(u+u-R.xy)/R.y;     o-=o- 1e3/min(u.x,u.y); //  99
    // u = abs(u+u-R.xy)/R.y; o-=o- step(max(u.x,u.y),.5);   // 101

}