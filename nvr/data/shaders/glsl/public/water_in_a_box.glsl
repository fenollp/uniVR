// Shader downloaded from https://www.shadertoy.com/view/MlsSzS
// written by shadertoy user adam27
//
// Name: Water in a box
// Description: Woda, pudełko i powietrze.

float rand(vec2 v)
{
	float x = fract(sin(dot(v, vec2(1872.8497, -2574.9248))) * 72123.19);
	return x;
}

float noise(in vec2 p) 
{
    vec2 i = floor(p);
    vec2 f = fract(p);	
	vec2 u = f*f*(3.0-2.0*f);
    return -1.0+2.0*mix(mix(rand(i + vec2(0.0,0.0)), rand(i + vec2(1.0,0.0)), u.x),
						mix(rand(i + vec2(0.0,1.0)), rand(i + vec2(1.0,1.0)), u.x), u.y);
}

float map(vec2 xz)
{
	xz += noise(xz);
	vec2 a = 1.0 - abs(sin(xz));
	vec2 b = abs(cos(xz));
	return pow(dot(a, b), 0.5);
}

const mat2 mat = mat2(1.8, 1.1, -1.1, 1.8);

float water(vec3 p)
{
	vec2 xz = p.xz;
	xz.x *= 0.7;
	float amp = 1.0;
	float h = 0.0;
	float freq = 0.2;
	for (int i = 0; i < 5; i++)
	{
		float h1 = map((xz + iGlobalTime) * freq);
		float h2 = 0.0;
		h += (h1 + h2) * amp;
		freq *= 1.8;
		amp *= 0.18;
		xz *= mat;
	}
	return p.y - h;
}

vec3 getNormal(vec3 p, float d)
{
    vec3 n;
    n.y = water(p);    
    n.x = water(p + vec3(d,0,0)) - n.y;
    n.z = water(p + vec3(0,0,d)) - n.y;
    n.y = d;
    return normalize(n);
}

const int MAX_STEPS = 100;

struct Distance
{
	float value;
	vec3 color;
};

struct Hit
{
	bool is;
	vec3 pos, normal;
	vec3 color;
};
    
float box(vec3 p, vec3 s)
{ 
    vec3 w = abs(p) - s;
    return min(max(w.x,max(w.y,w.z)),0.0) + length(max(w,0.0));   
}
    
Distance add(Distance d1, Distance d2)
{
    if (d2.value > d1.value)
        return d1;
    else
        return d2;
}
    
Distance distance(vec3 p)
{   
    Distance d = Distance(box(p - vec3(0.4, 0.0, 0.0), vec3(0.02, 0.4, 0.42)), vec3(0.3, 0.7, 0.5)); 
    d = add(d, Distance(box(p + vec3(0.4, 0.0, 0.0), vec3(0.02, 0.4, 0.42)), vec3(0.3, 0.7, 0.5))); 
    d = add(d, Distance(box(p - vec3(0.0, 0.0, 0.4), vec3(0.42, 0.4, 0.02)), vec3(0.3, 0.7, 0.5))); 
    d = add(d, Distance(box(p + vec3(0.0, 0.0, 0.4), vec3(0.42, 0.4, 0.02)), vec3(0.3, 0.7, 0.5))); 
    d = add(d, Distance(box(p + vec3(0.0, 0.4, 0.0), vec3(0.4, 0.02, 0.4)), vec3(0.3, 0.7, 0.5))); 
    
    d = add(d, Distance(box(p - vec3(0.0, 0.32, 0.0), vec3(0.36, 0.02, 0.36)), vec3(0.2, 0.3, 0.6))); 
    
    return d;
}

Distance distance2(vec3 p)
{    
    
    Distance d = Distance(box(p - vec3(0.4, 0.0, 0.0), vec3(0.02, 0.4, 0.42)), vec3(0.3, 0.7, 0.5)); 
    d = add(d, Distance(box(p + vec3(0.4, 0.0, 0.0), vec3(0.02, 0.4, 0.42)), vec3(0.3, 0.7, 0.5))); 
    d = add(d, Distance(box(p - vec3(0.0, 0.0, 0.4), vec3(0.42, 0.4, 0.02)), vec3(0.3, 0.7, 0.5))); 
    d = add(d, Distance(box(p + vec3(0.0, 0.0, 0.4), vec3(0.42, 0.4, 0.02)), vec3(0.3, 0.7, 0.5))); 
    d = add(d, Distance(box(p + vec3(0.0, 0.4, 0.0), vec3(0.4, 0.02, 0.4)), vec3(0.3, 0.7, 0.5))); 
    
    return d;
}

Hit castRay(inout vec3 p, vec3 dir)
{	
	Hit hit;
	Distance dist = distance(p);
	float eps = 0.001;
    bool r = false;
    vec3 c = vec3(0.0);
	
	for (int i = 0; i < MAX_STEPS; i++)
	{
		Distance dist;
        if (r)
            dist = distance2(p);
        else
            dist = distance(p);
                
		float d = dist.value;
		if (abs(d) <= eps)
		{
           	if (!r && dist.color.b > 0.55)
            {            
            	dir = refract(dir, getNormal(p, 0.001), 0.9);
                c = dist.color;
                r = true;
            }
            else
            {
                hit.is = true;
                hit.pos = p;
                hit.normal.x = distance(p + vec3(eps,0,0)).value - distance(p - vec3(eps,0,0)).value;
                hit.normal.y = distance(p + vec3(0,eps,0)).value - distance(p - vec3(0,eps,0)).value;
                hit.normal.z = distance(p + vec3(0,0,eps)).value - distance(p - vec3(0,0,eps)).value;
                hit.normal = normalize(hit.normal);
                hit.color = dist.color * (1.0 - float(i) / float(MAX_STEPS));
                if (r)
                    hit.color += c;
                return hit;
            }
		}
		p += dir*d;
	}	
	hit.is = false;
	hit.color = vec3(0);
	return hit;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 angle = vec2(-iMouse.x/200.0, radians(50.0));
    vec3 center = vec3(0.0);
    float zoom = 2.0;
    
    vec3 p = vec3(cos(angle.x)*cos(angle.y), sin(angle.y), sin(angle.x)*cos(angle.y));
	vec2 uv = (fragCoord.xy/* + vec2(int(iGlobalTime*30.0))*/) / iResolution.yy - vec2(iResolution.x / iResolution.y / 2.0, 0.5);
    
    vec3 tx = vec3(-sin(angle.x), 0.0, cos(angle.x));
    vec3 ty = vec3(-cos(angle.x)*sin(angle.y), cos(angle.y), -sin(angle.x)*sin(angle.y));
    
    vec3 p2 = p;
    p = p * zoom + center;
    
    vec3 dir = tx * uv.x + ty * uv.y - p2;
    
    vec3 color = vec3(0.0);
    vec3 light = normalize(vec3(-0.6, 0.8, -0.3));
    
    
	Hit hit = castRay(p, dir);
    
	if (hit.is)
		color = hit.color * (max(dot(hit.normal, light), 0.0) * 0.8 + 0.2);
	else
		color = vec3(0);
	
    
    fragColor = vec4(color, 1.0);
}