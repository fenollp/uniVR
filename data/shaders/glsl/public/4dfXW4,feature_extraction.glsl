// Shader downloaded from https://www.shadertoy.com/view/4dfXW4
// written by shadertoy user paniq
//
// Name: Feature Extraction
// Description: using techniques described in https://www.graphics.rwth-aachen.de/media/papers/feature1.pdf and http://www.sandboxie.com/misc/isosurf/isosurfaces.html to identify and extract surface features
// marching cube on dual grid visualization
// -- @paniq

#define GRIDRES 10

#ifdef GLSLSANDBOX
#ifdef GL_ES
precision mediump float;
#endif
uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
#define iGlobalTime time
#define iResolution resolution
#endif

// interface
//////////////////////////////////////////////////////////

// set color source for stroke / fill / clear
void set_source_rgba(vec4 c);
void set_source_rgba(float r, float g, float b, float a);
void set_source_rgb(vec3 c);
void set_source_rgb(float r, float g, float b);
void set_source(sampler2D image);

// set line width in normalized units for stroke
void set_line_width(float w);
// set line width in pixels for stroke
void set_line_width_px(float w);
// set blur strength for strokes in normalized units
void set_blur(float b);

// add a circle path at P with radius R
void circle(vec2 p, float r);
void circle(float x, float y, float r);
// add a rectangle at O with size S
void rectangle(vec2 o, vec2 s);
void rectangle(float ox, float oy, float sx, float sy);

// set starting point for curves and lines to P
void move_to(vec2 p);
void move_to(float x, float y);
// draw straight line from starting point to P,
// and set new starting point to P
void line_to(vec2 p);
void line_to(float x, float y);
// draw quadratic bezier curve from starting point
// over B1 to B2 and set new starting point to B2
void curve_to(vec2 b1, vec2 b2);
void curve_to(float b1x, float b1y, float b2x, float b2y);
// connect current starting point with first
// drawing point.
void close_path();

// clear screen in the current source color
void clear();
// fill paths and clear the path buffer
void fill();
// fill paths and preserve them for additional ops
void fill_preserve();
// stroke paths and clear the path buffer
void stroke_preserve();
// stroke paths and preserve them for additional ops
void stroke();
// clears the path buffer
void new_path();

// return rgb color for given hue (0..1)
vec3 hue(float hue);
// return rgb color for given hue, saturation and lightness
vec3 hsl(float h, float s, float l);
vec4 hsl(float h, float s, float l, float a);

// rotate the context by A in radians
void rotate(float a);
// uniformly scale the context by S
void scale(float s);
// translate the context by offset P
void translate(vec2 p);
void translate(float x, float y);
// clear all transformations for the active context
void identity_matrix();
// transform the active context by the given matrix
void transform(mat3 mtx);
// set the transformation matrix for the active context
void set_matrix(mat3 mtx);

// represents the current drawing context
// you usually don't need to change anything here
struct Context {
    vec2 position;
    float scale;
    float shape;
    float line_width;
    vec2 blur;
    vec4 source;
    vec2 start_pt;
    vec2 last_pt;
};
    
// save current source color, stroke width and starting
// point from active context.
Context save();
// restore source color, stroke width and starting point
// to a context previously returned by save()
void restore(Context ctx);

// draws a half-transparent debug gradient for the
// active path
void debug_gradient();

void paint();

// implementation
//////////////////////////////////////////////////////////

vec2 aspect = vec2(iResolution.x / iResolution.y, 1.0);
vec2 uv;
vec2 position;
float ScreenH = min(iResolution.x,iResolution.y);
float AA = ScreenH*0.4;
float AAINV = 1.0 / AA;

//////////////////////////////////////////////////////////

float det(vec2 a, vec2 b) { return a.x*b.y-b.x*a.y; }

//////////////////////////////////////////////////////////

vec3 hue(float hue) {
    return clamp( 
        abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
        0.0, 1.0);
}

vec3 hsl(float h, float s, float l) {
    vec3 rgb = hue(h);
    return l + s * (rgb - 0.5) * (1.0 - abs(2.0 * l - 1.0));
}

vec4 hsl(float h, float s, float l, float a) {
    return vec4(hsl(h,s,l),a);
}

//////////////////////////////////////////////////////////

#define DEFAULT_SHAPE_V 1e+20
    
Context _stack;

