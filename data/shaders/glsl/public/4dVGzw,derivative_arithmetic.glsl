// Shader downloaded from https://www.shadertoy.com/view/4dVGzw
// written by shadertoy user paniq
//
// Name: Derivative Arithmetic
// Description: A demo for derivative arithmetic aka dual numbers aka automatic differentiation, where a gradient is calculated as a byproduct, usually faster than using central differences and always precise.

// inspired by https://www.shadertoy.com/view/Mdl3Ws, I implemented a full
// arithmetic set for automatic differentiation or as I like to call it,
// derivative arithmetic.

// uncomment to see rendering of a non-C1 continuous surface; another
// advantage that DA affords.
// #define TANGLE

#define DAValue vec4

struct DAVec3 {
    DAValue x;
    DAValue y;
    DAValue z;
};

DAVec3 da_domain(vec3 p) {
	return DAVec3(
        DAValue(1.0,0.0,0.0,p.x),
        DAValue(0.0,1.0,0.0,p.y),
        DAValue(0.0,0.0,1.0,p.z));
}

DAValue da_const(float a) {
    return DAValue(0.0,0.0,0.0,a);
}

float safeinv(float x) {
    return (x == 0.0)?x:1.0/x;
}

DAValue da_sub(DAValue a, DAValue b) {
    return a - b;
}
DAValue da_sub(DAValue a, float b) {
    return DAValue(a.xyz, a.w - b);
}
DAValue da_sub(float a, DAValue b) {
    return DAValue(-b.xyz, a - b.w);
}

DAValue da_add(DAValue a, DAValue b) {
    return a + b;
}
DAValue da_add(DAValue a, float b) {
    return DAValue(a.xyz, a.w + b);
}
DAValue da_add(float a, DAValue b) {
    return DAValue(b.xyz, a + b.w);
}

DAValue da_mul(DAValue a, DAValue b) {
    return DAValue(a.xyz * b.w + a.w * b.xyz, a.w * b.w);
}
DAValue da_mul(DAValue a, float b) {
    return a * b;
}
DAValue da_mul(float a, DAValue b) {
    return a * b;
}

DAValue da_div(DAValue a, DAValue b) {
    return DAValue((a.xyz * b.w - a.w * b.xyz) / (b.w * b.w), a.w / b.w);
}
DAValue da_div(DAValue a, float b) {
    return a / b;
}
DAValue da_div(float a, DAValue b) {
    return DAValue((-a * b.xyz) / (b.w * b.w), a / b.w);
}

DAValue da_min(DAValue a, DAValue b) {
    return (a.w <= b.w)?a:b;
}
DAValue da_min(DAValue a, float b) {
    return (a.w <= b)?a:da_const(b);
}
DAValue da_min(float a, DAValue b) {
    return (a < b.w)?da_const(a):b;
}

DAValue da_max(DAValue a, DAValue b) {
    return (a.w >= b.w)?a:b;
}
DAValue da_max(DAValue a, float b) {
    return (a.w >= b)?a:da_const(b);
}
DAValue da_max(float a, DAValue b) {
    return (a > b.w)?da_const(a):b;
}

DAValue da_pow2 (DAValue a) {
    return DAValue(2.0 * a.w * a.xyz, a.w * a.w);
}

DAValue da_sqrt (DAValue a) {
    float q = sqrt(a.w);
    return DAValue(0.5 * a.xyz * safeinv(q), q);
}
        
DAValue da_abs(DAValue a) {
    return DAValue(a.xyz * sign(a.w), abs(a.w));
}
DAValue da_sin(DAValue a) {
    return DAValue(a.xyz * cos(a.w), sin(a.w));
}
DAValue da_cos(DAValue a) {
    return DAValue(-a.xyz * sin(a.w), cos(a.w));
}
DAValue da_log(DAValue a) {
    return DAValue(a.xyz / a.w, log(a.w));
}
DAValue da_exp(DAValue a) {
    float w = exp(a.w);
    return DAValue(a.xyz * w, w);
}


