// Shader downloaded from https://www.shadertoy.com/view/4dVGzd
// written by shadertoy user FabriceNeyret2
//
// Name: Escher-like tiling
// Description: .
/**/ // 254 chars original version 


void mainImage( out vec4 O, vec2 U )
{
	U *= 12./iResolution.y;
    O-=O;
    vec2 f = floor(U), u = 2.*fract(U)-1.;  // ceil cause line on some OS
    float b = mod(f.x+f.y,2.), y;

    for(int i=0; i<4; i++) 
        u *= mat2(0,-1,1,0),
        y = 2.*fract(.2*iDate.w+U.x*.01)-1.,
	    O += smoothstep(.55,.45, length(u-vec2(.5,1.5*y)));
   
    if (b>0.) O = 1.-O; // try also without :-)
}

/**/


/* // shorter version: 212 chars

void mainImage( out vec4 O, vec2 U )
{
    O-=O;
    vec2 f = ceil(U*= 12./iResolution.y), u = 2.*fract(U)-1.;

#define q   u = u.yx, u.x*=-1., O += step(length( u - vec2(.5, 3.*fract(.2*iDate.w+U.x*.01)-1.5) ), .5)
    q; q; q; q;
    
    f.x+f.y,2.>0. ? O = 1.-O : O;   // golfed by 834144373
}

/**/