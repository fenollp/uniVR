// Shader downloaded from https://www.shadertoy.com/view/XdtSWl
// written by shadertoy user jackdavenport
//
// Name: Raymarcher Visualization
// Description: This shader visualises the way a raymarcher works. The left side of the screen shows the depth (distance from the camera to FAR_PLANE), and the iterations (how many times the for loop in raymarch() runs to calculate that pixel).
#define MAX_ITERATIONS 128
#define MIN_DISTANCE .001
#define FAR_PLANE    64.

struct Ray { vec3 ori; vec3 dir;  };
struct Hit { float dst; int iter; };

float dstSphere(vec3 p, vec3 pos, float r) {
 
    return length(pos - p) - r;
    
}

float dstFloor(vec3 p, float y) {
 
    return p.y - y;
    
}

//Smooth Minimum by iq
//Source: http://www.iquilezles.org/www/articles/smin/smin.htm
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

float dstScene(vec3 p) {
    
    float dst = dstFloor(p, -1.);
    float sphDst = dstSphere(p, vec3(0.), 1.);
    sphDst = smin(sphDst, dstSphere(p, vec3(1.5 * sin(iGlobalTime),.5,-.5), .5), .1);
    sphDst = smin(sphDst, dstSphere(p, vec3(-1.5* sin(iGlobalTime),.25,-.5), .5), .1);
    
    dst = min(dst, sphDst);
    return dst;
    
}

Hit raymarch(Ray ray) {
 
    float d  = 0.;
    int iter = 0;
    
    for(int i = 0; i < MAX_ITERATIONS; i++) {
     
        d += dstScene(ray.ori + ray.dir * d) * .75;
        
        if(d <= MIN_DISTANCE || d > FAR_PLANE) {
         
            iter = i;
            break;
            
        }
        
    }
    
    return Hit(d,iter);
    
}

vec3 shade(Ray ray, vec2 fragCoord) {
 
    Hit scn = raymarch(ray);
    float x = iMouse.x / iResolution.x;
    if(iMouse.x == 0.) x = .5;
    
    vec3 col = vec3(0.);
    
    if((fragCoord.x / iResolution.x) <= x) {
        
        col = vec3(scn.dst) / FAR_PLANE;
        
    } else {

        col = vec3(scn.iter) / float(MAX_ITERATIONS);
        
    }
    
    return col;
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord - iResolution.xy * .5) / iResolution.y;
    
    vec3 ori = vec3(0.,0.,-3.);
    vec3 dir = vec3(uv, 1.);
    
	fragColor = vec4(shade(Ray(ori,dir),fragCoord),1.);
}