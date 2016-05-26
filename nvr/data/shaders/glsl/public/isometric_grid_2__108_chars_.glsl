// Shader downloaded from https://www.shadertoy.com/view/ls3XW8
// written by shadertoy user FabriceNeyret2
//
// Name: Isometric Grid 2 (108 chars)
// Description: code golfing of  lejeunerenard's https://www.shadertoy.com/view/ltjGWt
// code golfing of  lejeunerenard's https://www.shadertoy.com/view/ltjGWt

/**/      // 108 chars

void mainImage( out vec4 O,  vec2 U )
{
    U =  fract( vec2(4,6.7) * U/iResolution.y );

    O = vec4( U.x < .5 == U.x < 1.-U.y == U.x < U.y );
}
/**/





/**      // 110 chars

void mainImage( out vec4 O,  vec2 U )
{
    U.y *= 5./3.;
    U =  fract( 4.*U/iResolution.y);

    O = vec4( U.x < .5 == U.x < 1.-U.y == U.x < U.y );
}
/**/



/**      // 121 chars

void mainImage( out vec4 O,  vec2 U )
{
    U.y *= 5./3.;
    U =  fract( 4.*U/iResolution.y);

    O = vec4( (U.x < .5) == ( ( U.x + U.y < 1.) == ( U.x - U.y < 0. )));
}
/**/



/**      // 140 chars

void mainImage( out vec4 o,  vec2 U )
{
    U.y *= 5./3.;
    U =  fract( 4.*U/iResolution.y);

    o = vec4(U.x + U.y < 1., U.x - U.y < 0., U.x < .5, 1);
    o +=  abs(o.z - abs(o.x-o.y))-o;
}
/**/



/**      // 150 chars

void mainImage( out vec4 o,  vec2 U )
{
    U.y *= 5./3.;
    U =  fract( 4.*U/iResolution.y);

    float s = abs(   step( U.x + U.y, 1.)
                   - step( U.x - U.y, 0.)
                         ),
          d  = step( U.x, .5);   
    
	o +=  abs(d - s)-o;
}
/**/
