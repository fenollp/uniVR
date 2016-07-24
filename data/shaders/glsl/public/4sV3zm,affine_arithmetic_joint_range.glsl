// Shader downloaded from https://www.shadertoy.com/view/4sV3zm
// written by shadertoy user paniq
//
// Name: Affine Arithmetic Joint Range
// Description: visualizing the joint and zero crossing range of 1D revised affine arithmetic operations; drag the mouse to change the search width. Intervals are drawn in purple, affine forms in orange.
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
#define iMouse mouse
#endif

// Revised Affine Arithmetic
// based on the implementation guide contained in
// Fast Reliable Interrogation of Procedurally Defined 
//  	Implicit Surfaces Using Extended Revised Affine Arithmetic
// by Fryazinov, Pasko et al

// revised affine form of rank 1
struct raf1 {
    float x0;
    float x1;
    float e;
};
   
raf1 ra_const(float x) {
    return raf1(x, 0.0, 0.0);
}
float ra_radius(raf1 a) {
    return abs(a.x1) + a.e;
}
vec2 ra_interval(raf1 a) {
    float r = ra_radius(a);
    return vec2(a.x0 - r, a.x0 + r);
}
    
raf1 ra_add(raf1 a, raf1 b) {
	return raf1(a.x0 + b.x0, a.x1 + b.x1, a.e + b.e);
}
raf1 ra_add(raf1 a, float b) {
	return raf1(a.x0 + b, a.x1, a.e);
}
raf1 ra_add(float a, raf1 b) {
	return raf1(a + b.x0, b.x1, b.e);
}

raf1 ra_sub(raf1 a, raf1 b) {
	return raf1(a.x0 - b.x0, a.x1 - b.x1, a.e + b.e);
}
raf1 ra_sub(raf1 a, float b) {
	return raf1(a.x0 - b, a.x1, a.e);
}
raf1 ra_sub(float a, raf1 b) {
	return raf1(a - b.x0, -b.x1, b.e);
}

raf1 ra_unm(raf1 a) {
	return raf1(-a.x0, -a.x1, a.e);
}

raf1 ra_mul(raf1 a, raf1 b) {
    float s = abs(a.x1);
    float t = abs(b.x1);
    float w = dot(a.x1, b.x1);
    float u = s;
    float v = t;
    return raf1(
        a.x0 * b.x0 + 0.5 * w,
        a.x0 * b.x1 + a.x1 * b.x0,
        a.e * b.e
        + b.e * (abs(a.x0) + u)
        + a.e * (abs(b.x0) + v)
        + u * v
        - 0.5 * dot(s, t));
}		
raf1 ra_mul(raf1 a, float b) {
    return raf1(
        a.x0 * b,
        a.x1 * b,        
        a.e * abs(b));
}		
raf1 ra_mul(float a, raf1 b) {
    return ra_mul(b, a);
}

raf1 ra_rcp(raf1 a) {
    vec2 i = ra_interval(a);
    float i0i1 = i[0]*i[1];
    if (i0i1 < 0.0) {
        return raf1(1.0/a.x0, 0.0, 1.0/0.0);
    } else {
        vec2 ab = 1.0 / i;
        float h = sign(i[0]) / sqrt(i0i1);
        float c = (ab[0]+ab[1]) * 0.5;
        float nalpha = ab[0] * ab[1];
        float alpha = -nalpha;
        float zeta = c + h;
        float delta = abs(c-h);
        return raf1(
            alpha * a.x0 + zeta,
            alpha * a.x1,
            nalpha * a.e + delta);
    }
}

raf1 ra_pow2(raf1 a) {
    float s = abs(a.x1);
    float w = dot(a.x1, a.x1);
    float u = s;
    return raf1(
        a.x0 * a.x0 + 0.5 * w,
        2.0 * a.x0 * a.x1,
        a.e * (1.0 + 2.0 * (abs(a.x0) + u))
        + u * u
        - 0.5 * w);
}

