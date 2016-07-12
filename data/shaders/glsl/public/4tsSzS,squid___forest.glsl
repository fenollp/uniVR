// Shader downloaded from https://www.shadertoy.com/view/4tsSzS
// written by shadertoy user squid
//
// Name: squid - Forest
// Description: Only one loop in map()! Unfortunately also very broken. Suggestions?
#define ITERATIONS 4
// *** Change these to suit your range of random numbers..
// This current set suits the UV coords of the screen and up..
#define MOD2 vec2(443.8975,397.2973)
#define MOD3 vec3(443.8975,397.2973, 491.1871)
#define MOD4 vec4(443.8975,397.2973, 491.1871, 470.7827)

// *** Use these for integer ranges, ie Value-Noise/Perlin functions.
//#define MOD2 vec2(.16632,.17369)
//#define MOD3 vec3(.16532,.17369,.15787)
//#define MOD4 vec4(.16532,.17369,.15787, .14987)

//----------------------------------------------------------------------------------------
//  1 out, 1 in...
float hash11(float p)
{
	vec2 p2 = fract(vec2(p) * MOD2);
    p2 += dot(p2.yx, p2.xy+19.19);
	return fract(p2.x * p2.y);
}

//----------------------------------------------------------------------------------------
//  1 out, 2 in...
float hash12(vec2 p)
{
	p  = fract(p * MOD2);
    p += dot(p.xy, p.yx+19.19);
    return fract(p.x * p.y);
}

//----------------------------------------------------------------------------------------
//  1 out, 3 in...
float hash13(vec3 p)
{
	p  = fract(p * MOD3);
    p += dot(p.xyz, p.yzx + 19.19);
    return fract(p.x * p.y * p.z);
}

//----------------------------------------------------------------------------------------
//  2 out, 1 in...
vec2 hash21(float p)
{
	//p  = fract(p * MOD3);
    vec3 p3 = fract(vec3(p) * MOD3);
    p3 += dot(p3.xyz, p3.yzx + 19.19);
   return fract(vec2(p3.x * p3.y, p3.z*p3.x));
}

//----------------------------------------------------------------------------------------
///  2 out, 2 in...
vec2 hash22(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3.zxy, p3.yxz+19.19);
    return fract(vec2(p3.x * p3.y, p3.z*p3.x));
}

//----------------------------------------------------------------------------------------
//  3 out, 1 in...
vec3 hash31(float p)
{
   vec3 p3 = fract(vec3(p) * MOD3);
   p3 += dot(p3.xyz, p3.yzx + 19.19);
   return fract(vec3(p3.x * p3.y, p3.x*p3.z, p3.y*p3.z));
}


//----------------------------------------------------------------------------------------
///  3 out, 2 in...
vec3 hash32(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3.zxy, p3.yxz+19.19);
    return fract(vec3(p3.x * p3.y, p3.x*p3.z, p3.y*p3.z));
}

//----------------------------------------------------------------------------------------
///  3 out, 3 in...
vec3 hash33(vec3 p)
{
	p = fract(p * MOD3);
    p += dot(p.zxy, p+19.19);
    return fract(vec3(p.x * p.y, p.x*p.z, p.y*p.z));
}

//----------------------------------------------------------------------------------------
// 4 out, 1 in...
vec4 hash41(float p)
{
	vec4 p4 = fract(vec4(p) * MOD4);
    p4 += dot(p4.wzxy, p4+19.19);
    return fract(vec4(p4.x * p4.y, p4.x*p4.z, p4.y*p4.w, p4.x*p4.w));
}

//----------------------------------------------------------------------------------------
// 4 out, 2 in...
vec4 hash42(vec2 p)
{
	vec4 p4 = fract(vec4(p.xyxy) * MOD4);
    p4 += dot(p4.wzxy, p4+19.19);
    return fract(vec4(p4.x * p4.y, p4.x*p4.z, p4.y*p4.w, p4.x*p4.w));
}

//----------------------------------------------------------------------------------------
// 4 out, 3 in...
vec4 hash43(vec3 p)
{
	vec4 p4 = fract(vec4(p.xyzx) * MOD4);
    p4 += dot(p4.wzxy, p4+19.19);
    return fract(vec4(p4.x * p4.y, p4.x*p4.z, p4.y*p4.w, p4.x*p4.w));
}

//----------------------------------------------------------------------------------------
// 4 out, 4 in...
vec4 hash44(vec4 p)
{
	vec4 p4 = fract(p * MOD4);
    p4 += dot(p4.wzxy, p4+19.19);
    return fract(vec4(p4.x * p4.y, p4.x*p4.z, p4.y*p4.w, p4.x*p4.w));
}

