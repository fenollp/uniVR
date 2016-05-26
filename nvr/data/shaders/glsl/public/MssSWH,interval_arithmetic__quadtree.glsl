// Shader downloaded from https://www.shadertoy.com/view/MssSWH
// written by shadertoy user paniq
//
// Name: Interval Arithmetic: Quadtree
// Description: Traversing an implicit function octree-style using interval arithmetic
// IA quadtree visualization
// -- @paniq

// undefine if you are running on glslsandbox.com
// #define GLSLSANDBOX

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

#define iafloat vec2
#define iavec3 mat3 // in glsl: mat3x2

iavec3 iavec3_new(iafloat x, iafloat y, iafloat z) {
	return iavec3(x, 0.0, y, 0.0, z, 0.0);
}

iavec3 iavec3_new(float x, float y, float z) {
	return iavec3(x, x, 0.0, y, y, 0.0, z, z, 0.0);
}

iavec3 iavec3_new(vec3 p) {
	return iavec3(p.xx, 0.0, p.yy, 0.0, p.zz, 0.0);
}

iavec3 iavec3_new(vec3 p0, vec3 p1) {
	return iavec3(p0.x, p1.x, 0.0, p0.y, p1.y, 0.0, p0.z, p1.z, 0.0);
}

iafloat imin(iafloat a, iafloat b) {
	return iafloat(min(a.x,b.x),min(a.y,b.y));
}

iafloat imax(iafloat a, iafloat b) {
	return iafloat(max(a.x,b.x),max(a.y,b.y));
}

iafloat iadd(iafloat a, iafloat b) {
	return a + b;
}

iavec3 iadd(iavec3 a, iavec3 b) {
	return iavec3_new(
		a[0].xy + b[0].xy,
		a[1].xy + b[1].xy,
		a[2].xy + b[2].xy);
}

iavec3 iadd(vec3 a, iavec3 b) {
	return iavec3_new(
		a.xx + b[0].xy,
		a.yy + b[1].xy,
		a.zz + b[2].xy);
}

iafloat isub(iafloat a, iafloat b) {
	return a - b.yx;
}

iavec3 isub(iavec3 a, iavec3 b) {
	return iavec3_new(
		a[0].xy - b[0].yx,
		a[1].xy - b[1].yx,
		a[2].xy - b[2].yx);
}

iavec3 isub(iavec3 a, vec3 b) {
	return iavec3_new(
		a[0].xy - b.xx,
		a[1].xy - b.yy,
		a[2].xy - b.zz);
}

iafloat imul(iafloat a, iafloat b) {
	vec4 f = vec4(
		a.xxyy * b.xyxy
	);	
	return iafloat(
		min(min(f[0],f[1]),min(f[2],f[3])),
		max(max(f[0],f[1]),max(f[2],f[3])));
}

iafloat imul(float a, iafloat b) {
	vec2 f = vec2(a*b);	
	return iafloat(
		min(f[0],f[1]),
		max(f[0],f[1]));
}

iavec3 imul(iavec3 a, iavec3 b) {
	return iavec3_new(
		imul(a[0].xy, b[0].xy),
		imul(a[1].xy, b[1].xy),
		imul(a[2].xy, b[2].xy)
	);
}

iavec3 imul(float a, iavec3 b) {
	return iavec3_new(
		imul(a, b[0].xy),
		imul(a, b[1].xy),
		imul(a, b[2].xy)
	);
}

iavec3 imul(vec3 a, iavec3 b) {
	return iavec3_new(
		imul(a.xx, b[0].xy),
		imul(a.yy, b[1].xy),
		imul(a.zz, b[2].xy)
	);
}

iavec3 imul(vec3 a, iafloat b) {
	return iavec3_new(
		imul(a.x, b),
		imul(a.y, b),
		imul(a.z, b)
	);
}


iafloat idiv(iafloat a, iafloat b) {
	vec4 f = vec4(
		a.x/b, a.y/b
	);
	return iafloat(
		min(min(f[0],f[1]),min(f[2],f[3])),
		max(max(f[0],f[1]),max(f[2],f[3])));
}

iavec3 idiv(iavec3 a, iavec3 b) {
	return iavec3_new(
		idiv(a[0].xy, b[0].xy),
		idiv(a[1].xy, b[1].xy),
		idiv(a[2].xy, b[2].xy)
	);
}

iafloat isqrt(iafloat a) {
	return iafloat(sqrt(a.x),sqrt(a.y));
}

// for even powers in general,
// for odd powers, it's just iafloat(a*a)
iafloat ipow2(iafloat a) {	
	return (a.x>=0.0)?iafloat(a*a):(a.y<0.0)?iafloat((a*a).yx):iafloat(0.0,max(a.x*a.x,a.y*a.y));
}

iavec3 ipow2(iavec3 v) {
	return iavec3_new(
		ipow2(v[0].xy),
		ipow2(v[1].xy),
		ipow2(v[2].xy));
}

