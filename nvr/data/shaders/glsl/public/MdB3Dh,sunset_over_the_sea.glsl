// Shader downloaded from https://www.shadertoy.com/view/MdB3Dh
// written by shadertoy user 4rknova
//
// Name: Sunset over the sea
// Description: Move along, nothing to see here.
// by nikos papadopoulos, 4rknova / 2013
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define RMARCH_MAX_STEPS 	280
#define FOG_COLOR			vec3(.65, .4875, .1625)
#define FOG_K				.021

#define EPS 				.001
#define PI					3.14159265359
#define RADIAN				180. / PI

float hash(in vec3 p)
{
    return fract(sin(dot(p,vec3(127.1,311.7, 321.4)))*43758.5453123);
}

float noise(in vec3 p)
{
    vec3 i = floor(p);
	vec3 f = fract(p); 
	f *= f * (3.-2.*f);

    return mix(
		mix(mix(hash(i + vec3(0.,0.,0.)), hash(i + vec3(1.,0.,0.)),f.x),
			mix(hash(i + vec3(0.,1.,0.)), hash(i + vec3(1.,1.,0.)),f.x),
			f.y),
		mix(mix(hash(i + vec3(0.,0.,1.)), hash(i + vec3(1.,0.,1.)),f.x),
			mix(hash(i + vec3(0.,1.,1.)), hash(i + vec3(1.,1.,1.)),f.x),
			f.y),
		f.z);
}

float fbm(vec3 p)
{
	return  .151 * noise(1.242 * p + iGlobalTime * .2362)
		   +.203 * noise(1.436 * p + iGlobalTime * .4121)
		   +.512 * noise(1.181 * p + iGlobalTime * .3360);
}

vec3  cubemap(vec3 d, vec3 c1, vec3 c2)
{
	return fbm(d) * mix(c1, c2, clamp(d * .5 + .5, 0. ,1.));
}

vec3 sun(vec3 d, vec3 bg)
{
	vec3 r = bg;
	
	float k = 2. - length(vec2(d.x * 2., d.z + 1. ));
		
	if (k < 10.) {
		r = .21 * k * FOG_COLOR + bg;
	}
	
	return r;
}

float dst(in vec3 p)
{
	float t = iGlobalTime * 2.;
	return dot(p + 0.1 *
		   vec3(hash(vec3(p-t)), .5 * fbm(2.5 * p - vec3(t, p.z + t, t - p.x)), hash(p*t)), vec3(0.,1.,0.));
}

vec3 nrm(vec3 pos, float d)
{
	return normalize(
    	vec3(dst(vec3(pos.x + EPS, pos.y, pos.z)),
			 dst(vec3(pos.x, pos.y + EPS, pos.z)),
	         dst(vec3(pos.x, pos.y, pos.z + EPS))) - d);
}

vec3 scene_shade(vec3 p, vec3 n, vec3 c)
{
	vec3 l = normalize(c-p);

	return vec3(.4, .3, .4) * dot(l, n) +
		 	vec3(1., .7, .4) *
		  pow(abs(dot(reflect(normalize(vec3(0., 128.,-256.)), n), l)), 256.);
}

bool rmarch(vec3 ro, vec3 rd, out vec3 p, out vec3 n)
{
	p = ro;
	vec3 pos = p;
	float d = 1.;

	for (int i = 0; i < RMARCH_MAX_STEPS; i++) {
		d = dst(pos);
		if (d < EPS) {
			p = pos;
			break;
		}
		pos += d * rd;
	}
	n = nrm(p, d);
	return d < EPS;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 uvn = (2.*uv-1.)
			 * vec2(iResolution.x / iResolution.y, 1.);
	
	vec3 ro, ct, cu;
	ro = vec3(0., 3.75 + .5 *noise(vec3(iGlobalTime)) * .3, 0.);
	ct = vec3(0., 1., -100.);
	ct.y += ro.y;
	ro.z += ct.y * .1;
	cu = normalize(vec3(sin(iGlobalTime * 1.5)*.03,1.,0.));
	
	vec3 rd = normalize(vec3(uvn.x, uvn.y, 1. / tan(30. * RADIAN)));
	
	vec3 cd = ct - ro;

	vec3 rx,ry,rz;
	rz = normalize(cd);
	rx = normalize(cross(rz, cu));
	ry = normalize(cross(rx, rz));
	
	mat3 tmat = mat3(rx.x, rx.y, rx.z,
			  		 ry.x, ry.y, ry.z,
					 rz.x, rz.y, rz.z);

	rd = normalize(tmat * rd);
	
	vec3 sp, sn, col;
	
	if (dot(rd, vec3(0.,1.,0.)) < -0.05 ? rmarch(ro, rd, sp, sn): false)
	{
		col = scene_shade(sp, sn, ro);
		col += FOG_COLOR * FOG_K * length(ro - sp);
	}
	else
	{
		col = 0.08 * mix(rd, mix(vec3(dot(vec3(.8125, .7154, .9721), vec3(1.4))), vec3(1.4), 1.3), 1.5)
			+ 0.08 + mix(vec3(.65), vec3(.15,.25,.52) + .41 * cubemap(rd.zxy * 12.4  + cos(0.0021 * iGlobalTime),vec3(.6,.4, 0.), vec3(.0,.4,0.))
			- .36 * cubemap(rd.zyx * 8.3  + sin(EPS * iGlobalTime),vec3(1.,.1,.1), vec3(1.,.7,.2)),
			vec3(rd.y * 9.));
		
		col = sun(rd, col);
	}
	
	fragColor = vec4(col * smoothstep(EPS, 3.5, iGlobalTime), 1.);
}