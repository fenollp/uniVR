// Shader downloaded from https://www.shadertoy.com/view/4syGzy
// written by shadertoy user paniq
//
// Name: Polynomial Arithmetic
// Description: Raytracing implicit surfaces in the fewest possible steps via polynomial arithmetic. Drag the mouse to change the starting point of the ray.
// instant implicit surfaces via polynomial arithmetic
// -- @paniq

// uncomment to visualize various extra graphs
// #define DEBUG_VIZ
// rainbow zig zag line: actual trace, each hue is an iteration
// red: zero line
// white: f(x)
// yellow: f'(x)
// green: f''(x)
// magenta: distance to next horizon (discontinuity)
// cyan: distance to next root

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

/////////////////////////////////////////////////////////

void paint();

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
    
    fragColor = vec4(_color.xyz, 1.0);
}

#ifdef GLSLSANDBOX
void main() {
    mainImage(gl_FragColor, gl_FragCoord.xy);
}
#endif

//////////////////////////////////////////////////////////

// polynomial arithmetic
// describes piecewise univariate polynomial with degree 2
struct poly2 {
    // the coefficients for f(x) = a0 * x^0 + a1 * x^1 + a2 * x^2
    vec3 a;
    // distance to horizon
    float h;
};

const float infinity = 1. / 0.;

bool hasaxis(float h) {
    return (h != infinity);
}

bool hasaxis(poly2 f) {
    return hasaxis(f.h);
}

poly2 pa_init(float x) {
    return poly2(vec3(x,1.0,0.0),infinity);
}

float merge_axes(float f, float g) {
    if (hasaxis(g)) {
        if (hasaxis(f)) {
            float a0 = min(f, g);
            float a1 = max(f, g);
            return ((a0 > 0.0)?a0:a1);
        } else {
            return g;
		}
    }
    return f;
}

float merge_axes(poly2 f, poly2 g) {
    return merge_axes(f.h,g.h);
}

poly2 pa_add(poly2 f, poly2 g) {
    return poly2(f.a + g.a,merge_axes(f,g));
}
poly2 pa_add(poly2 f, float c) {
    return poly2(vec3(f.a[0] + c,f.a[1],f.a[2]),f.h);
}
poly2 pa_add(float c, poly2 f) {
    return poly2(vec3(f.a[0] + c,f.a[1],f.a[2]),f.h);
}
poly2 pa_sub(poly2 f, poly2 g) {
    return poly2(f.a - g.a,merge_axes(f,g));
}
poly2 pa_sub(poly2 f, float c) {
    return poly2(vec3(f.a[0] - c,f.a[1],f.a[2]),f.h);
}
poly2 pa_sub(float c, poly2 f) {
    return poly2(vec3(c - f.a[0],-f.a[1],-f.a[2]),f.h);
}
poly2 pa_unm(poly2 f) {
    return poly2(-f.a,f.h);
}

// {a0 a1 a2} * {b0 b1 b2}
// = {a0*b0 (a0*b1 + a1*b0) (a0*b2 + a2*b0 + a1*b1) (a1*b2 + a2*b1) (a2*b2)}
// the two new coefficients are truncated, so only linear
// functions are going to work here
poly2 pa_mul(poly2 f, poly2 g) {    
    return poly2(vec3(
    	f.a[0] * g.a[0],
	    f.a[0] * g.a[1] + f.a[1] * g.a[0],
        /* f.a[0] * g.a[2] + */ f.a[1] * g.a[1] /* + f.a[2] * g.a[0] */
        //f.a[1] * g.a[2] + f.a[2] * g.a[1],
        //f.a[2] * g.a[2]
        ), f.h);
}
poly2 pa_mul(poly2 f, float c) {
    return poly2(f.a * c,f.h);
}
poly2 pa_mul(float c, poly2 f) {
    return poly2(f.a * c,f.h);
}

