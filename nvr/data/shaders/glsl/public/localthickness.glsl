// Shader downloaded from https://www.shadertoy.com/view/ldGGzR
// written by shadertoy user ZigguratVertigo
//
// Name: LocalThickness
// Description: This shadertoy describes how one can compute &quot;Local Thickness&quot;, the surface thickness approximation term described in [1] and [2]. Approximates how &quot;thick&quot; or &quot;thin&quot; various parts of an object are.
//
// Local Thickness
//
// This shadertoy describes how one can compute "Local Thickness", the surface thickness approximation term described
// in [1] and [2]. 
//
// The general idea behind the technique is to use a computation similar to ambient occlusion (AO) to approximate how 
// "thick" or "thin" various parts of an object are. The trick behind this technique is to invert the surface normal 
// and calculate ambient occlusion from inside the surface. That's it ;)
//
// This gives a rough approximation of how occluded part of an object is relative to its surroundings, therefore giving 
// a sense of thickness.  While this approximation is really not at all accurate - real thickness being relative to an entry 
// and exit point - the overall result still gives a good sense of thin vs thick. Also, it's possible to remap the value 
// to something that makes more sense to your needs. For example, if you need a big difference between thick and thin
// objects, you can play with the contrasts. It's also recommended to have a base grey value for thickness, to show better
// transitions, and not start from pure black. Otherwise, the transition might be too harsh.
//
// I've created this shadertoy because a few people have implemented an interpretation of local thickness, and I didn't find
// it complete. Then again, this wouldn't have been possible without the great many shadertoys I've used as reference, 
// which you can find below. I also have other ideas on how to improve this, and will keep updating it. :)
//
// Just like for any AO calculation, results will vary depending on the scene, and distance-based tolerance factors. 
//
// A few parameters below are tweakable, THICKNESS_MAX_DISTANCE will give you the most control. Also, you can get away
// with way less samples, especially if your surfaces are not super smooth. 
//
// References:
//	[1] GDC 2011 – Approximating Translucency for a Fast, Cheap and Convincing Subsurface Scattering Look
//		http://colinbarrebrisebois.com/2011/03/07/gdc-2011-approximating-translucency-for-a-fast-cheap-and-convincing-subsurface-scattering-look/
//
//  [2] [BarréBrisebois11] Barré-Brisebois, Colin and Bouchard, Marc.”Real-Time Approximation of Light Transport in 
//      Translucent Homogenous Media”, GPU Pro 2, Wolfgang Engel, Ed. Charles River Media, 2011.
//
//  [3] Translucency in Frostbite 2 engine: https://www.youtube.com/watch?v=t7Qw05BUuss
//
// Shadertoy References:
//  [4] Raymarching - Primitives, by IQ
//	    https://www.shadertoy.com/view/Xds3zN
//  
//  [5] Alien Coccoons, by XT95
//      https://www.shadertoy.com/view/MsdGz2
//  
//  [6] Shadeaday 6 / 4 / 2015 - a bunch of rods, by cabbibo
//      https://www.shadertoy.com/view/4tS3Dt
// 

// Constants
const float PI = 3.14159265359;
const float MAX_TRACE_DISTANCE	   = 50.0;
const int   NUM_TRACE_STEPS 	   = 128;
const float INTERSECTION_PRECISION = 0.0001;
const float THICKNESS_MAX_DISTANCE = 1.0;
const int 	NUM_THICKNESS_SAMPLES  = 128;
const float NUM_SAMPLES_INV 	   = 1.0 / float(NUM_THICKNESS_SAMPLES);    

// Function Declarations
vec2 Scene(vec3 p);
float Hash(float n);
vec3 RandomSphereDir(vec2 rnd);
vec3 RandomHemisphereDir(vec3 dir, float i);

//---------------------------------------------------------------------------------------------------------
// Local Thickness 
//---------------------------------------------------------------------------------------------------------
float CalculateThickness(vec3 p, vec3 n, float maxDist)
{
    float thickness = 0.0;
    
    for (int i=0; i < NUM_THICKNESS_SAMPLES; i++)
    {
        // Randomly sample along the hemisphere inside the surface
        // To sample inside the surface, flip the normal
        float l = Hash(float(i)) * maxDist;
        vec3 rd = normalize(-n + RandomHemisphereDir(-n, l)) * l;
        
        // Accumulate
        thickness += l + Scene(p + rd).x;
    }
	
    return clamp(thickness * NUM_SAMPLES_INV, 0.0, 1.0);
}

//---------------------------------------------------------------------------------------------------------
// SDF Functions
//---------------------------------------------------------------------------------------------------------
float sdPlane(vec3 p)
{
	return p.y;
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r)
{
    vec3 pa = p - a, ba = b - a;
    float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
    return length(pa - ba * h) - r;
}

float smin(float a, float b, float k)
{
    float res = exp(-k * a) + exp(-k * b);
    return -log(res) / k;
}

