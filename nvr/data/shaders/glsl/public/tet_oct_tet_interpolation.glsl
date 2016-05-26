// Shader downloaded from https://www.shadertoy.com/view/Xlj3zR
// written by shadertoy user paniq
//
// Name: Tet-Oct-Tet Interpolation
// Description: Linear interpolation of eight cube corners by treating the cube as a composite of two tetrahedra and one octahedron. Press P to change the cutting plane.

vec2 m;

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

//------------------------------------------------------------------------
// Camera
//
// Move the camera. In this case it's using time and the mouse position
// to orbitate the camera around the origin of the world (0,0,0), where
// the yellow sphere is.
//------------------------------------------------------------------------
void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float an = 0.3*iGlobalTime;
    float d = 3.0;
	camPos = vec3(d*sin(an),1.2,d*cos(an));
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

float cube(vec3 p, float r) {
    vec3 o = abs(p);
	float s = o.x;
	s = max(s, o.y);
	s = max(s, o.z);
	return s-r;
}

float sdf_round_box(vec3 p, vec3 b, float r) {
  return length(max(abs(p)-b,0.0))-r;
}

vec2 min2(vec2 a, vec2 b) {
    return (a.x <= b.x)?a:b;
}

vec2 max2(vec2 a, vec2 b) {
    return (a.x > b.x)?a:b;
}

float doModel( vec3 p ) {
    
    float mouse_delta = clamp(m.x,0.0,1.0)*2.0-1.0;
    float plane = p.y  + mouse_delta;
    if (ReadKey(Key_P)) {
		plane = ((p.x+p.y+p.z) + mouse_delta)/sqrt(3.0);
       	plane = abs(plane)-0.01;
    }
    
    return max(cube(p,1.0), plane);
  
}

//------------------------------------------------------------------------
// Material 
//
// Defines the material (colors, shading, pattern, texturing) of the model
// at every point based on its position and normal. In this case, it simply
// returns a constant yellow color.
//------------------------------------------------------------------------

#define TEST 0

vec3 hue2rgb(float hue) {
    return clamp( 
        abs(mod(hue * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
        0.0, 1.0);
}

float gray(vec3 color) {
    return dot(vec3(1.0/3.0), color);
}

// given three factors in the range (0..1), return the eight interpolants 
// -xyzw, +xyzw required to mix the corners of a cube
void trilinear_interpolants(in vec3 p, out vec4 s, out vec4 t) {
    vec3 q = 1.0 - p;

    vec2 h = vec2(q.x,p.x);
    vec4 k = vec4(h*q.y, h*p.y);
    s = k * q.z;
    t = k * p.z;
}

// given three interpolants (0..1) within a tet-oct-tet cube, return the 
// weights required for interpolation.
void fcc_interpolants(vec3 x, out vec4 a, out vec4 b) {
    float q = x.x+x.y+x.z;
    if (q < 1.0) {
        a = vec4(1.0-q,x.x,x.y,0.0);
        b = vec4(x.z, 0.0, 0.0, 0.0);
    } else if (q < 2.0) {    
        vec3 t = x.yzx + x.zxy - 1.0;
        float d = (1.0 - (abs(t.x)+abs(t.y)+abs(t.z)))/6.0;
        vec3 u = d+max(-t,0.0);
        vec3 v = d+max(t,0.0);
        a = vec4(0.0, u.x, u.y, v.z);
        b = vec4(u.z, v.y, v.x, 0.0);
    } else {
        vec3 t = 1.0-x;
        a = vec4(0.0, 0.0, 0.0, t.z);
        b = vec4(0.0, t.y, t.x, q-2.0);
    }
}

vec3 doMaterial( in vec3 pos, in vec3 nor )
{
    // color cube with components swapped
    // to bring out the discontinuities
    const vec3 c0 = vec3(1.0,1.0,0.0);
    const vec3 c1 = vec3(0.0,1.0,0.0);
    const vec3 c2 = vec3(1.0,0.0,0.0);
    const vec3 c3 = vec3(0.0,0.0,0.0);
    const vec3 c4 = vec3(1.0,1.0,1.0);
    const vec3 c5 = vec3(1.0,0.0,1.0);
    const vec3 c6 = vec3(0.0,1.0,1.0);
    const vec3 c7 = vec3(0.0,0.0,1.0);
    
    pos = vec3(pos.x, -pos.z, pos.y);
    
    vec4 s,t;
    vec3 col = vec3(0.0);

    vec3 p = pos*0.5+0.5;

    //trilinear_interpolants(p, s, t);
    fcc_interpolants(p,s,t);
    
    col = c0*s.x + c1*s.y + c2*s.z + c3*s.w
    	+ c4*t.x + c5*t.y + c6*t.z + c7*t.w;
    
    if (ReadKey(Key_C)) {
    	return hue2rgb(gray(col)*4.0);
    } else {
        return col;
    }
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
    m = iMouse.xy/iResolution.xy;

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

        col = doMaterial( pos, nor );
	}
	   
    fragColor = vec4( col, 1.0 );
}