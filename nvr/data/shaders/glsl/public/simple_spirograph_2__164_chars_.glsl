// Shader downloaded from https://www.shadertoy.com/view/4dc3DM
// written by shadertoy user FabriceNeyret2
//
// Name: Simple Spirograph 2 (164 chars)
// Description: code-golfed black&amp;white version of Xor's https://www.shadertoy.com/view/lddGD4
// code-golfed black&white version of Xor's https://www.shadertoy.com/view/lddGD4

void mainImage( out vec4 o,  vec2 u )
{
	vec2  R = iResolution.xy;  u -= R*.5;  o-=o;
    
    for ( float i = 0.; i<88.; i+=8.)
    	o += // R.x = 
             1e-3/ abs(.3 - length(u)/R.y  + .2* cos( i + atan(u.y,u.x)/.785 + iDate.w) ); //atan(1)
                                                   // i*.9996 if you want to avoid the slight glitch

    // o += 2.*R.x; // uncomment (and R.x=) to see construction
}