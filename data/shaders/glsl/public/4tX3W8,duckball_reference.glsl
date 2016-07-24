// Shader downloaded from https://www.shadertoy.com/view/4tX3W8
// written by shadertoy user bergi
//
// Name: duckball reference
// Description: Reference shader for the 2D Kali set.
/** @file reference shader for the 2D Kali set. 
    @author stefan berke
    @version 2015/01/14

    license: gpl3
*/

/*  Simplest form of the 'duckball' fractal which looks adequate. 

    Discovered by this guy ;)
    http://www.fractalforums.com/new-theories-and-research/very-simple-formula-for-fractal-patterns

    The fractal pops up at some places here on Shadertoy.
    After a night of closely investigating the Kali world,
    i fell in love, admittedly. 

    x = abs(x) / dot(x, x) - y

    where x is the input position and y a fixed parameter, 
    both vectors of at least two dimensions. 
    The parameter values should be in the range 0 > 2.

    The list of good things i have to say about this fractal:
      - totally cheap equation
      - extends to any number of dimensions easily
        (just need to find n good parameters)
      - very complex, almost random/noisy at places while remaining 'arty'
      - zooming in on interesting parts is like cosmic

    Seemingly, the higher the dimension the more complex it gets.
    "I've seen things, you people wouldn't believe," 
    things like almost-read-to-play science fiction games 
    and depictions of the garden of shiva.

    In the forum above, Kali credited his findings to 
    Samuel Monnier's Ducks and Tglad's ballfold. 
    Hence the name of the function below.

    To keep it simple to read, the coloring is very basic
    and values of x are simply accumulated over the iteration loop.

    What else can be said for sure, play with it.
*/

#define NUM_ITER 50

vec2 duckball(in vec2 p, in vec2 param)
{
    // accumulator
    vec2 ac = vec2(0.);
    
    for (int i=0; i<NUM_ITER; ++i)
    {
        p = abs(p) / dot(p, p);
        ac += p;
        p -= param;
    }

    return min(vec2(1.), .2 * ac / float(NUM_ITER));
}


// permute through 'all' parameters of the 2d set
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ti = iGlobalTime;
    
    // ---- config ----
    
    // zoom
    float scale = 1. + .99 * sin(ti / 17.);
    // center of view
    vec2 center = vec2(0.3*sin(ti / 7.), 
                       0.3 * sin(ti / 5.));
    // fractal parameter [0,~2]
    vec2 param = vec2(0.6 + 0.5 * sin(ti / 11.),
                      0.6 + 0.5 * sin(ti / 13.));
    
    
    // construct coordinate
    vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
    uv = uv * scale + center;
    
    
    // ---- get color ----
    
    vec3 col = vec3(duckball(uv, param), 0.);
    
    fragColor = vec4(col, 1.0);
}