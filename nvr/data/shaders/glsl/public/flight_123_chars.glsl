// Shader downloaded from https://www.shadertoy.com/view/XlX3D2
// written by shadertoy user GregRostami
//
// Name: Flight 123 chars
// Description: My fist shader is less than one tweet, inspired by baldand's:
//    https://www.shadertoy.com/view/4lsGWN
//    
//    Thanks to coyote the shader now is an AMAZING 129 chars!!
// Thanks to Fabrice, this shader is now 123 chars:
/**/
void mainImage(out vec4 o,vec2 i)
{
    o.xy = i/iResolution.y;
    o = abs( o.x += sin(o -= .8).y ) 
        * texture2D(iChannel0, o.yz/o.x+iGlobalTime);
}
/**/

/*
void mainImage( out vec4 o, vec2 i )
{
    o = vec4(i,0,0)/iResolution.y-.8;
    o = abs( o.x += sin(o.y) ) * texture2D(iChannel0,o.yw/o.x+iGlobalTime);
}
*/

/* Here's the original shader for reference:
void mainImage( out vec4 o, vec2 i )
{
	vec4 u = vec4(i,0,1)/iResolution.y-.8;
    u.x += sin(u.y);
	o = texture2D(iChannel0,u.yw/u.x+iGlobalTime)*abs(u.x);
}
*/