poly2 pa_pow2(poly2 f) {
    return poly2(vec3(
    	f.a[0] * f.a[0],
	    2.0 * f.a[0] * f.a[1],
        /* 2.0 * f.a[0] * f.a[2] + */ f.a[1] * f.a[1]
        //2.0 * f.a[1] * f.a[2],
        //f.a[2] * f.a[2]
        ), f.h);
}

// returns f(x), f'(x), f''(x)
vec3 pa_f(vec3 a, float x) {
    return vec3(
        a[0] + (a[1] +       a[2] * x) * x,
                a[1] + 2.0 * a[2] * x,
                             a[2]);
}

float solve_quadratic(vec3 fa, float x) {
    float a = fa[2];
    float b = fa[1];
    float c = fa[0];

    // the quadratic solve doesn't work for a=0
    // so we need a branch here.
    if (a == 0.0) {
        return -c / b;
    } else { 
        // (-b +- sqrt(b*b - 4.0*a*c)) / 2.0*a
        float k = -0.5*b/a;
        float q = sqrt(k*k - c/a);
        float q0 = k - q;
        float q1 = k + q;
        
        // pick the root right of x
		return (q0 <= x)?q1:q0;
    }
}

float solve_quadratic0(vec3 fa) {
    float a = fa[2];
    float b = fa[1];
    float c = fa[0];

    // the quadratic solve doesn't work for a=0
    // so we need a branch here.
    if (a == 0.0) {
        return -c / b;
    } else { 
        // (-b +- sqrt(b*b - 4.0*a*c)) / 2.0*a
        float k = -0.5*b/a;
        float q = sqrt(k*k - c/a);
        // pick the closest root right of 0
		return k + ((k <= q)?q:-q);
    }
}

float solve_quadratic(poly2 f) {
    return solve_quadratic0(f.a);
}

// returns the x position of the next root, where f(x) = 0
float nextroot(poly2 f) {
    return solve_quadratic(f);
}

// returns the position of the next event (root or start of new segment)
float nextevent(poly2 f) {
    float s = nextroot(f);
    float h = (f.h <= 0.0)?infinity:f.h;
    s = (s <= 0.0)?h:min(s,h);
    return s;
}

float axis(poly2 f) {
    return nextevent(f);
}

poly2 pa_abs(poly2 f) {
    float s = ((f.a[0] < 0.0)?-1.0:1.0);
    return poly2(f.a * s, axis(f));
}

// intermediate abs: discontinuity will disappear in next step
poly2 pa_imabs(poly2 f) {
    float s = ((f.a[0] < 0.0)?-1.0:1.0);
    return poly2(f.a * s, f.h);
}

poly2 pa_const(float c) {
    return poly2(vec3(c,0.0,0.0), infinity);
}

poly2 pa_ipol(vec2 a, vec2 b) {
    float a1 = (a.y - b.y)/(a.x - b.x);
	float a0 = a.y - a1*a.x;
    return poly2(vec3(a0, a1, 0.0), infinity);
}

poly2 pa_ipol(vec2 a, vec2 b, float k) {
    float a2 = 0.5*k;
    float aa2 = a2*a.x*a.x;
    float a1 = (a.y - b.y + a2*b.x*b.x - aa2) / (a.x - b.x);
    float a0 = a.y - a1*a.x - aa2;
    return poly2(vec3(a0, a1, a2), infinity);
}

poly2 pa_min(poly2 f, poly2 g) {
    float h = axis(pa_sub(f,g));
    float fx = f.a[0];
    float gx = g.a[0];
    return poly2((fx < gx)?f.a:g.a, h);
}
poly2 pa_max(poly2 f, poly2 g) {
    float h = axis(pa_sub(f,g));
    float fx = f.a[0];
    float gx = g.a[0];
    return poly2((fx > gx)?f.a:g.a, h);
    
}

// intermediate min: discontinuity will disappear
poly2 pa_immin(poly2 f, poly2 g) {
    float fx = f.a[0];
    float gx = g.a[0];
    return poly2((fx < gx)?f.a:g.a, merge_axes(f,g));
}

