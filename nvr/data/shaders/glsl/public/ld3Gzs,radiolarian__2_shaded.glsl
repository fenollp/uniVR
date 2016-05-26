// Shader downloaded from https://www.shadertoy.com/view/ld3Gzs
// written by shadertoy user tdhooper
//
// Name: Radiolarian #2 shaded
// Description: Sources:
//    * https://www.shadertoy.com/view/Mdt3RX
//    * https://www.shadertoy.com/view/XljGDz
//    * https://www.shadertoy.com/view/Xt2XDt




#define PHI (sqrt(5.)*0.5 + 0.5)
#define PI 3.14159265

float t;




float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}

float fPlane(vec3 p, vec3 n, float distanceFromOrigin) {
    return dot(p, n) + distanceFromOrigin;
}

// Box: correct distance to corners
float fBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}

float fOpIntersectionRound(float a, float b, float r) {
    float m = max(a, b);
    if ((-a < r) && (-b < r)) {
        return max(m, -(r - sqrt((r+a)*(r+a) + (r+b)*(r+b))));
    } else {
        return m;
    }
}


// Cone with correct distances to tip and base circle. Y is up, 0 is in the middle of the base.
float fCone(vec3 p, float radius, float height) {
    vec2 q = vec2(length(p.xz), p.y);
    vec2 tip = q - vec2(0, height);
    vec2 mantleDir = normalize(vec2(height, radius));
    float mantle = dot(tip, mantleDir);
    float d = max(mantle, -q.y);
    float projected = dot(tip, vec2(mantleDir.y, -mantleDir.x));
    
    // distance to tip
    if ((q.y > height) && (projected < 0.)) {
        d = max(d, length(tip));
    }
    
    // distance to base ring
    if ((q.x > radius) && (projected > length(vec2(height, radius)))) {
        d = max(d, length(q - vec2(radius, 0)));
    }
    return d;
}

// Reflect space at a plane
float pReflect(inout vec3 p, vec3 planeNormal, float offset) {
    float t = dot(p, planeNormal)+offset;
    if (t < 0.) {
        p = p - (2.*t)*planeNormal;
    }
    return sign(t);
}

// Rotate around a coordinate axis (i.e. in a plane perpendicular to that axis) by angle <a>.
// Read like this: R(p.xz, a) rotates "x towards z".
// This is fast if <a> is a compile-time constant and slower (but still practical) if not.
void pR(inout vec2 p, float a) {
    p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}

// The "Round" variant uses a quarter-circle to join the two objects smoothly:
float fOpUnionRound(float a, float b, float r) {
    float m = min(a, b);
    if ((a < r) && (b < r) ) {
        return min(m, r - sqrt((r-a)*(r-a) + (r-b)*(r-b)));
    } else {
     return m;
    }
}

