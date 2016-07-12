// Shader downloaded from https://www.shadertoy.com/view/MlsGDf
// written by shadertoy user valentingalea
//
// Name: Vectorpark Egg 3D
// Description: A tribute to the wonderful www.vectorpark.com (now with 3D effect!)
//    
//    Go play Windosill and Metamorphabet!
//    
#define SHADERTOY

#ifdef __cplusplus
#define _in(T) const T &
#define _inout(T) T &
#define _out(T) T &
#define _begin(type) type {
#define _end }
#define _mutable(T) T
#define _constant(T) const T
#define mul(a, b) (a) * (b)
#endif

#if defined(GL_ES) || defined(GL_SHADING_LANGUAGE_VERSION)
#define _in(T) const in T
#define _inout(T) inout T
#define _out(T) out T
#define _begin(type) type (
#define _end )
#define _mutable(T) T
#define _constant(T) const T
#define mul(a, b) (a) * (b)
precision mediump float;
#endif

#ifdef HLSL
#define _in(T) const in T
#define _inout(T) inout T
#define _out(T) out T
#define _begin(type) {
#define _end }
#define _mutable(T) static T
#define _constant(T) static const T
#define vec2 float2
#define vec3 float3
#define vec4 float4
#define mat2 float2x2
#define mat3 float3x3
#define mat4 float4x4
#define mix lerp
#define fract frac
#define mod fmod
#pragma pack_matrix(row_major)
#endif

#ifdef HLSLTOY
cbuffer uniforms : register(b0) {
	float2 u_res;
	float u_time;
	float2 u_mouse;
};
void mainImage(_out(float4) fragColor, _in(float2) fragCoord);
float4 main(float4 uv : SV_Position) : SV_Target{ float4 col; mainImage(col, uv.xy); return col; }
#endif

#if defined(__cplusplus) || defined(SHADERTOY)
#define u_res iResolution
#define u_time iGlobalTime
#define u_mouse iMouse
#endif

#ifdef GLSLSANDBOX
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
#define u_res resolution
#define u_time time
#define u_mouse mouse
void mainImage(_out(vec4) fragColor, _in(vec2) fragCoord);
void main() { mainImage(gl_FragColor, gl_FragCoord.xy); }
#endif

#ifdef UE4
_constant(vec2) u_res = vec2(0, 0);
_constant(vec2) u_mouse = vec2(0, 0);
_mutable(float) u_time = 0;
#endif

#define PI 3.14159265359

struct ray_t {
	vec3 origin;
	vec3 direction;
};
#define BIAS 1e-4 // small offset to avoid self-intersections

struct sphere_t {
	vec3 origin;
	float radius;
	int material;
};

struct plane_t {
	vec3 direction;
	float distance;
	int material;
};

struct hit_t {
	float t;
	int material_id;
	vec3 normal;
	vec3 origin;
};
#define max_dist 1e8
_constant(hit_t) no_hit = _begin(hit_t)
	float(max_dist + 1e1), // 'infinite' distance
	-1, // material id
	vec3(0., 0., 0.), // normal
	vec3(0., 0., 0.) // origin
_end;

// ----------------------------------------------------------------------------
// Various 3D utilities functions
// ----------------------------------------------------------------------------

ray_t get_primary_ray(
	_in(vec3) cam_local_point,
	_inout(vec3) cam_origin,
	_inout(vec3) cam_look_at
){
	vec3 fwd = normalize(cam_look_at - cam_origin);
	vec3 up = vec3(0, 1, 0);
	vec3 right = cross(up, fwd);
	up = cross(fwd, right);

	ray_t r = _begin(ray_t)
		cam_origin,
		normalize(fwd + up * cam_local_point.y + right * cam_local_point.x)
		_end;
	return r;
}

mat2 rotate_2d(
	_in(float) angle_degrees
){
	float angle = radians(angle_degrees);
	float _sin = sin(angle);
	float _cos = cos(angle);
	return mat2(_cos, -_sin, _sin, _cos);
}

mat3 rotate_around_z(
	_in(float) angle_degrees
){
	float angle = radians(angle_degrees);
	float _sin = sin(angle);
	float _cos = cos(angle);
	return mat3(_cos, -_sin, 0, _sin, _cos, 0, 0, 0, 1);
}

