// Shader downloaded from https://www.shadertoy.com/view/4stGD2
// written by shadertoy user Makio64
//
// Name: Everyday008-Cathedrale01
// Description: First &quot;Cathedrale&quot; study :)
// Everyday008 - Cathedrale
// By David Ronai / @Makio64

//------------------------------------------------------------------ VISUAL QUALITY
#define POSTPROCESS
#define RAYMARCHING_STEP 40
#define RAYMARCHING_MIN 10.
#define RAYMARCHING_MAX 400.
#define RAYMARCHING_JUMP 1.
//------------------------------------------------------------------ DEBUG
//#define RENDER_DEPTH
//#define RENDER_NORMAL
//#define RENDER_AO

#define PHI (sqrt(5.)*0.5 + 0.5)
const float PI = 3.14159265359;
float snoise(vec3 v);

//-------------------------------------------------------  PPRIMITIVES / OPERATIONS
vec3 orbit(float phi, float theta, float radius)
{
	return vec3(
		radius * sin( phi ) * cos( theta ),
		radius * cos( phi ),
		radius * sin( phi ) * sin( theta )
	);
}
float pyramid( vec3 p, float h) {
	vec3 q=abs(p);
	return max(-p.y, (q.x*2.1+q.y+q.z*2.1-h)/3.0 );
}

void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}
void pR45(inout vec2 p) {
	p = (p + vec2(p.y, -p.x))*sqrt(0.5);
}
float fOpUnionRound(float a, float b, float r) {
	vec2 u = max(vec2(r - a,r - b), vec2(0));
	return max(r, min (a, b)) - length(u);
}
float fCylinder(vec3 p, float r, float height) {
	float d = length(p.xz) - r;
	d = max(d, abs(p.y) - height);
	return d;
}
float fTorus(vec3 p, float smallRadius, float largeRadius) {
	return length(vec2(length(p.xz) - largeRadius, p.y)) - smallRadius;
}
float fSphere(vec3 p, float r) {
	return length(p) - r;
}
float vmax(vec3 v) {
	return max(max(v.x, v.y), v.z);
}
float fBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return length(max(d, vec3(0))) + vmax(min(d, vec3(0)));
}
float fOpIntersectionChamfer(float a, float b, float r) {
	return max(max(a, b), (a + r + b)*sqrt(0.5));
}
float fOpIntersectionRound(float a, float b, float r) {
	vec2 u = max(vec2(r + a,r + b), vec2(0));
	return min(-r, max (a, b)) + length(u);
}
vec2 pModMirror2(inout vec2 p, vec2 size) {
	vec2 halfsize = size*0.5;
	vec2 c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	p *= mod(c,vec2(2.))*2. - vec2(1.);
	return c;
}
float fOpUnionStairs(float a, float b, float r, float n) {
	float s = r/n;
	float u = b-r;
	return min(min(a,b), 0.5 * (u + a + abs ((mod (u - a + s, 2. * s)) - s)));
}

//------------------------------------------------------------------ MAP
float map( in vec3 pos ) {
    //arch
    vec3 q = pos;
    pModMirror2(q.xz,vec2(22.));
    q.y -= 40.;
    q.zx -= 21.;
    pR(q.yz,PI/2.);
    pR45(q.xy);
    float d = fTorus(q,1.3,44.);
    q = pos;
    pModMirror2(q.xz,vec2(500.));
    d = max(-fBox(q-vec3(0.,10.5,0.),vec3(500.,30.,500.)),d);
    
    //column
    q = pos;
    q.zx -= 22.;
    q.zx += texture2D(iChannel0,pos.xy/50.).x*.5;
    vec2 idx = pModMirror2(q.xz,vec2(22.));
    q.xz -= 9.5;
    d = fOpUnionStairs(d, fCylinder(q,2.,40.),4.,10.);
    
    //ground
    d = fOpUnionStairs(d, pos.y+40.1+texture2D(iChannel0,pos.xz/50.).x*.5, 5., 5.);
    
    //pyramid on top of arch
    q = pos;
    q.y -= 80.;
    q.zx += 11.;
    pModMirror2(q.xz,vec2(44.));
    pR45(q.xz);
    float d2 = pyramid( q, 12. );
    pR(q.xy,PI);
    d2 = min(d2,pyramid( q, 12. ));
    d = fOpUnionRound(d, d2,1.);
    return d;
}



//------------------------------------------------------------------ RAYMARCHING

float castRay( in vec3 ro, in vec3 rd, inout float depth )
{
	float t = RAYMARCHING_MIN;
	float res;
	for( int i=0; i<RAYMARCHING_STEP; i++ )
	{
		vec3 pos = ro+rd*t;
		res = map( pos );
		if( res < 0.001 || t > RAYMARCHING_MAX ) break;
		t += res*RAYMARCHING_JUMP;
		depth += 1./float(RAYMARCHING_STEP);
	}
	return t;
}

