// Shader downloaded from https://www.shadertoy.com/view/ltlGD8
// written by shadertoy user bergi
//
// Name: Space Patrol
// Description: It's space time 0.11, 0.81, 0.8. 
//    The Space Patrol &quot;ltlGD8&quot; is making it's round in the nearby Kali star system, looking for glitches - and boy they found some!
/** Space Patrol

	(c) 2015, stefan berke (aGPL3)
	
	Looked like a nice idea. 
	The volume tracer needs to be revised though, 
    or you have 4 recent GTX or Quadros SLIed together...

	update: added random start pos for tracing to remove banding
	
	Parameter and path created via
	https://www.shadertoy.com/view/XlsGDH
*/

// ------------------ "interface" -----------------------

#define QUALITY			0							// 0 = friendly but noisy, 1 = better, 2 = future
#define RANDOMIZE		1							// randomize trace start
#define POST_PROCESS	1							// cheap post-proc to hide the artefacts

const vec3 KALI_PARAM =	vec3(0.11, 0.81, 0.8);		// the magic number 
const int  NUM_ITER =	23;							// number of iterations in kali set

const float MIX_ALPHA =	1.;							// opacity of the traced samples
#if QUALITY == 0
const float DEPTH = 	0.04;						// maximum depth to trace in volume
const int 	NUM_TRACE =	40;							// number traces through volume
#elif QUALITY == 1
const float DEPTH = 	0.06;				
const int 	NUM_TRACE =	100;					
#elif QUALITY == 2
const float DEPTH = 	0.08;				
const int 	NUM_TRACE =	350;					
#endif
const float STEP = 		DEPTH / float(NUM_TRACE);


// ----------------- kali set --------------------------

vec3 kaliset(in vec3 p)
{
    vec3 c = vec3(0.);
    for (int i=0; i<NUM_ITER; ++i)
    {
        p = abs(p) / dot(p, p) - KALI_PARAM;
        c += p;
    }
    return c / float(NUM_ITER);
}

// ---------------------- renderer --------------------------

// hash functions by Dave_Hoskins https://www.shadertoy.com/view/4djSRW
float hash11(float p)
{
	vec2 p2 = fract(vec2(p * 5.3983, p * 5.4427));
    p2 += dot(p2.yx, p2.xy + vec2(21.5351, 14.3137));
	return fract(p2.x * p2.y * 95.4337);
}
float hash12(vec2 p)
{
	p  = fract(p * vec2(5.3983, 5.4427));
    p += dot(p.yx, p.xy + vec2(21.5351, 14.3137));
	return fract(p.x * p.y * 95.4337);
}

// brute force volume tracer
// it starts at the end of the ray (pos + DEPTH * dir)
// and moves towards the camera plane
// mixing-in the colors from the kaliset() function
vec3 trace(in vec3 pos, in vec3 dir)
{
#if RANDOMIZE != 0
    pos += dir * STEP * hash12(dir.xy + iGlobalTime / 100.);
#endif
    
    vec3 col = vec3(0.);
    for (int i=0; i<NUM_TRACE; ++i)
    {
        float t = float(i) / float(NUM_TRACE);
        
        vec3 p = pos + DEPTH * (1.-t) * dir;
        
        vec3 k = clamp(kaliset(p), 0., 1.) * (0.01+0.99*t);
      
        float ka = dot(k, k) / 3.;
              
        col += ka * MIX_ALPHA * (k - col);
        
    }
    
    return col;
}


vec3 postproc(in vec3 col, vec2 fragCoord)
{
    vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
    
    col *= 0.8+0.2*sin(uv.y * 240. + iGlobalTime);
    
    col *= 1. - 4.*length(max(abs(uv)-.8, 0.));
    col = min(vec3(1.), col*1.7);
    
    return col;
}


// --------------------- put it together -----------------------

/* The path more or less describes an ellipse on the x,y plane
   with the big radius on x, so we follow the direction of these star stripes
   most of the time. 
   By the way, the camera's up vector is z. */
vec3 path(in float ti)
{
    return vec3(
        0.28 + 0.16 * sin(ti),
        2.91 + 0.02 * cos(ti) + 0.006 * sin(ti * 7.),
        0.1  + 0.003 * sin(ti * 7.7)
        );
}

vec2 rotate(in vec2 v, float r)
{
	float s = sin(r), c = cos(r);
    	return vec2(v.x * c - v.y * s, v.x * s + v.y * c);
}
                
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
	float aspect = iResolution.x / iResolution.y;

#if POST_PROCESS != 0    
    float disto = hash11(uv.y/100000. + iGlobalTime / 50.);
    float distoamt = pow(hash11(iGlobalTime / 4200.), 10.);
    disto = pow(disto, 100. - distoamt * 99.);
    uv.x += disto * hash11(uv.y + iGlobalTime / 51.);
#endif
    
    float ti = iGlobalTime / 24.;
    vec3 pos = path(ti);
    
    vec3 look =  normalize(path(ti + .02) - path(ti - .02));
    vec3 up =    normalize(vec3(0., look.y, 2.));
	vec3 right = normalize(cross(look, up));
         look =  normalize(cross(up, right));
	
	const float map_size = .2;
    const vec2 map_pos = vec2(map_size + 0.01);
    
    vec2 mapuv = uv - map_pos;
    float mapr = length(mapuv) / map_size;
        
    vec3 col;
    
    // paint map
    if (mapr < 1.)
    {
        mapuv = mat2(vec2(look.y, -look.x), look.xy) * mapuv;
        pos.z = path(0.).z; // avoid wandering through the map slice
        col = kaliset(pos + 0.01 * vec3(mapuv / map_size, 0.));
        col = max(col, vec3(0.5,1.,0.5) * smoothstep(0.9, 1., mapr));
        col *= smoothstep(1., .95, mapr);
    }
    // render volume
    else
    {
        uv -= vec2(aspect*.5, .5);
        uv *= 2.;
        
        mat3 dirm = mat3(right, up, look);
    	vec3 dir = dirm * normalize(vec3(uv, 1.1));
        col = trace(pos, dir);
    }
	
#if POST_PROCESS != 0
    col = postproc(col,fragCoord);
#endif
    
    fragColor = vec4(col, 1.);
}