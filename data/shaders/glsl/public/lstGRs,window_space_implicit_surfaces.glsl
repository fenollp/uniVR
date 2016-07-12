// Shader downloaded from https://www.shadertoy.com/view/lstGRs
// written by shadertoy user paniq
//
// Name: Window Space Implicit Surfaces
// Description: Demos how to use bisection using interval arithmetic to interrogate an implicit surface in window/frustum space. Features implicit frustum culling, backfacing gradient culling and detecting fully occluded cells (for filling a hierarchical z-buffer).
// originally written in Nonelang and auto-translated to GLSL, 
// sorry for the mess ;-)

vec2 u_resolution;
float u_time;

vec2 _2986 (float near, float far) {
    return vec2(far + near, (-2.000000 * far) * near) / (far - near);
}
float outline (float d) {
    return 1.000000 - smoothstep(0.000000, 3.000000 / u_resolution . y, abs(d));
}
float crossline (vec2 p) {
    p = abs(p);
    float minp;
    minp = min(p . x, p . y);
    float maxp;
    maxp = (p . x + p . y) - minp;
    return max(maxp - 1.000000, minp);
}
vec2 ia_div (vec2 a, vec2 b) {
    vec4 q;
    q = vec4(a . x / b, a . y / b);
    return vec2(min(min(min(q . x, q . y), q . z), q . w), max(max(max(q . x, q . y), q . z), q . w));
}
vec2 _44 (vec2 a, float b) {
    return a - vec2(b);
}
vec2 _51 (vec2 a, vec2 b) {
    vec4 q;
    q = a . xxyy * b . xyxy;
    return vec2(min(min(min(q . x, q . y), q . z), q . w), max(max(max(q . x, q . y), q . z), q . w));
}
vec2 _32 (vec2 a, float b) {
    return a + b;
}
vec2 _29 (vec2 a, vec2 b) {
    return a + b;
}
vec2 _57 (float a, vec2 b) {
    vec2 q;
    q = a * b . xy;
    return vec2(min(q . x, q . y), max(q . x, q . y));
}
void _69 (mat2 m, vec2 x, vec2 y, inout vec2 ox, inout vec2 oy) {
    ox = _29(_57(m[0][0], x), _57(m[1][0], y));
    oy = _29(_57(m[0][1], x), _57(m[1][1], y));
}
vec2 _11 (vec2 a, vec2 b) {
    return vec2(min(a . x, b . x), min(a . y, b . y));
}
vec2 _20 (vec2 a, vec2 b) {
    return vec2(max(a . x, b . x), max(a . y, b . y));
}
vec2 ia_unm (vec2 a) {
    return-a . yx;
}
vec2 ia_abs (vec2 a) {
    if (a . x >= 0.000000)
        return a;
    else if (a . y < 0.000000)
        return ia_unm(a);
    else
        return vec2(0.000000, max(-a . x, a . y));
}
vec2 ia_sqrt (vec2 a) {
    return sqrt(a);
}
vec2 ia_pow2 (vec2 a) {
    vec2 q;
    q = a * a;
    if (a . x >= 0.000000)
        return q;
    else if (a . y < 0.000000)
        return q . yx;
    else
        return vec2(0.000000, max(q . x, q . y));
}
vec2 circle_ia (vec2 x, vec2 y, vec2 r) {
    return _44(ia_sqrt(_29(ia_pow2(x), ia_pow2(y))), r . x);
}
vec2 surface (mat2 mtx, vec2 x, vec2 y) {
    y = _44(y, 0.500000);
    y = _32(y, mix(0.500000, -3.000000, (cos(u_time) * 0.500000) + 0.500000));
    x = _32(x, sin(u_time));
    _69(mtx, x, y, x, y);
    return _11(_44(_20(ia_abs(x), ia_abs(y)), 0.600000 * 0.400000), _20(circle_ia(x, y, vec2(0.600000)), ia_unm(circle_ia(x, y, vec2(0.600000 * 0.500000)))));
}
bool ia_contains (vec2 a, float t) {
    return(t >= a . x) && (t <= a . y);
}
vec2 _63 (vec2 a, float b) {
    vec2 q;
    q = b * a . xy;
    return vec2(min(q . x, q . y), max(q . x, q . y));
}
vec2 _38 (vec2 a, vec2 b) {
    return a - b . yx;
}
vec2 gradient_limit (mat2 mtx, vec2 x, vec2 y, vec2 d, float eps) {
    vec2 dx;
    dx = _63(_38(surface(mtx, _32(x, eps), y), surface(mtx, _44(x, eps), y)), 1.000000 / (2.000000 * eps));
    vec2 dy;
    dy = _63(_38(surface(mtx, x, _32(y, eps)), surface(mtx, x, _44(y, eps))), 1.000000 / (2.000000 * eps));
    return _29(_63(dx, d . x), _63(dy, d . y));
}
vec4 trace_tree_ia (mat2 mtx, vec2 p) {
    float near;
    near = 0.500000;
    vec2 coeffs;
    coeffs = _2986(near, 100.000000);
    float b;
    b = 0.000000;
    float s;
    s = 1.000000;
    p . y = p . y + 1.000000;
    // scaling factor
    p = p * 2.0;
    p . y = p . y + near;
    vec2 q;
    q = vec2(p . x / p . y, ((p . y * coeffs . x) + coeffs . y) / p . y);
    vec2 c;
    c = vec2(0.000000);
    float L;
    L = 0.000000;
    float cf;
    cf = mtx[0][0];
    float sf;
    sf = mtx[0][1];
    vec2 iax;
    iax = vec2(0.000000);
    vec2 iay;
    iay = vec2(0.000000);
    vec2 vpos;
    vpos = vec2(0.000000);
    vec4 vcol;
    vcol = vec4(0.000000);
    if (max(abs(q . x), abs(q . y)) < 1.000000) {
        {
            for (int i = 0; i < 11; ++i) {
                {
                    b = b + outline(crossline(q) * s);
                }
                {
                    s = s * 0.500000;
                }
                vec2 o;
                o = (step(vec2(0.000000), q) * 2.000000) - 1.000000;
                q = (q * 2.000000) - o;
                c = c + (o * s);
                iax = vec2(c . x - s, c . x + s);
                iay = vec2(c . y - s, c . y + s);
                vec2 w;
                w = ia_div(vec2(coeffs . y), _44(iay, coeffs . x));
                iax = _51(iax, w);
                iay = _51(iay, w);
                vec2 va;
                va = vec2(c . x, -1.000000) * (coeffs . y / (-1.000000 - coeffs . x));
                vec2 vb;
                vb = vec2(c . x, 1.000000) * (coeffs . y / (1.000000 - coeffs . x));
                vec2 vq;
                vq = c * (coeffs . y / (c - coeffs . x));
                vpos = normalize(va - vb);
                vec2 d2;
                d2 = surface(mtx, iax, iay);
                if (d2 . y <= 0.000000) {
                    vcol = vcol + vec4(0.000000, 1.000000, 0.000000, 1.000000);
                }
                if (ia_contains(d2, 0.000000)) {
                    vec2 g2;
                    g2 = gradient_limit(mtx, iax, iay, vpos, 0.050000);
                    float gc;
                    gc = (g2 . x + g2 . y) * 0.500000;
                    if (g2 . y > 0.000000) L = L + 1.0;
                    else {
                        break;
                    }
                } else {
                    break;
                }
            }
        }
    }
    return vcol + ((L / 11.000000) * vec4(1.000000));
}
float circle_l2 (vec2 p, vec2 r) {
    return(length(p / r) - 1.000000) * min(r . x, r . y);
}
vec4 frag () {
    vec2 p;
    p = ((2.000000 * gl_FragCoord . xy) - u_resolution) / u_resolution . y;
    float L;
    L = 0.000000;
    vec4 M;
    M = vec4(0.000000);
    float N;
    N = 0.000000;
    float a;
    a = u_time * 0.300000;
    float cf;
    cf = cos(a);
    float sf;
    sf = sin(a);
    mat2 mtx;
    mtx = mat2(cf, sf, -sf, cf);
    M = trace_tree_ia(mtx, p);
    float od;
    od = circle_l2(p, vec2(0.600000));
    return 0.000000 + M;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    u_resolution = iResolution.xy;
    u_time = iGlobalTime;
	fragColor = frag();
}