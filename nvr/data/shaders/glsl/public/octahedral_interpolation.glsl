// Shader downloaded from https://www.shadertoy.com/view/XtX3WX
// written by shadertoy user paniq
//
// Name: Octahedral Interpolation
// Description: A method for linear interpolation of six octahedral corners that regresses to simple barycentric interpolation on the faces; drag the mouse for a cutaway; hit P to toggle the cutting plane. Hit N to toggle nearest neighbor interpolation.

// linearly interpolates the three axes inside the octahedron with an average
// of all edges at the center; it's not the most beautiful method
// for some cases but meshes very well with the regular linear tetrahedral
// interpolation.

// see doMaterial for the interpolation routine

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

// 3D distance of XYZ cross diagonal plane
float octahedron(vec3 p, float r) {
    vec3 o = abs(p);
	float s = o.x+o.y+o.z;
	return (s-r)/sqrt(3.0);
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
    
    return max(octahedron(p,1.0), plane);
  
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

vec3 doMaterial( in vec3 pos, in vec3 nor )
{
    
#if TEST == 0
    const vec3 c0 = vec3(1.0,0.0,0.0);
    const vec3 c1 = vec3(0.0,1.0,1.0);
    const vec3 c2 = vec3(0.0,1.0,0.0);
    const vec3 c3 = vec3(1.0,0.0,1.0);
    const vec3 c4 = vec3(0.0,0.0,1.0);
    const vec3 c5 = vec3(1.0,1.0,0.0);
#elif TEST == 1
    // edge case
    const vec3 c0 = vec3(0.0,0.0,0.0);
    const vec3 c1 = vec3(1.0,1.0,1.0);
    const vec3 c2 = vec3(1.0,1.0,1.0);
    const vec3 c3 = vec3(1.0,1.0,1.0);
    const vec3 c4 = vec3(1.0,1.0,1.0);
    const vec3 c5 = vec3(1.0,1.0,1.0);
#else
    // edge case
    const vec3 c0 = vec3(1.0,1.0,1.0);
    const vec3 c1 = vec3(0.0,0.0,0.0);
    const vec3 c2 = vec3(0.0,0.0,0.0);
    const vec3 c3 = vec3(0.0,0.0,0.0);
    const vec3 c4 = vec3(0.0,0.0,0.0);
    const vec3 c5 = vec3(0.0,0.0,0.0);
#endif
    
    pos = vec3(pos.x, -pos.z, pos.y);
    if (max(pos.x,max(pos.y,pos.z)) > 1.01)
        return vec3(0.0);
    
    vec3 s,t;
    vec3 col = vec3(0.0);

    float d = (1.0 - (abs(pos.x)+abs(pos.y)+abs(pos.z)))/6.0;

    s = d+max(-pos,0.0);
    t = d+max(pos,0.0);
    
    if (ReadKey(Key_N)) {
        vec3 ps = floor(1.0+s-max(max(s.yzx,s.zxy),max(t.zxy,max(t.xyz,t.yzx))));
        vec3 pt = floor(1.0+t-max(max(t.yzx,t.zxy),max(s.zxy,max(s.xyz,s.yzx))));
        
        s = ps;
        t = pt;
    }
    
    
    col = c0*s.x + c1*s.y + c2*s.z + c3*t.x + c4*t.y + c5*t.z;

#if 0
    // check if total energy of colors is below 1
    if ((abs(col.x)+abs(col.y)+abs(col.z)) < 0.99)
        return vec3(1.0);

#endif
    
#if 0
    if (max(col.x,max(col.y,col.z)) > 1.01)
        return vec3(1.0,0.0,0.0);
#endif
    
    if (ReadKey(Key_C)) {
    	return hue2rgb(gray(col));
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