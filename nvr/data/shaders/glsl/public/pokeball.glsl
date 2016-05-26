// Shader downloaded from https://www.shadertoy.com/view/4slGWN
// written by shadertoy user 4rknova
//
// Name: Pokeball
// Description: Gotta catch' em all!
// by Nikos Papadopoulos, 4rknova / 2013
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define EPS		.001
#define EPS_M	.1
#define PI		3.14159265359
#define	RADIAN	180. / PI

#define RM_MAX	256
#define RS_MAX	32
#define PNMBRA	25.

struct L { vec3 p,d,s; };
struct M { vec3 d,s; float e; };
struct C { vec3 p,t,u; };
struct R { vec3 o,d; };
	
float gmp(vec3 p, vec4 n)		{return dot(p,normalize(n.xyz)) + n.w;}
float gms(vec3 p, float r)		{return length(p) - r;}
float gmb(vec3 p, vec3 b)		{vec3 d = abs(p)-b;
								 return min(max(d.x,max(d.y,d.z)), 0.) 
									 	+length(max(d,0.0));}
float opu(float d1, float d2) 	{return min( d1, d2);}
float ops(float d1, float d2)	{return max( d1,-d2);}
float opi(float d1, float d2)	{return max( d1, d2);}
vec3  tmv(vec3 v, vec3 t)		{return v - t;}

void ray(C c, out R r, in vec2 fragCoord)
{
	vec2  uv = (fragCoord.xy / iResolution.xy * 2. - 1.)
			 * vec2(iResolution.x / iResolution.y, 1.);
	
	r.o = c.p;
	r.d = normalize(vec3(uv.x, uv.y, 1.0 / tan(30. * RADIAN)));
	
	vec3 cd = c.t - c.p,
		 rz = normalize(cd),
		 rx = normalize(cross(rz, c.u)),
		 ry = normalize(cross(rx, rz));

	r.d = normalize(mat3(rx, ry, rz) * r.d);
}

float dst(vec3 p)
{
    vec3 v0 = vec3( 0., 10.,  0.0);
    vec3 v1 = vec3(10., 10.,  1.0);
    vec3 v2 = vec3(20., .49, 20.0);
    vec3 v3 = vec3( 0., 10.,-10.4);
    vec3 v4 = vec3( 0., 10.,-11.5);
    vec3 v5 = vec3( 0., 10.,- 8.9);
    vec3 v6 = vec3( 0., 10.,-10.8);
    vec3 v7 = vec3( 0. ,10.,- 9.3);
	vec3 v8 = vec3( 0., 10.,-11.0);
    vec4 v9 = vec4( 0, 1, 0, 0);
    
	float d = gms(tmv(p, v0), 10.);
	d = opu(ops(d,gmb(tmv(p, v0),v2)), gms(tmv(p, v0),9.5));
	d = opu(ops(d,opi(gmb(tmv(p, v3), v1), gms(tmv(p, v4), 2.7))), 
            ops(gms(tmv(p, v5), 1.5), gmb(tmv(p, v6), v1)));
	d = opu(d,ops(gms(tmv(p, v7), 1.), gmb(tmv(p, v8), v1)));	
	return opu(d,gmp(p, v9));
}


vec3 scene_normal(vec3 pos, float d)
{
    return normalize(
		vec3(dst(vec3(pos.x + EPS, pos.y, pos.z)),
			 dst(vec3(pos.x, pos.y + EPS, pos.z)),
		 	 dst(vec3(pos.x, pos.y, pos.z + EPS))) - d);
}

vec3 scene_shade(vec3 p, vec3 n, L l, M m, C c)
{
	return l.d * m.d * dot(n, normalize(l.p - p))
		+ l.s * m.s * pow(clamp(dot(normalize(reflect(l.p - p, n)), normalize(p - c.p)), 0., 1.), m.e);
}

bool rm(R r, out vec3 p, out vec3 n)
{
	p = r.o;

	vec3 pos = p;

	for (int i = 0; i < RM_MAX; i++) {
		float d = dst(pos);

		if (d > 25.) {
			return false;
		} else if (d < EPS) {
			p = pos;
			n = scene_normal(p, d);

			return true;
		}
		
		pos += d * r.d;
	}
	
	return false;
}

float sh( in vec3 ro, in vec3 rd)
{
    float res = 1.;
	
	float t = EPS_M;
	
	for (int i = 0; i < RS_MAX; i++) {
        float d = dst(ro + rd * t);
		
		if (d < EPS) {
			return 0.;
			break;
		}
		
        res = min(res, PNMBRA * d / t);

        t += d;
    }

    return res;
}

void dmap (out vec3 c, vec3 p)
{
	c = p.y > EPS ? 
		(p.y > 9.54 ? (p.y > 10.45 ? vec3(1, 0, 0) : vec3(0)): vec3(1))
		: vec3(.8);
		
	if (length(p - vec3(0, 10, -10)) < 1.5) c = vec3(1);
	else if (length(p - vec3(0, 10, -10)) < 1.8) c = vec3(0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	C c;

	float t1 = sin(mod(iGlobalTime * .34, 2. * PI + EPS)),
		  t2 = cos(mod(iGlobalTime * .23, 2. * PI + EPS)),
		  t3 = sin(mod(iGlobalTime * .10, PI + EPS));

	c.p = vec3(26. * t1, 15. + 8. * t2, -(15. + 17. * t3));
	c.t = vec3(0, 10, 0);
	c.u = vec3(0, 1, 0);
	
	R r;
	ray(c, r, fragCoord);

	vec3 sp, sn, col = vec3(0);
	
	if (rm(r, sp, sn)) {
		L l1, l2;
		l1.p = vec3(13, 35, -40);
		l1.d = vec3(.7); l1.s = vec3(1);
		l2.p = vec3(0, 1000, 0);
		l2.d = vec3(.1); l2.s = vec3(0);
	
		M m;		
		dmap(m.d, sp);
		m.s = vec3(1.) * length(1. - m.d);
		m.e = 256.;
	
		col = sh(sp, normalize(l1.p-sp)) * scene_shade(sp, sn, l1, m, c) +
		      sh(sp, normalize(l2.p-sp)) * scene_shade(sp, sn, l2, m, c);
	}

	fragColor = vec4(smoothstep(EPS, 3.5, iGlobalTime) *	col, 1.);
}