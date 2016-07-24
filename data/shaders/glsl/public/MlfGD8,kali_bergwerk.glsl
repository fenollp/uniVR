// Shader downloaded from https://www.shadertoy.com/view/MlfGD8
// written by shadertoy user bergi
//
// Name: Kali-Bergwerk
// Description: After a hit on the head, the dwarf seems to have forgotten where she came from. Use the mouse to help her find the exit.
/*  Kali-Bergwerk

	Another nice island in the absdot world
    https://www.shadertoy.com/view/4tX3W8
	(lengthy fractal forums url ommitted for style)

	aGPL3 / (c) 2014 stefan berke

	Oh no, there is no flooooooo...

	This tunnel would be a great fly-through show. 
	Up/down in the hardcoded path is actually the z coord
	which can be travelled for a while.
	I messed with some path generation but today only came up with
	this spline which behaves like a drunken mine worker.

	Raytracing the set is quite difficult for me in general.
	This one looks not completely bad if you let the values untouched. 
	It's terribly wrong down there, but i couldn't fix it and keep the look..
	The distant glitches are not very realistic but they show the
	inherent tree ornament when looking along z, which forms the cave.

	Anyways, just came across this part in 2d and it looked interesting. 
	Would be create to find a function to describe a nice flight through the whole cave. 
	See the DEBUG_PLOT define and CEILING..
*/

#define PATH 1				// 0=mouse, 1=hardcoded spline
#define NUM_ITER 25			// iterations for distance field
#define NUM_TEX_ITER 35		// iterations for texture
#define NORM_EPS 0.002	
#define NUM_TRACE 100
#define PRECISSION 0.1		// unfortunately needs very low stepwidth
#define FOG_DIST 0.27
#define NUM_SUPERSAMP 1  	// super samples - super slow - and somewhat ugly

// 1 for slice of the cave (mouse y for slice z-position, x for surface distance)
// 2 for value graph of a slice
#define DEBUG_PLOT 0

#define CEILING 0			// ornamental ceiling :)

// shader-local global animation time
#define sec (iGlobalTime - 2.)


// -------------------------- helper ------------------------------

// just invented these, not special, rather lousy
float hash(float x) { return fract(sin(x*123.543912)*55.39284); }
vec3 hash3(vec3 x) { return fract(cos(x * vec3(1123.481, 135.2854, 385.21))
                                        * vec3(1593.70341, 23142.54073, 497.2)); }
float noise(float x)
{
    float f = floor(x), t = fract(x);
    return hash(f) * (1.-t) + t * hash(f+1.);
}