void init (vec2 fragCoord) {
    uv = fragCoord.xy / iResolution.xy;
    
     position = (uv*2.0-1.0)*aspect;
    _stack = Context(
        position, 1.0,
        DEFAULT_SHAPE_V,
        1.0,
        vec2(AA,0.0),
        vec4(vec3(0.0),1.0),
        vec2(0.0),
        vec2(0.0)
    );
}

vec3 _color = vec3(1.0);

Context save() {
    return _stack;
}

void restore(Context ctx) {
    // preserve shape
    float shape = _stack.shape;
    _stack = ctx;
    _stack.shape = shape;
}

mat3 mat2x3_invert(mat3 s)
{
    float d = det(s[0].xy,s[1].xy);
    d = (d != 0.0)?(1.0 / d):d;

    return mat3(
        s[1].y*d, -s[0].y*d, 0.0,
        -s[1].x*d, s[0].x*d, 0.0,
        det(s[1].xy,s[2].xy)*d,
        det(s[2].xy,s[0].xy)*d,
        1.0);
}

void identity_matrix() {
    _stack.position = position;
    _stack.scale = 1.0;
}

void set_matrix(mat3 mtx) {
    mtx = mat2x3_invert(mtx);
    _stack.position = (mtx * vec3(position,1.0)).xy;
    _stack.scale = length(vec2(mtx[0].x,mtx[1].y));
}

void transform(mat3 mtx) {
    mtx = mat2x3_invert(mtx);
    _stack.position = (mtx * vec3(_stack.position,1.0)).xy;
    vec2 u = vec2(mtx[0].x, mtx[1].x);
    _stack.scale *= length(u);
}

void rotate(float a) {
    float cs = cos(a), sn = sin(a);
    transform(mat3(
        cs, sn, 0.0,
        -sn, cs, 0.0,
        0.0, 0.0, 1.0));
}

void scale(float s) {
    transform(mat3(s,0.0,0.0,0.0,s,0.0,0.0,0.0,1.0));
}

void translate(vec2 p) {
    transform(mat3(1.0,0.0,0.0,0.0,1.0,0.0,p.x,p.y,1.0));
}

void translate(float x, float y) { translate(vec2(x,y)); }

void clear() {
    _color = mix(_color, _stack.source.rgb, _stack.source.a);
}

void add(float d) {
    _stack.shape = min(_stack.shape, d / _stack.scale);
}

void new_path() {
    _stack.shape = DEFAULT_SHAPE_V;
}

void debug_gradient() {
    _color = mix(_color, 
        hsl(_stack.shape * 6.0, 
            1.0, (_stack.shape>=0.0)?0.5:0.3), 
        0.5);
}

void set_blur(float b) {
    if (b == 0.0) {
        _stack.blur = vec2(AA, 0.0);
        return;
    }
    float a = 1.0 / max(AAINV, b);
    _stack.blur = vec2(
        a,
        0.0); // 0 = blur ends at outline, 1 = blur starts at outline
}

void fill_preserve() {
    float w = clamp(-_stack.shape*AA, 0.0, 1.0);
    _color = mix(_color, _stack.source.rgb, w * _stack.source.a);
}

void fill() {
    fill_preserve();
    new_path();
}

void set_line_width(float w) {
    _stack.line_width = w;
}

void set_line_width_px(float w) {
    _stack.line_width = w*_stack.scale/AA;
}

void stroke_preserve() {
    float w = abs(_stack.shape)- _stack.line_width/_stack.scale;
    vec2 blur = _stack.blur;// / _stack.scale;
    w = clamp(-w*blur.x + blur.y, 0.0, 1.0);
    _color = mix(_color, _stack.source.rgb, w * _stack.source.a);
}

void stroke() {
    stroke_preserve();
    new_path();
}

void set_source_rgba(vec4 c) {
    _stack.source = c;
}

void set_source_rgba(float r, float g, float b, float a) { 
    set_source_rgba(vec4(r,g,b,a)); }

void set_source_rgb(vec3 c) {
    set_source_rgba(vec4(c,1.0));
}

void set_source_rgb(float r, float g, float b) { set_source_rgb(vec3(r,g,b)); }

void set_source(sampler2D image) {
    set_source_rgba(texture2D(image, _stack.position));
}

void rectangle(vec2 o, vec2 s) {
    s*=0.5;
    o = o - _stack.position + s;
    vec2 d = abs(o) - s;
    add(min(max(d.x,d.y),0.0) + length(max(d,0.0)));
}