vec3 calcNormal(vec3 p) {
	float eps = 0.01;
	const vec3 v1 = vec3( 1.0,-1.0,-1.0);
	const vec3 v2 = vec3(-1.0,-1.0, 1.0);
	const vec3 v3 = vec3(-1.0, 1.0,-1.0);
	const vec3 v4 = vec3( 1.0, 1.0, 1.0);
	return normalize( v1 * map( p + v1*eps ) +
					  v2 * map( p + v2*eps ) +
					  v3 * map( p + v3*eps ) +
					  v4 * map( p + v4*eps ) );
}

float hash( float n ){
	return fract(sin(n)*3538.5453);
}

float calcAO( in vec3 p, in vec3 n, float maxDist, float falloff ){
	float ao = 0.0;
	const int nbIte = 6;
	for( int i=0; i<nbIte; i++ )
	{
		float l = hash(float(i))*maxDist;
		vec3 rd = n*l;
		ao += (l - map( p + rd )) / pow(1.+l, falloff);
	}
	return clamp( 1.-ao/float(nbIte), 0., 1.);
}

float thickness( in vec3 p, in vec3 n, float maxDist, float falloff )
{
	float ao = 0.0;
	const int nbIte = 6;
	for( int i=0; i<nbIte; i++ )
	{
		float l = hash(float(i))*maxDist;
		vec3 rd = -n*l;
		ao += (l + map( p + rd )) / pow(1.+l, falloff);
	}
	return clamp( 1.-ao/float(nbIte), 0., 1.);
}

//------------------------------------------------------------------ POSTEFFECTS
float random(vec2 n, float offset ){
	return .5 - fract(sin(dot(n.xy + vec2( offset, 0. ), vec2(12.9898, 78.233)))* 43758.5453);
}

#ifdef POSTPROCESS
vec3 postEffects( in vec3 col, in vec2 uv, in float time )
{
	// vigneting
    float vignette = .8*pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.8 );
	col *= .2+vignette;
	col += (1.-vignette)*vec3( .25 * random( uv, .001 * iGlobalTime ) );
	return col;
}
#endif

vec3 render( in vec3 ro, in vec3 rd, in vec2 uv )
{
	vec3 col = vec3(.0,.0,1.2);

	float depth = 0.;
	float t = castRay(ro,rd,depth);
	#ifdef RENDER_DEPTH
	return vec3(depth/10.,depth/5.,depth);
	#endif
	vec3 pos = ro + t * rd;
	vec3 nor = calcNormal(pos);
	#ifdef RENDER_NORMAL
	return nor;
	#endif
	float ao = calcAO(pos,nor,10.,1.2);
	#ifdef RENDER_AO
	return vec3(ao);
	#endif

    float thi = thickness(pos, nor, 10., 1.4);
	col = max(vec3(0.), dot(nor,vec3(.5)));
    if(pos.y>-40.1){
        col*=texture2D(iChannel0,pos.xy/10.).ggg*.5;
    }
    col += vec3(depth/10.,depth/5.,depth);
    col *= clamp(1.-smoothstep(250.,400.,t),0.,1.);
    col *= ao*thi*1.3;
	return col;
}

//------------------------------------------------------------------ MAIN
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
	return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 coords )
{
	vec2 uv = coords.xy / iResolution.xy;
	vec2 mouse = iMouse.xy / iResolution.xy;
	vec2 q = coords.xy/iResolution.xy;
	vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;

	//Camera
	float radius = 80.;
	vec3 ro = orbit(PI/2.-.2,PI/2.,radius);
    ro.z-=30.*iGlobalTime;
    ro.x-=11.;
	vec3 ta  = vec3(-11.0+sin(iGlobalTime)*40.,15., -30.*iGlobalTime);
	mat3 ca = setCamera( ro, ta, 0. );
	vec3 rd = ca * normalize( vec3(p.xy,1.3) );

	// Raymarching
	vec3 color = render( ro, rd, uv );
	#ifdef POSTPROCESS
	color = postEffects( color, uv, iGlobalTime );
	#endif
	fragColor = vec4(color,1.0);
}

//------------------------------------------------------------------ NOISE
//AshimaOptim https://www.shadertoy.com/view/Xd3GRf
vec4 permute(vec4 x){return mod(x*x*34.0+x,289.);}
float snoise(vec3 v){
  const vec2  C = vec2(0.166666667, 0.33333333333) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 = v - i + dot(i, C.xxx) ;
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy;
  vec3 x3 = x0 - D.yyy;
  i = mod(i,289.);
  vec4 p = permute( permute( permute(
	  i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
	+ i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
	+ i.x + vec4(0.0, i1.x, i2.x, 1.0 ));
  vec3 ns = 0.142857142857 * D.wyz - D.xzx;
  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);
  vec4 x_ = floor(j * ns.z);
  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = floor(j - 7.0 * x_ ) *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);
  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));
  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;
  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);
  vec4 norm = inversesqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m * m;
  return .5 + 12.0 * dot( m, vec4( dot(p0,x0), dot(p1,x1),dot(p2,x2), dot(p3,x3) ) );
}
