// Shader downloaded from https://www.shadertoy.com/view/4ddGWf
// written by shadertoy user maeln
//
// Name: Simple Julia Fractal
// Description: This is my first try at rendering a fractal with a shader. The code is purposely very verbose but I'm interested in any tip to make a more compact code :) .
#define MAXITER 128

// + op for complex number.
//vec2 cadd(vec2 i1, vec2 i2)
//{
//    return vec2(i1.x+i2.x, i1.y+i2.y);
//}

// * op for complex number.
vec2 cmul(vec2 i1, vec2 i2) 
{
    return vec2(i1.x*i2.x - i1.y*i2.y, i1.y*i2.x + i1.x*i2.y);
}

// ^2 for complex number.
//float csquare(vec2 i1) 
//{
//    return i1.x*i1.x + i1.y*i1.y;
//}

int julia(vec2 z, vec2 c)
{
    int i = 0;
    vec2 zi = z;
    
    for(int n=0; n < MAXITER; ++n)
    {
        if(dot(zi,zi) > 4.0)
            break;
        i++;
        zi = cmul(zi,zi) + c;
        
    }
    
    return i;
}

vec4 gen_color(int iter)
{
    vec3 c1 = vec3(1.0,1.0,1.0);
    vec3 c2 = vec3(0.0,0.6,0.3);
    vec3 m = vec3(float(iter)/float(MAXITER));
    vec3 base = mix(c1,c2,m);
    return vec4(base,1.0);
}

// Remap the OpenGL space to the space where the julia set is defined ( [(-2;-2),(2;2)] ).
vec2 space(vec2 res, vec2 coord)
{
    // Center the coordinate so that (0,0) is in the center of the screen.
    vec2 base = (2.*coord.xy - res.xy) / res.x;
    // base*2 so that the range is [-2;2] (the julia set is defined on this range)
    return base*2.;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 z = space(iResolution.xy, fragCoord.xy);
    // Display the julia fractal for C = (-0.8, [0.0;0.3]).
    int iter = julia(z, vec2(-0.8, mix(0.0, 0.3, sin(iGlobalTime))));
	fragColor = gen_color(iter);
}