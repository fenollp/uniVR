// Shader downloaded from https://www.shadertoy.com/view/lsVXRw
// written by shadertoy user GregRostami
//
// Name: Ball Bounce - 125 chars
// Description: I was trying to make this shader smaller https://www.shadertoy.com/view/XsVXzm  Please help me make this shader smaller. Thank you.
// 125 chars - Obi-Wan coyote used the Force to reduce this shader!
/**/
void mainImage(out vec4 o,vec2 u)
{
    o = vec4( length(u/iResolution.y - .09 - abs( 1.6*vec2( mod(o=iDate,2.).w - 1., .4*sin(o.a*5.)))) <.1 );
}
/**/

// 137 chars - Original shader
/*
void mainImage(out vec4 o,vec2 u)
{
    u /= iResolution.y;
    o = vec4( length(u-(.09 + vec2(abs(mod(o.a=iDate.w, 2.) -1.) * 1.6, .7*abs(sin(o.a*5.))))) <.1 );    
}
*/