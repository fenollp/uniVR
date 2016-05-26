// Shader downloaded from https://www.shadertoy.com/view/4tsGRl
// written by shadertoy user paniq
//
// Name: Plane Feature Points
// Description: finding feature points of planes with a simplified SVD

// minimal SVD implementation for calculating feature points from hermite data
// works in C++ and GLSL

#define PLANE_COUNT 3


// SVD/QEF parts are public domain

#define SVD_NUM_SWEEPS 10

// GLSL prerequisites

#define IN(t,x) in t x
#define OUT(t, x) out t x
#define INOUT(t, x) inout t x
#define rsqrt inversesqrt

#define SWIZZLE_XYZ(v) v.xyz

// SVD
////////////////////////////////////////////////////////////////////////////////

const float Tiny_Number = 0.1;

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
    // the lower left triagonal
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

// uncomment for a cross section view
//#define CROSS_SECTION

//------------------------------------------------------------------------
// Camera
//
// Move the camera. In this case it's using time and the mouse position
// to orbitate the camera around the origin of the world (0,0,0), where
// the yellow sphere is.
//------------------------------------------------------------------------
void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
#ifdef CROSS_SECTION
    float an = 1.5+sin(0.3*iGlobalTime);
#else
    float an = 0.3*iGlobalTime + 10.0*mouseX;
#endif
	camPos = vec3(4.5*sin(an),2.0,4.5*cos(an));
    camTar = vec3(0.0,0.0,0.0);
}


//------------------------------------------------------------------------
// Background 
//
// The background color. In this case it's just a black color.
//------------------------------------------------------------------------
vec3 doBackground( void )
{
    return vec3( 0.0, 0.0, 0.0);
}

vec2 min2(vec2 a, vec2 b) {
    return (a.x <= b.x)?a:b;
}

vec2 max2(vec2 a, vec2 b) {
    return (a.x > b.x)?a:b;
}

void rotate_xy(inout float x, inout float y, in float a) {
    float c = cos(a);
    float s = sin(a);
    float u = x; float v = y;
    x = c * u - s * v;
    y = s * u + c * v;
}

#define PI 3.141592653589793
#define PI2 6.283185307179586

//------------------------------------------------------------------------
// Modelling 
//
// Defines the shapes (a sphere in this case) through a distance field
//------------------------------------------------------------------------

#define PLANE_RADIUS 1.0
#define PLANE_PT_R 0.05
#define FEATURE_PT_R 0.1

vec4 planef[PLANE_COUNT];
vec3 normals[PLANE_COUNT];
vec3 origins[PLANE_COUNT];
vec3 points[PLANE_COUNT];

mat3 ATA = mat3(0.0);
vec3 ATb = vec3(0.0);
vec4 pointaccum = vec4(0.0);
vec3 corner;
float error;

// pluecker line stored in a matrix
mat3 line(vec3 p, vec3 q) {
    return mat3(q-p, cross(p,q), vec3(0.0));
}

vec4 intersect_line_plane(mat3 l, vec4 e) {
    vec3 t = l[0];
    vec3 m = l[1];
    return vec4(
        m.z*e.y - m.y*e.z - t.x*e.w,
        m.x*e.z - m.z*e.x - t.y*e.w,
        m.y*e.x - m.x*e.y - t.z*e.w,
        e.x*t.x + e.y*t.y + e.z*t.z
    );
}

void update_planes() {
    for (int i = 0; i < PLANE_COUNT; ++i) {
        float a = float(i)*PI2 / float(PLANE_COUNT);
        float f = mod(float(i),2.0)*2.0-1.0;
        normals[i] = normalize(vec3(sin(iGlobalTime*0.1+a)*cos(iGlobalTime*0.22+a*7.41)*0.8,1.0,0.0));
        rotate_xy(normals[i].x, normals[i].z, -a*11.2*f);
        origins[i] = vec3(cos(a)*PLANE_RADIUS,0.0,sin(a)*PLANE_RADIUS);
        planef[i] = vec4(normals[i], dot(-origins[i],normals[i]));
    }
    // push origins onto deepest plane
    for (int i = 0; i < PLANE_COUNT; ++i) {
        points[i] = origins[i] * 2.0;
        points[i].y = 5.0;
        vec3 n = normals[i];
        for (int j=0; j < PLANE_COUNT; ++j) {
            mat3 l = line(points[i], points[i] + vec3(0.0,-1.0,0.0));
            vec4 np = intersect_line_plane(l, planef[j]);
            float h = np.y / np.w;
            if (h < points[i].y) {
                points[i].y = h;
                n = normals[j];
            }                
        }
	    qef_add(n, points[i], ATA, ATb, pointaccum);
    }
    
    error = qef_solve(ATA, ATb, pointaccum, corner);
}

