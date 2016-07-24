// Shader downloaded from https://www.shadertoy.com/view/XdtSRn
// written by shadertoy user paniq
//
// Name: Light Propagation Volume
// Description: diffuse illumination with occlusion and infinite bounces using a single 32^3 light propagation volume. Implemented after http://www.crytek.com/download/Light_Propagation_Volumes.pdf
/*

also helpful for reference:
Light Propagation Volumes - Annotations, Andreas Kirsch (2010)
http://blog.blackhc.net/wp-content/uploads/2010/07/lpv-annotations.pdf

*/
const vec3 lpvsize = vec3(32.0);

float packfragcoord2 (vec2 p, vec2 s) {
    return floor(p.y) * s.x + p.x;
}
vec2 unpackfragcoord2 (float p, vec2 s) {
    float x = mod(p, s.x);
    float y = (p - x) / s.x + 0.5;
    return vec2(x,y);
}
float packfragcoord3 (vec3 p, vec3 s) {
    return floor(p.z) * s.x * s.y + floor(p.y) * s.x + p.x;
}
vec3 unpackfragcoord3 (float p, vec3 s) {
    float x = mod(p, s.x);
    float y = mod((p - x) / s.x, s.y);
    float z = (p - x - floor(y) * s.x) / (s.x * s.y);
    return vec3(x,y+0.5,z+0.5);
}

vec4 sample_lpv(vec3 p, float channel) {
    p = clamp(p * lpvsize, vec3(0.5), lpvsize - 0.5);
    float posidx = packfragcoord3(p, lpvsize) + channel * (lpvsize.x * lpvsize.y * lpvsize.z);
    vec2 uv = unpackfragcoord2(posidx, iChannelResolution[0].xy) / iChannelResolution[0].xy;
    return texture2D(iChannel0, uv);    
}

vec4 fetch_lpv(vec3 p, float channel) {
    p = clamp(p, vec3(0.5), lpvsize - 0.5);
    float posidx = packfragcoord3(p, lpvsize) + channel * (lpvsize.x * lpvsize.y * lpvsize.z);
    vec2 uv = unpackfragcoord2(posidx, iChannelResolution[0].xy) / iChannelResolution[0].xy;
    return texture2D(iChannel0, uv);    
}

vec4 sample_lpv_trilin(vec3 p, float channel) {
    p = clamp(p * lpvsize - 0.5, vec3(0.5), lpvsize - 0.5);
    vec2 e = vec2(0.0,1.0);
    vec4 p000 = fetch_lpv(p + e.xxx, channel);
    vec4 p001 = fetch_lpv(p + e.xxy, channel);
    vec4 p010 = fetch_lpv(p + e.xyx, channel);
    vec4 p011 = fetch_lpv(p + e.xyy, channel);
    vec4 p100 = fetch_lpv(p + e.yxx, channel);
    vec4 p101 = fetch_lpv(p + e.yxy, channel);
    vec4 p110 = fetch_lpv(p + e.yyx, channel);
    vec4 p111 = fetch_lpv(p + e.yyy, channel);

    vec3 w = fract(p);

    vec3 q = 1.0 - w;

    vec2 h = vec2(q.x,w.x);
    vec4 k = vec4(h*q.y, h*w.y);
    vec4 s = k * q.z;
    vec4 t = k * w.z;
        
    return
          p000*s.x + p100*s.y + p010*s.z + p110*s.w
        + p001*t.x + p101*t.y + p011*t.z + p111*t.w;
}

vec4 sh_project(vec3 n) {
    return vec4(
        n,
        0.57735026918963);
}

float sh_dot(vec4 a, vec4 b) {
    return max(dot(a,b),0.0);
}

// 3 / (4 * pi)
const float m3div4pi = 0.23873241463784;
float sh_flux(float d) {
	return d * m3div4pi;
}

#ifndef M_DIVPI
#define M_DIVPI 0.3183098861837907
#endif

float sh_shade(vec4 vL, vec4 vN) {
    return sh_flux(sh_dot(vL, vN)) * M_DIVPI;
}

