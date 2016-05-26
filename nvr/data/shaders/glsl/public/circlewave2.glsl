// Shader downloaded from https://www.shadertoy.com/view/Xd33DH
// written by shadertoy user FabriceNeyret2
//
// Name: CircleWave2
// Description: trochoid waves caused by dephased rotations of water.
//    inspired by RenoM's  https://www.shadertoy.com/view/4dc3D8
// inspired by RenoM's  https://www.shadertoy.com/view/4dc3D8

#define SCALE 20.
#define SPEED 9.
#define FREQUENCY .3

float d;
#define D(p,o)  ( (d=length(p-o)*5.)<=.6 ? 1.-d : 0. )
//#define P(i)    if (i.y<10.) O.gb += D(i-p, .5 + r * sin( iDate.w*SPEED + i.x*FREQUENCY + vec2(1.6,0) ));
#define P(i)    R = r * sin( iDate.w*SPEED + i.x*FREQUENCY + vec2(1.6,0)); if ((p-R).y<10.1) O.b++, O.g+= D(i-p,.5+R);

void mainImage( out vec4 O, in vec2 U )
{
    O -= O;
    vec2 R = iResolution.xy, 
         p = SCALE*(U+U/R)/R.y,
         I = vec2(.5,0);
  //float r = 1.*U.y/R.y;
    float r = .5*exp(-4.*(.5-U.y/R.y));

    P( ceil(p))
    P((ceil(p+.5)-.5))
    P((ceil(p+I)-I))

}