// Shader downloaded from https://www.shadertoy.com/view/Xlf3D8
// written by shadertoy user bergi
//
// Name: scifi
// Description: More explorations of the Kali set. 
//    Watch for at least 5 hours, or play with the offset in line 39.
/*  i like artefacts
    
	Another nice island in the absdot world
    https://www.shadertoy.com/view/4tX3W8
	(lengthy fractal forums url ommitted for style)

	aGPL3 / (c) 2014 stefan berke

	Watch for at least 5 hours, or play with the offset in line 39.
	But beware, this is like those Planetarium shows where the camera 
	travels with approximately 1000 light years per second to show us 
	the beauty of the milky way.
	It's not related to our daily experience. 
	The Kali set gets really interesting when we zoom in on a particular
	spot. We just need the coordinates!
*/

#define PATH 3				// 1-3
#define NUM_ITER 19			// very depended value
#define NUM_TEX_ITER 60		// iterations for texture
#define NORM_EPS 0.002	
#define NUM_TRACE 100
#define PRECISSION 0.1
#define FOG_DIST 0.05
#define DIMENSIONS 3		// 3 or 4 - complexity switch

#if DIMENSIONS == 3
// 3 coordinates to navigate through the sets
// be careful! this is probably where arthur dent lost fenchurch.
#define MAGIC_PARAM vec3(-.4+0.3*sin(sec/7.), -.8, -1.5 + 0.01*sin(sec/3.))

#elif DIMENSIONS == 4
// a 4 dimensional key to our three-dimensional space
#define MAGIC_PARAM vec4(-.4+0.3*sin(sec/17.), -.31, -1.5 + 0.01*sin(sec/13.3), -0.5)
#endif

// shader-local global animation time
// add an offset to jump to other places
float sec = iGlobalTime / 5. + 124.;


// -------------------------- fractal -----------------------------

#if DIMENSIONS == 3
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

// same as above but in 'some' color
vec3 duckball_color(in vec3 p) 
{
    vec3 col = vec3(0.);
	float mag;
	for (int i = 0; i < NUM_TEX_ITER; ++i) 
	{
		mag = dot(p, p);
		p = abs(p) / mag + MAGIC_PARAM;
        col += p;
	}
	return min(vec3(1.), 2.0 * col / float(NUM_TEX_ITER));
}

#elif DIMENSIONS == 4

float duckball_s(in vec3 pos) 
{
    vec4 p = vec4(pos, 0.1);
	float mag;
	for (int i = 0; i < NUM_ITER; ++i) 
	{
		mag = dot(p, p);
		p = abs(p) / mag + MAGIC_PARAM;
	}
    // it seems much more crowded in 4d
    // so increase the distance to surfaces
	return mag * 2.7;
}

vec3 duckball_color(in vec3 pos) 
{
    vec4 p = vec4(pos, 0.1), col = vec4(0.);
	float mag;
	for (int i = 0; i < NUM_TEX_ITER; ++i) 
	{
		mag = dot(p, p);
		p = abs(p) / mag + MAGIC_PARAM;
        col += p;
	}
	return min(vec3(1.), col.xyz / float(NUM_TEX_ITER));
}

#endif

// ---- canonical shader magic ----

float scene_d(in vec3 p)
{
	return min(50.1+50.*sin(sec/12.), duckball_s(p)*0.01-0.004);
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
	vec3 ambcol = 
        vec3(0.9,0.5,0.1) * (0.2+duckball_color(p));
    
    // lighting
	float dull = max(0., dot(vec3(1.), scene_n(p)));
	return ambcol * (0.3+0.7*dull);
}

vec3 sky_color(in vec3 pos, in vec3 dir)
{
	vec3 c = vec3(0.2,0.6,0.9);
    return c * 0.5 + 0.1 * duckball_color(dir + 0.3 * pos);
}

vec3 traceRay(in vec3 pos, in vec3 dir)
{
	vec3 p;
	float t = 0.;
	for (int i=0; i<NUM_TRACE; ++i)
	{
		p = pos + t * dir;
		float d = scene_d(p);

        // increase distance for too close surfaces
        d += 0.01*(1. - smoothstep(0.01, 0.011, t));

	//	if (d < 0.001)
	//		break;

		t += d * PRECISSION;
	}
	
	return mix(scene_color(p), sky_color(p, dir), min(2.6, t/FOG_DIST));
}




// ---------- helper --------

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

    vec3 pos = vec3(0.   + 0.25 * sin(sec/47.), 
                    0.   + 0.85 * sin(sec/17.), 
                    1.   + 0.95 * sin(sec/20.));
    dir.xy = rotate(dir.xy, sec*0.7 + sin(sec*0.41));
    dir.xz = rotate(dir.xz, sec*0.6);
    
    	// run
	vec3 col = traceRay(pos, dir);
  
   	fragColor = vec4(traceRay(pos, dir),1.0);
}