mat3 rotate_around_y(
	_in(float) angle_degrees
){
	float angle = radians(angle_degrees);
	float _sin = sin(angle);
	float _cos = cos(angle);
	return mat3(_cos, 0, _sin, 0, 1, 0, -_sin, 0, _cos);
}

mat3 rotate_around_x(
	_in(float) angle_degrees
){
	float angle = radians(angle_degrees);
	float _sin = sin(angle);
	float _cos = cos(angle);
	return mat3(1, 0, 0, 0, _cos, -_sin, 0, _sin, _cos);
}

vec3 corect_gamma(
	_in(vec3) color,
	_in(float) gamma
){
	float p = 1.0 / gamma;
	return vec3(pow(color.r, p), pow(color.g, p), pow(color.b, p));
}

#ifdef __cplusplus
vec3 faceforward(
	_in(vec3) N,
	_in(vec3) I,
	_in(vec3) Nref
){
	return dot(Nref, I) < 0 ? N : -N;
}
#endif

float checkboard_pattern(
	_in(vec2) pos,
	_in(float) scale
){
	vec2 pattern = floor(pos * scale);
	return mod(pattern.x + pattern.y, 2.0);
}

float band (
	_in(float) start,
	_in(float) peak,
	_in(float) end,
	_in(float) t
){
	return
	smoothstep (start, peak, t) *
	(1. - smoothstep (peak, end, t));
}
// ----------------------------------------------------------------------------
// Inverse Kinematics solvers
// ----------------------------------------------------------------------------

vec3 ik_2_bone_centered_solver(
	_in(vec3) goal,
	_in(float) L1,
	_in(float) L2
){
#if 0 // from https://www.shadertoy.com/view/ldlGR7
	vec3 q = goal*(0.5 + 0.5*(L1*L1 - L2*L2) / dot(goal, goal));

	float s = L1*L1 - dot(q, q);
	s = max(s, 0.0);
	q += sqrt(s)*normalize(cross(goal, vec3(0, 0, 1)));

	return q;
#else // naive version with law of cosines
	float G = length(goal);

	// tetha is the angle between bone1 and goal direction
	// get it from law of cosines applied to the
	// triangle with sides: bone1, bone2, pivot_of_bone1<->goal
	float cos_theta = (L1*L1 + G*G - L2*L2) / (2.*L1*G);

	// sin^2 + cos^2 = 1 (Pythagoras in unit circle)
	float sin_theta = sqrt(1. - cos_theta * cos_theta);

	// rotation matrix by theta amount around the axis
	// perpendicular to the plane created by bone1 and bone2
	mat3 rot = mat3(
		cos_theta, -sin_theta, 0,
		sin_theta, cos_theta, 0,
		0, 0, 1.
		);

	// get the end of bone1 aka the pivot of bone2
	// by getting a vector from the goal direction
	// and rotating along with the newly found theta angle
	return mul(rot, (normalize(goal) * L1));
#endif
}

vec3 ik_solver(
	_in(vec3) start,
	_in(vec3) goal,
	_in(float) bone_length_1,
	_in(float) bone_length_2
){
	return start + ik_2_bone_centered_solver(
		goal - start, bone_length_1, bone_length_2);
}
// ----------------------------------------------------------------------------
// Signed Distance Fields functions
// ----------------------------------------------------------------------------

vec2 op_add( // union
	_in(vec2) d1,
	_in(vec2) d2
){
	// minimum distance (preserving material info)
	return d1.x < d2.x ? d1 : d2;
}

float op_sub( // difference
	_in(float) d1,
	_in(float) d2
){
	// intersection between first and
	// complement of the second field
	// aka the second 'carved out' from the first
	return max(d1, -d2);
}

float op_intersect( // intersection
	_in(float) d1,
	_in(float) d2
){
	// what's common for both fields
	return max(d1, d2);
}

float op_blend(
	_in(float) a,
	_in(float) b,
	_in(float) k // factor of smoothing
){
	// from http://iquilezles.org/www/articles/smin/smin.htm
	// NOTE: not true distance but estimate
	float h = clamp(0.5 + 0.5*(b - a) / k, 0.0, 1.0);
	return mix(b, a, h) - k*h*(1.0 - h);
}

float sd_plane(
	_in(vec3) p,
	_in(vec3) n, // normal
	_in(float) d // distance
){
	// distance from point to plane
	// http://mathworld.wolfram.com/Point-PlaneDistance.html
	return dot(n, p) + d;
}

