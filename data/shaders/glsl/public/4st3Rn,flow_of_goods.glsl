// Shader downloaded from https://www.shadertoy.com/view/4st3Rn
// written by shadertoy user movAX13h
//
// Name: Flow Of Goods
// Description: From one of those superfancy Euclideon videos... https://youtu.be/Irf-HJ4fBls?t=184
//    I know, I should look into translucent raymarching... feel free to enhance this, if you like.
// Flow of goods, fragment shader by movAX13h, Nov.2015

#define SHADOW
#define EDGES
#define SUN_POS vec3(15.0, 15.0, -8.0)

#define GAMMA 2.2

//---
float sdBox(vec3 p, vec3 b)
{	
	vec3 d = abs(p) - b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdHexPrism(vec3 p, vec2 h)
{
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+q.y*0.5,q.y)-h.x);
}

float sdTriPrism(vec3 p, vec2 h)
{
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

vec2 rotate(vec2 p, float a)
{
	vec2 r;
	r.x = p.x*cos(a) - p.y*sin(a);
	r.y = p.x*sin(a) + p.y*cos(a);
	return r;
}

// globals
float T = iGlobalTime;
vec3 sun = normalize(SUN_POS);
const float focus = 5.0;
const float far = 50.0;
const vec3 green = vec3(0.2, 1.0, 0.9);
const vec3 red = vec3(0.9, 0.3, 0.3);

struct Hit
{
	float d;
	vec3 col;
};

Hit scene(vec3 p)
{
    Hit hit = Hit(1e6,vec3(0.01));
    if (p.z > 4.0) return hit;
    
    vec3 r = p;
    float side = sign(p.z);
	vec3 c = mix(green,red,side);
    
    p.x = mod(-side*p.x-3.0*iGlobalTime,5.5)-2.75;
	p.z = mod(p.z, 6.0)-3.0;
    
    hit.d = sdBox(p-vec3(0.0, -0.9, 0.0), vec3(8.0, 0.2, 1.3)); // road
    float arrow = smoothstep(0.6, 0.65, abs(mod(side*r.x, 2.6)-0.6-abs(p.z)));
    hit.col = mix(hit.col, green, arrow*(0.4 + max(0.0, 0.6*sin(0.1*r.x+side*4.0*iGlobalTime))));
    hit.col = mix(hit.col, vec3(1.0), smoothstep(0.5, 1.9, abs(p.z)));
        
    float t = sdHexPrism(p-vec3(1.1, -0.1, 0.0), vec2(0.3, 0.3)); // truck
    t = min(t, sdBox(p-vec3(0.0, 0.0, 0.0), vec3(0.9, 0.4, 0.4)));
    t = min(t, sdBox(p-vec3(1.35, -0.3, 0.0), vec3(0.1, 0.2, 0.3)));
    t = min(t, sdBox(p-vec3(-0.8, -0.3, 0.0), vec3(0.1, 0.2, 0.4)));
    if (t < hit.d) { hit = Hit(t,vec3(1.0)); }
    
    vec3 q = p-vec3(0.19, 0.0, 0.0); // arrow
    q.xy = rotate(q.xy, -0.5);
    t = sdTriPrism(q, vec2(0.2, 0.41));
    t = min(t, sdBox(p-vec3(-0.14, 0.0, 0.0), vec3(0.25, 0.1, 0.41)));
    if (t < hit.d) { hit = Hit(t,c); }
    
	return hit;
}

vec3 normal(vec3 p)
{
	float c = scene(p).d;
	vec2 h = vec2(0.01, 0.0);
	return normalize(vec3(scene(p + h.xyy).d - c, 
						  scene(p + h.yxy).d - c, 
		                  scene(p + h.yyx).d - c));
}

float edges(vec3 p) // by srtuss
{
	float acc = 0.0;
	float h = 0.01;
	acc += scene(p + vec3(-h, -h, -h)).d;
	acc += scene(p + vec3(-h, -h, +h)).d;
	acc += scene(p + vec3(-h, +h, -h)).d;
	acc += scene(p + vec3(-h, +h, +h)).d;
	acc += scene(p + vec3(+h, -h, -h)).d;
	acc += scene(p + vec3(+h, -h, +h)).d;
	acc += scene(p + vec3(+h, +h, -h)).d;
	acc += scene(p + vec3(+h, +h, +h)).d;
	return acc / h;
}

vec3 colorize(Hit hit, vec3 n, vec3 dir, const in vec3 lightPos)
{
	float diffuse = 0.3*max(0.0, dot(n, lightPos));
	
	vec3 ref = normalize(reflect(dir, n));
	float specular = 0.4*pow(max(0.0, dot(ref, lightPos)), 6.5);
    
	return (hit.col + 
			diffuse * vec3(0.9) +
			specular * vec3(1.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
    vec2 pos = (fragCoord.xy*2.0 - iResolution.xy) / iResolution.y;
	
	vec3 cp = vec3(15.0, 8.0, -13.0); 
    vec3 ct = vec3(0.0, 0.0, 0.0);
   	vec3 cd = normalize(ct-cp);
    vec3 cu  = vec3(0.0, 1.0, 0.0);
    vec3 cs = cross(cd, cu);
    vec3 dir = normalize(cs*pos.x + cu*pos.y + cd*focus);	
	
    Hit h;
	vec3 col = vec3(0.16);
	vec3 ray = cp;
	float dist = 0.0;
	vec3 glowCol = vec3(0.0);
        
	// raymarch scene
    for(int i=0; i < 60; i++) 
	{
        h = scene(ray);
        
		if(h.d < 0.0001) break;
		
		dist += h.d;
		ray += dir * h.d * 0.9;

        if(dist > far) 
		{ 
			dist = far; 
			break; 
		}
    }

	float m = (1.0 - dist/far);
	vec3 n = normal(ray);
	col = colorize(h, n, dir, sun)*m;

    #ifdef EDGES
	float edge = edges(ray);
    col = mix(col, vec3(0.0), min(0.1*edge, 1.0));
    #endif
	
	// SHADOW with low number of rm iterations (from obj to sun)
	#ifdef SHADOW
	vec3 ray1 = ray;
	dir = normalize(SUN_POS - ray1);
	ray1 += n*0.002;
	
	float sunDist = length(SUN_POS-ray1);
	dist = 0.0;
	
	for(int i=0; i < 35; i++) 
	{
		h = scene(ray1 + dir*dist);
		dist += h.d;
		if (abs(h.d) < 0.001) break;
	}

	col -= 0.24*smoothstep(0.5, -0.3, min(dist, sunDist)/max(0.0001,sunDist));
	#endif
    
	col -= 0.2*smoothstep(0.0,2.0,length(pos));
	col = clamp(col, vec3(0.0), vec3(1.0));
	col = pow(col, vec3(2.2, 2.4, 2.3)) * 2.1;
	col = pow(col, vec3(1.0 / GAMMA));
    
	fragColor = vec4(col, 1.0);
}
