// Shader downloaded from https://www.shadertoy.com/view/MscSWl
// written by shadertoy user olawlor
//
// Name: Blurry Conetracer
// Description: Shows how you can build soft shadows and camera blur using a conetracer (raytracer with thickened rays) approach.
//    
//    Just a simple demo of the technique, not a production version. 
/*
A toy GLSL demonstration of "conetracing", a raytracing variant
that uses thicker cones instead of thin rays, which gives us cheap:
  - Single-sample soft shadows
  - Antialiased object edges
  - Camera blurring
  - Blurry reflections

The scene is hardcoded here, and generally just a toy demo implementation.

See the original SIGGRAPH 1984 paper "Ray Tracing with Cones" by John Amanatides,
or Cyril Crassin's Pacific Graphics 2011 "Interactive Indirect Illumination Using Voxel Cone Tracing".

This version by Dr. Orion Lawlor, lawlor@alaska.edu
Codebase stretches back to the 1990's, this version 2016-04-30 
Code released as Public Domain (though attribution is welcome!)
*/
/********************* Conetracer utilities ***************/

/**
circleSliceArea:
Return the area of:
	 the portion of a circle, centered at the origin with radius 1, 
	 which has x-coordinate greater than frac.
	 -1<=frac<=1

i.e. return the area in #'s:

<pre>
    y
 
    ^
    |<---- 1 ---->|
_--------___
    |       -_         
    |        |\_        
    |        |##\         
    |        |###\       
    |        |####|       
    |        |####|    
----+--------+####+-----> x 
    |        |####| 
    |        |####|       
    |        |###/       
    |        |##/        
    |        |/        
_   |   ___--         
 -------
 -->|  frac  |<--
</pre>

This value is also equal to the integral
      / 1
      |
      | 2*sqrt(1-x^2) dx
      |
      / frac
(multiply by r^2 to get the area for a non-unit circle)
*/
float circleSliceArea(float frac)
{
	float half_pi=3.14159265358979/2.0;
	return (
		half_pi-
		frac*sqrt((1.0-frac)*(1.0+frac))-
		asin(frac)
		);
}

struct circleOverlap_t {
	float f1; // fraction of circle 1 overlapped by circle 2
	float f2; // fraction of circle 2 overlapped by circle 1
};

/*circleOverlap:
Given two circles with radii 1.0 and r2, 
with centers separated by a distance d, return 
the fraction f1 of circle 1 overlapped by circle 2, and 
the fraction f2 of circle 2 overlapped by circle 1.
*/
//(Version with r1 not fixed to 1.0)
circleOverlap_t circleOverlap(float r1,float r2,float d)
{
	circleOverlap_t r;
	if (r1+r2<=d) //Circles do not overlap at all
		{r.f1=0.0; r.f2=0.0;}
	else if (d+r2<=r1) //Circle 2 entirely in circle 1
		{r.f1=r2*r2/(r1*r1); r.f2=1.0;}
	else if (d+r1<=r2) //Circle 1 entirely in circle 2
		{r.f1=1.0; r.f2=r1*r1/(r2*r2);}
	else {
	//Circles partially overlap, creating a crescent shape
	//Compute the area of the circles
		float pi=3.14159265358979;
		float area1=r1*r1*pi;
		float area2=r2*r2*pi;
	//Compute area of overlap region
		float alpha=(r1*r1+d*d-r2*r2)/(2.0*d);
		float beta=d-alpha;
		float area_overlap=r1*r1*circleSliceArea(alpha/r1)+
		                  r2*r2*circleSliceArea(beta/r2);
		r.f1=area_overlap/area1;
		r.f2=area_overlap/area2;
	}
	return r;
}


/***************************** shared vertex/fragment code *********************/
vec3 camera; // location of camera center
vec3 L=normalize(vec3(0.8,-0.5,0.7)); // points toward light source
float time; // time, in seconds


/* Raytracer framework */
const float invalid_t=1.0e3; // far away
const float close_t=1.0e-3; // too close (behind head, self-intersection, etc)

/* This struct describes a ray */
struct ray_t {
	vec3 C; // start point of ray (typically the camera, hence the name C)
	vec3 D; // direction of ray 
	
	float r_start; // radius of cone at start of ray
	float r_per; // change in radius as a function of (unit) ray parameter T
};

/* Return the location along this ray at this t value. */
vec3 ray_at(ray_t ray,float t) {
	return ray.C+t*ray.D;
}

/* Return the radius of this ray at this t value. 
   The "abs" allows camera rays to narrow down, then expand again.
*/
float ray_radius(ray_t ray,float t) {
	return ray.r_start + abs(t*ray.r_per);
}