float sd_sphere(
	_in(vec3) p,
	_in(float) r
){
	// distance to center of sphere offset by the radius
	return length(p) - r;
}

float sd_box(
	_in(vec3) p,
	_in(vec3) b // dimensions of box
){
	// intersection of 3 axis aligned 'slabs'
	return max(abs(p.x) - b.x, max(abs(p.y) - b.y, abs(p.z) - b.z));
}

float sd_torus( // around Z axis
	_in(vec3) p,
	_in(float) R, // 'donut' radius
	_in(float) r  // thickness
){
	// projected circle of radius R on xy plane
	// combined with circle of radius r around z axis
	return length(vec2(length(p.xy) - R, p.z)) - r;
}

float sd_y_cylinder(
	_in(vec3) p,
	_in(float) r, // radius
	_in(float) h  // height
){
	// distance to the Y axis, offset (aka inflated) by the cylinder radius
	// then intersected with 2 cutting planes
	return max(length(p.xz) - r, abs(p.y) - h / 2.);
}

float sd_cylinder(
	_in(vec3) P,
	_in(vec3) P0, // start point
	_in(vec3) P1, // end point
	_in(float) R  // thickness
){
	// distance to segment -- http://geomalgorithms.com/a02-_lines.html
	// then cut it with 2 planes at the ends
	// then offset it with radius    
	vec3 dir = normalize(P1 - P0);
	float dist = length(cross(dir, P - P0));
	float plane_1 = sd_plane(P, dir, length(P1));
	float plane_2 = sd_plane(P, -dir, -length(P0));
	return op_sub(op_sub(dist, plane_1), plane_2) - R;
}

// 3D Bezier curved cylinder
// original by http://research.microsoft.com/en-us/um/people/hoppe/ravg.pdf
// adapted by iq https://www.shadertoy.com/view/ldj3Wh
float det(
	_in(vec2) a,
	_in(vec2) b
){
	return a.x*b.y - b.x*a.y;
}
vec3 sd_bezier_get_closest(
	_in(vec2) b0,
	_in(vec2) b1,
	_in(vec2) b2
){
	float a = det(b0, b2);
	float b = 2.0*det(b1, b0);
	float d = 2.0*det(b2, b1);
	float f = b*d - a*a;
	vec2  d21 = b2 - b1;
	vec2  d10 = b1 - b0;
	vec2  d20 = b2 - b0;
	vec2  gf = 2.0*(b*d21 + d*d10 + a*d20); gf = vec2(gf.y, -gf.x);
	vec2  pp = -f*gf / dot(gf, gf);
	vec2  d0p = b0 - pp;
	float ap = det(d0p, d20);
	float bp = 2.0*det(d10, d0p);
	float t = clamp((ap + bp) / (2.0*a + b + d), 0.0, 1.0);
	return vec3(mix(mix(b0, b1, t), mix(b1, b2, t), t), t);
}
vec2 sd_bezier(
	_in(vec3) a, // start
	_in(vec3) b, // knot (control point)
	_in(vec3) c, // end
	_in(vec3) p, 
	_in(float) thickness
){
	vec3 w = normalize(cross(c - b, a - b));
	vec3 u = normalize(c - b);
	vec3 v = normalize(cross(w, u));

	vec2 a2 = vec2(dot(a - b, u), dot(a - b, v));
	vec2 b2 = vec2(0., 0.);
	vec2 c2 = vec2(dot(c - b, u), dot(c - b, v));
	vec3 p3 = vec3(dot(p - b, u), dot(p - b, v), dot(p - b, w));

	vec3 cp = sd_bezier_get_closest(a2 - p3.xy, b2 - p3.xy, c2 - p3.xy);

	return vec2(0.85*(sqrt(dot(cp.xy, cp.xy) + p3.z*p3.z) - thickness), cp.z);
}

// ----------------------------------------------------------------------------
// Vectorpark Egg
// ----------------------------------------------------------------------------

vec3 background(_in(ray_t) ray)
{
	return vec3(.1, .1, .7);
}

void setup_scene()
{
#define mat_debug 0
#define mat_egg 1
#define mat_bike 2
#define mat_ground 3
}

void setup_camera(_inout(vec3) eye, _inout(vec3) look_at)
{
	eye = vec3(0, 0.25, 5.25);
	look_at = vec3(0, 0.25, 0);
}

