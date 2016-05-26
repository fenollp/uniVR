// Shader downloaded from https://www.shadertoy.com/view/XdtXWn
// written by shadertoy user FabriceNeyret2
//
// Name: Mach bands and dithering
// Description: 256 grey (or R/G/B) levels is far not enough: visual system see steps in gradient and color oscillations.&amp;lt;br/&amp;gt;But dithering  within +- 1/512 helps a lot.
//    
//    Artefact is faint: better look in full screen.
#define V0 .45
#define V1 .55

void mainImage( out vec4 O, vec2 uv )
{
	vec2 U = uv/iResolution.xy;
    float l = U.x; //(U.x+U.y)/2.;

    O = U.y < .5 ? mix ( vec4(V0),
                          vec4(V1),
                          l )
	              : mix ( vec4(V0)*vec4(1.137, 1,1,1),
                          vec4(V1)*vec4(1, 1,1.121,1),
                          l );

    if ( abs(U.y-.5)>.25 ) O+= (texture2D(iChannel0,uv/256.)-.5)/256. ;
}