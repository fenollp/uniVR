// Shader downloaded from https://www.shadertoy.com/view/4tXGDf
// written by shadertoy user paniq
//
// Name: Tetrahedral Interpolation
// Description: A method for linear interpolation of four tetrahedral corners that regresses to simple barycentric interpolation on the faces; drag the mouse for a cutaway; hit P to toggle the cutting plane. Hit N to toggle nearest neighbor interpolation.

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

float tetrahedron(vec3 p, float r) {
    vec3 o = p / sqrt(3.0);
    float p1 = -o.x+o.y-o.z;
    float p2 =  o.x-o.y-o.z;
    float p3 = -o.x-o.y+o.z;
    float p4 =  o.x+o.y+o.z;    
	float s = max(max(max(p1,p2),p3),p4);
    
	return s-r*1.0/sqrt(3.0);
}

float octahedron(vec3 p, float r) {
    vec3 o = abs(p) / sqrt(3.0);
	float s = o.x+o.y+o.z;
	return s-r*2.0/sqrt(3.0);
}

float doModel( vec3 p ) {
    
    float mouse_delta = clamp(m.x,0.0,1.0)*2.0-1.0;
    float plane = p.y  + mouse_delta;
    if (ReadKey(Key_P)) {
		plane = ((p.x+p.y+p.z) + mouse_delta)/sqrt(3.0);
       	plane = abs(plane)-0.01;
    }
    
    return max(tetrahedron(p,0.5), plane);
  
}

//------------------------------------------------------------------------
// Material 
//
// Defines the material (colors, shading, pattern, texturing) of the model
// at every point based on its position and normal. In this case, it simply
// returns a constant yellow color.
//------------------------------------------------------------------------

vec4 max4(vec4 a, vec4 b) {
    return (a.w > b.w)?a:b;
}
vec2 max4(vec2 a, vec2 b) {
    return (a.y > b.y)?a:b;
}

vec3 doMaterial( in vec3 pos, in vec3 nor )
{
#if 1
    const vec3 c0 = vec3(1.0,0.0,0.0);
    const vec3 c1 = vec3(0.0,1.0,0.0);
    const vec3 c2 = vec3(0.0,0.0,1.0);
    const vec3 c3 = vec3(1.0,1.0,0.0);
#else
    // edge case
    const vec3 c0 = vec3(1.0,0.0,0.0);
    const vec3 c1 = vec3(0.0,0.0,0.0);
    const vec3 c2 = vec3(0.0,0.0,0.0);
    const vec3 c3 = vec3(0.0,0.0,0.0);
#endif
    
    pos = vec3(pos.x, -pos.z, pos.y);
    if (max(pos.x,max(pos.y,pos.z)) > 1.01)
        return vec3(0.0);

    vec4 edge = vec4((pos.yxz - pos.zyx - pos.xzy)*0.5+0.25, 0.0);
    edge.w = 1.0-edge.x-edge.y-edge.z;
    
    vec3 col = vec3(0.0);
    
    if (ReadKey(Key_N)) {
        edge = floor(1.0+edge-max(max(edge.yzwx,edge.zwxy),edge.wxyz));
    }
    
    col = c0*edge.x + c1*edge.y + c2*edge.z + c3*edge.w;

#if 0
    // check if total energy of colors is below 1
    if ((abs(col.x)+abs(col.y)+abs(col.z)) < 1.0)
        return vec3(1.0);
    if (max(col.x,max(col.y,col.z)) > 1.01)
        return vec3(0.0);
#endif
    
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