DAValue da_length(DAValue x,DAValue y) {
    float q = length(vec2(x.w,y.w));
    return DAValue((x.xyz * x.w + y.xyz * y.w) * safeinv(q), q);
}
DAValue da_length(DAValue x,DAValue y,DAValue z) {
    float q = length(vec3(x.w,y.w,z.w));
    return DAValue((x.xyz * x.w + y.xyz * y.w + z.xyz * z.w) * safeinv(q), q);
}

// s: width, height, depth, thickness
// r: xy corner radius, z corner radius
DAValue sdSuperprim(DAVec3 p, vec4 s, vec2 r) {
    DAValue dx = da_sub(da_abs(p.x),s.x);
    DAValue dy = da_sub(da_abs(p.y),s.y);
    DAValue dz = da_sub(da_abs(p.z),s.z);
    DAValue q = 
       	da_sub(
            da_abs(
                da_add(
                    da_add(
                        da_length(
                            da_max(da_add(dx, r.x), 0.0),
                            da_max(da_add(dy, r.x), 0.0)),
                  		da_min(-r.x,da_max(dx,dy))),
                    s.w)), 
                s.w);
    return da_add(
                da_length(
                    da_max(da_add(q, r.y),0.0),
                    da_max(da_add(dz, r.y),0.0)),
                da_min(-r.y,da_max(q,dz)));
}

DAValue sdTangle(DAVec3 p) {
    p.x = da_mul(p.x, 2.0);
    p.y = da_mul(p.y, 2.0);
    p.z = da_mul(p.z, 2.0);
    DAValue d = 
        da_add(11.8,
            da_sub(
                da_add(
                    da_pow2(da_pow2(p.x)), 
                    da_add(
                        da_pow2(da_pow2(p.y)),
                        da_pow2(da_pow2(p.z)))),
                da_add(
                    da_mul(5.0,da_pow2(p.x)),
                    da_add(
                        da_mul(5.0,da_pow2(p.y)),
                        da_mul(5.0,da_pow2(p.z))))));
    return da_div(d, max(11.8,length(d.xyz)));
}

// example parameters
#define SHAPE_COUNT 10.0
void getfactor (int i, out vec4 s, out vec2 r) {
    //i = 8;
    if (i == 0) { // cube
        s = vec4(1.0);
        r = vec2(0.0);
    } else if (i == 1) { // corridor
        s = vec4(vec3(1.0),0.25);
        r = vec2(0.0);
    } else if (i == 2) { // pipe
        s = vec4(vec3(1.0),0.25);
        r = vec2(1.0,0.0);
    } else if (i == 3) { // cylinder
        s = vec4(1.0);
        r = vec2(1.0,0.0);
	} else if (i == 4) { // pill
        s = vec4(1.0,1.0,2.0,1.0);
        r = vec2(1.0);
    } else if (i == 5) { // sphere
        s = vec4(1.0);
        r = vec2(1.0);
    } else if (i == 6) { // pellet
        s = vec4(1.0,1.0,0.25,1.0);
        r = vec2(1.0,0.25);
    } else if (i == 7) { // torus
        s = vec4(1.0,1.0,0.25,0.25);
        r = vec2(1.0,0.25);
    } else if (i == 8) { // sausage mouth
        s = vec4(2.0,0.5,0.25,0.25);
        r = vec2(0.5,0.25);
    } else if (i == 9) { // beveled O
        s = vec4(0.7,1.0,1.0,0.25);
        r = vec2(0.125);
	}
}

void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float an = 1.5 + sin(time * 0.1) * 0.7;
	camPos = vec3(4.5*sin(an),2.0,4.5*cos(an));
    camTar = vec3(0.0,0.0,0.0);
}

vec3 doBackground( void )
{
    return vec3( 0.0, 0.0, 0.0);
}

struct DAMValue {
    DAValue d;
    float mat;
};

DAMValue min2(DAMValue a, DAMValue b) {
    if (a.d.w <= b.d.w)
        return a;
    else
        return b;
}