/* This struct describes how a surface looks */
struct surface_hit_t {
	float shiny; /* 0: totally matte surface; 1: big phong highlight */
	vec3 reflectance; /* diffuse color */
	float mirror; /* proportion of perfect mirror specular reflection (0.0 for non-mirror) */
	float solid; /* if <1.0, object is emissive only */
};


/* This struct describes everything we know about a ray-object hit. */
struct ray_hit_t {
	vec3 P; /* world coords location of hit */
	vec3 N; /* surface normal of the hit */
	float t; /* ray t value at hit (or invalid_t if a miss) */
	float exit_t; /* where to continue world walk on a miss */
	float frac; /* fraction of ray that is covered by this object (0.0: none; 1.0: all)*/
	float shadowfrac; /* fraction of ray that is covered by all objects (0.0: none; 1.0: all)*/
	surface_hit_t s;
};

vec3 calc_world_color(vec3 C,vec3 D);

/* Return the t value where this ray hits 
    the sphere with this center and radius. */
void sphere_hit(inout ray_hit_t rh,ray_t ray,   // ray parameters
		vec3 center,float r, // object parameters
		surface_hit_t surface)  // shading parameters
{
	// solve for ray-object intersection via quadratic equation:
	//   0 = a*t^2 + b*t + c
	float a=dot(ray.D,ray.D);
	float b=2.0*dot(ray.C-center,ray.D);
	float closest_t=-b/(2.0*a); // ray T value at closest approach point
	float ray_rad=ray_radius(ray,closest_t); // radius at closest approach
	float center_to_center=length(ray_at(ray,closest_t)-center); // distance between centers
	circleOverlap_t overlap=circleOverlap(r,ray_rad,center_to_center);
	float rayFrac=min(overlap.f2,1.0);
	if (rayFrac==0.0) return; // ray misses completely
	
	float first_t, last_t;
	first_t=last_t=closest_t; // ray-object intersection point
	float c=dot(ray.C-center,ray.C-center)-r*r;
	float det=b*b-4.0*a*c;
	if (det>=0.0) { /* a real hit (not just a glancing edge hit) */
		float entr_t=(-b-sqrt(det))/(2.0*a); /* - intersection == entry point */
		float exit_t=(-b+sqrt(det))/(2.0*a); /* + intersection == exit point */
		if (entr_t>close_t) first_t=entr_t;
		if (exit_t>close_t) last_t=exit_t;
	}
	
	if (first_t<close_t) return; /* behind head */
	
	// Add shadow contribution regardless of sort order:
	//rh.shadowfrac=max(rh.shadowfrac,rayFrac);  // max shadows (weird voronoi look on boundaries)
	rh.shadowfrac=min(1.0,rh.shadowfrac+rayFrac);  // sum shadows (still looks a little weird)
	
	if (first_t>rh.t) return; /* beyond another object */
	
	vec3 P=ray_at(ray,first_t); // ray-object hit point (world coordinates)
	
	/* If we got here, we're the closest hit so far. */
	rh.s=surface;
	rh.t=first_t; // hit location
	rh.exit_t=last_t; /* continue walk from exit point */
	rh.P=P;
	rh.N=normalize(P-center); // sphere normal is easy!
	rh.frac=rayFrac; 
	
}

/* Return a ray_hit for this world ray.  Tests against all objects (in principle). */
ray_hit_t world_hit(ray_t ray,float is_shadowray)
{
	ray_hit_t rh; rh.t=invalid_t; rh.frac=rh.shadowfrac=0.0;
	
// Intersect new ray with all the world's geometry:
    if (is_shadowray<0.5) {
        // The Sun
        sphere_hit(rh,ray, L*100.0,10.0,
             surface_hit_t(0.0,vec3(10.0),0.0,0.0));
    }
    
	// Black camera sphere
	sphere_hit(rh,ray, camera,0.2,
		 surface_hit_t(1.0,vec3(0.0,0.0,0.0),0.0,1.0));
	
	// Big brown outer sphere
	sphere_hit(rh,ray, vec3(0.0,0.0,-115.0),105.0,
		 surface_hit_t(1.0,vec3(0.4,0.3,0.2),0.0,1.0));
	
	// Big green outer sphere
	sphere_hit(rh,ray, vec3(0.0,0.0,-11.5),10.7,
		 surface_hit_t(1.0,vec3(0.2,0.6,0.4),0.3,1.0));

	// Wavy lines of floating red spheres
	for (float i=-2.0;i<=2.0;i+=1.0) 
	for (float j=-2.0;j<=2.0;j+=1.0) 
	{
		vec2 loc=vec2(i*2.0,j*2.0);
		// float r=length(loc)/10.0; // around green sphere
		float z=0.0;
		sphere_hit(rh,ray, vec3(loc,abs(3.0*sin(i*j+time))-z),0.3+1.0*fract(0.3*i*j),
			 surface_hit_t(1.0,vec3(0.8,0.4,0.4),0.2,1.0));
	}
	
	return rh;
}