raf1 ra_sqrt(raf1 x) {
    vec2 i = ra_interval(x);
    if (i[1] < 0.0) return ra_const(0.0);
    i[0] = max(i[0], 0.0);
    vec2 sq = sqrt(i);
    float c = sq[1] + sq[0];
    float h = sq[1] - sq[0];
    float alpha = 1.0 / c;
    float dzeta = c / 8.0 + 0.5 * sq[0] * sq[1] / c;
    float delta = h * h / (8.0 * c);
    return raf1(
        alpha * x.x0 + dzeta,
        alpha * x.x1,
        alpha * x.e + delta);
}

raf1 ra_abs (raf1 a) {
    vec2 i = ra_interval(a);
    if (i[0]*i[1] >= 0.0) {
        return raf1(abs(a.x0), a.x1 * sign(a.x0), a.e);
    } else {
        vec2 ab = abs(i);        
        float alpha = (ab[1] - ab[0]) / (i[1] - i[0]);
        float zeta = (ab[0] - i[0] * alpha) * 0.5;
        float delta = zeta;
        
        return raf1(
            alpha * a.x0 + zeta, 
            alpha * a.x1, 
            abs(alpha) * a.e + delta);
    }
}

// crude approximation for min/max
// there are more opportunities for truncation here, as only
// the overlapping parallelogram and either one or both top parts (max)
// or bottom parts (min) of each argument need to be bounded.
// e.g. if all minimum values of a are above the minimum values of b, 
// regardless of any overlapping, only a needs to be considered for max(a,b).

raf1 ra_max(raf1 a, raf1 b) {
    vec2 ia = ra_interval(a);
    vec2 ib = ra_interval(b);
    if (ia[0] >= ib[1])
        return a;
    else if (ib[0] >= ia[1])
        return b;
    else {
	    return ra_mul(ra_add(ra_add(a,b),ra_abs(ra_sub(a, b))),0.5);
    }
}

raf1 ra_min(raf1 a, raf1 b) {
    vec2 ia = ra_interval(a);
    vec2 ib = ra_interval(b);
    if (ia[1] <= ib[0])
        return a;
    else if (ib[1] <= ia[0])
        return b;
    else {
	    return ra_mul(ra_sub(ra_add(a,b),ra_abs(ra_sub(a, b))),0.5);
    }
}

raf1 ra_zero(raf1 x, raf1 y) {
    float dxdy = x.x1 / y.x1;
    return raf1(x.x0 - dxdy * y.x0, dxdy * y.e, 0.0);
}

// interface
//////////////////////////////////////////////////////////

// set color source for stroke / fill / clear
void set_source_rgba(vec4 c);
void set_source_rgba(float r, float g, float b, float a);
void set_source_rgb(vec3 c);
void set_source_rgb(float r, float g, float b);
void set_source(sampler2D image);
// if enabled, blends using premultiplied alpha instead of
// regular alpha blending.
void premultiply_alpha(bool enable);

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

// return the active query position for in_fill/in_stroke
// by default, this is the mouse position
vec2 get_query();
// set the query position for subsequent calls to
// in_fill/in_stroke; clears the query path
void set_query(vec2 p);
// true if the query position is inside the current path
bool in_fill();
// true if the query position is inside the current stroke
bool in_stroke();

// return the transformed coordinate of the current pixel
vec2 get_origin();
// draw a 1D graph from coordinate p, result f(p.x),
// and gradient1D(f,p.x)
void graph(vec2 p, float f_x, float df_x);
// draw a 2D graph from coordinate p, result f(p),
// and gradient2D(f,p)
void graph(vec2 p, float f_x, vec2 df_x);
// adds a custom distance field as path
// this field will not be testable by queries
void add_field(float c);

