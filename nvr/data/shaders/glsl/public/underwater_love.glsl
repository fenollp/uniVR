// Shader downloaded from https://www.shadertoy.com/view/4tfGD8
// written by shadertoy user bergi
//
// Name: underwater love
// Description: Humans tend to like watching these things in the winter sometimes.
//    Dedicated to Katta :D
/*  No there is no actual love going on,
    except the love for numbers.

    Another nice island in the absdot world
    https://www.shadertoy.com/view/4tX3W8
	(lengthy fractal forums url ommitted for style)

    Liked the feeling of the scene, so here it is (aGPL3).
    Does the usual ray marching, while using the surface normal
    to shade the pixels regardless of a hit or not.
    Together with the right fog this makes all the 
    low precission almost realtime rendering glitches
    fit the holiday atmosphere perfectly well.

    Path generation is the tricky part here.
    Anyone? 

    bergi 
*/

// PATH 1 and 2 are two short predefined paths 
// they are near to a spot where i really would like to take my girlfriend once..
// 3 is 'through the whole thing' - unchecked and unbounded
// and noise and artefacts and all but some really cool parts in between
// trust me! already at 8458 seconds ;)
// it's helpful to reduce NUM_ITER then because many parts are impossible to
// raytrace adequately for higher iterations
// especially these blue dots are quite frequent at places (just had them at ~8730)
// they appear more frequent with higher iterations and make a good star texture otherwise 
// but here they are impossible objects with very high distance although just next to the camera..
// amazing..
#define PATH 1				// 1-3
#define NUM_ITER 32			// very depended value
#define NORM_EPS 0.002	
#define NUM_TRACE 50
#define PRECISSION 0.2
#define FOG_DIST 0.1
// 3 coordinates to navigate through the sets
// be careful! this is probably where arthur dent lost fenchurch.
#define MAGIC_PARAM vec3(-.5, -.4, -1.5)

// shader-local global animation time
#define sec (iGlobalTime / 10.)

// kali set
// position range depending on parameters
// but usually at least +/- 0.01 to 2.0 or even (even much) larger
// check the camera path's in main(), it's tiny!
float duckball_s(in vec3 p) 
{
	float mag;
	for (int i = 0; i < NUM_ITER; ++i) 
	{
		mag = dot(p, p);
		p = abs(p) / mag + MAGIC_PARAM;
	}
	return mag;
}


// ---- canonical shader magic ----

// well, what is the set?
// divide inside from outside
float scene_d(in vec3 p)
{
	// numbers might look a bit off
	// but work for the renderer below
	return duckball_s(p)*0.01-0.004;
}

vec3 scene_n(in vec3 p)
{
	const vec3 e = vec3(NORM_EPS, 0., 0.);
	return normalize(vec3(
			scene_d(p + e.xyy) - scene_d(p - e.xyy),
			scene_d(p + e.yxy) - scene_d(p - e.yxy),
			scene_d(p + e.yyx) - scene_d(p - e.yyx) ));
}

vec3 scene_color(in vec3 p)
{
	vec3 ambcol = vec3(0.9,0.5,0.1);
    	// lighting
	float dull = max(0., dot(vec3(1.), scene_n(p)));
	return ambcol * (0.3+0.7*dull);
}

vec3 sky_color(in vec3 dir)
{
	vec3 c1 = vec3(0.3,0.4,0.7),
		 c2 = vec3(0.2,0.6,0.9),
		 c3 = vec3(0.0,0.3,0.5);
    	// some fade across y [-1,1]
	return mix(mix(c1, c2, smoothstep(-1., .5, dir.y)),
				c3, smoothstep(.5, .1, dir.y));
}

vec3 traceRay(in vec3 pos, in vec3 dir)
{
	vec3 p;
	float t = 0.;
	for (int i=0; i<NUM_TRACE; ++i)
	{
		p = pos + t * dir;
		float d = scene_d(p);

#if PATH == 3
        // increase distance for too close surfaces
        d += 0.01*(1. - smoothstep(0.01, 0.011, t));
#endif

	//	if (d < 0.001)
	//		break;

		t += d * PRECISSION;
	}
	
	return mix(scene_color(p), sky_color(dir), t/FOG_DIST);
}




// ---------- helper --------

// cubic interpolation from a to b using the respective derivatives ad and bd
vec3 spline_d(float t, in vec3 a, in vec3 ad, in vec3 b, in vec3 bd)
{
    float tq2 = t * t,
          tq3 = tq2 * t,
          tr1 = 2. * tq3 - 3. * tq2 + 1.,
          tr2 = tq3 - 2.*tq2 + t;
    return tr1 * a + tr2 * ad + (tq3-tq2) * bd + (1. - tr1) * b;
}

// attempt to smoothly connect 4 points
vec3 spline(float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d)
{
    return spline_d(t, a, normalize(c-a), d, normalize(d-b));
}

vec2 rotate(in vec2 v, float r)
{
	float s = sin(r), c = cos(r);
    	return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   	vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
    	uv.x *= float(iResolution.x) / float(iResolution.y);
    
	// ray direction (cheap sphere section)
	vec3 dir = normalize(vec3(uv, 1.5));

	// position & look-at
#if PATH == 1
	vec3 pos = vec3(
			2.48   + 0.01*cos(sec*2.),
        	-0.56  + 0.07*sin(sec-.05),// + 0.02*sin(sec*2.+2.),
        	-1.5   + 0.1*sin(sec)
    		);
    
	dir.xz = rotate(dir.xz, sec * 0.3);
	dir.xy = rotate(dir.xy, 1.);
    
#elif PATH == 2
    // 4 predefined points
    vec3 p_0 = vec3(2.47  , -0.56, -1.62);
    vec3 p_1 = vec3(2.474 , -0.56, -1.6);
    vec3 p_2 = vec3(2.49 ,  -0.55, -1.5);
    vec3 p_3 = vec3(2.473 , -0.51, -1.38);

    float t = .5 + .5 * sin(sec);
    vec3 pos = spline(t, p_0, p_1, p_2, p_3);

    dir.xy = rotate(dir.xy, sec);
    dir.xz = rotate(dir.xz, sec*0.7);

#else 
    // PATH == 3

    vec3 pos = vec3(1., 1. + sin(sec/21.), sin(sec/20.));
    dir.xy = rotate(dir.xy, sec*0.7 + sin(sec*0.41));
    dir.xz = rotate(dir.xz, sec*0.6);

#endif
    
    	// run
	vec3 col = traceRay(pos, dir);
  
   	fragColor = vec4(traceRay(pos, dir),1.0);
}