float sphere(vec3 p, float r) {
    return length(p) - r;
}

float plane(vec3 p, vec3 n, vec3 o) {
    return dot(p,n) + dot(-o,n);
}

float doModel( vec3 p ) {
    float d = plane(p, normals[0], origins[0]);
    float s = sphere(p - corner, FEATURE_PT_R + error);
    s = min(s, sphere(p - points[0], PLANE_PT_R));
    for (int i = 1; i < PLANE_COUNT; ++i) {
        d = max(d, plane(p, normals[i], origins[i]));
        s = min(s, sphere(p - points[i], PLANE_PT_R));
    }
    
  	return min(s, d);
}

//------------------------------------------------------------------------
// Material 
//
// Defines the material (colors, shading, pattern, texturing) of the model
// at every point based on its position and normal. In this case, it simply
// returns a constant yellow color.
//------------------------------------------------------------------------
vec3 doMaterial( in vec3 pos, in vec3 nor )
{
    return vec3(0.3);
}

//------------------------------------------------------------------------
// Lighting
//------------------------------------------------------------------------
float calcSoftshadow( in vec3 ro, in vec3 rd );

vec3 doLighting( in vec3 pos, in vec3 nor, in vec3 rd, in float dis, in vec3 mal )
{
    vec3 lin = vec3(0.0);

    // key light
    //-----------------------------
    vec3  lig = normalize(vec3(1.0,0.7,0.9));
    float dif = max(dot(nor,lig),0.0);
    float sha = 0.0; if( dif>0.01 ) sha=calcSoftshadow( pos+0.01*nor, lig );
    lin += dif*vec3(4.00,4.00,4.00)*sha;

    // ambient light
    //-----------------------------
    lin += vec3(0.50,0.50,0.50);

    
    // surface-light interacion
    //-----------------------------
    vec3 col = mal*lin;

    
    // fog    
    //-----------------------------
	col *= exp(-0.01*dis*dis);

    return col;
}

float calcIntersection( in vec3 ro, in vec3 rd )
{
	const float maxd = 20.0;           // max trace distance
	const float precis = 0.001;        // precission of the intersection
    float h = precis*2.0;
    float t = 0.0;
	float res = -1.0;
    for( int i=0; i<90; i++ )          // max number of raymarching iterations is 90
    {
        if( h<precis||t>maxd ) break;
	    h = doModel( ro+rd*t );
        t += h;
    }

    if( t<maxd ) res = t;
    return res;
}

vec3 calcNormal( in vec3 pos )
{
    const float eps = 0.002;             // precision of the normal computation

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*doModel( pos + v1*eps ) + 
					  v2*doModel( pos + v2*eps ) + 
					  v3*doModel( pos + v3*eps ) + 
					  v4*doModel( pos + v4*eps ) );
}

float calcSoftshadow( in vec3 ro, in vec3 rd )
{
    float res = 1.0;
    float t = 0.0005;                 // selfintersection avoidance distance
	float h = 1.0;
    for( int i=0; i<40; i++ )         // 40 is the max numnber of raymarching steps
    {
        h = doModel(ro + rd*t);
        res = min( res, 64.0*h/t );   // 64 is the hardness of the shadows
		t += clamp( h, 0.02, 2.0 );   // limit the max and min stepping distances
    }
    return clamp(res,0.0,1.0);
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    vec2 m = iMouse.xy/iResolution.xy;

    update_planes();

    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
    
    // camera movement
    vec3 ro, ta;
    doCamera( ro, ta, iGlobalTime, m.x );

    // camera matrix
    mat3 camMat = calcLookAtMatrix( ro, ta, 0.0 );  // 0.0 is the camera roll
    
	// create view ray
	vec3 rd = normalize( camMat * vec3(p.xy,2.0) ); // 2.0 is the lens length

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------

	vec3 col = doBackground();

	// raymarch
    float t = calcIntersection( ro, rd );
    if( t>-0.5 )
    {
        // geometry
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal(pos);

        // materials
        vec3 mal = doMaterial( pos, nor );

        col = doLighting( pos, nor, rd, t, mal );
	}

	//-----------------------------------------------------
	// postprocessing
    //-----------------------------------------------------
    // gamma
	col = pow( clamp(col,0.0,1.0), vec3(0.4545) );
	   
    fragColor = vec4( col, 1.0 );
}