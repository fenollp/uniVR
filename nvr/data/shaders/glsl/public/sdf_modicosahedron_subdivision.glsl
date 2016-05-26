// Shader downloaded from https://www.shadertoy.com/view/lsV3RV
// written by shadertoy user tdhooper
//
// Name: sdf modIcosahedron subdivision
// Description: Creating a subdivided icosahedron by modifying space
#define PI 3.14159265359
#define t iGlobalTime


// HG_SDF

float fPlane(vec3 p, vec3 n, float distanceFromOrigin) {
    return dot(p, n) + distanceFromOrigin;
}

// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
void pR(inout vec2 p, float a) {
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

// Reflect space at a plane
float pReflect(inout vec3 p, vec3 planeNormal, float offset) {
    float t = dot(p, planeNormal)+offset;
    if (t < 0.) {
        p = p - (2.*t)*planeNormal;
    }
    return sign(t);
}


// Knighty https://www.shadertoy.com/view/XlX3zB

int Type=5;

vec3 nc,pab,pbc,pca;
void initIcosahedron() {//setup folding planes and vertex
    float cospin=cos(PI/float(Type)), scospin=sqrt(0.75-cospin*cospin);
	nc=vec3(-0.5,-cospin,scospin);//3rd folding plane. The two others are xz and yz planes
	pab=vec3(0.,0.,1.);
	pbc=vec3(scospin,0.,0.5);//No normalization in order to have 'barycentric' coordinates work evenly
	pca=vec3(0.,scospin,cospin);
	pbc=normalize(pbc);	pca=normalize(pca);//for slightly better DE. In reality it's not necesary to apply normalization :) 
}

// Barycentric to Cartesian 
vec3 bToC(vec3 A, vec3 B, vec3 C, vec3 barycentric) {
	return barycentric.x * A + barycentric.y * B + barycentric.z * C;
}

vec3 pModIcosahedron(inout vec3 p, int subdivisions) {
    p = abs(p);
	pReflect(p, nc, 0.);
    p.xy = abs(p.xy);
	pReflect(p, nc, 0.);
    p.xy = abs(p.xy);
	pReflect(p, nc, 0.);
    
    if (subdivisions > 0) {

        vec3 A = pbc;
       	vec3 C = reflect(A, normalize(cross(pab, pca)));
        vec3 B = reflect(C, normalize(cross(pbc, pca)));
       
        vec3 n;

        // Fold in corner A 
        
        vec3 p1 = bToC(A, B, C, vec3(.5, .0, .5));
        vec3 p2 = bToC(A, B, C, vec3(.5, .5, .0));
        n = normalize(cross(p1, p2));
        pReflect(p, n, 0.);
        
        if (subdivisions > 1) {

            // Get corners of triangle created by fold

            A = reflect(A, n);
            B = p1;
            C = p2;
            
            // Fold in corner A

            p1 = bToC(A, B, C, vec3(.5, .0, .5));
            p2 = bToC(A, B, C, vec3(.5, .5, .0));
            n = normalize(cross(p1, p2));
            pReflect(p, n, 0.);
            

            // Fold in corner B
            
			p2 = bToC(A, B, C, vec3(.0, .5, .5));
            p1 = bToC(A, B, C, vec3(.5, .5, .0));
            n = normalize(cross(p1, p2));
            pReflect(p, n, 0.);
        }
    }

    return p;
}

vec3 pRoll(inout vec3 p) {
    //return p;
    float s = 5.;
    float d = 0.01;
    float a = sin(t * s) * d;
    float b = cos(t * s) * d;
    pR(p.xy, a);
    pR(p.xz, a + b);
    pR(p.yz, b);
    return p;
}

vec3 lerp(vec3 a, vec3 b, float s) {
	return a + (b - a) * s;
}

float face(vec3 p) {
    // Align face with the xy plane
	vec3 rn = normalize(lerp(pca, vec3(0,0,1), 0.5));
    p = reflect(p, rn);
	return min(
        fPlane(p, vec3(0,0,-1), -1.4),
        length(p + vec3(0,0,1.4)) - 0.02
    );
}

float exampleModelA(vec3 p) {
    vec3 pp = p;
    pp -= vec3(1.5,0,3.3);
	pModIcosahedron(pp, 0);
	return face(pp);
}

float exampleModelB(vec3 p) {
    vec3 pp = p;
	pModIcosahedron(pp, 1);
	return face(pp);
}

float exampleModelC(vec3 p) {
    vec3 pp = p;
    pp += vec3(1.5,0,3.3);
	pModIcosahedron(pp, 2);
	return face(pp);
}

float exampleModel(vec3 p) {
    pRoll(p);
    float A = exampleModelA(p);
    float B = exampleModelB(p);
    float C = exampleModelC(p);
    return min(A, min(B, C));
}

vec3 doBackground(vec3 rayVec) {
    return vec3(.13);
}

// The MINIMIZED version of https://www.shadertoy.com/view/Xl2XWt


const float MAX_TRACE_DISTANCE = 20.0;           // max trace distance
const float INTERSECTION_PRECISION = 0.001;        // precision of the intersection
const int NUM_OF_TRACE_STEPS = 100;


// checks to see which intersection is closer
// and makes the y of the vec2 be the proper id
vec2 opU( vec2 d1, vec2 d2 ){
    
    return (d1.x<d2.x) ? d1 : d2;
    
}


//--------------------------------
// Modelling 
//--------------------------------
vec2 map( vec3 p ){  
    
    vec2 res = vec2(exampleModel(p) ,1.); 
    
    return res;
}



vec2 calcIntersection( in vec3 ro, in vec3 rd ){

    
    float h =  INTERSECTION_PRECISION*2.0;
    float t = 0.0;
    float res = -1.0;
    float id = -1.;
    
    for( int i=0; i< NUM_OF_TRACE_STEPS ; i++ ){
        
        if( h < INTERSECTION_PRECISION || t > MAX_TRACE_DISTANCE ) break;
        vec2 m = map( ro+rd*t );
        h = m.x;
        t += h;
        id = m.y;
        
    }

    if( t < MAX_TRACE_DISTANCE ) res = t;
    if( t > MAX_TRACE_DISTANCE ) id =-1.0;
    
    return vec2( res , id );
    
}


//----
// Camera Stuffs
//----
mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

void doCamera(out vec3 camPos, out vec3 camTar, in float time, in vec2 mouse) {
    
    float x = .366 + (mouse.x * 0.5);
    float y = .4 + (mouse.y * 0.33);
    
    float an = 10.0 * x + PI / 2.;
    //an = 10.;
    float roll = .6;
    //roll = 0.;
    
    //float d = 2. + sin(an) * 1.6;
    float d = 2. + (1. - y) * 10.;
    camPos = vec3(
        sin(an),
        sin(y * PI / 2.) - roll,
        cos(an) - roll
    ) * d;

    camTar = vec3(0);
}


// Calculates the normal by taking a very small distance,
// remapping the function, and getting normal for that
vec3 calcNormal( in vec3 pos ){
    
    vec3 eps = vec3( 0.001, 0.0, 0.0 );
    vec3 nor = vec3(
        map(pos+eps.xyy).x - map(pos-eps.xyy).x,
        map(pos+eps.yxy).x - map(pos-eps.yxy).x,
        map(pos+eps.yyx).x - map(pos-eps.yyx).x );
    return normalize(nor);
}




vec3 render( vec2 res , vec3 ro , vec3 rd ){
   

  vec3 color = doBackground(rd);
    
  if( res.y > -.5 ){
      
    vec3 pos = ro + rd * res.x;
    vec3 norm = calcNormal( pos );
    vec3 ref = reflect(rd, norm);
	color = norm * 0.5 + 0.5;
  }
   
  return color;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    initIcosahedron();
    
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    vec2 m = iMouse.xy / iResolution.xy;

    vec3 ro = vec3( 0., 0., 2.);
    vec3 ta = vec3( 0. , 0. , 0. );
    
    // camera movement
    doCamera(ro, ta, iGlobalTime, m);
    
    // camera matrix
    mat3 camMat = calcLookAtMatrix( ro, ta, 0.0 );  // 0.0 is the camera roll
    
    // create view ray
    vec3 rd = normalize( camMat * vec3(p.xy,2.0) ); // 2.0 is the lens length
    
    vec2 res = calcIntersection( ro , rd  );

    
    vec3 color = render( res , ro , rd );
    
    fragColor = vec4(color,1.0);

    
    
}