iafloat ilensq(iavec3 a) {
	iavec3 c = ipow2(a);
	return c[0].xy + c[1].xy + c[2].xy;
}

iafloat ilength(iavec3 a) {
	iavec3 c = ipow2(a);
	return isqrt(c[0].xy + c[1].xy + c[2].xy);
}

iafloat idot(iavec3 a, iavec3 b) {
	iavec3 c = imul(a,b);
	return c[0].xy + c[1].xy + c[2].xy;
}

bool icontains(iafloat a, float v) {
	return ((v >= a.x) && (v < a.y));
}

//////////////////////////////////////////////////////////

iafloat sphere(iavec3 p, float r) {
	// x^2 + y^2 + z^2 - r^2
	return isub(ilensq(p),iafloat(r*r));
}

iafloat teardrop(iavec3 p) {
	// -0.5x^5 - 0.5x^4 + y^2 + z^2
	
	iafloat x2 = ipow2(p[2].xy);
	iafloat y2 = ipow2(p[1].xy);
	iafloat z2 = ipow2(p[0].xy);
	
	iafloat x4 = ipow2(x2);
	iafloat x5 = imul(p[2].xy,x4);
	
	return iadd(iadd(isub(imul(-0.5,x5), imul(0.5,x4)), y2), z2);	
}

float as = sin(iGlobalTime)*0.5+0.5;

iafloat map(iavec3 p) {
	// scaling needs no distance fix
	iafloat drop = teardrop(imul(2.0,isub(p, vec3(1.0,0.0,0.0))));
	iafloat sph1 = sphere(isub(p, vec3(1.0,0.0,0.0)), 0.8);
	// anisotropic scaling is no problem
	iafloat sph2 = sphere(imul(
		vec3(3.0,1.0,1.0),
		isub(p, vec3(0.0,0.0,-0.9+0.2*as))), 0.5);
	
	return imin(imax(drop,sph1), sph2);
}

vec2 grad2d(vec3 p) {
	vec2 d = vec2(0.0, 1e-3);
	
	// could do this with only two queries if only the sign
	// could be recovered.
	vec2 hx = map(iavec3_new(p + d.yxx)) - map(iavec3_new(p - d.yxx));
	vec2 hy = map(iavec3_new(p + d.xxy)) - map(iavec3_new(p - d.xxy));
	
	return normalize(vec2(
		hx.x, hy.x));
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

iafloat trace_paint(vec3 ro, vec3 rd, iafloat t) {
	iavec3 r = iadd(ro, imul(rd, t));
	
	iafloat h = map(r);
	if (icontains(h, 0.0))
		set_source_rgba(vec4(0.0,1.0,0.0,0.5));
	else
		set_source_rgba(vec4(1.0,0.0,0.0,0.5));
	
	move_to(ro.xz+rd.xz*t.x);
	line_to(ro.xz+rd.xz*t.y);
	stroke();
	
	rectangle(r[0].x, r[2].x, r[0].y - r[0].x, r[2].y - r[2].x);
	stroke();
	
	return h;
}

void paint() {
	vec2 ms = ((iMouse.xy/iResolution.xy)*2.0-1.0) * aspect;
	
	// clear screen
	
	iafloat d = map(iavec3_new(
		vec3(position.x,0.0,position.y)));
	
	
	set_source_rgb(
		(d.x<=0.0)?hsl(0.6, 1.0, 0.7):vec3(0.0,0.0,0.5));
	clear();

	set_source_rgba(hsl(0.6, 1.0, 0.7, 0.3));
	set_line_width_px(3.0);
	for (int i = 0; i < 8; ++i) {
		_stack.shape = d.x-float(i)*0.2;
		stroke();
	}

	set_source_rgb(vec3(1.0));
	set_line_width_px(1.0);
	new_path();

	float D = 2.0;
	vec3 p0 = vec3(-D,0.0,-D);
	vec3 p1 = vec3(D,0.0,D);
	
	#define MAX_STEP 12
	for (int i = 0; i < MAX_STEP; ++i) {
		iafloat t = map(iavec3_new(p0,p1));
		if (icontains(t,0.0)) {
			if (i == MAX_STEP-1) {
				set_source_rgb(vec3(0.0,1.0,0.0));
			} else {
				set_source_rgb(vec3(1.0,0.0,0.0));
			}
			
			rectangle(p0.xz, (p1 - p0).xz);
			stroke();
			
			vec3 pc = (p0+p1)*0.5;
			if (position.x > pc.x)
				p0.x = pc.x;
			else
				p1.x = pc.x;
			if (position.y > pc.z)
				p0.z = pc.z;
			else
				p1.z = pc.z;
		} else if (max(t.x,t.y) <= 0.0) {
			set_source_rgb(vec3(1.0,1.0,1.0));
			rectangle(p0.xz, (p1 - p0).xz);
			stroke();
			break;
		} else {
			break;
		}
		

	}


}