// intermediate max: discontinuity will disappear
poly2 pa_immax(poly2 f, poly2 g) {
    float fx = f.a[0];
    float gx = g.a[0];
    return poly2((fx > gx)?f.a:g.a, merge_axes(f,g));
    
}

// can only be used once on flat surfaces
poly2 pa_smin(poly2 a, poly2 b, float r) {
    poly2 c = pa_sub(a,b);
    float h0 = axis(pa_sub(c, r));
    float h1 = axis(pa_add(c, r));
    float h = merge_axes(h0,h1);
    poly2 e = pa_immin(
        pa_immax(
            pa_add(
                pa_unm(
                    pa_imabs(
                        pa_sub(a, b))), r),
            pa_const(0.0)),pa_const(r));
    poly2 d = pa_sub(pa_immin(a, b), pa_mul(pa_pow2(e), 0.25 / r));
    d.h = h;
    return d;
}

// approximates blend with a quadratic patch, but
// still buggy. do not use.
poly2 pa_smin2(poly2 a, poly2 b, float r) {
    poly2 c = pa_sub(a,b);
    float h0 = axis(pa_sub(c, r));
    float h1 = axis(pa_add(c, r));
    float x0 = min(h0,h1);
    float x1 = max(h0,h1);
    float h = merge_axes(h0,h1);
    if (x0 > 0.0) {
        a.h = h;
        return a;
    } else if (x1 <= 0.0) {
        b.h = h;
        return b;
    } else {
        vec3 ay0 = pa_f(a.a, x0);
        vec3 by0 = pa_f(b.a, x0);
        vec3 ay1 = pa_f(a.a, x1);
        vec3 by1 = pa_f(b.a, x1);
        vec3 y0 = (ay0.x < by0.x)?ay0:by0;
        vec3 y1 = (ay1.x < by1.x)?ay1:by1;
        poly2 m = pa_ipol(vec2(x0, y0.x), vec2(x1, y1.x), (y1.y - y0.y) / (x1 - x0));
        m.h = x0;
    	return m;
    }
}

poly2 pa_map(poly2 f) {
    float wf = mix(0.0,0.3,sin(iGlobalTime)*0.5+0.5);
    float wu = mix(1.0,0.0,cos(iGlobalTime*0.2)*0.5+0.5);

#if 0
    f = pa_add(pa_mul(f,0.85),wf);

    f = pa_abs(f);
    f = pa_mul(f, -1.0);
    f = pa_add(f, 0.5);
    f = pa_add(f, mix(-0.8,0.3,wu));
    f = pa_abs(f);
    f = pa_add(f, -0.2);
    f = pa_abs(f);
    f = pa_add(f, -0.1);
#endif
#if 0
    poly2 a = pa_add(pa_mul(f,0.9),0.1);
    poly2 b = pa_add(pa_mul(f,-0.2),0.3);
    
    f = pa_smin2(a,b,0.1);
    
    //f.w = max(a.w,b.w);
    
    f = pa_add(f,wf-0.5);
    //f = pa_abs(f);
    f = pa_add(f,0.2);
#endif
#if 0
    poly2 x = pa_add(pa_mul(f, 0.44721),0.2);
    poly2 y = pa_add(pa_mul(f, 0.89443),-0.3);
    
    //f = pa_add(pa_abs(x),pa_abs(y));
    
    f = pa_add(pa_pow2(x),pa_pow2(y));
    //f = pa_sqrt(f);
    f = pa_add(f,-0.9+wf);
    f = pa_mul(f, -0.5);
    f = pa_abs(f);
    f = pa_add(f, -0.3);
#endif
#if 0
    
    poly2 a = pa_pow2(f);
    a = pa_add(a, -0.2);

    poly2 b = pa_pow2(pa_add(f, -0.5));
    b = pa_add(b, -0.2);
    b = pa_unm(b);
    
    f = pa_smin(a,b,0.1);
    
    f = pa_add(f, mix(-0.5,0.5,wu));
    
    
#endif
#if 1
    // rotating cube with subtracted sphere
    poly2 x = pa_const(0.0);
    poly2 y = f;
	poly2 z = pa_const(0.45);
    
    float a = iGlobalTime*0.1;
    float s = sin(a);
    float c = cos(a);
    
    poly2 rz = pa_sub(pa_mul(c, z),pa_mul(s, y));
    poly2 ry = pa_add(pa_mul(s, z),pa_mul(c, y));
    
    // cube
    poly2 cube = pa_sub(pa_max(pa_abs(x),pa_max(pa_abs(ry),pa_abs(rz))),0.5);
    
    // sphere
    poly2 sphere = pa_sub(pa_add(pa_add(pa_pow2(x),pa_pow2(ry)),pa_pow2(pa_sub(rz,0.5))),0.25*0.25);
    
    // subtract sphere from cube
    f = pa_max(cube, pa_unm(sphere));
    
    
#endif
    
    //f = pa_ipol(f, vec2(-1.0, 0.0), vec2(1.0, 1.0), -0.5);
    
    return f;
}

