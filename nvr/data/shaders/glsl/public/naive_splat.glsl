// Shader downloaded from https://www.shadertoy.com/view/4dGXWR
// written by shadertoy user FabriceNeyret2
//
// Name: naive splat
// Description: naive splat
#define N 60. // numver of particles = NxN
#define r 3. // sprite radius  

void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy;
    O -= O;
    
    for (float y=0.; y<N; y++)
        for (float x=0.; x<N; x++) {
            vec4 T = texture2D(iChannel0,(.5+vec2(x,y))/R);
            O += step(length(T.xy*R-U),r)*vec4(T.zw,-T.zw);
        }
}