vec2 rotate(in vec2 v, float r)
{
	float s = sin(r), c = cos(r);
    	return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

// cubic 
vec2 spline(float x, vec2 v0, vec2 v1, vec2 v2, vec2 v3) 
{
	vec2 p = (v3 - v2) - (v0 - v1);
	return p*(x*x*x) + ((v0 - v1) - p)*(x*x) + (v2 - v0)*x + v1;
}

// -------------------------- fractal -----------------------------


/* Kali set
   somewhere in the sqaure x,y ~[0,1] is a nice 'metal-tree-skelleton-hand-snake-tunnel' 
   where a result of at least 0.1 should be the inside to make it a cave
   the 'tree decoration' is on the xy-plane while the actual tunnel expands along z.
   The fractal parameter is locked to the x position.
*/
float tunnelthing_scalar(in vec3 p)
{
    p *= 0.2;
    p.x += 0.12;
    vec3 param = vec3(p.x);
    p.xy *= 4.;
    
	float mag, ac = 0.;
	for (int i=0; i<NUM_ITER; ++i)
    {
		mag = dot(p, p);
        p = abs(p) / mag - param;
        ac += mag;
    }
    return 0.1 * ac / float(NUM_ITER);
}

// same as above but other iteration count
// and a color as return value
vec3 tunnel_texture(in vec3 p)
{
    vec3 pin = p;
    p *= 0.2;
    p.x += 0.12;
    vec3 param = vec3(p.x);
    p.xy *= 4.;
    
	float mag;
    vec3 ac = vec3(0.);
	for (int i=0; i<NUM_TEX_ITER; ++i)
    {
        p = abs(p) / dot(p, p) - param;
        ac += 0.5+0.5*sin(p*84.);
        ac.xy = rotate(ac.xy, p.z);
        ac.xz = rotate(ac.xz, p.y);
    }
    ac = clamp(1.1 * ac / float(NUM_TEX_ITER), 0., 1.);
    
    float mixf = 0.5*(ac.y*2.+ac.z);
#if CEILING == 1
    mixf += smoothstep(0.5, 0.6, pin.z);
#endif    

    return mix(vec3(0.3,0.5,0.8), ac, mixf);

}

// position in the tunnel for [0,1]
vec3 tunnelpos(float t)
{
    t *= 21.;
    vec2 p1  = vec2(0.1, 0.8);
    vec2 p2  = vec2(0.175, 0.73);
    vec2 p3  = vec2(0.21, 0.68);
	vec2 p4  = vec2(0.22, 0.66);
	vec2 p5  = vec2(0.24, 0.61);
    vec2 p6  = vec2(0.27, 0.59);
    vec2 p7  = vec2(0.265, 0.55);
    vec2 p8  = vec2(0.29, 0.50);
    vec2 p9  = vec2(0.33, 0.52);
    vec2 p10 = vec2(0.33, 0.47);
    vec2 p11 = vec2(0.32, 0.47);
    vec2 p12 = vec2(0.30, 0.45);
    vec2 p13 = vec2(0.31, 0.37);
    vec2 p14 = vec2(0.36, 0.35);
    vec2 p15 = vec2(0.40, 0.38);
    vec2 p16 = vec2(0.42, 0.38);
    vec2 p17 = vec2(0.40, 0.41);
    vec2 p18 = vec2(0.41, 0.45);
    // the last part is even more crappy 
    vec2 p19 = vec2(0.46, 0.49);
    vec2 p20 = vec2(0.51, 0.475);
    vec2 p21 = vec2(0.545, 0.385);
    vec2 p22 = vec2(0.535, 0.30);
    vec2 p23 = vec2(0.47, 0.26);

    vec2 p;
         if (t < 1.)  p = spline(t,     p1,p2,p3,p4);
    else if (t < 2.)  p = spline(t-1.,  p2,p3,p4,p5);
    else if (t < 3.)  p = spline(t-2.,  p3,p4,p5,p6);
    else if (t < 4.)  p = spline(t-3.,  p4,p5,p6,p7);
    else if (t < 5.)  p = spline(t-4.,  p5,p6,p7,p8);
    else if (t < 6.)  p = spline(t-5.,  p6,p7,p8,p9);
    else if (t < 7.)  p = spline(t-6.,  p7,p8,p9,p10);
    else if (t < 8.)  p = spline(t-7.,  p8,p9,p10,p10);
    else if (t < 9.)  p = spline(t-8.,  p9,p10,p11,p12);
    else if (t < 10.) p = spline(t-9.,  p10,p11,p12,p13);
    else if (t < 11.) p = spline(t-10., p11,p12,p13,p14);
    else if (t < 12.) p = spline(t-11., p12,p13,p14,p15);
    else if (t < 13.) p = spline(t-12., p13,p14,p15,p16);
    else if (t < 14.) p = spline(t-13., p14,p15,p16,p17);
    else if (t < 15.) p = spline(t-14., p15,p16,p17,p17);
    else if (t < 16.) p = spline(t-15., p16,p17,p18,p18);
    else if (t < 17.) p = spline(t-16., p17,p18,p19,p19);
    else if (t < 18.) p = spline(t-17., p18,p19,p20,p20);
    else if (t < 19.) p = spline(t-18., p19,p20,p21,p21);
    else if (t < 20.) p = spline(t-19., p20,p21,p22,p22);
    else if (t < 21.) p = spline(t-20., p21,p22,p23,p23);
        
    return vec3( p, 0.54)  
           //+ 0.01*sin(vec3(sec*0.3,sec*0.5,sec*0.7))
        	;
}



// ---- canonical rayder  ----

// 'distance' to the kali set
// not really a distance of course
// the scaling at the end is matched somewhat to 
// what the raytracer like
// in fact as you can see, it returns a negative value. 
// somehow this renders better (less noise)
// but it screws up everything below. 
// camera is tracing backwards omg
#if CEILING == 0
float scene_d(in vec3 p) { return (tunnelthing_scalar(p) - 0.5) * 0.1; }

#else
float scene_d(in vec3 p) 
{ 
    float flr = smoothstep(0.58, 0.6, p.z);
    return (tunnelthing_scalar(p) - 0.5) * 0.1 * (1.-flr); 
}
#endif

vec3 scene_n(in vec3 p)
{
	const vec3 e = vec3(NORM_EPS, 0., 0.);
	return normalize(vec3(
			scene_d(p + e.xyy) - scene_d(p - e.xyy),
			scene_d(p + e.yxy) - scene_d(p - e.yxy),
			scene_d(p + e.yyx) - scene_d(p - e.yyx) ));
}

vec3 sky_color(in vec3 pos, in vec3 dir)
{
	return vec3(0.2,0.6,0.9);
}

// returns final color
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

		t += d * PRECISSION;
	}

    vec3 nrm = scene_n(p),
    
         ambcol = tunnel_texture(p);
    
    // lighting
    float dull = max(0., dot(nrm, vec3(0.707)));
	dull = pow(dull, 2.);
    // another ambient light
    dull += max(0., dot(nrm, normalize(vec3(-1.,-0.3,2.))));
    
    vec3 col = ambcol * (0.3 + 0.7 * dull);

    return mix(col, col.zyx*0.3, min(2.0, -t/FOG_DIST));
}