// Repeat around the origin by a fixed angle.
// For easier use, num of repetitions is use to specify the angle.
float pModPolar(inout vec2 p, float repetitions) {
    float angle = 2.*PI/repetitions;
    float a = atan(p.y, p.x) + angle/2.;
    float r = length(p);
    float c = floor(a/angle);
    a = mod(a,angle) - angle/2.;
    p = vec2(cos(a), sin(a))*r;
    // For an odd number of repetitions, fix cell index of the cell in -x direction
    // (cell index would be e.g. -5 and 5 in the two halves of the cell):
    if (abs(c) >= (repetitions/2.)) c = abs(c);
    return c;
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

vec3 lerp(vec3 a, vec3 b, float s) {
	return a + (b - a) * s;
}

void faceDodecahedron(inout vec3 p) {
	vec3 rn = normalize(lerp(pbc, vec3(0,0,1), 0.5));
    p = reflect(p, rn);
}

void faceIcosahedron(inout vec3 p) {
	vec3 rn = normalize(lerp(pca, vec3(0,0,1), 0.5));
    p = reflect(p, rn);
}

vec3 pModDodecahedron(inout vec3 p) {
	pModIcosahedron(p, 0);
	faceDodecahedron(p);
    return p;
}


float spikeModel(vec3 p) {
    faceDodecahedron(p);
	pR(p.zy, PI/2.);
    return fCone(p, 0.25, 3.);
}

vec3 faceB(vec3 p) {
    p = reflect(p, vec3(1,0,0));
    return p;
}

vec3 faceC(vec3 p) {
    p = reflect(p, nc);
    p = faceB(p);
    return p;
}

vec3 icosaFaceB(vec3 p) {
    p = reflect(p, vec3(0,1,0));
    return p;
}


float spikesModel(vec3 p) {
    float smooth = 0.6;
    
    pModIcosahedron(p, 0);
    
    float spikeA = spikeModel(p);
    float spikeB = spikeModel(faceB(p));
    float spikeC = spikeModel(faceC(p));

    return fOpUnionRound(
        spikeC,
        fOpUnionRound(
            spikeA,
            spikeB,
            smooth
        ),
        smooth
    );
}

float coreModel(vec3 p) {
    float outer = length(p) - .9;
    float spikes = spikesModel(p);
    outer = fOpUnionRound(outer, spikes, 0.4);
    return outer;
}

float exoSpikeModel(vec3 p) {
    faceIcosahedron(p);
    pR(p.zy, PI/2.);
    p.y -= 1.;
    return fCone(p, 0.5, 1.);
}

float exoSpikesModel(vec3 p) {
    pModIcosahedron(p, 0);
    float spikeA = exoSpikeModel(p);
    float spikeB = exoSpikeModel(icosaFaceB(p));
    return fOpUnionRound(spikeA, spikeB, 0.5);
}

float exoHolesModel(vec3 p) {
    float len = 3.;
    pModDodecahedron(p);
    p.z += 1.5;
    return length(p) - .65;
}

float exoModel(vec3 p) {    
    float thickness = 0.18;
    float outer = length(p) - 1.5;
    float inner = outer + thickness;

    float spikes = exoSpikesModel(p);
    outer = fOpUnionRound(outer, spikes, 0.3);
    
    float shell = max(-inner, outer);

    float holes = exoHolesModel(p);
    shell = fOpIntersectionRound(-holes, shell, thickness/2.);
    
    return shell;
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

float doExo(vec3 p) {
    //return 1000.;
	//return length(p + vec3(0,0,-2)) - 3.;
	pRoll(p);
    //float disp = (sin(length(p) * 5. - t * 8.)) * 0.03;
    return exoModel(p);
}

float doCore(vec3 p) {
    // return 1000.;
	//return length(p + vec3(0,0,2)) - 3.;
	pRoll(p);
    return coreModel(p);
}

float lerp(float a, float b, float s) {
	return a + (b - a) * s;
}


vec3 envLight(vec3 col, vec3 rayDir, float blur) {
	float shiny = 0.;
	float blurry = 0.;
    
    //rayDir.x = mod(rayDir.x + t, 1.);

    if (
        (rayDir.y > abs(rayDir.x) * 3.5)
        &&
        (rayDir.y > abs(rayDir.z * 0.))
    ) {
        shiny += rayDir.y;
    }
    
	shiny += max(rayDir.y, 0.);
    blurry += acos(dot(normalize(vec3(0,-1,0)), normalize(rayDir))) / PI;
    blurry *= 0.3;
    blurry += pow(max(rayDir.y, 0.), 2.) * 0.5;
    return col * lerp(shiny, blurry, blur);
}

// from https://www.shadertoy.com/view/XljGDz
vec3 GetEnvColor2(vec3 rayDir, float blur) {
	//pR(rayDir.zy, sin(-t * 1.));
	pR(rayDir.xz, PI * 0.5);
    rayDir = normalize(rayDir);
    vec3 light1 = envLight(vec3(0,1.2,1.4) * .8, rayDir, blur);
	pR(rayDir.xy, PI);
    rayDir = normalize(rayDir);
    vec3 light2 = envLight(vec3(.15), rayDir, blur);
	return light1 + light2;
}


vec3 doBackground(vec3 rayVec) {
    //return GetEnvColor2(rayVec, 0.5);
    return vec3(.13);
}

vec3 doMaterial(in vec3 p, in vec3 nor, vec3 ref, float blur) {
    return GetEnvColor2(ref, blur);
}

vec3 doExoMaterial(vec3 pos, vec3 nor, vec3 ref) {
    return doMaterial(pos, nor, ref, .0);
}

vec3 doCoreMaterial(vec3 pos, vec3 nor, vec3 ref) {
    vec3 mat = doMaterial(pos, nor, ref, 1.);
    float light = max(3. - length(pos), 0.);
    
    float r = 0.2;
    float stripe = mod(light, r * 2.);
    if (stripe > r) {
    	mat = vec3(length(mat)) * 0.1;
    }
	return mat;
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
    
 	vec2 res = vec2(doExo(p) ,1.); 
    res = opU(res, vec2(doCore(p) ,2.));
    
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
    float y = .7 + (mouse.y * 0.33);
    
    float an = 10.0 * x + PI / 2.;
    //an = 10.;

    //float d = 2. + sin(an) * 1.6;
    float d = 2. + (1. - y) * 10.;
    camPos = vec3(
        sin(an),
        sin(y * PI / 2.),
        cos(an)
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

      
    // Exo
    if( res.y == 1. ){

        color = doExoMaterial(pos, norm, ref);
    
    // Core
    }else if(res.y == 2. ){
        
		color = doCoreMaterial(pos, norm, ref);
        
    }
        
        
  }
   
  return color;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    t = iGlobalTime;
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