/* Compute the world's color looking along this ray */
vec3 calc_world_color(ray_t ray) {
	vec3 skycolor=vec3(0.4,0.6,1.0);
	vec3 color=vec3(0.0);
	float frac=1.0; /* fraction of object light that makes it to the camera */
	
	for (int bounce=0;bounce<8;bounce++) 
	{
		ray.D=normalize(ray.D);
	/* Intersect camera ray with world geometry */
		ray_hit_t rh=world_hit(ray,0.0);

		if (rh.t>=invalid_t) {
			color+=frac*skycolor; // sky color
			break; // return color; //<- crashes my ATI
		}

	/* Else do lighting */
		if (rh.s.solid>0.5) { // solid surface 
			if (dot(rh.N,ray.D)>0.01) rh.N=-rh.N; // flip normal to face right way
            
            /*
            // Phong (crude hack, 'sun' sphere works better)
			vec3 H=normalize(L+normalize(-ray.D));
            float specular=rh.s.shiny*pow(clamp(dot(H,rh.N),0.0,1.0),500.0);
            */
			float diffuse=clamp(dot(rh.N,L),0.0,1.0);

			// check shadow ray 
			ray_t shadow_ray=ray_t(rh.P,L, ray_radius(ray,rh.t),0.01);
			ray_hit_t shadow=world_hit(shadow_ray,1.0);
			if (shadow.t<invalid_t) {
				float illum=1.0-shadow.shadowfrac;
				diffuse*=illum; 
				//specular*=illum; 
			}

			float ambient=0.05;

			vec3 curObject=(ambient+diffuse)*rh.s.reflectance; // +specular*vec3(1.0);
			
			color+=frac*rh.frac*curObject;
			//color=rh.N; // debug: show surface normal at hit
        } else { // emissive object
            color+=frac*rh.frac*rh.s.reflectance;
        }
		
	/* Check for ray continuation */
		if (rh.frac<1.0) 
        { // partial hit--continue ray walk to composite background
			if (rh.s.mirror>0.0) { // uh oh, need two recursions
				// fake partial mirror using sky light
				color+=frac*rh.frac*rh.s.mirror*skycolor;
				//color+=vec3(1,0,0); 
			}
			
			frac*=(1.0-rh.frac);
			
			float t=rh.exit_t+0.1;
			ray.r_start=ray_radius(ray,t);
			ray.C=ray_at(ray,t);
		}
		else if (rh.s.mirror>0.0) { // mirror reflection
			frac*=rh.s.mirror;
			float t=rh.t;
			ray.r_start=ray_radius(ray,t);
            float curvature=10.0; // HACK: should depend on radius
            ray.r_per=curvature*ray.r_per; 
			ray.C=ray_at(ray,t);
			//color+=rh.s.mirror*calc_world_color(rh.P,reflect(D,rh.N));
			ray.D=reflect(ray.D,rh.N); // bounce off normal
		}
		else break;
		if (frac<0.005) return color;
	} 
	
	return color;
}

/* 
// Old GLSL main 
uniform vec3 camera; // world coordinates of camera
varying vec4 myColor;
varying vec3 location; // world coordinates of our pixel

void main(void) {
	vec3 C=camera; // origin of ray (world coords)
	vec3 D=location-camera; // direction of ray (world coords)
	ray_t camera_ray=ray_t(C,D,0.0,2.0/768.0);

	gl_FragColor.rgb=calc_world_color(camera_ray);
	gl_FragColor.a=1.0; // opaque
}
*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xx-0.5;
    vec2 mouse = iMouse.xy / iResolution.xy-0.5;
    time=iGlobalTime;
    camera=vec3(5.0*mouse.x,-10.0,5.0+5.0*mouse.y);
    
	vec3 C=camera; // origin of ray (world coords)
	vec3 D=normalize(vec3(uv.x,1.0,uv.y-0.2)); // direction of ray (world coords)

    float blur=abs(10.0*sin(0.5*time)); // wild time-dependent blurring
   	//float blur=1.3; // reasonable antialiasing
    ray_t camera_ray=ray_t(C,D,0.1/iResolution.x,blur/iResolution.x);

	fragColor=vec4(calc_world_color(camera_ray),1.0);
}


// VR stuff is UNTESTED!
void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 fragRayOri, in vec3 fragRayDir )
{
    float blur=1.3;
    ray_t camera_ray=ray_t(fragRayOri+vec3(0.0,-10.0,0.0),fragRayDir,0.1/iResolution.x,blur/iResolution.x);
	fragColor=vec4(calc_world_color(camera_ray),1.0);
}