// ---------- helper --------


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
   	vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
    vec2 mouse = iMouse.xy / iResolution.xy;

    // ----------- plot cave slice -----------
#if DEBUG_PLOT == 1

    vec3 p = vec3(uv*0.5+0.5, mouse.y);
    float k = tunnelthing_scalar(p);
    
    float b = k > 0.09 + 0.9*mouse.x ? 1. : 0.;
	    
    fragColor = vec4(b * tunnel_texture(p), 1.);
#endif

    // ----------- plot value graph -----------
#if DEBUG_PLOT == 2

    vec3 p = vec3(uv.x, mouse.x, mouse.y);
    float k = tunnelthing_scalar(p);
    
    uv.y = (uv.y+1.) * 4.;
    float b = k >= uv.y ? 1. : 0.;
    
    float grid = smoothstep(0.9,1., mod(uv.y, 1.));
    
    fragColor = vec4(b, b, grid, 1.);
#endif

    // ---------- render thing ----------
#if DEBUG_PLOT == 0
    
    // aspect
    uv.x *= float(iResolution.x) / float(iResolution.y);
    
	// look-at
    vec3 dir = normalize(vec3(uv, -1.5));

#if PATH == 0
    vec3 pos = vec3((mouse.x-0.5) * 5. + 0.001 * sin(sec), 
                     mouse.x-0.5       + 0.001 * sin(sec*1.1) + 0.07,
                     0.0 + mouse.y*5.);
    
#elif PATH == 1
    float derd = 1.;
    vec3 pos = tunnelpos(0.5+0.5*sin(sec/10.));
    // path derivative
    vec3 posd = (tunnelpos(0.5+0.5*sin((sec+derd)/10.)) - pos) / derd;
    float movespeed = length(posd);
    
    // walk-up-down
    pos.z += 0.02*length(posd)*sin(sec*9.)
           - 0.05+.05*sin(sec/6.);
    
    // look along path
    float rotz = atan(-posd.x, posd.y);

    // 'yaw'
    float rotup = -4.*movespeed;
    if (iMouse.z < 0.5)
    	// occasionally look up
        rotup -= 1.13 * (1. - pow(noise(sec*1.), 3.));

    // ego interaction
    if (iMouse.z > 0.5)
    {
      	rotz = -iMouse.x / iResolution.x * 6.;
        rotup += iMouse.y / iResolution.y * 4.;
    }

    dir.yz = rotate(dir.yz, rotup);
    dir.xy = rotate(dir.xy, rotz);
#endif
    
    // run
#if NUM_SUPERSAMP <= 1
    vec3 col = traceRay(pos, dir);
#else
	vec3 col = vec3(0.);
    float dofs = 0.1 + 0.03 * float(NUM_SUPERSAMP);
    for (int i=0; i<NUM_SUPERSAMP; ++i)
    {
        // some ill-formed dof
        // after the dir vec is already set
        vec3 dis = hash3(vec3(uv, 1.1) * float(1+i)) - 0.5;
		vec3 di = normalize(dir + dofs*0.05*dis);
        vec3 p = pos + 0.004*dofs*dis;;
        col += traceRay(p, di);
    }
    col /= float(NUM_SUPERSAMP);
#endif
    
   	fragColor = vec4(col,1.0);
#endif
}