// Shader downloaded from https://www.shadertoy.com/view/XtsSDs
// written by shadertoy user piotrekli
//
// Name: Test ray marched scene
// Description: Move mouse to change light direction.
precision mediump float;

#define MAXITER 160
#define EPSILON 0.001
#define LIGHT vec3((iMouse.xy/iResolution.xy-0.5)*2.0, -1.0)

vec4 add(vec4 a, vec4 b)
{
	if (a.w < b.w) return a;
	return b;
}

 vec4 mul(vec4 a, vec4 b)
{
	if (a.w > b.w) return a;
	return b;
}

float halfspace(vec3 dir, vec3 pos)
{
	return dot(dir, pos);
}

float ball(float r, vec3 pos)
{
	return sqrt(dot(pos, pos))-r;
}

float blob2(float r, vec3 pos1, vec3 pos2, vec3 translate)
{
	/* from http://www.pouet.net/topic.php?which=7931&page=4#c373814 */
	float f = 0.0;
	f += 1.0/(ball(r, pos1+translate)+r+EPSILON);
	f += 1.0/(ball(r, pos2+translate)+r+EPSILON);
	return 1.0/f-r*0.5;
}

vec4 scene(vec3 pos)
{
    float time = iGlobalTime;
	vec4 a =
	    add(vec4(1.0, 0.5, 0.0, ball(1.0+cos(time*0.3)*0.3, pos-vec3(0.0+sin(time*2.1234), 1.0+cos(time), 7.0+sin(time)))),
	        vec4(0.3, 0.4+sin(time-length(cos(pos*8.0))*20.0)*0.25, 0.9, ball(1.25, pos-vec3(-0.5, 1.75, 7.5))));
	a = add(a,
	        vec4(0.7, 1.0, 0.5,
	             max(ball(0.8, pos-vec3(1.0, 0.8, 6.0)),
	                 ball(0.8, pos-vec3(1.5, 0.7, 6.1)))));
	a = add(a,
		vec4(1.0, 1.0, 0.8,
	             halfspace(normalize(vec3(1.0, 1.0, -0.5)), pos-vec3(-4.0, -1.0, 0.0))));
	a = add(a,
		vec4(1.0, 0.0, 0.4,
	             blob2(0.6+cos(time*(cos(time*0.03)+2.0)*0.25)*0.05, vec3(0.1, -1.0, 5.0), vec3(1.0, -0.6, 4.8), -pos)));
	
	return a;
}

vec3 normal(vec3 pos)
{
	vec3 n = vec3(0.0);
	for (float xx=-1.0; xx<=1.0; xx+=2.0)
		for (float yy=-1.0; yy<=1.0; yy+=2.0)
			for (float zz=-1.0; zz<=1.0; zz+=2.0)
			{
				vec3 d = vec3(xx, yy, zz);
				n += scene(d*EPSILON+pos).w*d;
			}
	return normalize(n);
}

vec3 raymarch(vec3 ray_dir, inout vec3 ray_pos)
{
	vec3 col = vec3(-1.0);
	for (int i=0; i<MAXITER; ++i)
	{
		vec4 sc = scene(ray_pos);
		float r = sc.w + EPSILON;
		ray_pos += r * ray_dir;
		if (r <= EPSILON)
		{
			col = sc.xyz;
			break;
		}
	}
	return col;
}

float light(vec3 pos)
{
	float l = length(pos-LIGHT);
	l = (dot(normalize(LIGHT), normal(pos))*0.5+1.0) / (l*l);
	return l;
}

float shadow(vec3 pos)
{
	float d = 0.2;
	return clamp(1.0-scene(pos+normal(pos)*d).w/d, 0.0, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord-iResolution.xy*0.5) / min(iResolution.x, iResolution.y); 
	vec3 ray_dir = normalize(vec3(uv, 1.0));
	vec3 ray_pos = vec3(0.0);
	vec3 col = raymarch(ray_dir, ray_pos);
	bool found = col.x >= 0.0;
	if (found)
	{
		float l = light(ray_pos) - shadow(ray_pos)*0.01;
		fragColor = vec4( l*20.9*col, 1.0 );
	}
	else fragColor = vec4( vec3(0.0), 1.0 );
}