// returns a gradient for 1D graph function f at position x
#define gradient1D(f,x) (f(x + get_gradient_eps()) - f(x - get_gradient_eps())) / (2.0*get_gradient_eps())
// returns a gradient for 2D graph function f at position x
#define gradient2D(f,x) vec2(f(x + vec2(get_gradient_eps(),0.0)) - f(x - vec2(get_gradient_eps(),0.0)),f(x + vec2(0.0,get_gradient_eps())) - f(x - vec2(0.0,get_gradient_eps()))) / (2.0*get_gradient_eps())
// draws a 1D graph at the current position
#define graph1D(f) { vec2 pp = get_origin(); graph(pp, f(pp.x), gradient1D(f,pp.x)); }
// draws a 2D graph at the current position
#define graph2D(f) { vec2 pp = get_origin(); graph(pp, f(pp), gradient2D(f,pp)); }

// represents the current drawing context
// you usually don't need to change anything here
struct Context {
    // screen position, query position
    vec4 position;
    vec2 shape;
    float scale;
    float line_width;
    bool premultiply;
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
// returns the gradient epsilon width
float get_gradient_eps();

// your draw calls here
//////////////////////////////////////////////////////////

raf1 ra_myf(raf1 a) {
    raf1 o = a;
    a = ra_add(a, sin(iGlobalTime * 0.1));
    
    a = ra_pow2(a);
    
    a = ra_max(o,ra_abs(ra_sub(a, 0.5)));
    
    return ra_sub(a,cos(iGlobalTime * 0.17)*0.5+0.5);
}

float myf(float x) {
    //return sin(x) * cos((x + iGlobalTime * 0.2) * 20.0);
    return ra_myf(ra_const(x)).x0;
}

void paint() {
    float t = iGlobalTime;
    
    // clear screen
    
    set_source_rgb(vec3(0.0,0.0,0.5));
    clear();

    float w = (iMouse.z > 0.5)?abs(get_query().x):0.5;
    
    vec2 p = get_origin();
    float i0 = p.x - mod(p.x, w);
    float i1 = i0 + w;  
    
    
    raf1 ax = raf1((i1 + i0)*0.5, (i1 - i0)*0.5, 0.0);
    raf1 ay = ra_myf(ax);
    
    // grid
    move_to(i0, -1.0);
    line_to(i0, 1.0);
    move_to(i1, -1.0);
    line_to(i1, 1.0);
    move_to(i0, 0.0);
    line_to(i1, 0.0);
    set_line_width_px(1.0);
    set_source_rgba(hsl(0.5,1.0,0.8,0.3));
    stroke();

    // visualize interval
    vec2 iv = ra_interval(ay);
    // interval crosses zero?
    bool crossing = (iv.x*iv.y < 0.0);
    
    rectangle(i0,iv.x,w,(iv.y - iv.x));
    set_source_rgba(hsl(0.9,1.0,0.5,crossing?0.5:0.2));
    fill();
    
    // visualize minkowski sum of affine segments
    // after the description given in
    // An Introduction to Affine Arithmetic
    // by stolfi et al.
    vec2 c = vec2(ax.x0,ay.x0);
    vec2 d = vec2(ax.x1, ay.x1);
    vec2 e = vec2(ax.e, ay.e);
    
    vec2 c0 = c - d - e;
    vec2 c1 = c + d - e;
    vec2 c2 = c - d + e;
    vec2 c3 = c + d + e;
    
    move_to(c0);
    line_to(c1);
    move_to(c2);
    line_to(c3);
    close_path();
    set_source_rgba(hsl(0.1,1.0,0.5,1.0));
    set_line_width_px(1.0);
    stroke();
    
    // draw 1D graph
    graph1D(myf);
    // graphs only look good at pixel size
    set_line_width_px(1.0);
    set_source_rgb(vec3(1.0));
    stroke();
    
	// draw intersections with zero plane
    vec2 pr = ra_interval(ra_zero(ax, ay));
    move_to(pr[0],0.0);
    line_to(pr[1],0.0);
    set_source_rgba(hsl(0.0,1.0,0.5,1.0));
    set_line_width_px(2.0);
    stroke();
    
}

// implementation
//////////////////////////////////////////////////////////

vec2 aspect = vec2(iResolution.x / iResolution.y, 1.0);
vec2 uv;
vec2 position;
vec2 query_position;
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
    vec2 m = iMouse.xy / iResolution.xy;
    