void rectangle(float ox, float oy, float sx, float sy) {
    rectangle(vec2(ox,oy), vec2(sx,sy));
}

void circle(vec2 p, float r) {
    add(length(_stack.position - p) - r);
}
void circle(float x, float y, float r) { circle(vec2(x,y),r); }

void move_to(vec2 p) {
    _stack.start_pt = p;
    _stack.last_pt = p;
}

void move_to(float x, float y) { move_to(vec2(x,y)); }

// stroke only
void line_to(vec2 p) {
    vec2 pa = _stack.position - _stack.last_pt;
    vec2 ba = p - _stack.last_pt;
    float h = clamp(dot(pa, ba)/dot(ba,ba), 0.0, 1.0);
    add(length(pa - ba*h));
    
    _stack.last_pt = p;
}

void line_to(float x, float y) { line_to(vec2(x,y)); }

void close_path() {
    line_to(_stack.start_pt);
}

// from "Random-access rendering of general vector graphics"
// by Nehab and Hoppe
// only quadratic, not cubic
void curve_to(vec2 b1, vec2 b2)
{
    vec2 b0 = _stack.last_pt - _stack.position;
	_stack.last_pt = b2;
    b1 -= _stack.position;
    b2 -= _stack.position;
    float a=det(b0,b2), b=2.0*det(b1,b0), d=2.0*det(b2,b1);
    float f=b*d-a*a;
    vec2 d21=b2-b1, d10=b1-b0, d20=b2-b0;
    vec2 gf=2.0*(b*d21+d*d10+a*d20);
    gf=vec2(gf.y,-gf.x);
    vec2 pp=-f*gf/dot(gf,gf);
    vec2 d0p=b0-pp;
    float ap=det(d0p,d20), bp=2.0*det(d10,d0p);
    float t=clamp((ap+bp)/(2.0*a+b+d), 0.0, 1.0);
    add(length(mix(mix(b0,b1,t),mix(b1,b2,t),t)));
}

void curve_to(float b1x, float b1y, float b2x, float b2y) {
    curve_to(vec2(b1x,b1y),vec2(b2x,b2y));
}

//////////////////////////////////////////////////////////

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    init(fragCoord);
    
    paint();
    
    fragColor = vec4(_color.xyz, 1.0);
}

#ifdef GLSLSANDBOX
void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}
#endif

//////////////////////////////////////////////////////////

float box(vec3 p, vec3 size) {
	vec3 d = abs(p) - size;
    
	vec3 dm = max(d, 0.0);
    
    return min(max(d.x,max(d.y,d.z)),0.0) + length(dm);
}

float sphere(vec3 p, float r) {
	return length(p) - r;
}

float plane(vec3 p, vec4 n) {
	return dot(p,n.xyz) - n.w;
}

// c must be normalized
float cone(vec3 p, vec2 a, float l) {
    return max(max(a.x*length(p.xy)+a.y*p.z, p.z), abs(p.z)-l);
}

vec2 ms = ((iMouse.xy/iResolution.xy)*2.0-1.0) * aspect;

vec3 rotate(vec3 p, float a) {
	float sa = sin(a);
	float ca = cos(a);
	return vec3(
		p.x*ca - p.z*sa,
		0.0,
		p.x*sa + p.z*ca
	);
}

#if 0 // R functions

float r_min(float a, float b) {
	return a + b - sqrt(a*a+b*b);
}

float r_max(float a, float b) {
	return a + b + sqrt(a*a+b*b);
}


#else // boolean

float r_min(float a, float b) {
	return min(a,b);
}

float r_max(float a, float b) {
	return max(a,b);
}

#endif

float map(vec3 p) {
	float w = plane(p, vec4(0.0,0.0,1.0,-0.6));
	float s = sphere(p - vec3(1.0,0.0,0.0), 0.5);
	float s2 = sphere(p - vec3(0.67,0.0,0.0), 0.2);
	float c = cone(p - vec3(-0.5,0.0,-0.3), normalize(vec2(1.0,0.5)), 0.5);
	float b = box(rotate(p - vec3(-0.5,0.0,0.2),iGlobalTime), vec3(0.3,1.0,0.1));
	return r_min(b, r_min(c, r_min(r_max(s,-s2),w)));
}

float map(vec2 p) {
	return map(vec3(p.x, 0.0, p.y));
}

vec3 grad0(vec3 p, float e) {
	vec2 d = vec2(0.0, e);
	return -vec3(
		map(p + d.yxx) - map(p - d.yxx),
		map(p + d.xyx) - map(p - d.xyx),
		map(p + d.xxy) - map(p - d.xxy));
}

