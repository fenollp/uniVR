// Shader downloaded from https://www.shadertoy.com/view/4dB3Dw
// written by shadertoy user w23
//
// Name: ruins
// Description: This is glitchy and of no value!
// set this to 128 if you live in the future or have 1895719 GTX 780 in SLI
#define TRACE_STEPS 64


float t = iGlobalTime;

mat4 m_translation(vec3 tr) {
	return mat4(
		vec4(1., 0., 0., 0.),
		vec4(0., 1., 0., 0.),
		vec4(0., 0., 1., 0.),
		vec4(tr, 1.));
}

mat3 m_rot_x(float a) {
	float s = sin(a), c = cos(a);
	return mat3(1., 0., 0., 0., c, s, 0., -s, c);
}

mat3 m_rot_y(float a) {
	float s = sin(a), c = cos(a);
	return mat3(c, 0., -s, 0., 1., 0., s, 0., c);
}

mat3 m_rot_z(float a) {
	float s = sin(a), c = cos(a);
	return mat3(c, s, 0., -s, c, 0., 0., 0., 1.);
}

mat4 m_look_at(in vec3 pos, in vec3 at, in vec3 up) {
	vec3 fwd = normalize(at - pos);
	vec3 right = cross(up, fwd);
	up = cross(fwd, right);
	return m_translation(pos)
		* mat4(vec4(right, 0.), vec4(up, 0.), vec4(fwd, 0.),
			  vec4(0., 0., 0., 1.));
}

vec4 noise4(in vec2 v) { return texture2D(iChannel0, v / 256., -100.); }
float hash(float v) { return texture2D(iChannel0, vec2(v) / 256., -100.).r; }
float hash(in vec2 v) { return texture2D(iChannel0, (v + .5) / 256., -100.).r; }
float noise(in vec2 v) { return texture2D(iChannel0, v / 256., -100.).r; }
float noise(in vec3 v) {
	v /= 256.;
	return .5 * (
		texture2D(iChannel0, v.xz, -100.).b +
		texture2D(iChannel0, v.yx, -100.).g);
}
float hash(vec3 v) { return noise(vec2(dot(v, vec3(1., 51., 23.)), 0.)); }
float noise(in float v) {
	float F = floor(v), f = fract(v);
	f = f * f * (3. - 2. * f);
	return mix(hash(F), hash(F+1.), f);
}
vec3 noise3(in float v) {
	return vec3(noise(v), noise(v+17.3), noise(v+23.9));
}
vec3 noise3(in vec2 v) { return texture2D(iChannel0, v / 256., -100.).rgb; }
vec3 noise3(in vec3 v) {
	v /= 256.;
	return .5 * (
		texture2D(iChannel0, v.xz, -100.).rgb +
		texture2D(iChannel0, v.yx, -100.).abg);
}
float fnoise(in vec3 v) {
	return .5 * noise(v) + .25 * noise(v * 2.01) + .125 * noise(v * 3.98);
	//return noise(v);// + .25 * noise(v * 2.01) + .125 * noise(v * 3.98);
}

float vmax(in vec3 v) {
	return max(v.x, max(v.y, v.z));
}

float d_box(in vec3 at, in vec3 size) {
	return vmax(abs(at)-size);
}

vec3 o_rep(in vec3 at, in vec3 rep) {
	return mod(at - .5 * rep, rep) - .5 * rep;
}

float bld(in vec3 at, in vec3 size) {
	float bbox = d_box(at, size);
	if (bbox > 1.) return bbox;
	
	float rows = d_box(o_rep(at, vec3(1., 3., 1.)), vec3(1., .2, 1.));
	float cols = d_box(o_rep(at, vec3(4., 1., 5.)), vec3(.2, 1., .2));
	
	return max(bbox, min(rows, cols));
}

#define SS 45.

float wbld(in vec3 at) {
	vec2 s = floor(at.xz / SS), sid = s / 16.;
	vec3 sat = vec3(at.x - SS * (s.x + .5), at.y, at.z - SS * (s.y + .5));
	float height = 5. + hash(s+11.) * 36.;
	float X = (hash(s)-.5) * 20.;
	float Y = (hash(s+8.)-.5) * 20.;
	float rz = (hash(s+2.)-.5)*.6;
	float rx = (hash(s+3.)-.5)*.6;
	float W = 6. + hash(s+.4)*8.;
	float D = 3. + hash(s+.4)*6.;
	
	sat += vec3(X, 0., Y);
	mat3 mrot = m_rot_z(rz) * m_rot_x(rx);
	
	const float ns_scale = .2;
	const float ns_iso = .49;
	float hole = fnoise(at*ns_scale) - ns_iso;	
	
	return .9 * max(2. * hole / ns_scale, bld(sat * mrot, vec3(D, height, W)));
}

