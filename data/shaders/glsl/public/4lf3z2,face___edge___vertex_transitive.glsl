// Shader downloaded from https://www.shadertoy.com/view/4lf3z2
// written by shadertoy user paniq
//
// Name: Face / Edge / Vertex Transitive
// Description: Demonstrates how cube and octahedron are each others dual (one's face is the other's vertex), and the rhombic dodecahedron unites vertices from both sets and turns either edges into faces.

//------------------------------------------------------------------------
// Camera
//
// Move the camera. In this case it's using time and the mouse position
// to orbitate the camera around the origin of the world (0,0,0), where
// the yellow sphere is.
//------------------------------------------------------------------------
void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float an = 0.05*iGlobalTime + 10.0*mouseX;
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

// all three basic bodies are symmetric across the XYZ planes
// octahedron and rhombic dodecahedron have been scaled to align
// with the vertices of the cube.

// 1D distance of X Y Z planes
vec2 cube(vec3 p, float r) {
    vec3 o = abs(p);
	float s = o.x;
	s = max(s, o.y);
	s = max(s, o.z);
	return vec2(s-r, 0.0);
}

// 3D distance of XYZ cross diagonal plane
vec2 octahedron(vec3 p, float r) {
    vec3 o = abs(p) / sqrt(3.0);
	float s = o.x+o.y+o.z;
	return vec2(s-r*2.0/sqrt(3.0), 1.0);
}

// 2D distance of XY YZ ZX diagonal planes
vec2 rhombic(vec3 p, float r) {
    vec3 o = abs(p) / sqrt(2.0);    
	float s = o.x+o.y;
	s = max(s, o.y+o.z);
	s = max(s, o.z+o.x);
	return vec2(
        s-r*sqrt(2.0),
        2.0);
}

vec2 capsule(vec3 p, vec3 a, vec3 b)
{
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return vec2(length( pa - ba*h ), 3.0);
}

// cube-centered axis (cubic symmetry), 6 directions
vec2 axis_cc(vec3 p) {
    vec3 o = p*p;    
    float s = sqrt(o.x+o.y);
    s = min(s, sqrt(o.x+o.z));
    s = min(s, sqrt(o.y+o.z));
    return vec2(s, 0.0);
}

// face-centered axis (rhombic dodecahedral symmetry), 12 directions
vec2 axis_fcc(vec3 p) {
    vec3 o = abs(p);
    vec3 q = o / 2.0;
    float s = length(vec3(o.xy - (q.x + q.y), o.z));
    s = min(s, length(vec3(o.xz - (q.x + q.z), o.y)));
    s = min(s, length(vec3(o.yz - (q.y + q.z), o.x)));
    return vec2(s, 2.0);
}

// body-centered axis (octahedral symmetry), 8 directions
vec2 axis_bcc(vec3 p) {
    vec3 o = abs(p);    
    return vec2(length( o - (o.x+o.y+o.z) / 3.0 ), 1.0);
}


vec2 min2(vec2 a, vec2 b) {
    return (a.x <= b.x)?a:b;
}

vec2 max2(vec2 a, vec2 b) {
    return (a.x > b.x)?a:b;
}

vec2 plane( vec3 p) {
    return vec2(p.y+2.0,3.0);
}

#define SHAPE_COUNT 4.0
vec2 get_shape(vec3 p, int i) {
    if (i == 0) {
        return cube(p, 1.0);
    } else if ((i == 1)||(i == 3)) {
        return rhombic(p, 1.0);
    } else if (i == 2) {
        return octahedron(p, 1.0);
    }
    return vec2(0.0);
}

//------------------------------------------------------------------------
// Modelling 
//
// Defines the shapes (a sphere in this case) through a distance field, in
// this case it's a sphere of radius 1.
//------------------------------------------------------------------------
vec2 doModel( vec3 p ) {
    vec2 m = axis_bcc(p);
    m = min2(m, axis_fcc(p));
    m = min2(m, axis_cc(p));
    m.x -= 0.05;
    
    float k = iGlobalTime*0.1;
    float u = smoothstep(0.0,1.0,pow(fract(k),3.0));
    int s1 = int(mod(k,SHAPE_COUNT));
    int s2 = int(mod(k+1.0,SHAPE_COUNT));    
    vec2 sh = mix(get_shape(p,s1),get_shape(p,s2),u);
    m = min2(m, sh);
    
    return m;
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
    float k = doModel(pos).y;
    return mix(mix(mix(vec3(1.0,0.07,0.01),vec3(0.2,1.0,0.01),clamp(k,0.0,1.0)),
               vec3(0.1,0.07,1.0),
               clamp(k-1.0,0.0,1.0)),
               vec3(0.1),
               clamp(k-2.0,0.0,1.0));
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
	    h = doModel( ro+rd*t ).x;
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

	return normalize( v1*doModel( pos + v1*eps ).x + 
					  v2*doModel( pos + v2*eps ).x + 
					  v3*doModel( pos + v3*eps ).x + 
					  v4*doModel( pos + v4*eps ).x );
}

float calcSoftshadow( in vec3 ro, in vec3 rd )
{
    float res = 1.0;
    float t = 0.0005;                 // selfintersection avoidance distance
	float h = 1.0;
    for( int i=0; i<40; i++ )         // 40 is the max numnber of raymarching steps
    {
        h = doModel(ro + rd*t).x;
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