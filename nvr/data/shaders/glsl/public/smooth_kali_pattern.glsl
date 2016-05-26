// Shader downloaded from https://www.shadertoy.com/view/MlXGWH
// written by shadertoy user bergi
//
// Name: smooth kali pattern
// Description: A hand selected 1&sup3; block in the kali set that looks a bit like voronoi cells and doesn't exhibit 'noise' - up to an iteration count of about 30.
//    mouse y = slice / x = surface selector
/* (c) stefan berke - common shadertoy.com license

   A hand selected 1³ block in the kali set 
   that looks a bit like voronoi cells 
   and doesn't exhibit 'noise' 
     - up to a certain iteration count.

   Playing with the iteration count is very nice though ;)

   It's a relatively small area but with a higher iteration
   this could be a huge generative map i presume. 

   Any help of raymarching the kali set efficiently is really appreciated.
   I mean, getting a real distance to some choosen surface value. 
   Is saw iq's dual-number mandelbrot. Is there a similiar trick for doing
   non-complex-numbered fractals?

*/   

#define NUM_ITERS 26

// for lights - not enabled by default
#define NORM_EPS 0.0002


// a voronoi like pattern for [0,1]
// max iterations before cosmos: ~31
float smoothpattern(in vec3 pos)
{
    // squeeze into the smooth region
    vec3 p = pos;
    p.x -= 0.2*p.y; // unstretch a bit
    p *= 0.06;
    p += vec3(0.32, 0.61, 0.48);
    // magic param is a function of input pos
    vec3 param = vec3(p.x); 

    // kali set
	float mag, ac = 0.;
	for (int i=0; i<NUM_ITERS; ++i)
    {
		mag = dot(p, p);
        p = abs(p) / mag - param;
        ac += mag;
    }
    
    return ac / float(NUM_ITERS)
        // keep the intensity roughly the same
        // for all points
        	* 0.9 * (0.75 + 0.25 * pos.x) 
        // and push the surface in the [0,1] range
        - 1.5;
}


vec3 smoothpattern_norm(in vec3 pos)
{
    const vec3 e = vec3(NORM_EPS, 0., 0.);
    return normalize(vec3(	smoothpattern(pos+e.xyy) - smoothpattern(pos-e.xyy),
                          	smoothpattern(pos+e.yxy) - smoothpattern(pos-e.yxy),
                          	smoothpattern(pos+e.yyx) - smoothpattern(pos-e.yyx) ));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    // z position
    float Z = iMouse.y / iResolution.y;
    // surface value
    float S = iMouse.x / iResolution.x;

    float V = min(1., smoothpattern(vec3(uv, Z)));
    vec3  N = smoothpattern_norm(vec3(uv, Z));
    
    //black/white
    vec3 col = vec3(smoothstep(S-0.01, S+0.01, V));
    
    // mix in a bit of the actual value
    col += 0.3*(vec3(V*V,V,V*V*V)-col);;
    
    // no - does not actuall look so nice
    //float light = max(0., dot(N, normalize(vec3(1,1,.5))));
    //col += 0.4 * light * vec3(1.,0.8,0.2);
    
    fragColor = vec4(col,1.0);
}