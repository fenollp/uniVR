// Shader downloaded from https://www.shadertoy.com/view/4lfSD7
// written by shadertoy user adam27
//
// Name: The Red Planet
// Description: My vision of Mars.

const mat2 mat = mat2(1.8, 1.1, -1.1, 1.8);

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
	return pow(dot(a, b) * length(cos(xz)), 0.5) + pow(sin(xz.x), 1.0) + pow(cos(xz.y), 1.0);
}

float terrain(vec3 p)
{
	vec2 xz = p.xz / 5.0;
	xz.x *= 0.7;
	float amp = 1.5;
	float h = 0.0;
	float freq = 0.1;
	for (int i = 0; i < 5; i++)
	{
		float h1 = map(xz * freq);
		float h2 = map(xz * freq);
		h += (h1 + h2) * amp;
		freq *= 2.1;
		amp *= 0.21;
		xz *= mat;
	}
	return p.y - h;
}


float castRay(inout vec3 p, vec3 dir)
{	
	float t = 0.1;    
	float d = 0.1;
	for (int i = 0; i < 200; i++)
	{
		float h = terrain(p + dir*t);
		if (h < 0.0)
			break;
		
		d *= 1.05;
        t += d;
        if (i == 199)
            return 20000.0;
	}
    
	float t2 = t;
	float h2 = terrain(p + dir*t2);
	if (h2 > 0.0)
		return t2;
	float t1 = t - d*10.0;
	float h1 = terrain(p + dir*t1);
	for (int i = 0; i < 8; i++)
	{
		t = mix(t1, t2, h1/(h1-h2));
		float h = terrain(p + dir*t);
		if (h < 0.0)
		{
            t2 = t; 
            h2 = h;
        }
		else
		{
            t1 = t; 
            h1 = h;
        }
	}	
	p = p + dir*t;
	return t;
}

vec3 getNormal(vec3 p, float d)
{
    vec3 n;
    n.y = terrain(p);    
    n.x = terrain(p + vec3(d, 0.0, 0.0)) - n.y;
    n.z = terrain(p + vec3(0.0, 0.0, d)) - n.y;
    n.y = d;
    return normalize(n);
}


void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    vec2 angle = vec2(iGlobalTime / 4.0, radians(5.0));
    vec3 center = vec3(-iGlobalTime * 10.0, 0.0, -iGlobalTime * 10.0);
    float zoom = 1.0;
    
    vec3 p = vec3(cos(angle.x)*cos(angle.y), sin(angle.y), sin(angle.x)*cos(angle.y));
	vec2 uv = (fragCoord.xy/* + vec2(int(iGlobalTime*30.0))*/) / iResolution.yy - vec2(iResolution.x / iResolution.y / 2.0, 0.5);
    
    vec3 tx = vec3(-sin(angle.x), 0.0, cos(angle.x));
    vec3 ty = vec3(-cos(angle.x)*sin(angle.y), cos(angle.y), -sin(angle.x)*sin(angle.y));
    
    vec3 p2 = p * 1.5;
    p = p * zoom + center;
    p.y -= terrain(vec3(p.x, 0.0, p.z)) - 3.0;
    
    vec3 dir = tx * uv.x + ty * uv.y - p2;
    
    vec3 color = vec3(0.0);
    vec3 light = normalize(vec3(0.6, 0.8, 0.3));
    
    
	float dist = castRay(p, dir);
	
    if (dist > 10000.0)
        color = vec3(0.8, 0.4, 0.2) * 1.0 - dot(vec3(0.0, 1.0, 0.0), dir);
    else    
   		color = vec3(0.8, 0.45, 0.2) * pow(max(dot(getNormal(p, dist*0.001), light), 0.0), 2.0) + noise(p.xz * 4.0) / 25.0;
	
    
    fragColor = vec4(color, 1.0);
}