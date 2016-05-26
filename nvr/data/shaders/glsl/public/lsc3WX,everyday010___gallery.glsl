// Shader downloaded from https://www.shadertoy.com/view/lsc3WX
// written by shadertoy user Makio64
//
// Name: Everyday010 - Gallery
// Description: Shader gallery in shader on shadertoy ^.^
// Everyday010 - Gallery
// By David Ronai / @Makio64

//------------------------------------------------------------------ VISUAL QUALITY
#define POSTPROCESS
#define RAYMARCHING_STEP 30
#define RAYMARCHING_JUMP 1.
//------------------------------------------------------------------ DEBUG
//#define RENDER_DEPTH
//#define RENDER_NORMAL
//#define RENDER_AO

const float PI = 3.14159265359;

//------------------------------------------------------------------  OPERATIONS / PRIMITIVES
//http://mercury.sexy/hg_sdf/
float vmax(vec2 v) { return max(v.x, v.y); }
float vmax(vec3 v) { return max(max(v.x, v.y), v.z); }
float fBox2Cheap(vec2 p, vec2 b) {return vmax(abs(p)-b);}
float fBoxCheap(vec3 p, vec3 b) { return vmax(abs(p) - b);}
float pMod1(inout float p, float size) {
	float halfsize = size*0.5;
	float c = floor((p + halfsize)/size);
	p = mod(p + halfsize, size) - halfsize;
	return c;
}

//------------------------------------------------------------------ NOISE

float hash(vec2 p){ return fract(21654.65155 * sin(35.51 * p.x + 45.51 * p.y));}
float noise(vec2 p){
	vec2 fl = floor(p);
	vec2 fr = fract(p);
	fr.x = smoothstep(0.0,1.0,fr.x);
	fr.y = smoothstep(0.0,1.0,fr.y);
	float a = mix(hash(fl + vec2(0.0,0.0)), hash(fl + vec2(1.0,0.0)),fr.x);
	float b = mix(hash(fl + vec2(0.0,1.0)), hash(fl + vec2(1.0,1.0)),fr.x);
	return mix(a,b,fr.y);
}
float fbm(vec2 x) {
    float v = 0.0, a = 0.5;
    vec2 shift = vec2(100);
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
    for (int i = 0; i < 5; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

vec3 hsv2rgb( in vec3 c ){
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
	rgb = rgb*rgb*(3.0-2.0*rgb);	
	return c.z * mix( vec3(1.0), rgb, c.y);
}


//------------------------------------------------------------------ MAP
float map( in vec3 pos ) {
    pMod1(pos.x,70.);
    float d = fBoxCheap(pos,vec3(30.,20.,1.));
    	  d = min(fBoxCheap(pos+vec3(0.,0.,10.),vec3(10000.,10000.,2.)),d);
    return d;
}

//------------------------------------------------------------------ RAYMARCHING
#ifdef RENDER_DEPTH
float castRay( in vec3 ro, in vec3 rd, inout float depth )
#else
float castRay( in vec3 ro, in vec3 rd )
#endif
{
	float t = 0.0;
	float res;
	for( int i=0; i<RAYMARCHING_STEP; i++ )
	{
		vec3 pos = ro+rd*t;
		res = map( pos );
		if( res < 0.01 || t > 200. ) break;
		t += res*RAYMARCHING_JUMP;
		#ifdef RENDER_DEPTH
		depth += 1./float(RAYMARCHING_STEP);
		#endif
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
	col *= 0.5+0.5*pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.5 );
	return col;
}
#endif

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

	float ao = calcAO(pos,nor,15.,1.4);
	#ifdef RENDER_AO
	return vec3(ao);
	#endif

	col = vec3(1.)*max(0.,dot(nor,vec3(.0,.0,1.)));
    uv.x += iGlobalTime/3.;
    uv *= 10.;
    if(pos.z>1.){
		col *= .2*vec3(fbm(vec2(noise(uv+sin(iGlobalTime))+iGlobalTime)));
    	uv *= 1.5;
		col += .35*vec3(fbm(vec2(noise(uv+vec2(0.,iGlobalTime/2.))+iGlobalTime/2.+20.)));
	    uv *= 1.2;
		col += .45*vec3(fbm(vec2(noise(uv+vec2(0.,iGlobalTime/4.))+iGlobalTime/3.+100.)));
    	col*=col*1.9;
    	col*= hsv2rgb(vec3(.6+.2*cos(uv.y/10.+iGlobalTime*1.2),.1+.4*sin(uv.x/5.+iGlobalTime*.2),1.));
    	col*= 1.5;
    }
	col *= ao;

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
	float radius = 80.;
	vec3 ro = orbit(PI/2.-.2*sin(iGlobalTime),PI/2.,radius);
    ro.x += iGlobalTime*40.;
	vec3 ta  = vec3(iGlobalTime*40.,0.,0.);
	mat3 ca = setCamera( ro, ta, 0. );
	vec3 rd = ca * normalize( vec3(p.xy,1.5) );

	// Raymarching
	vec3 color = render( ro, rd, uv );
	#ifdef POSTPROCESS
	color = postEffects( color, uv, iGlobalTime );
	#endif
	fragColor = vec4(color,1.0);
}