    position = (uv*2.0-1.0)*aspect;
    query_position = (m*2.0-1.0)*aspect;
    
    _stack = Context(
        vec4(position, query_position),
        vec2(DEFAULT_SHAPE_V),
        1.0,
        1.0,
        false,
        vec2(0.0,1.0),
        vec4(vec3(0.0),1.0),
        vec2(0.0),
        vec2(0.0)
    );
}

vec3 _color = vec3(1.0);

vec2 get_origin() {
    return _stack.position.xy;
}

vec2 get_query() {
    return _stack.position.zw;
}

void set_query(vec2 p) {
    _stack.position.zw = p;
    _stack.shape.y = DEFAULT_SHAPE_V;
}

Context save() {
    return _stack;
}

void restore(Context ctx) {
    // preserve shape
    vec2 shape = _stack.shape;    
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
    _stack.position = vec4(position, query_position);
    _stack.scale = 1.0;
}

void set_matrix(mat3 mtx) {
    mtx = mat2x3_invert(mtx);
    _stack.position.xy = (mtx * vec3(position,1.0)).xy;
    _stack.position.zw = (mtx * vec3(query_position,1.0)).xy;    
    _stack.scale = length(vec2(mtx[0].x,mtx[1].y));
}

void transform(mat3 mtx) {
    mtx = mat2x3_invert(mtx);
    _stack.position.xy = (mtx * vec3(_stack.position.xy,1.0)).xy;
    _stack.position.zw = (mtx * vec3(_stack.position.zw,1.0)).xy;
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

void blit(out vec4 dest) {
    dest = vec4(_color, 1.0);
}

void blit(out vec3 dest) {
    dest = _color;
}

void add_field(vec2 d) {
    d = d / _stack.scale;
    _stack.shape = min(_stack.shape, d);    
}

void add_field(float c) {
    _stack.shape.x = min(_stack.shape.x, c);
}

void new_path() {
    _stack.shape = vec2(DEFAULT_SHAPE_V);
}

void debug_gradient() {
    _color = mix(_color, 
        hsl(_stack.shape.x * 6.0, 
            1.0, (_stack.shape.x>=0.0)?0.5:0.3), 
        0.5);
}

void set_blur(float b) {
    if (b == 0.0) {
        _stack.blur = vec2(0.0, 1.0);
    } else {
        _stack.blur = vec2(
            b,
            0.0);
    }
}

void write_color(vec4 rgba, float w) {
    float src_a = w * rgba.a;
    float dst_a = _stack.premultiply?w:src_a;
    _color = _color * (1.0 - src_a) + rgba.rgb * dst_a;    
}

void premultiply_alpha(bool enable) {
    _stack.premultiply = enable;
}

float calc_aa_blur(float w) {
    vec2 blur = _stack.blur;
    w -= blur.x;
    float wa = clamp(-w*AA, 0.0, 1.0);
    float wb = clamp(-w / blur.x + blur.y, 0.0, 1.0);    
	return wa * wb; //min(wa,wb);    
}

void fill_preserve() {
    write_color(_stack.source, calc_aa_blur(_stack.shape.x));
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

float get_gradient_eps() {
    return _stack.scale/AA;
}

vec2 stroke_shape() {
    return abs(_stack.shape) - _stack.line_width/_stack.scale;
}

void stroke_preserve() {
    float w = stroke_shape().x;
    write_color(_stack.source, calc_aa_blur(w));
}

void stroke() {
    stroke_preserve();
    new_path();
}

bool in_fill() {
    return (_stack.shape.y <= 0.0);
}

bool in_stroke() {
    float w = stroke_shape().y;
    return (w <= 0.0);
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
    set_source_rgba(texture2D(image, _stack.position.xy));
}

vec2 length2(vec4 a) {
    return vec2(length(a.xy),length(a.zw));
}

vec2 dot2(vec4 a, vec2 b) {
    return vec2(dot(a.xy,b),dot(a.zw,b));
}

void rectangle(vec2 o, vec2 s) {
    s*=0.5;
    o += s;
    vec4 d = abs(o.xyxy - _stack.position) - s.xyxy;
    vec4 dmin = min(d,0.0);
    vec4 dmax = max(d,0.0);
    add_field(max(dmin.xz, dmin.yw) + length2(dmax));
}

void rectangle(float ox, float oy, float sx, float sy) {
    rectangle(vec2(ox,oy), vec2(sx,sy));
}

void circle(vec2 p, float r) {
    vec4 c = _stack.position - p.xyxy;
    add_field(vec2(length(c.xy),length(c.zw)) - r);
}
void circle(float x, float y, float r) { circle(vec2(x,y),r); }

void move_to(vec2 p) {
    _stack.start_pt = p;
    _stack.last_pt = p;
}

void move_to(float x, float y) { move_to(vec2(x,y)); }

// stroke only
void line_to(vec2 p) {
    vec4 pa = _stack.position - _stack.last_pt.xyxy;
    vec2 ba = p - _stack.last_pt;
    vec2 h = clamp(dot2(pa, ba)/dot(ba,ba), 0.0, 1.0);
    add_field(length2(pa - ba.xyxy*h.xxyy));
    
    _stack.last_pt = p;
}

void line_to(float x, float y) { line_to(vec2(x,y)); }

void close_path() {
    line_to(_stack.start_pt);
}

// from https://www.shadertoy.com/view/ltXSDB

// Solve cubic equation for roots
vec3 bezier_solve(float a, float b, float c) {
    float p = b - a*a / 3.0, p3 = p*p*p;
    float q = a * (2.0*a*a - 9.0*b) / 27.0 + c;
    float d = q*q + 4.0*p3 / 27.0;
    float offset = -a / 3.0;
    if(d >= 0.0) { 
        float z = sqrt(d);
        vec2 x = (vec2(z, -z) - q) / 2.0;
        vec2 uv = sign(x)*pow(abs(x), vec2(1.0/3.0));
        return vec3(offset + uv.x + uv.y);
    }
    float v = acos(-sqrt(-27.0 / p3) * q / 2.0) / 3.0;
    float m = cos(v), n = sin(v)*1.732050808;
    return vec3(m + m, -n - m, n - m) * sqrt(-p / 3.0) + offset;
}

// Find the signed distance from a point to a quadratic bezier curve
float bezier(vec2 A, vec2 B, vec2 C, vec2 p)
{    
    B = mix(B + vec2(1e-4), B, abs(sign(B * 2.0 - A - C)));
    vec2 a = B - A, b = A - B * 2.0 + C, c = a * 2.0, d = A - p;
    vec3 k = vec3(3.*dot(a,b),2.*dot(a,a)+dot(d,b),dot(d,a)) / dot(b,b);      
    vec3 t = clamp(bezier_solve(k.x, k.y, k.z), 0.0, 1.0);
    vec2 pos = A + (c + b*t.x)*t.x;
    float dis = length(pos - p);
    pos = A + (c + b*t.y)*t.y;
    dis = min(dis, length(pos - p));
    pos = A + (c + b*t.z)*t.z;
    dis = min(dis, length(pos - p));
    return dis; // * bezier_sign(A, B, C, p);
}

void curve_to(vec2 b1, vec2 b2) {
    add_field(vec2(
        bezier(_stack.last_pt, b1, b2, _stack.position.xy),
        bezier(_stack.last_pt, b1, b2, _stack.position.zw)));
	_stack.last_pt = b2;
}

void curve_to(float b1x, float b1y, float b2x, float b2y) {
    curve_to(vec2(b1x,b1y),vec2(b2x,b2y));
}

void graph(vec2 p, float f_x, float df_x) {
    add_field(abs(f_x - p.y) / sqrt(1.0 + (df_x * df_x)));
}

void graph(vec2 p, float f_x, vec2 df_x) {
    add_field(abs(f_x) / length(df_x));
}

//////////////////////////////////////////////////////////

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    init(fragCoord);
    
    paint();
    
    blit(fragColor);
}

#ifdef GLSLSANDBOX
void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}
#endif