vec3 wbld_normal(in vec3 at) {
	const float e = .005;
	vec3 n = normalize(vec3(
		wbld(at+vec3(e, 0., 0.)) - wbld(at-vec3(e, 0., 0.)),
		wbld(at+vec3(0., e, 0.)) - wbld(at-vec3(0., e, 0.)),
		wbld(at+vec3(0., 0., e)) - wbld(at-vec3(0., 0., e))
		));
	return normalize(n + (noise(18.*at)-.5));
}

float trace(in vec3 o, in vec3 d) {
	float L  = 0.;
	for (int i = 0; i < TRACE_STEPS; ++i) {
		vec3 p = o + d * L;
		vec2 s = floor(p.xz / SS);
		vec3 sp = vec3(p.x - SS * (s.x + .5), p.y, p.z - SS * (s.y + .5));
		float d = wbld(p);
		const float ST = SS*.5 + 6.;
		L += min(d, -max(abs(sp.x)-ST, abs(sp.z)-ST));
		if (d < .001 * L) break;
	}
	return L;
}

float H(in vec3 at) {
	vec2 a = at.xz / 256. * .02;
	return 9.-24. * (
		.5 * texture2D(iChannel0, a, -100.).r +
		.25 * texture2D(iChannel0, a * 1.93, -100.).r +
		.0625 * texture2D(iChannel0, a * 8.07, -100.).r);
}

vec3 ground_normal(in vec3 at) {
	vec3 tx = vec3(2., H(at+vec3(1.,0.,0.)) - H(at-vec3(1.,0.,0.)), 0.);
	vec3 tz = vec3(.0, H(at+vec3(0.,0.,1.)) - H(at-vec3(0.,0.,1.)), 2.);
	return normalize(normalize(cross(tz, tx))
		+ 1.5 * (noise3(at.xz*21.)-.5));
}

float trace_ground(in vec3 o, in vec3 d) {
	float L = 0.;
	for (int i = 0; i < 16; ++i) {
		vec3 p = o + d * L;
		float d = p.y - H(p);
		L += d * 2.;
		if (d < .001 * L) break;
	}
	return L;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy * 2. - 1.;
	uv.x *= iResolution.x / iResolution.y;
	
	vec3 wobble = 2. * noise3(t);
	vec3 eye = vec3(70., 38., -70.);
	if (iMouse.z > 0.) {
		eye = vec3(70., 10. + iMouse.y / iResolution.y * 68., -70.);
		eye *= m_rot_y(-iMouse.x / iResolution.x * 8.);
	}
	mat4 M = m_look_at(eye + wobble, vec3(0.), vec3(0., 1., 0.));
	vec3 o = (M * vec4(uv * .01, 0., 1.)).xyz;
	vec3 d = (M * normalize(vec4(uv, 2., 0.))).xyz;
	
	float L_b = trace(o, d);
	float L_g = trace_ground(o, d);
	float L = min(L_b, L_g);
	vec3 p = o + d * L;
	vec3 n = vec3(0.);
	vec3 c = vec3(0.);
	if (L_g < L_b) {
		n = ground_normal(p);
		c = mix(
			vec3(.0, .4, .05),
			vec3(.3, .35, .15), noise(p.xz*.2))
			* (.5+.5*noise(p.xz*8.));
		c += vec3(1.,0.,0.) * smoothstep(.4,.6,noise(p.xz*.3)) * smoothstep(.9,.91,noise(p.xz*8.));
		c += vec3(.5,.5,1.) * smoothstep(.4,.6,noise(p.xz*.2 + vec2(100.))) * smoothstep(.9,.91,noise(p.xz*11.));
	} else {
		n = wbld_normal(p);
		c = mix(vec3(.3, .3, .24) + vec3(.3) * noise(p*2.),
				vec3(.0, .4, .05),
			   mix(.01, .9,
				   smoothstep(.3, .7, noise(p.xz*18.))
				   *smoothstep(.5, .7, noise(p*.5))));
	}
	
	vec3 skycolor = mix(vec3(.53, .81, .92), vec3(0., .51, 1.), smoothstep(.05, .2, d.y));
	
	vec3 ldir = vec3(1.,1.2,.3);
	vec3 lcolor = vec3(.8);
	
	float klight = (trace(p + n*.02, ldir) < 100.) ? 0. : 1.;
	float occlusion = .0;
	
	for (int i = 0; i < 8; ++i) {
		float f = float(i) * 6. / 8.;
		occlusion += smoothstep(0., f, wbld(p + n * f)) / 8.;
	}
	
	vec3 color = c * (vec3(.25) * occlusion + klight * lcolor * max(0.,dot(normalize(ldir), n)));
	color = mix(color, skycolor, clamp((L-150.) / 300.,0.,1.));
	
	fragColor = vec4(pow(color, vec3(1. / 2.2)), 1.);
}