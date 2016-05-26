// Shader downloaded from https://www.shadertoy.com/view/MlfGDX
// written by shadertoy user paniq
//
// Name: FCC Linear Interpolation
// Description: Linear interpolation of values in a face-centered cubic (FCC) lattice - original left, interpolated right; T = visualization; W = grid; C = automatic / user-controlled cross section; when user-controlled: P = change cutting plane.
/*

To find the cell that a point is passing, we skew the coordinates so that
an octahedron with two tetrahedra at opposing sides forms a perfect
cube with two interior faces along the normal (1 1 1); 

We can now split the coordinate into an integer and a fractional part. 
The integer coordinate is unskewed to find the local basis; we take the
dot product of the fractional part and the normal (x+y+z) to get the type
of cell: 

x < 1 is the lower left front tetrahedron, 
1 <= x < 2 is the center octahedron,
2 <= x is the upper right back tetrahedron.

The first three interpolants q,r,s of the tetrahedra are simply the 
xyz components of the fractional part. The fourth interpolant
is 1-q-r-s.

The three axis aligned interpolants of the octahedron are the unskewed
fractional part - 1.
*/

vec3 cart2fcc(vec3 p) {
    return vec3(p.yzx + p.zxy - p.xyz)/2.0;
}

vec3 fcc2cart(vec3 p) {
    return vec3(p.yzx + p.zxy);
}

//------------------------------------------------------------------------

// keys are javascript keycode: http://www.webonweboff.com/tips/js/event_key_codes.aspx
const int Key_A = 65; const int Key_B = 66; const int Key_C = 67; const int Key_D = 68; const int Key_E = 69;
const int Key_F = 70; const int Key_G = 71; const int Key_H = 72; const int Key_I = 73; const int Key_J = 74;
const int Key_K = 75; const int Key_L = 76; const int Key_M = 77; const int Key_N = 78; const int Key_O = 79;
const int Key_P = 80; const int Key_Q = 81; const int Key_R = 82; const int Key_S = 83; const int Key_T = 84;
const int Key_U = 85; const int Key_V = 86; const int Key_W = 87; const int Key_X = 88; const int Key_Y = 89;
const int Key_Z = 90;
const int Key_0 = 48; const int Key_1 = 49; const int Key_2 = 50; const int Key_3 = 51; const int Key_4 = 52;
const int Key_5 = 53; const int Key_6 = 54; const int Key_7 = 55; const int Key_8 = 56; const int Key_9 = 57;

bool ReadKey( int key )//, bool toggle )
{
	bool toggle = true;
	float keyVal = texture2D( iChannel3, vec2( (float(key)+.5)/256.0, toggle?.75:.25 ) ).x;
	return (keyVal>.5)?true:false;
}

vec2 mouse;

//------------------------------------------------------------------------
// Camera
//
// Move the camera. In this case it's using time and the mouse position
// to orbitate the camera around the origin of the world (0,0,0), where
// the yellow sphere is.
//------------------------------------------------------------------------
void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float ur = 6.5;
    float an = 0.1*sin(iGlobalTime);// + 10.0*mouseX;
	camPos = vec3(ur*sin(an),3.0+cos(iGlobalTime*0.7)*1.5,ur*cos(an));
    //camPos = vec3(0.0,4.0,ur);
    camTar = vec3(0.0,0.0,0.0);
}


vec3 doBackground( void )
{
    return vec3( 1.0);
}

float box(vec3 p, vec3 b)
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

const float INVSQRT3 = 0.5773502691896258;

float octa(vec3 p) {
    vec3 o = abs(p);
	float s = o.x+o.y+o.z;
	return (s-1.0)*INVSQRT3;
}

float tetra1(vec3 o) {
    float p1 = -o.x+o.y-o.z;
    float p2 =  o.x-o.y-o.z;
    float p3 = -o.x-o.y+o.z;
    float p4 =  o.x+o.y+o.z;    
	float s = max(max(max(p1,p2),p3),p4);
	return (s-0.5)*INVSQRT3;
}

float tetra2(vec3 o) {
    return tetra1(vec3(-o.x,o.yz));
}

// face-centered lattice (rhombic dodecahedral symmetry), 12 directions
float fcc_axis(vec3 p) {
    vec3 o = abs(p);
    vec3 q = o / 2.0;
    float s = length(vec3(o.xy - (q.x + q.y), o.z));
    s = min(s, length(vec3(o.xz - (q.x + q.z), o.y)));
    s = min(s, length(vec3(o.yz - (q.y + q.z), o.x)));
    return s;
}