const float ERR = 1e-2;
vec3 grad(vec3 p) {
	return grad0(p,ERR) / (2.0 * ERR);
}


vec2 grad2d(vec3 p) {
	vec2 d = vec2(0.0, 1e-3);
	return normalize(vec2(
		map(p + d.yxx) - map(p - d.yxx),
		map(p + d.xxy) - map(p - d.xxy)));
}

vec2 grad2d(vec2 p) {
	return grad2d(vec3(p.x,0.0,p.y));
}

void arrow(vec2 u, vec2 n) {
	vec2 o = vec2(n.y, -n.x);
	move_to(u);
	u += n;
	line_to(u);
	move_to(u - o*0.2);
	line_to(u + o*0.2);
	line_to(u + n*0.4);
	close_path();
}

float mlen(vec2 c) {
	c = abs(c);
	return max(c.x, c.y);
}

float mlen(vec3 c) {
	c = abs(c);
	return max(c.x, max(c.y, c.z));
}

bool gravitymarch(vec3 ro, float maxt, out vec3 p) {
	float precis = 0.001;
	float h = 1000.0;
	p = ro;
	for(int i = 0; i < 5; i++) {
		if(abs(h) < precis || length(p - ro) > maxt) break;
		h = map(p);
		vec2 n = grad2d(p);
		p.xz -= n*h;
	}	
	return (abs(h) < precis);
}



vec3 sigcolor(float k) {
	return hue(clamp(-k,-1.0,1.0)*0.3333+0.6667);
}

// minimal SVD implementation for calculating feature points from hermite data
// works in C++ and GLSL

// public domain

#define USE_GLSL 1

#define DEBUG_SVD 0

#define SVD_NUM_SWEEPS 10

// GLSL prerequisites

#define IN(t,x) in t x
#define OUT(t, x) out t x
#define INOUT(t, x) inout t x
#define rsqrt inversesqrt

#define SWIZZLE_XYZ(v) v.xyz

// SVD
////////////////////////////////////////////////////////////////////////////////

const float Tiny_Number = 1.e-20;

void givens_coeffs_sym(float a_pp, float a_pq, float a_qq, OUT(float,c), OUT(float,s)) {
    if (a_pq == 0.0) {
        c = 1.0;
        s = 0.0;
        return;
    }
    float tau = (a_qq - a_pp) / (2.0 * a_pq);
    float stt = sqrt(1.0 + tau * tau);
    float tan = 1.0 / ((tau >= 0.0) ? (tau + stt) : (tau - stt));
    c = rsqrt(1.0 + tan * tan);
    s = tan * c;
}

void svd_rotate_xy(INOUT(float,x), INOUT(float,y), IN(float,c), IN(float,s)) {
    float u = x; float v = y;
    x = c * u - s * v;
    y = s * u + c * v;
}

void svd_rotateq_xy(INOUT(float,x), INOUT(float,y), INOUT(float,a), IN(float,c), IN(float,s)) {
    float cc = c * c; float ss = s * s;
    float mx = 2.0 * c * s * a;
    float u = x; float v = y;
    x = cc * u - mx + ss * v;
    y = ss * u + mx + cc * v;
}

void svd_rotate01(INOUT(mat3,vtav), INOUT(mat3,v)) {
    if (vtav[0][1] == 0.0) return;
    
    float c, s;
    givens_coeffs_sym(vtav[0][0], vtav[0][1], vtav[1][1], c, s);
    svd_rotateq_xy(vtav[0][0],vtav[1][1],vtav[0][1],c,s);
    svd_rotate_xy(vtav[0][2], vtav[1][2], c, s);
    vtav[0][1] = 0.0;
    
    svd_rotate_xy(v[0][0], v[0][1], c, s);
    svd_rotate_xy(v[1][0], v[1][1], c, s);
    svd_rotate_xy(v[2][0], v[2][1], c, s);
}

void svd_rotate02(INOUT(mat3,vtav), INOUT(mat3,v)) {
    if (vtav[0][2] == 0.0) return;
    
    float c, s;
    givens_coeffs_sym(vtav[0][0], vtav[0][2], vtav[2][2], c, s);
    svd_rotateq_xy(vtav[0][0],vtav[2][2],vtav[0][2],c,s);
    svd_rotate_xy(vtav[0][1], vtav[1][2], c, s);
    vtav[0][2] = 0.0;
    
    svd_rotate_xy(v[0][0], v[0][2], c, s);
    svd_rotate_xy(v[1][0], v[1][2], c, s);
    svd_rotate_xy(v[2][0], v[2][2], c, s);
}

