// Shader downloaded from https://www.shadertoy.com/view/4tXXzn
// written by shadertoy user 4rknova
//
// Name: Collision Test: Triangle - Point
// Description: Point to triangle testing using barycentric coordinates.
//    Use the mouse to move the point around and test it against the triangle.
#define EPS  .01
#define COL0 vec3(.2, .35, .55)
#define COL1 vec3(.9, .43, .34)
#define COL2 vec3(.1, .6, .3)
#define COL3 vec3(.1)

float df_circ(in vec2 p, in vec2 c, in float r)
{
    return abs(r - length(p - c));
}

float df_line(in vec2 p, in vec2 a, in vec2 b)
{
    vec2 pa = p - a, ba = b - a;
	float h = clamp(dot(pa,ba) / dot(ba,ba), 0., 1.);	
	return length(pa - ba * h);
}

float sharpen(in float d, in float w)
{
    float e = 1. / min(iResolution.y , iResolution.x);
    return 1. - smoothstep(-e, e, d - w);
}

vec3 bary(in vec3 a, in vec3 b, in vec3 c, in vec3 p)
{
    // The cross product of two vectors has a magnitude
    // equal to twice the area of the triangle formed by 
    // the two vectors.
    vec3 n = cross(b - a, c - a);    
	float area = dot(n, n);
	
	if(abs(area) < 0.0001) return vec3(0);
	
	vec3 v0 = a - p;
	vec3 v1 = b - p;
	vec3 v2 = c - p;
	
	vec3 asub = vec3(dot(cross(v1, v2), n),
					 dot(cross(v2, v0), n),
					 dot(cross(v0, v1), n));
    
	return asub / vec3(area);
}

bool test(in vec2 a, in vec2 b, in vec2 c, in vec2 p)
{
    vec3 v = bary(vec3(a.x, 0., a.y),
                  vec3(b.x, 0., b.y),
                  vec3(c.x, 0., c.y),
                  vec3(p.x, 0., p.y));
    
    return v.x > 0. && v.y > 0. && v.z > 0.;
}


float df_bounds(in vec2 uv, in vec2 p, in vec2 a, in vec2 b, in vec2 c)
{
    float cp = 0.;
    
    float c0 = sharpen(df_circ(uv, p, 
                       (.03 + cos(15.*iGlobalTime) *.01))
                       , EPS * 1.);

    float l0 = sharpen(df_line(uv, a, b), EPS * 1.);
    float l1 = sharpen(df_line(uv, b, c), EPS * 1.);
    float l2 = sharpen(df_line(uv, c, a), EPS * 1.);

    cp = max(c0, max(max(l0, l1),l2));

    return cp;
}

vec3 scene(in vec2 uv, in vec2 a, in vec2 b, in vec2 c, in vec2 p)
{
    float d = df_bounds(uv, p, a, b, c);
    return d > 0. ? COL3 : COL1;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float ar = iResolution.x / iResolution.y;
    
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.) * vec2(ar, 1.);
    vec2 mc = (iMouse.xy    / iResolution.xy * 2. - 1.) * vec2(ar, 1.);

    vec2 a = vec2( .73,  .75);
    vec2 b = vec2(-.85,  .15);
    vec2 c = vec2( .25, -.75);

    float l = df_bounds(uv, mc, a, b, c);
    bool t0 = test(a, b, c, mc);
    bool t1 = test(a, b, c, uv);    
    
    vec3 col = l > 0. ? COL3 : (t1 ? COL0 : (t0 ? COL2 : COL1));        
    
	fragColor = vec4(col, 1);
}