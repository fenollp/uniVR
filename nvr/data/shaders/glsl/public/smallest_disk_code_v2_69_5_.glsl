// Shader downloaded from https://www.shadertoy.com/view/4sd3RH
// written by shadertoy user 834144373
//
// Name: Smallest Disk Code v2(69+5)
// Description: Challenge form FabriceNeyret's shader : [url]https://www.shadertoy.com/view/XddGR8[/url]

/////////
////here 69+5 chars version
void mainImage(out vec4 o, vec2 u){ 
    o -= o;
    o -= length(u+u-iResolution.xy)-1e2; 
}


//////////////
////here 76+5 chars version
/*
void mainImage( out vec4 o,  vec2 u )
{   
  o -= o;
  o -= length(u+u-(u=iResolution.xy))-u.y/2.;  
}
*/