void svd_rotate12(INOUT(mat3,vtav), INOUT(mat3,v)) {
    if (vtav[1][2] == 0.0) return;
    
    float c, s;
    givens_coeffs_sym(vtav[1][1], vtav[1][2], vtav[2][2], c, s);
    svd_rotateq_xy(vtav[1][1],vtav[2][2],vtav[1][2],c,s);
    svd_rotate_xy(vtav[0][1], vtav[0][2], c, s);
    vtav[1][2] = 0.0;
    
    svd_rotate_xy(v[0][1], v[0][2], c, s);
    svd_rotate_xy(v[1][1], v[1][2], c, s);
    svd_rotate_xy(v[2][1], v[2][2], c, s);
}

void svd_solve_sym(IN(mat3,a), OUT(vec3,sigma), INOUT(mat3,v)) {
    // assuming that A is symmetric: can optimize all operations for 
    // the upper right triagonal
    mat3 vtav = a;
    // assuming V is identity: you can also pass a matrix the rotations
    // should be applied to
    // U is not computed
    for (int i = 0; i < SVD_NUM_SWEEPS; ++i) {
        svd_rotate01(vtav, v);
        svd_rotate02(vtav, v);
        svd_rotate12(vtav, v);
    }
    sigma = vec3(vtav[0][0],vtav[1][1],vtav[2][2]);    
}

float svd_invdet(float x, float tol) {
    return (abs(x) < tol || abs(1.0 / x) < tol) ? 0.0 : (1.0 / x);
}

void svd_pseudoinverse(OUT(mat3,o), IN(vec3,sigma), IN(mat3,v)) {
    float d0 = svd_invdet(sigma[0], Tiny_Number);
    float d1 = svd_invdet(sigma[1], Tiny_Number);
    float d2 = svd_invdet(sigma[2], Tiny_Number);
    o = mat3(v[0][0] * d0 * v[0][0] + v[0][1] * d1 * v[0][1] + v[0][2] * d2 * v[0][2],
             v[0][0] * d0 * v[1][0] + v[0][1] * d1 * v[1][1] + v[0][2] * d2 * v[1][2],
             v[0][0] * d0 * v[2][0] + v[0][1] * d1 * v[2][1] + v[0][2] * d2 * v[2][2],
             v[1][0] * d0 * v[0][0] + v[1][1] * d1 * v[0][1] + v[1][2] * d2 * v[0][2],
             v[1][0] * d0 * v[1][0] + v[1][1] * d1 * v[1][1] + v[1][2] * d2 * v[1][2],
             v[1][0] * d0 * v[2][0] + v[1][1] * d1 * v[2][1] + v[1][2] * d2 * v[2][2],
             v[2][0] * d0 * v[0][0] + v[2][1] * d1 * v[0][1] + v[2][2] * d2 * v[0][2],
             v[2][0] * d0 * v[1][0] + v[2][1] * d1 * v[1][1] + v[2][2] * d2 * v[1][2],
             v[2][0] * d0 * v[2][0] + v[2][1] * d1 * v[2][1] + v[2][2] * d2 * v[2][2]);
}

void svd_solve_ATA_ATb(
    IN(mat3,ATA), IN(vec3,ATb), OUT(vec3,x)
) {
    mat3 V = mat3(1.0);
    vec3 sigma;
    
    svd_solve_sym(ATA, sigma, V);
    
    mat3 Vinv;
    svd_pseudoinverse(Vinv, sigma, V);
    x = Vinv * ATb;
}

vec3 svd_vmul_sym(IN(mat3,a), IN(vec3,v)) {
    return vec3(
        dot(a[0],v),
        (a[0][1] * v.x) + (a[1][1] * v.y) + (a[1][2] * v.z),
        (a[0][2] * v.x) + (a[1][2] * v.y) + (a[2][2] * v.z)
    );
}

// QEF
////////////////////////////////////////////////////////////////////////////////