vec3 illuminate(_in(hit_t) hit)
{
	if (hit.material_id == mat_ground) return vec3(13. / 255., 104. / 255., 0. / 255.);
	if (hit.material_id == mat_egg) return vec3(0.9, 0.95, 0.95);
	if (hit.material_id == mat_bike) return vec3(.2, .2, .2);
	return vec3(1, 1, 1);
}

#define BEZIER
vec2 sdf(_in(vec3) P)
{
	vec3 p = mul(rotate_around_y(u_time * -80.0), P)
		- vec3(0, 0.5, 3.5);

	int material = mat_egg;

	float egg_y = 0.65;
#if 1
	float egg_m = sd_sphere(p - vec3(0, egg_y, 0), 0.475);
	float egg_b = sd_sphere(p - vec3(0, egg_y - 0.45, 0), 0.25);
	float egg_t = sd_sphere(p - vec3(0, egg_y + 0.45, 0), 0.25);
	float egg_1 = op_blend(egg_m, egg_b, .5);
	float egg_2 = op_blend(egg_1, egg_t, .5);
	vec2 egg = vec2(egg_2, material);
#else
	float s = 1.55;
	mat3 scale = mat3(
		s, 0, 0,
		0, 1, 0,
		0, 0, 1);
	mat3 iscale = mat3(
		1./s, 0, 0,
		0, 1./s, 0,
		0, 0, 1.);
	vec2 egg = vec2(
		sd_sphere(iscale * (scale * (p - vec3(0, egg_y, 0))), 0.475),
		material);
#endif

	vec3 wheel_pos = vec3(0, 1.2, 0);
	float pedal_radius = 0.3;
	float pedal_speed = 500.;
	float pedal_off = 0.2;

	mat3 rot_z = rotate_around_z(-u_time * pedal_speed);
	vec3 left_foot_pos = wheel_pos + mul(rot_z, vec3(0., pedal_radius, pedal_off));

	rot_z = rotate_around_z(-u_time * pedal_speed);
	vec3 right_foot_pos = wheel_pos + mul(rot_z, vec3(0., -pedal_radius, -pedal_off));

	vec3 side = vec3(0, 0, pedal_off);
	float femur = 0.8;
	float tibia = 0.75;
	float thick = .05;

	vec3 pelvis = vec3(0, 0., 0) + side;
	vec3 knee_l = ik_solver(pelvis, left_foot_pos, femur, tibia);
#ifndef BEZIER
	vec2 left_leg_a = vec2(
		sd_cylinder(p + pelvis, vec3(0., 0., 0.), knee_l - side, thick),
		material);
	vec2 left_leg_b = vec2(
		sd_cylinder(p + knee_l, vec3(0., 0., 0.), left_foot_pos - knee_l, thick),
		material);
#endif

	pelvis = vec3(0, 0., 0) - side;
	vec3 knee_r = ik_solver(pelvis, right_foot_pos, femur, tibia);
#ifndef BEZIER
	vec2 right_leg_a = vec2(
		sd_cylinder(p + pelvis, vec3(0., 0., 0.), knee_r + side, thick),
		material);
	vec2 right_leg_b = vec2(
		sd_cylinder(p + knee_r, vec3(0., 0., 0.), right_foot_pos - knee_r, thick),
		material);
#endif

	vec2 legs = op_add(
#ifndef BEZIER
		vec2(op_blend(left_leg_a.x, left_leg_b.x, .01), material),
		op_add(right_leg_a, right_leg_b)
#else
		vec2(
		sd_bezier(-(vec3(0., 0., 0.) + side), -knee_l, -left_foot_pos, p, thick).x,
		material),
		vec2(
		sd_bezier(-(vec3(0., 0., 0.) - side), -knee_r, -right_foot_pos, p, thick).x,
		material)
#endif
	);

	vec3 left_toe = normalize(vec3(left_foot_pos.y - knee_l.y, knee_l.x - left_foot_pos.x, 0));
	vec2 left_foot = vec2(
		sd_cylinder(p + left_foot_pos, vec3(0., 0., 0.), left_toe / 8., thick),
		material);

	vec3 right_toe = normalize(vec3(right_foot_pos.y - knee_r.y, knee_r.x - right_foot_pos.x, 0));
	vec2 right_foot = vec2(
		sd_cylinder(p + right_foot_pos, vec3(0., 0., 0.), right_toe / 8., thick),
		material);

	vec2 feet = op_add(left_foot, right_foot);

	vec2 bike = vec2(
		sd_torus(p + wheel_pos, 1., .03),
		mat_bike);

	vec2 ground = vec2(
		sd_plane(P, vec3(0., 1., 0.), wheel_pos.y + 0.5),
		mat_ground);

	vec2 _1 = op_add(feet, bike);
	vec2 _2 = op_add(egg, _1);
	vec2 _3 = op_add(legs, _2);
	return op_add(ground, _3);
}

