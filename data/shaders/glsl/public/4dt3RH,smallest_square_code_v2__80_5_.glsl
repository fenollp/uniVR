// Shader downloaded from https://www.shadertoy.com/view/4dt3RH
// written by shadertoy user 834144373
//
// Name: Smallest Square Code v2 (80+5)
// Description: Challenge form FabriceNeyret's shader : [url]https://www.shadertoy.com/view/4ddGR8[/url]

/////////////////////////
////here is 80+5 chars version 
void mainImage( out vec4 o,  vec2 u )
{   
  //if you have a error,maybe you should uncomment here 
  //---------------for Win/Mac/Linux :)
  o -= o;
  //-------------------
  o += length(step(1e2,abs(u+u-iResolution.xy))); // Nrx version to reduce 3 chars :-)
  //o += length(step(.0,abs(u+u-iResolution.xy)-1e2));  
}



//////////////////////////
////here is 85+5 chars version by myself
/*
void mainImage( out vec4 o,  vec2 u )
{   
  //if you have a error,maybe you should uncomment here 
  o -= o;
  u =1.- sign(abs(u+u-iResolution.xy)-2e2);
  o += u.x*u.y;
}
*/