DAMValue plane(DAVec3 p) {
    return DAMValue(da_add(p.y,2.0),1.0);
}

DAMValue add_plane(DAVec3 p, DAMValue m) {
    return min2(plane(p),m);
}

DAMValue doScene (DAVec3 p) {
    float k = iGlobalTime*0.5;
    float u = smoothstep(0.0,1.0,smoothstep(0.0,1.0,fract(k)));
    int s1 = int(mod(k,SHAPE_COUNT));
    int s2 = int(mod(k+1.0,SHAPE_COUNT));
    
    vec4 sa,sb;
    vec2 ra,rb;
    getfactor(s1,sa,ra);
    getfactor(s2,sb,rb);
    
    DAValue d;
#ifdef TANGLE
    d = sdTangle(p);
#else
    DAVec3 pp = DAVec3(p.z,p.y,p.x);
    if (iMouse.z > 0.5) {
    	vec2 m = iMouse.xy/iResolution.xy;
    	d = sdSuperprim(pp, vec4(vec3(1.0),mix(sa.w,sb.w,u)), m);
	} else {
    	d = sdSuperprim(pp, mix(sa,sb,u), mix(ra,rb,u));
	}
#endif
    
    return add_plane(p, DAMValue(d,0.0));
}


vec2 doModel( vec3 p ) {
    DAMValue d = doScene(da_domain(p));
	return vec2(d.d.w, d.mat);
}

//------------------------------------------------------------------------
// Material 
//
// Defines the material (colors, shading, pattern, texturing) of the model
// at every point based on its position and normal. In this case, it simply
// returns a constant yellow color.
//------------------------------------------------------------------------
vec4 doMaterial( in vec3 pos, in vec3 nor )
{
    float k = doModel(pos).y;
    DAValue d = doScene(da_domain(vec3(pos.x,0.0,pos.z))).d;
    
    float w = abs(mod(d.w, 0.1)/0.1 - 0.5);
    
    return mix(vec4(nor * 0.5 + 0.5,0.1),
               vec4(d.xyz * 0.5 + 0.5,0.0) * w,
               clamp(k,0.0,1.0));
}

//------------------------------------------------------------------------
// Lighting
//------------------------------------------------------------------------
float calcSoftshadow( in vec3 ro, in vec3 rd );

vec3 doLighting( in vec3 pos, in vec3 nor, in vec3 rd, in float dis, in vec4 mal )
{
    vec3 lin = vec3(0.0);

    vec3  lig = normalize(vec3(1.0,0.7,0.9));
	float cos_Ol = max(0.0, dot(nor, lig));
    vec3 h = normalize(lig - rd);
    float cos_Oh = max(0.0,dot(nor, h));
    float dif = cos_Ol;
    float sha = 0.0; if( dif>0.01 ) sha=calcSoftshadow( pos+0.01*nor, lig );
    lin += dif*vec3(0.8,0.7,0.6)*sha;
    
    lin += vec3(0.20,0.30,0.30);

    
    vec3 col = mal.rgb*lin;

    // specular
    col += cos_Ol * pow(cos_Oh,40.0) * sha;
    
    // envmap
    col += mal.w*textureCube(iChannel0, reflect(rd,nor)).rgb;
    
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
    DAMValue d = doScene(da_domain(pos));
    return d.d.xyz;
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

vec3 ff_filmic_gamma3(vec3 linear) {
    vec3 x = max(vec3(0.0), linear-0.004);
    return (x*(x*6.2+0.5))/(x*(x*6.2+1.7)+0.06);
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
    //doCamera( ro, ta, 3.0, 0.0 );

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
        vec4 mal = doMaterial( pos, nor );

        col = doLighting( pos, nor, rd, t, mal );
	}

	//-----------------------------------------------------
	// postprocessing
    //-----------------------------------------------------
    // gamma
	col = ff_filmic_gamma3(col * 0.6); //pow( clamp(col,0.0,1.0), vec3(0.4545) );
	   
    fragColor = vec4( col, 1.0 );
}