#define SHSharpness 1.0 // 2.0
vec4 sh_irradiance_probe(vec4 v) {
    const float sh_c0 = (2.0 - SHSharpness) * 1.0;
    const float sh_c1 = SHSharpness * 2.0 / 3.0;
    return vec4(v.xyz * sh_c1, v.w * sh_c0);
}

float shade_probe(vec4 sh, vec4 shn) {
    return sh_shade(sh_irradiance_probe(sh), shn);
}

void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float an = 1.5 + sin(time * 0.37) * 0.4;
	camPos = vec3(4.5*sin(an),2.0,4.5*cos(an));
    camTar = vec3(0.0,0.0,0.0);
}

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

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdCylinder( vec3 p, float s )
{
  return length(p.xz)-s;
}

float sdTorus( vec3 p, vec2 t )
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

vec2 plane( vec3 p) {
    return vec2(p.y+1.0,4.0);
}

vec2 doModel( vec3 p ) {
	
    vec2 d = plane(p);
    
    vec2 q = vec2(sdSphere(p - vec3(0.0,0.0,-0.8), 1.0),1.0);
    q = max2(q, vec2(-sdCylinder(p - vec3(0.0,0.0,-0.8), 0.5),2.0));
    d = min2(d, q);
    
    d = min2(d, vec2(sdBox(p - vec3(0.0,0.0,2.2), vec3(2.0,4.0,0.3)),2.0));
    d = min2(d, vec2(sdBox(p - vec3(0.0,0.0,-2.2), vec3(2.0,4.0,0.3)),3.0));
    d = min2(d, vec2(sdBox(p - vec3(-2.2,0.0,0.0), vec3(0.3,4.0,2.0)),1.0));
    
    q = vec2(sdBox(p - vec3(-1.0,0.0,1.0), vec3(0.5,1.0,0.5)),1.0);
    q = max2(q, vec2(-sdBox(p - vec3(-0.5,0.5,0.5), vec3(0.5,0.7,0.5)),3.0));
    
    d = min2(d, q);
    
    d = min2(d, vec2(sdTorus(p.yxz - vec3(-0.5 + sin(iGlobalTime*0.25),1.4,0.5), vec2(1.0, 0.3)),1.0));
    
    //d = max2(d, vec2(p.y, 1.0));
    
    return d;
}

vec4 doMaterial( in vec3 pos, in vec3 nor )
{
    float k = doModel(pos).y;
    
    vec3 c = vec3(0.0);
    
    c = mix(c, vec3(1.0,1.0,1.0), float(k == 1.0));
    c = mix(c, vec3(1.0,0.2,0.1), float(k == 2.0));
    c = mix(c, vec3(0.1,0.3,1.0), float(k == 3.0));
    c = mix(c, vec3(0.3,0.15,0.1), float(k == 4.0));
    c = mix(c, vec3(0.4,1.0,0.1), float(k == 5.0));
    
    
    return vec4(c,0.0);
}

//------------------------------------------------------------------------
// Lighting
//------------------------------------------------------------------------
vec3 doLighting( in vec3 pos, in vec3 nor, in vec3 rd, in float dis, in vec4 mal )
{
    vec3 col = mal.rgb;
    
    vec3 tpos = ((pos - vec3(0.0,1.0,0.0)) / 2.5) * 0.5 + 0.5;
    vec4 shr = sample_lpv_trilin(tpos, 0.0);
    vec4 shg = sample_lpv_trilin(tpos, 1.0);
    vec4 shb = sample_lpv_trilin(tpos, 2.0);
    
    vec4 shn = sh_project(-nor);
    col *= vec3(shade_probe(shr, shn),shade_probe(shg, shn),shade_probe(shb, shn));
    //col = vec3(shade_probe(shb, shn));   

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
	col = ff_filmic_gamma3(col); //pow( clamp(col,0.0,1.0), vec3(0.4545) );
	   
    fragColor = vec4( col, 1.0 );
}