void qef_add(
    IN(vec3,n), IN(vec3,p),
    INOUT(mat3,ATA), 
    INOUT(vec3,ATb),
    INOUT(vec4,pointaccum))
{
    ATA[0][0] += n.x * n.x;
    ATA[0][1] += n.x * n.y;
    ATA[0][2] += n.x * n.z;
    ATA[1][1] += n.y * n.y;
    ATA[1][2] += n.y * n.z;
    ATA[2][2] += n.z * n.z;

    float b = dot(p, n);
    ATb += n * b;
    pointaccum += vec4(p,1.0);
}

float qef_calc_error(IN(mat3,A), IN(vec3, x), IN(vec3, b)) {
    vec3 vtmp = b - svd_vmul_sym(A, x);
    return dot(vtmp,vtmp);
}

float qef_solve(
    IN(mat3,ATA), 
    IN(vec3,ATb),
    IN(vec4,pointaccum),
    OUT(vec3,x)
) {
    vec3 masspoint = SWIZZLE_XYZ(pointaccum) / pointaccum.w;
    ATb -= svd_vmul_sym(ATA, masspoint);
    svd_solve_ATA_ATb(ATA, ATb, x);
    float result = qef_calc_error(ATA, x, ATb);
    
    x += masspoint;
        
    return result;
}

void find_contours(vec4 rc) {
	vec2 p[4];
	vec2 c[4];
	float d[4];
	float z[4];
	p[0] = rc.xy;	
	p[1] = rc.zy;	
	p[2] = rc.zw;	
	p[3] = rc.xw;	
	for (int i = 0; i < 4; ++i) {
		d[i] = map(p[i]);
	}
	
	z[0] = (-d[0] / (d[1]-d[0]));
	z[1] = (-d[1] / (d[2]-d[1]));
	z[2] = (-d[2] / (d[3]-d[2]));
	z[3] = (-d[3] / (d[0]-d[3]));
	
	c[0] = p[0] + (p[1]-p[0])*z[0];
	c[1] = p[1] + (p[2]-p[1])*z[1];
	c[2] = p[2] + (p[3]-p[2])*z[2];
	c[3] = p[3] + (p[0]-p[3])*z[3];
	
	vec2 mp[4];
	vec2 mg[4];
	int mc = 0;
	
    mat3 ATA = mat3(0.0);
    vec3 ATb = vec3(0.0);
    vec4 pointaccum = vec4(0.0);
    
	for (int i = 0; i < 4; ++i) {
		if (z[i] < 0.0 || z[i] > 1.0) continue;
		
		for (int k = 0; k < 4; ++k) {
			if (k != mc) continue;
			mp[k] = c[i];
			vec2 g = grad2d(c[i]);
			mg[k] = g;
			arrow(c[i], g*0.1);
			stroke();
			mc += 1;
            
            qef_add(
                vec3(g,0.0), vec3(c[i],0.0),
                ATA, ATb, pointaccum);
			break;
		}
	}
	
	const float O_sharp = 0.9;
	float min_ma = 1e+20;
	vec2 n0,n1;
	
	
	for (int i = 0; i < 4; ++i) {
		for (int j=0; j < 4; ++j) {
			if (i >= mc || j >= mc) continue;
			float ma = dot(mg[i].xy,mg[j].xy);
			if (ma < min_ma) {
				min_ma = ma;
				n0 = mg[i];
				n1 = mg[j];
			}
		}
	}
	
	if (min_ma < O_sharp) {
 		vec3 x;
        qef_solve(ATA, ATb, pointaccum, x);
        
        set_source_rgb(vec3(1.0,0.0,0.0));
		circle(x.x, x.y, 0.01);
		stroke();
        
		set_source_rgb(vec3(0.5,1.0,0.5));
	} else {
		set_source_rgb(vec3(1.0,1.0,0.5));
	}
	
	rectangle(rc.xy, rc.zw-rc.xy);
	stroke();
	
	
}

void paint() {
	vec3 mp = vec3(position.x,0.0,position.y);

	// clear screen
	
	set_source_rgb(vec3(0.0,0.0,0.5));
	clear();

	set_line_width_px(1.0);
	
	float d = map(mp);
	_stack.shape = d;
	set_source_rgb(vec3(1.0));
	//fill_preserve();
	stroke();
	
	set_source_rgb(vec3(0.5,0.5,1.0));
	set_line_width_px(1.0);
	for (int i = 0; i < 5; ++i) {
		_stack.shape = d-float(i)*0.05-mod(iGlobalTime*0.01,0.05);
		stroke();
	}
	
	float fc = 0.05;
	vec4 rc = vec4(ms - fc, ms + fc);
	
	find_contours(rc);
}
