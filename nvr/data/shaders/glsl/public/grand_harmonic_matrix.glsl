// Shader downloaded from https://www.shadertoy.com/view/lll3D8
// written by shadertoy user bergi
//
// Name: Grand Harmonic Matrix
// Description: Visualization of all integer divisors in 3D space.
//    (And, tatatataa, my first non-kali-set shader ;-)
/*	Grand Harmonic Matrix

  	(c) 2015, stefan berke

	license: aGPL3

	The Grand Harmonic Matrix - as Jan Ten called it -
	is the visualization of all integer divisors in space. 

	One can argue that it is a most trivial thing. 
	Each sphere simply represents a quotient of the term x/y/z (or any permutation). 
	But!
	There are some fundamental yet unsolved problems in mathematics that relate to
	these divisors. Most famous is the distribution of prime numbers. 
	We know the statistics, but we don't know the real numbers, unless a computer
	found them for us. In fact, you can do the same with any number of divisors. 
	Primes have two, the most common number is four. Square numbers always have an odd
	number of divisors, etc.. They all have in common that they are quite randomly 
	distributed. 
	For me it's like a marvel. We learned to count, add and multiply, which is, 
	again, quite trivial. But somehow the result is above what scientists can know for
	sure, even after thousands of years of mathematics.
	From looking at the Grand Harmonic Matrix we can at least see immediately
	why a prime is prime - in fact we don't understand why it is so hard to find the 
	next largest prime, because it looks so trivial. 
	It's much better though to only look at the 2d version for this. 
	See for example iq's "Multiples" https://www.shadertoy.com/view/4slXzr

	This is the long overdue matrix-in-a-shader. 
	You need to play a bit with the	camera yourself to investigate stuff. 
	The default scenes show
	1) the origin (where the matrix is most crowded in all directions)
	2) a plane at faculty 7 (5040) which has A LOT of divisors
	3) a flight along one axis until forever ;)

	Some further reading.

	http://www.cymatrix.org 
		Jan and my experimental site with .. experiments
	http://divisorplot.com
		Jeffrey Ventrella's excellent investigation into the 2d matrix
	http://vimeo.com/57713992
		A video where the quotients are used as notes for a synthesizer
		(one of my favorite algorithms for computational music)
	http://www.fddb.org/shows/loco-dyna-morphics
		A more advanced composition (from about 7 to 20 min).

*/
const float PI = 					3.14159265;

const float SPHERE_RAD = 			0.25;			// must be < 0.5
const float PRECISION = 	 		0.76;			// larger radius needs smaller precission
const float SURFACE = 				0.0001;

float time =						iGlobalTime;

#define COLORS						1
#define AA							1				// oversampling for anti-aliasing
													// totally not fast!

/* Dertermines if the components in p are divisable in any order.
   Returns 0 or the resulting quotient. */
float is_harmonic(in vec3 p)
{
    p = floor(p);

    if (p.x == 0. || p.y == 0. || p.z == 0.) return 0.;

    // for negative numbers, the d == floor(d) does not work
    p = abs(p);
    // (would need extra work here to return the correct sign)
    
    // there might be a more efficient way, but i never came up
    // with one... modulo is not sufficient
    float
    d = p.x / p.y / p.z; if (d == floor(d)) return d;
    d = p.x / p.z / p.y; if (d == floor(d)) return d;
    d = p.y / p.x / p.z; if (d == floor(d)) return d;
    d = p.y / p.z / p.x; if (d == floor(d)) return d;
    d = p.z / p.x / p.y; if (d == floor(d)) return d;
	d = p.z / p.y / p.x; if (d == floor(d)) return d;

    return 0.;
}


// ---------------- raymarching -------------------

// returns distance in x, quotient in y
vec2 scene_dist(in vec3 p)
{
    float h = is_harmonic(p + .5);

    vec3 pm = mod(p + .5, 1.) - .5;
    
    // no "real distance field"
    // the trick is to place spheres at every grid cell
    // but making the unwanted spheres a radius of 0.0
    return vec2( length(pm) - SPHERE_RAD * min(1., h) + 0.001, h);
}

// for normals
// simply puts a sphere at every grid cell
// to avoid the quotient calculation
float scene_dist_any(in vec3 p)
{
    vec3 pm = mod(p + .5, 1.) - .5;
    
    return length(pm) - SPHERE_RAD;
}

