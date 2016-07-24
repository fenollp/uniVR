// Shader downloaded from https://www.shadertoy.com/view/MlBSRd
// written by shadertoy user Macint
//
// Name: dotted grid sphere
// Description: tron-like grid on a sphere
#define PI 3.14159265359
#define ZMAX 12.0
#define GRIDINTERVAL 40.0/(2.0*PI)
#define DASHINTERVAL 200.0/(2.0*PI)

struct Intersection
{
	vec3 p;
    bool vis;
	float dist;
};

Intersection sphereintersect(vec3 raydir, vec3 origin) {
    //origin.z + raydir.z*t = plane.
    vec3 sphereorigin = origin + vec3(0,19.5,0);
    float sphereradius = 20.0;
    
    float A = dot(raydir,raydir);
    float B = 2.0*dot(raydir,origin-sphereorigin);
    float C = dot(origin-sphereorigin,origin-sphereorigin) - sphereradius*sphereradius;
    
    Intersection i;
    i.vis = false;
    
    if ( (B*B - 4.*A*C) < 0. ) {
        //imaginary!
    } else {
        float tmp_sqr = sqrt(B*B-4.*A*C);
        float t1 = (-B + tmp_sqr)/(2.*A);
        float t2 = (-B - tmp_sqr)/(2.*A);

        if (t1 < 0. && t2 < 0.) {

        } else {
            //find the smallest non zero t
            float t;
            if ( (t1 > 0. && t1 < t2) || (t2 < 0. && t1 > 0.) ) {
                t = t1;
            } else if (t2 > 0. && t2 < t1) {
                t = t2;
            }
            
            i.p = origin + raydir*t;
            i.vis = true;
	        i.dist = t;
        }

    }
	return i;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 pos = -1.0 + 2.0 * ( fragCoord.xy / iResolution.xy );
	vec2 posAR;
	posAR.x = pos.x * (iResolution.x/iResolution.y);
	posAR.y = pos.y;
    
    vec3 origin = vec3(0,0,iDate.w-10.0);
    vec3 raydir = vec3(posAR.x,posAR.y,1) - vec3(0,0,0);
    Intersection i = sphereintersect(raydir,origin);
    
    if (i.vis) {
        float d = 0.0;
        bool draw = (
            (
                sin(i.p.x*GRIDINTERVAL) < (-0.999) &&
            	sin(i.p.z*DASHINTERVAL) > 0.95
            ) 
            ||
            (
                sin(i.p.z*GRIDINTERVAL) < -0.999 &&
                sin(i.p.x*DASHINTERVAL) > 0.95
            )
        );
        d = (draw ? 1.0 : 0.0);
        fragColor = vec4(0,d,0,1);
        fragColor *= ((i.dist < ZMAX) ? 1. - i.dist/ZMAX : 0.);
    }
    else {
    	fragColor = vec4(0,0,0,0);
    }
}