//###############################################################################

float sdCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}
vec2 U( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

#define mat_tree_bark 1.0

mat3 rotateY(float r)
{
    vec2 cs = vec2(cos(r), sin(r));
    return mat3(cs.x, 0, cs.y, 0, 1, 0, -cs.y, 0, cs.x);
}

mat3 rotateZ(float r)
{
    vec2 cs = vec2(cos(r), sin(r));
    return mat3(cs.x, cs.y, 0., -cs.y, cs.x, 0., 0., 0., 1.);
}

vec2 tree(in vec3 p, in vec2 id) {
    vec4 h = hash42(vec2(id));
    float height = 5.+h.x*12.;
	vec2 r = vec2(sdCylinder(p-vec3(0.,height,0.), vec2(.6+h.x*.5,height)), 
                mat_tree_bark);
    
    vec3 np = p; float lh = height*2.;
    if(np.y > lh) return r;
    for(int i = 0; i < 2; ++i) {
    	float bh = mod(np.y, 2.)-1.;
        vec4 bhs = hash41(floor(np.y/2.)+h.y*30.);
        vec3 v = vec3(np.x,np.z,bh)*rotateZ((bhs.y)*12.28)+
                              vec3(0.,(3.*(bhs.x>0.5?1.:-1.)),0.);
        r = U(r, 
              vec2(sdCylinder(v, vec2(0.2-float(i)*0.08, 3.)), mat_tree_bark ));
        np = v;
    }
    return r;
}

vec2 map(in vec3 p) {
	vec2 tp = mod(p.xz, vec2(20.))-vec2(10.);
    return U(
		vec2(p.y, 0.1), 
        tree(vec3(tp.x, p.y, tp.y), ceil(p.xz/20.-10.) )
    );
}

vec2 nrm(in vec3 ro, in vec3 rd) {
	float tmin = .01;
    float tmax = 200.0;
    
	float precis = 0.002;
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<60; i++ )
    {
	    vec2 res = map( ro+rd*t );
        if( res.x<precis || t>tmax ) break;
        t += res.x;
	    m = res.y;
    }

    if( t>tmax ) m=-1.0;
    return vec2( t, m );
}

vec3 norm(in vec3 pos) {
	vec3 eps = vec3( 0.001, 0.0, 0.0 );
	vec3 nor = vec3(
	    map(pos+eps.xyy).x - map(pos-eps.xyy).x,
	    map(pos+eps.yxy).x - map(pos-eps.yxy).x,
	    map(pos+eps.yyx).x - map(pos-eps.yyx).x );
	return normalize(nor);
}
vec3 hsv2rgb( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );

	rgb = rgb*rgb*(3.0-2.0*rgb); // cubic smoothing	

	return c.z * mix( vec3(1.0), rgb, c.y);
}
float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax )
{
	float res = 1.0;
    float t = mint;
    for( int i=0; i<32; i++ )
    {
		float h = map( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );

}

vec3 matcol(in float id) {
	if(id == mat_tree_bark) return vec3(0.3, 0.2, 0.);
    else return vec3(0.2, 0.1, 0.);
}

vec3 shade(in vec3 ro, in vec3 rd, in vec2 nh) {
	vec3 p = ro+rd*nh.x;
    vec3 n = norm(p);
    vec3 l = normalize(vec3(.5, .7, 0.));
    return dot(n, l)*matcol(nh.y)*
        softshadow(p, l, 0.1, 5.);
}

vec3 render(in vec3 ro, in vec3 rd) {
	vec2 nh = nrm(ro, rd);
    return nh.y > -1. ? shade(ro, rd, nh) : vec3(0.);
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;
    vec2 mo = iMouse.xy/iResolution.xy;
		 
	float time = 15.0 + iGlobalTime;

	// camera	
    float z = 60.;
	vec3 ro = vec3( z*cos(0.1*time + 6.0*mo.x), z*.2 + z*mo.y, z*sin(0.1*time + 6.0*mo.x) );
	vec3 ta = vec3( 0. );
	
	// camera-to-world transformation
    mat3 ca = setCamera( ro, ta, 0.0 );
    
    // ray direction
	vec3 rd = ca * normalize( vec3(p.xy,2.5) );

    // render	
    vec3 col = render( ro, rd );

	col = pow( col, vec3(0.4545) );

    fragColor=vec4( col, 1.0 );
}