// how to convert pa_map to a classic map function
// t is the ray scalar
// returns function value at that point, and distance
// to next root or horizon
vec2 map(float t) {
    poly2 f = pa_map(pa_init(t));
    return vec2(f.a[0], nextevent(f));
}

float rayf(float t) {
    return pa_map(pa_init(t)).a[0];
}

float rayff(float t) {
    return pa_map(pa_init(t)).a[1];
}

float rayfff(float t) {
    return pa_map(pa_init(t)).a[2];
}

float raynextroot(float t) {
    return nextroot(pa_map(pa_init(t)));
}

float rayhorizon(float t) {
    return pa_map(pa_init(t)).h;
}

void paint() {
	vec2 ms = ((iMouse.xy/iResolution.xy)*2.0-1.0) * aspect;
	
    // clear screen
	
	set_source_rgb(vec3(0.0,0.0,0.5));
	clear();

	set_line_width_px(1.3);
    
    // draw zero crossing
    move_to(-2.0,0.0);
    line_to(2.0,0.0);
    set_line_width_px(1.0);
    set_source_rgb(vec3(1.0,0.0,0.0));
    stroke();

    #ifdef DEBUG_VIZ

    // draw 1D graph of estimated distance to horizon
    graph1D(rayhorizon);
    set_line_width_px(1.3);
    set_source_rgb(vec3(1.0,0.0,1.0));
    stroke();    

    // draw 1D graph of estimated distance to root
    graph1D(raynextroot);
    set_line_width_px(1.3);
    set_source_rgb(vec3(0.0,1.0,1.0));
    stroke();    

    // draw 1D graph of second derivative
    graph1D(rayfff);
    set_line_width_px(1.3);
    set_source_rgb(vec3(0.5,1.0,0.0));
    stroke();    

    // draw 1D graph of first derivative
    graph1D(rayff);
    set_line_width_px(1.3);
    set_source_rgb(vec3(1.0,1.0,0.0));
    stroke();    
    
    #endif

    // draw 1D graph of ray distances
    graph1D(rayf);
    set_line_width_px(1.3);
    set_source_rgb(vec3(1.0));
    stroke();    
    
	float maxt = aspect.x;
    
	float precis = 0.01;
	float t = (iMouse.z > 0.5)?ms.x:-aspect.x;
    
	for(int i = 0; i < 20; i++) {
		if(t > maxt) continue;
		set_source_rgb(hsl(float(i)/20.0, 1.0, 0.5));
        vec2 d = map(t);
        float w = t + d.y;
        move_to(t, 0.0);
        line_to(t, d.x);  
        line_to(w, 0.0);
		stroke();
        if (abs(d.x) <= precis) {
            circle(t, 0.0, 0.03);
            fill();
        }        
        t = w + 0.001;
	}
    if (t > maxt) {
        set_source_rgb(vec3(0.0,1.0,1.0));
        move_to(aspect.x * 0.99, -1.0);
        line_to(aspect.x * 0.99, 1.0);
        stroke();
    }
    
    
}
