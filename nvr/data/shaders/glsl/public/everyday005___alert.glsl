// Shader downloaded from https://www.shadertoy.com/view/ldcGDS
// written by shadertoy user Makio64
//
// Name: Everyday005 - Alert
// Description: My first &quot;tunnel&quot; to test more hg_sdf
// Everyday005 - Alert
// By David Ronai / @Makio64

//------------------------------------------------------------------ VISUAL QUALITY
#define POSTPROCESS
#define RAYMARCHING_STEP 40
#define RAYMARCHING_JUMP 1.
//------------------------------------------------------------------ DEBUG
//#define RENDER_DEPTH
//#define RENDER_NORMAL
//#define RENDER_AO

const float PI = 3.14159265359;

//------------------------------------------------------------------  SIGNED PRIMITIVES
//http://mercury.sexy/hg_sdf/
float fCylinder(vec3 p, float r, float height) {
	float d = length(p.xz) - r;
	d = max(d, abs(p.y) - height);
	return d;
}
vec3 pMod3(inout vec3 p, vec3 size) {
	vec3 c = floor((p + size*0.5)/size);
	p = mod(p + size*0.5, size) - size*0.5;
	return c;
}
void pR(inout vec2 p, float a) {
	p = cos(a)*p + sin(a)*vec2(p.y, -p.x);
}
float fOpUnionStairs(float a, float b, float r, float n) {
	float s = r/n;
	float u = b-r;
	return min(min(a,b), 0.5 * (u + a + abs ((mod (u - a + s, 2. * s)) - s)));
}
 
//------------------------------------------------------------------ MAP
float map( in vec3 pos ) {
	vec3 q = pos;
    pR(q.xy,PI/4.); 
    pMod3(q,vec3(40.,PI*4.*5.,40.));
	float d = fCylinder(q,5.,PI*4.*5.);
    
    q = pos;
    pR(q.zy,PI/2.); 
    pMod3(q,vec3(55.,PI*4.*5.,55.));
	d = fOpUnionStairs(d, fCylinder(q,5.,PI*4.*5.),10.,5.);

    q = pos;
    pR(q.xy,-PI/4.); 
    pMod3(q,vec3(40.,PI*4.*5.,40.));
	d = fOpUnionStairs(d, fCylinder(q,5.,PI*4.*5.),10.,5.);
	
    return d;
}

//------------------------------------------------------------------ RAYMARCHING
#ifdef RENDER_DEPTH
float castRay( in vec3 ro, in vec3 rd, inout float depth )
#else
float castRay( in vec3 ro, in vec3 rd )
#endif
{
	float t = 15.0;
	float res;
	for( int i=0; i<RAYMARCHING_STEP; i++ )
	{
		vec3 pos = ro+rd*t;
		res = map( pos );
		if( res < 0.01 || t > 150. ) break;
		t += res*RAYMARCHING_JUMP;
		#ifdef RENDER_DEPTH
		depth += 1./float(RAYMARCHING_STEP);
		#endif
	}
	return t;
}

vec3 calcNormal(vec3 p) {
	float eps = 0.0001;
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

// calculate local thickness
// base on AO but : inverse the normale & inverse the color
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

#ifdef POSTPROCESS
vec3 postEffects( in vec3 col, in vec2 uv, in float time )
{
	// vigneting
	col *= 0.4+0.6*pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.5 );
	return col;
}
#endif

vec3 addLight(in vec3 lpos, inout vec3 col, in vec3 pos, in vec3 nor, in vec3 rd, in float thi){
	vec3 ldir = normalize(lpos-pos);
	float latt = pow( length(lpos-pos)*.03, .5 );
    float trans =  pow( clamp( max(0.,dot(-rd, -ldir+nor)), 0., 1.), 1.) + 1.;
	//col = vec3(.2,.1,.1) * (max(dot(nor,ldir),0.) ) / latt;
	col += vec3(.3,.3,.1) * (trans/latt)*thi;
    return col;
   
}

vec3 render( in vec3 ro, in vec3 rd, in vec2 uv )
{
	vec3 col = vec3(.0,.0,1.2);

	#ifdef RENDER_DEPTH
	float depth = 0.;
	float t = castRay(ro,rd,depth);
	#else
	float t = castRay(ro,rd);
	#endif

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

    float thi = thickness(pos, nor, 4., 2.5);

    vec3 lpos1 = vec3(0.,27.5,-iGlobalTime*50.);
	vec3 ldir1 = normalize(lpos1-pos);
	float latt1 = pow( length(lpos1-pos)*.03, 1. );
    float trans1 =  pow( clamp( max(0.,dot(-rd, -ldir1+nor)), 0., 1.), 1.) + 1.;
	vec3 diff1 = vec3(.3,.1,.1) * (max(dot(nor,ldir1),0.) ) / latt1;
	col =  diff1;
	col += vec3(.3+abs(sin(iGlobalTime*10.))*.4,.3,.1) * (trans1/latt1)*thi;
    
    vec3 lpos = vec3(80.,0.,-iGlobalTime*50.);
    vec3 ldir = normalize(lpos-pos);
	float latt = pow( length(lpos-pos)*.03, .1 );
    float trans =  pow( clamp( max(0.,dot(-rd, -ldir+nor)), 0., 1.), 1.) + 1.;
	//col = vec3(.2,.1,.1) * (max(dot(nor,ldir),0.) ) / latt;
	col += vec3(.1,.1,.1) * (trans/latt)*thi;

    lpos = vec3(-80.,0.,-iGlobalTime*50.);
    ldir = normalize(lpos-pos);
	latt = pow( length(lpos-pos)*.03, 1.5 );
    trans =  pow( clamp( max(0.,dot(-rd, -ldir+nor)), 0., 1.), 1.) + 1.;
	col += vec3(.1,.1,.1) * (trans/latt)*thi;

    float d = distance(pos.xyz,vec3(0.));
	col = max(vec3(.05),col);
	col *= ao;
    
	col = mix( col, vec3(1.), 1.0-exp((0.000015+abs(sin(iGlobalTime)*0.00015))*t*t));

	return col;
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
	return mat3( cu, cv, cw );
}

vec3 orbit(float phi, float theta, float radius)
{
	return vec3(
		radius * sin( phi ) * cos( theta ),
		radius * cos( phi ),
		radius * sin( phi ) * sin( theta )
	);
}

//------------------------------------------------------------------ MAIN
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 p = -1. + 2. * uv;
    p.x *= iResolution.x / iResolution.y;
    
    //Camera
	float radius = 50.;
	vec3 ro = orbit(PI/2.-.5,PI/2.,radius);
    ro.z -= iGlobalTime*50.;
	vec3 ta  = vec3(ro.x, ro.y, ro.z-iGlobalTime*50.);
	mat3 ca = setCamera( ro, ta, 0. );
	vec3 rd = ca * normalize( vec3(p.xy,.5) );

	// Raymarching
	vec3 color = render( ro, rd, uv );
	#ifdef POSTPROCESS
	color = postEffects( color, uv, iGlobalTime );
	#endif
	fragColor = vec4(color,1.0);
}