float lattice_fcc(vec3 p) {
    p = mod(p-1.0,2.0)-1.0;
    float a0 = fcc_axis(p);
    float ax = min(min(
        fcc_axis(p-vec3(0.0,1.0,1.0)),
        fcc_axis(p-vec3(0.0,-1.0,-1.0))
   	), min(
        fcc_axis(p-vec3(0.0,-1.0,1.0)),
        fcc_axis(p-vec3(0.0,1.0,-1.0))
    ));
    float ay = min(min(
        fcc_axis(p-vec3(1.0,0.0,1.0)),
        fcc_axis(p-vec3(-1.0,0.0,-1.0))
   	), min(
        fcc_axis(p-vec3(-1.0,0.0,1.0)),
        fcc_axis(p-vec3(1.0,0.0,-1.0))
    ));
    
    return min(a0, min(ax, ay));
}

vec4 min4(vec4 a, vec4 b) {
    return (a.x <= b.x)?a:b;
}

vec4 max4(vec4 a, vec4 b) {
    return (a.x > b.x)?a:b;
}

const vec3 plane_color = vec3(0.6, 0.5, 0.4);
const vec3 oct_color = vec3(0.0,0.9,0.5);
const vec3 tet_color = vec3(0.1,0.9,0.5);
const vec3 point_color = vec3(0.1,0.0,0.1);
const vec3 lut_color = vec3(0.0);

vec3 random_point() {
    float t = iGlobalTime*0.05;
    vec3 p = vec3(2.0*cos(3.0*t+0.1),2.0*cos(4.0*t+0.7),2.0*cos(7.0*t));
    return p;//vec3(-0.3,-1.5,p.z);
}
    
vec4 scene(vec3 p) {
    // fix coordinate system so Z is up
    p = vec3(p.x,-p.z,p.y);
    
    vec4 plane = vec4(p.z+2.0, plane_color);
    
    vec4 d = plane;
    
    vec3 rp = random_point();
    vec3 mrp = cart2fcc(rp);
    vec3 f = floor(mrp);
    vec3 o = mrp - f;
    float q = dot(o, vec3(1.0));
    f = fcc2cart(f);
    
    float zcap = box(p, vec3(4.0,2.0,2.0));
    float lattice = lattice_fcc(p);
    vec4 m;
    if (!ReadKey(Key_W)) {
	    m = vec4(max(zcap, lattice-0.05), 0.0, 0.0, 1.0);
    } else {
        lattice = 1e+20;
        m.x = 1e+20;
    }
    
    if (!ReadKey(Key_T)) {
	    m = min4(m, vec4(max(zcap,-lattice+0.1), 0.0, 0.0, 0.0));
    } else {
    
        if (q < 1.0) {
            m = min4(m,vec4(tetra1(p-f-vec3(0.5,0.5,0.5))+0.01, lut_color));
        } else if (q < 2.0) {
            m = min4(m,vec4(octa(p-f-vec3(1.0,1.0,1.0))+0.01, lut_color));
        } else {
            m = min4(m,vec4(tetra2(p-f-vec3(1.5,1.5,1.5))+0.01, lut_color));
        }    
    }

    if (!ReadKey(Key_C)) {
        m.x = max(m.x, max(rp.y-p.y,p.z-rp.z));
	    d = min4(d, vec4(length(p-rp)-0.1, point_color));
    } else if (ReadKey(Key_P)) {
        float df = (p.x+p.y-p.z)*INVSQRT3;
	    m.x = max(m.x, (mouse.x*4.0)-2.0-df);
    } else {
	    m.x = max(m.x, (mouse.x*4.0)-2.0-p.y);
    }
    d = min4(d, m);
    
    return d;
}

vec3 hue2rgb(float hue) {
    return clamp( 
        abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
        0.0, 1.0);
}

vec3 hsl2rgb(vec3 c) {
    vec3 rgb = hue2rgb(c.x);
    return c.z + c.y * (rgb - 0.5) * (1.0 - abs(2.0 * c.z - 1.0));
}

#if 0

const vec3 c0 = vec3(1.0,0.0,0.0);
const vec3 c1 = vec3(0.0,1.0,1.0);
const vec3 c2 = vec3(0.0,1.0,0.0);
const vec3 c3 = vec3(1.0,0.0,1.0);
const vec3 c4 = vec3(0.0,0.0,1.0);
const vec3 c5 = vec3(1.0,1.0,0.0);

vec3 tet_demo1(vec3 b, vec4 q) {
    return c3*q.x + c1*q.y + c5*q.z + c4*q.w;
}

vec3 tet_demo2(vec3 b, vec4 q) {
    return c3*q.x + c4*q.y + c2*q.z + c1*q.w;
}

vec3 oct_demo(vec3 b, vec3 s, vec3 t) {
    return c0*s.x + c1*t.x + c2*s.y + c3*t.y + c4*s.z + c5*t.z;
}

#else