vec3 sdf_normal(_in(vec3) p)
{
	float dt = 0.05;
	vec3 x = vec3(dt, 0, 0);
	vec3 y = vec3(0, dt, 0);
	vec3 z = vec3(0, 0, dt);
	return normalize(vec3(
		sdf(p + x).r - sdf(p - x).r,
		sdf(p + y).r - sdf(p - y).r,
		sdf(p + z).r - sdf(p - z).r
	));
}

#define EPSILON 0.001

float shadowmarch(_in(ray_t) ray)
{
	const int steps = 20;
	const float end = 10.;
	const float penumbra_factor = 15.;
	const float darkest = 0.1;

	float t = 0.;
	float umbra = 1.;
	for (int i = 0; i < steps; i++) {
		vec3 p = ray.origin + ray.direction * t;
		vec2 d = sdf(p);

		if (t > end) break;
		if (d.x < EPSILON) {
			return darkest;
		}

		t += d.x;
		
		// from http://iquilezles.org/www/articles/rmshadows/rmshadows.htm
		umbra = min(umbra, penumbra_factor * d.x / t);
	}

	return umbra;
}

_mutable(float) depth = -max_dist;

vec3 render(_in(ray_t) ray)
{
	const int steps = 80;
	const float end = 15.;

	float t = 0.;
	for (int i = 0; i < steps; i++) {
		vec3 p = ray.origin + ray.direction * t;
		vec2 d = sdf(p);

		if (t > end) break;
		if (d.x < EPSILON) {
			hit_t h = _begin(hit_t)
				t, // ray length at impact
				int(d.y), // material id
				vec3(0, 0, 0), // sdf_normal(p),
				p // point of impact				
			_end;

			if (h.material_id == mat_egg || h.material_id == mat_bike) {
				depth = max(depth, p.z);
			}

			float s = 1.;
#if 1 // soft shadows
			if (int(d.y) == mat_ground) {
				vec3 sh_dir = vec3(0, 1, 1);
				ray_t sh_ray = _begin(ray_t)
					p + sh_dir * 0.05, sh_dir
				_end;
				s = shadowmarch(sh_ray);
			}
#endif

			return illuminate(h) * s;
		}

		t += d.x;
	}

	return background(ray);
}

void mainImage(
	_out(vec4) fragColor,
#ifdef SHADERTOY
	vec2 fragCoord
#else
	_in(vec2) fragCoord
#endif
){
	vec2 aspect_ratio = vec2(u_res.x / u_res.y, 1);
	float fov = tan(radians(30.0));

	vec3 final_color = vec3(0, 0, 0);

	vec3 eye, look_at;
	setup_camera(eye, look_at);

	setup_scene();

	vec2 point_ndc = fragCoord.xy / u_res.xy;
#ifdef HLSL
		point_ndc.y = 1. - point_ndc.y;
#endif
	vec3 point_cam = vec3(
		(2.0 * point_ndc - 1.0) * aspect_ratio,// * fov,
		-1.0);
	ray_t ray = get_primary_ray(point_cam, eye, look_at);

	final_color += render(ray);

#if 1
	// from https://www.shadertoy.com/view/4sjGzc
#define BAR_SEPARATION 0.6
#define BAR_WIDTH 0.05
#define BAR_DEPTH 1.
#define BAR_COLOR vec3(.6, .6, .6)
	float bar_factor = 1.0 - smoothstep(0.0, 0.01, abs((abs(point_cam.x) - BAR_SEPARATION)) - BAR_WIDTH);
	float depth_factor = 1. - step(BAR_DEPTH, depth);
	final_color = mix(final_color, BAR_COLOR, bar_factor * depth_factor);
#endif

	fragColor = vec4(corect_gamma(final_color, 2.25), 1.);
}
