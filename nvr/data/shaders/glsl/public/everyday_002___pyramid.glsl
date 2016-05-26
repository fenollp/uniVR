// Shader downloaded from https://www.shadertoy.com/view/XstGRl
// written by shadertoy user Makio64
//
// Name: Everyday 002 - Pyramid
// Description: Hi guys, this year I'm starting a &quot;everyday&quot; so here is a simple raymarching code template.
//    
//    comments line 33 to get only one pyramid
//    
//    If I'm doing anything wrong, thanks to let me know &amp; Happy new year again!
//    
// Pyramid - raymarching
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

float sdBox( vec3 p, vec3 b ){ return length(max(abs(p)-b,0.0)); }
float sdBox(vec3 p, vec3 b, float r) { return length(max(abs(p)-b,0.0))-r; }
float sdGround( in vec3 p ){ return p.y; }

//------------------------------------------------------------------ MAP

float map( in vec3 pos ) {
	float d = 1000000.;
	vec3 q;
	float t = mod(iGlobalTime*2.,1.);
	for(int i=-1; i < 10; i++){
		float ii = float(i);
        float y = -.1+(-ii-t)*.2;
        y += .2*t*smoothstep(8.,9.,ii);
		q = pos+vec3(0.,y,0.);
        vec3 c = vec3(2.,0.,2.);
        q = mod(q,c)-0.5*c;
        float size = 1.-ii*.1-t*.1;
		d = min(sdBox(q, vec3(size,.1,size)),d);
	}
	d = min(d,sdGround(pos));
	return d;
}

//------------------------------------------------------------------ RAYMARCHING

#ifdef RENDER_DEPTH
float castRay( in vec3 ro, in vec3 rd, inout float depth )
#else
float castRay( in vec3 ro, in vec3 rd )
#endif
{
	float tmax = 15.;
	float precis = .01;
	float t = 0.0;
	float res;
	for( int i=0; i<RAYMARCHING_STEP; i++ )
	{
		vec3 pos = ro+rd*t;
		res = map( pos );
		if( res<precis || t>tmax ) break;
		t += res*RAYMARCHING_JUMP;
		#ifdef RENDER_DEPTH
		depth += 1./float(RAYMARCHING_STEP);
		#endif
	}
	return t;
}

vec3 calcNormal(vec3 pos) {
    float eps = 0.001;
	const vec3 v1 = vec3( 1.0,-1.0,-1.0);
	const vec3 v2 = vec3(-1.0,-1.0, 1.0);
	const vec3 v3 = vec3(-1.0, 1.0,-1.0);
	const vec3 v4 = vec3( 1.0, 1.0, 1.0);
	return normalize( v1 * map( pos + v1*eps ) +
    	              v2 * map( pos + v2*eps ) +
        	          v3 * map( pos + v3*eps ) +
            	      v4 * map( pos + v4*eps ) );
}

float hash( float n ){//->0:1
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


//------------------------------------------------------------------ POSTEFFECTS

#ifdef POSTPROCESS
vec3 postEffects( in vec3 col, in vec2 uv, in float time )
{
	// gamma correction
	col = pow( clamp(col,0.0,1.0), vec3(0.45) );
	// vigneting
	col *= 0.5+0.5*pow( 16.0*uv.x*uv.y*(1.0-uv.x)*(1.0-uv.y), 0.15 );
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

	float ao = calcAO(pos,nor,1.,0.1);
	#ifdef RENDER_AO
	return vec3(ao);
	#endif

	vec3 light = vec3(.2,.5,.5);
    col = vec3(1.,.2,.2)*min(max(dot(nor,light),.0) + .05, 1.);
	col *= ao;
    vec3 fog = vec3(.0,0.,0.);
	col = mix( col, fog, 1.0-exp( -0.05*t*t ));

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
void mainImage( out vec4 fragColor, in vec2 coords )
{
	float time = iGlobalTime;
	vec2 uv = coords.xy / iResolution.xy;
	vec2 mouse = iMouse.xy / iResolution.xy;
	vec2 q = coords.xy/iResolution.xy;
	vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;

	//Camera
	float radius = 5.;
	vec3 ro = orbit(PI/2.-.7,time,4.5);
	vec3 ta  = vec3(0.0, 0.5, 0.0);
	mat3 ca = setCamera( ro, ta, 0. );
	vec3 rd = ca * normalize( vec3(p.xy,2.) );

	// Raymarching
	vec3 color = render( ro, rd, uv );
	#ifdef POSTPROCESS
	color = postEffects( color, uv, time );
	#endif
	fragColor = vec4(color,1.0);
}
