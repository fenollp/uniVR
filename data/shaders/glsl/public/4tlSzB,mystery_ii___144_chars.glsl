// Shader downloaded from https://www.shadertoy.com/view/4tlSzB
// written by shadertoy user GregRostami
//
// Name: Mystery II - 144 chars
// Description: Here's another version of Dave Hoskins' Mystery Mountain: https://www.shadertoy.com/view/llsGW7
//    We've already had an AMAZING size optimization with the help of coyote and Fabrice.
//    Thanks to coyote, we have the first terrain ray marcher in ONE TWEET!!
//Size optimizer extraordinaire coyote reworked the math to
//remove vec4() to break ONE TWEET (136 chars)

void mainImage(out vec4 o,vec2 w)
{
    o-=o;
    vec4 p = iDate;
    for( int i=0; i<999; i++ )
        o.x < p.y*.8 ?
            p.xy += w/1e4,
            p -= .03,
            o = texture2D(iChannel0, p.xw/50.,-99.)
          //o = texture2D(iChannel0, p.xw/1e2) < Swap the above line with this for 136 chars.
          : o;
}


//Thanks to Fabrice the shader is now 142 chars:
/*
void mainImage(inout vec4 o,vec2 w)
{
    vec4 p = iDate;
    for( int i=0; i<999; i++ )
        o.x < p.y*.2 ?
            o = texture2D(iChannel0, p.xw/2e2,-99.),
          //o = texture2D(iChannel0, p.xw/2e2), < Swap the above line with this for 142 chars.
        	p += vec4(w.xyy/7e3,0)-.05
          : o;
}
*/

//Original shader at 144 chars:
/*
void mainImage(out vec4 o,vec2 w)
{
    vec4 p = iDate/.1;
    for( int i=0; i<999; i++ )
        -o.x < p.y*.01 ?
            o = texture2D(iChannel0, p.xw/3e3,-99.),
          //o = texture2D(iChannel0, p.xw/3e3), < Swap the above line for 144 chars.
        	p += vec4(w.xyy/7e2,0)-.5
          : o;
}
*/