// orthonormal by nimitz 
// https://www.shadertoy.com/view/4sSSW3
vec3 scene_normal(in vec3 p)
{
    vec3 e = vec3(-1., 1., .0) * 0.001;
    return normalize(
          e.xxx * scene_dist_any(p+e.xxx)
        + e.xyy * scene_dist_any(p+e.xyy)
        + e.yxy * scene_dist_any(p+e.yxy)
        + e.yyx * scene_dist_any(p+e.yyx) );
}

// intensity of color as function of distance
float intensity(float d) { return smoothstep(15., 0., d); }

// ray has the format as in trace() below
vec3 scene_color(in vec3 ray, in vec3 norm)
{
#if COLORS == 1
    // base color from divisior
    float a = ray.y * PI * 2. / 12.;
    vec3 col = .6 + .4 * vec3(sin(a), sin(a*1.5), sin(a*2.));
#else
    vec3 col = vec3(.9, 1., .8);
#endif
    col *= .2;
    
    float dull = max(0., dot(vec3(.707), norm));
    col += .3 * dull + .1 * pow(dull, 9.);
    return col * intensity(ray.z);
}

// returns surface distance in x, 
// quotient in y, way travelled in z
vec3 trace(in vec3 pos, in vec3 dir)
{
    float t = 0.;
    vec2 d = scene_dist(pos);
    for (int i=0; i<70; ++i)
    {
        if (d.x <= SURFACE)
            continue;
        
        vec3 p = pos + t * dir;
        
        d = scene_dist(p);
        
        t += d.x * PRECISION;
    }
    
    return vec3(d.x, d.y, t);
}

// ---------------------- path --------------------

vec2 rotate(in vec2 v, float r)
{
	float s = sin(r), c = cos(r);
    	return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}

void path(out vec3 pos, out vec3 dir, in float ti, in vec2 uv)
{
    float seq = mod(ti / 10., 3.);
    // fly-through
    if (seq < 1.)
    {
    	pos = vec3(.2*sin(ti), 3.+3.*sin(ti/3.), -ti * 10.);
    	dir = normalize(vec3(uv, -1.1));
        dir.yz = rotate(dir.yz, -0.3*sin(ti/3.-1.));
    }
    // faculty plane
    else if (seq < 2.)
    {
        pos = vec3(10.*sin(ti/10.), 5040.5, 10.*cos(ti/10.));
        dir = normalize(vec3(uv, -1.5));
        dir.xy = rotate(dir.xy, -0.5*sin(ti/5.+2.));
        dir.xz = rotate(dir.xz, -ti/10. + 1. + sin(ti/5.));
    }
    // origin
    else if (seq < 3.)
    {
        pos = vec3(10.*sin(ti/10.), 3.5 + 2. * sin(ti/5.), 10.*cos(ti/10.));
        dir = normalize(vec3(uv, -1.5));
        dir.yz = rotate(dir.yz, -0.5*sin(ti/5.));
        dir.xz = rotate(dir.xz, -ti/10.);
    }
}


// ------------------- full render step -----------------

vec3 render(in vec2 uv)
{
    vec3 col = vec3(0.), pos, dir;
    
    path(pos, dir, time, uv);
    
    vec3 ray = trace(pos, dir);
   
    if (ray.x <= SURFACE)
    {
        vec3 p = pos + dir * ray.z;
        vec3 n = scene_normal(p);
        col += scene_color(ray, n);
        float it = intensity(ray.z);
        
        // reflection steps
        if (it > 0.)
        for (int i = 0; i<2; ++i)
        {
            dir = reflect(dir, n);;
            pos = p + .04 * dir;
            ray = trace(pos, dir);

            if (ray.x <= SURFACE)
            {
                p = pos + dir * ray.z;
                n = scene_normal(p);
                col += scene_color(ray, n) * it / (2. + float(i));
            }
            else continue;
        }
    }
    return col;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
    float aspect = iResolution.x / iResolution.y;
    uv.x *= aspect;

#if AA < 2	
    vec3 col = render(uv);
#else
	vec3 col = vec3(0.);
    for (int j=0; j<AA; ++j)
    for (int i=0; i<AA; ++i)
    {
        vec2 pix = vec2(float(i), float(j)) / float(AA)
            		/ (iResolution.xy);
        col += render(uv + pix);
    }
    col /= float(AA*AA);
#endif
    
    fragColor = vec4(pow(col, vec3(1./2.2)),1.0);
}