vec2 opU(vec2 d1, vec2 d2)
{
	return (d1.x < d2.x) ? d1 : d2;
}

float opBlend(vec2 d1, vec2 d2)
{
    return smin(d1.x, d2.x, 8.0);
}

//---------------------------------------------------------------------------------------------------------
// Helper Functions
//---------------------------------------------------------------------------------------------------------
float Hash(float n)
{
    return fract(sin(n) * 3538.5453);
}

vec3 RandomSphereDir(vec2 rnd)
{
	float s = rnd.x * PI * 2.0;
	float t = rnd.y * 2.0 - 1.0;
	return vec3(sin(s), cos(s), t) / sqrt(1.0 + t * t);
}

vec3 RandomHemisphereDir(vec3 dir, float i)
{
	vec3 v = RandomSphereDir(vec2(Hash(i + 1.0), Hash(i + 2.0)));
	return v * sign(dot(v, dir));
}

mat3 LookAtMatrix(vec3 ro, vec3 ta, float roll)
{
    vec3 ww = normalize(ta - ro);
    vec3 uu = normalize(cross(ww, vec3(sin(roll), cos(roll), 0.0)));
    vec3 vv = normalize(cross(uu, ww));
    return mat3(uu, vv, ww);
}

void Camera(out vec3 camPos, out vec3 camTar, float time, float mouseX)
{
    float an = 0.3 + 10.0 * mouseX + PI * sin(time * 0.1);
	camPos = vec3(3.5 * sin(an), 1.0, 3.5 * cos(an));
    camTar = vec3(0.0, 0.0, 0.0);
}

float Random(vec2 co)
{
	return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

//--------------------------------
// Scene Functions 
//--------------------------------
vec2 Scene(vec3 p)
{  
    float time = 195.0 + 7.0 + iGlobalTime;
   	vec2 res = vec2(sdPlane(p - vec3(0.0, -1.0, 0.0)), 0.0);
    
    for (int i = 0; i < 15; i++)
    {
        vec3 sp = texture2D(iChannel0 , vec2(float(i) / 15.0, 0.2 + sin(time * .00001) * 0.1)).xyz;
        vec3 ep = texture2D(iChannel0 , vec2(float(i) / 15.0, 0.4 + sin(time * .00001) * 0.1)).xyz;

        sp.x = Random(sp.xy);
        sp.y = Random(sp.zy);
        sp.z = Random(sp.xz);
        sp = sp * 2.0 - 1.0;
       
        ep.x = Random(ep.xy);
        ep.y = Random(ep.zy);
        ep.z = Random(ep.xz);
		//ep = ep * 2.0 - 1.0; // slightly slanted, for style ;)

    	res.x = opBlend(res, vec2(sdCapsule(p, sp * 1.5, ep * 1.5, 0.20),  float( i ) + 1.));
    }

   	return res;
}
 
vec2 Raymarch(vec3 ro, vec3 rd)
{
    float h =  INTERSECTION_PRECISION*2.0;
    float t = 0.0;
	float res = -1.0;
    float id = -1.0;
    
    for (int i=0; i< NUM_TRACE_STEPS ; i++)
    {
        if (h < INTERSECTION_PRECISION || t > MAX_TRACE_DISTANCE)
            break;
	   	
        vec2 m = Scene(ro + rd * t);
        h = m.x;
        t += h;
        id = m.y;
        
    }

    if (t < MAX_TRACE_DISTANCE) res = t;
    if (t > MAX_TRACE_DISTANCE) id =-1.0;
    
    return vec2(res, id);
    
}

vec3 Normal(vec3 p)
{
    vec3 eps = vec3(0.001, 0.0, 0.0);
	vec3 n 	 = vec3(Scene(p + eps.xyy).x - Scene(p - eps.xyy).x,
	    			Scene(p + eps.yxy).x - Scene(p - eps.yxy).x,
	    			Scene(p + eps.yyx).x - Scene(p - eps.yyx).x);
	
    return normalize(n);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = (-iResolution.xy + 2.0 * fragCoord.xy) / iResolution.y;
    vec2 m = 0.5 + iMouse.xy / iResolution.xy;
    
    // camera movement
    vec3 ro, ta;
    Camera(ro, ta, iGlobalTime, m.x);

    mat3 camMat = LookAtMatrix(ro, ta, 0.0);
	vec3 rd = normalize(camMat * vec3(p.xy, 1.3));
    vec2 res = Raymarch(ro, rd);
    
    vec3 col = vec3(0.0);
        
    if (res.y > -0.5)
    {
    	vec3 p = ro + rd * res.x;
        col = vec3(CalculateThickness(p, Normal(p), THICKNESS_MAX_DISTANCE));
        
        // For visualization purposes
        // at the end of the day, you can remap this based on your needs
        col = pow(col*col*col*7.0+0.0125, vec3(1.0 / 2.2));        
    }
    
    fragColor = vec4(col, 1.0);
}