const vec3 c0 = vec3(1.0,0.0,0.0);
const vec3 c1 = vec3(0.0,1.0,1.0);
const vec3 c2 = vec3(0.0,1.0,0.0);
const vec3 c3 = vec3(1.0,0.0,1.0);
const vec3 c4 = vec3(0.0,0.0,1.0);
const vec3 c5 = vec3(1.0,1.0,0.0);

vec3 fake_lut(vec3 p) {
    // this would access a texture in a real application
    p = fcc2cart(p);
    float w = length(p)*0.2;
    return hsl2rgb(vec3(w-iGlobalTime*0.01,1.0,0.5));
}

vec3 tet_demo1(vec3 b, vec4 q) {
    vec3 p0 = fake_lut(b + vec3( 1.0, 0.0, 0.0));
    vec3 p1 = fake_lut(b + vec3( 0.0, 1.0, 0.0));
    vec3 p2 = fake_lut(b + vec3( 0.0, 0.0, 1.0));
    vec3 p3 = fake_lut(b);
	
    return p0 * q.x + p1 * q.y + p2 * q.z + p3 * q.w;
}

vec3 tet_demo2(vec3 b, vec4 q) {
    vec3 p0 = fake_lut(b + vec3( 0.0, 1.0, 1.0));
    vec3 p1 = fake_lut(b + vec3( 1.0, 0.0, 1.0));
    vec3 p2 = fake_lut(b + vec3( 1.0, 1.0, 0.0));
    vec3 p3 = fake_lut(b + vec3( 1.0 ));
	
    return p0 * q.x + p1 * q.y + p2 * q.z + p3 * q.w;
}

vec3 oct_demo(vec3 b, vec3 s, vec3 t) {
    vec3 p0 = fake_lut(b + vec3( 1.0, 0.0, 0.0));
    vec3 p1 = fake_lut(b + vec3( 0.0, 1.0, 0.0));
    vec3 p2 = fake_lut(b + vec3( 0.0, 0.0, 1.0));
    vec3 p3 = fake_lut(b + vec3( 0.0, 1.0, 1.0));
    vec3 p4 = fake_lut(b + vec3( 1.0, 0.0, 1.0));
    vec3 p5 = fake_lut(b + vec3( 1.0, 1.0, 0.0));
    
    return p0*s.x + p1*s.y + p2*s.z + p3*t.x + p4*t.y + p5*t.z;
}

#endif

vec3 fcc_lookup(vec3 p) {
    // fix coordinate system so Z is up
    p = vec3(p.x,-p.z,p.y);
    
    vec3 fcc_p = cart2fcc(p);
    if (p.x < 0.0) {
        return fake_lut(fcc_p);
    }        
    
    vec3 fcc_basis = floor(fcc_p);
    
    vec3 fcc_fract = fcc_p - fcc_basis;
    float q = fcc_fract.x+fcc_fract.y+fcc_fract.z;
    
    if (q < 1.0) {
        vec4 t = vec4(fcc_fract, 1.0-q);
        return tet_demo1(fcc_basis, t);
    } else if (q < 2.0) {
        vec3 w = fcc2cart(fcc_fract)-1.0;
        float d = (1.0 - (abs(w.x)+abs(w.y)+abs(w.z)))/6.0;
        vec3 s = d+max(-w,0.0);
        vec3 t = d+max(w,0.0);
        return oct_demo(fcc_basis, s,t);
    } else {
        vec4 t = vec4(1.0 - fcc_fract, q-2.0);
        return tet_demo2(fcc_basis, t);
    }
    
    return vec3(0.0);
}

float doModel( vec3 p ) {
    return scene(p).x;
}

vec3 doMaterial( in vec3 pos, in vec3 nor )
{
    vec3 hsl = scene(pos).yzw;
    return hsl.b==0.0?fcc_lookup(pos):hsl2rgb(hsl);
}

//------------------------------------------------------------------------
// Lighting
//------------------------------------------------------------------------
float calcSoftshadow( in vec3 ro, in vec3 rd );

float ao(vec3 ro, vec3 rd) {
	const float st = 0.2;
	float total = 0.0;
	float weight = 0.5;
	for (int i = 1; i <= 5; ++i) {
		float d1 = st * float(i);
		float d2 = doModel(ro + rd * d1);
		total += weight * (d1 - d2);
		weight *= 0.5;
	}
	
	return clamp(1.0 - 2.0 * total, 0.0, 1.0);
}

vec3 doLighting( in vec3 pos, in vec3 nor, in vec3 rd, in float dis, in vec3 mal )
{
    vec3 lin = vec3(0.0);

    // ambient light
    //-----------------------------
    lin += vec3(1.0) * ao( pos, nor );

    
    // surface-light interacion
    //-----------------------------
    vec3 col = mal*lin;


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
    mouse = iMouse.xy/iResolution.xy;

    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
    
    // camera movement
    vec3 ro, ta;
    doCamera( ro, ta, iGlobalTime, mouse.x );

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