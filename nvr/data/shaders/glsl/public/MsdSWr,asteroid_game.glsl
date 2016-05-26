// Shader downloaded from https://www.shadertoy.com/view/MsdSWr
// written by shadertoy user pacolmos
//
// Name: Asteroid game
// Description: CONTROL: Teclas de direccion (como simulador de vuelo)
//    BARRA IZQUIERDA: Proximidad limite anillo asteroides (prohibido salir del anillo)
//    BARRA DERECHA: Integridad estructural (la nave no debe ser destruida)
//    CONTADOR: Distancia recorrida hacia planeta
//    
//    
//    
// ****************************************************************************
// Juego basado en Planet Shadertoy de Reinder Nijhoff
// https://www.shadertoy.com/view/4tjGRh
//
// Para pintar el texto se han utilizado funciones de Wordtoy de Pol Jeremias
// https://www.shadertoy.com/view/Xst3zX
//
// Para el control con el teclado hemos aprendido mucho de Drifter de eiffie
// https://www.shadertoy.com/view/lsK3Dt
// ****************************************************************************

// -----------------------------
// Función de lectura del Buffer
// -----------------------------
#define load(a) texture2D(iChannel0,(vec2(a - 0.5,0.5))/iResolution.xy)


// -------------------------------------
// Variables pasadas a través del Buffer
// -------------------------------------
const float COLISION = 1.;
const float POSICION = 2.;
const float DIRECCION = 3.;
const float UP = 4.;
const float TA = 5.;
const float GAME_OVER = 6.;
const float DANIO = 7.;

// ----------------------
// Constantes matemáticas
// ----------------------
const float PI = 3.14159265359;
const float DEG_TO_RAD = (PI / 180.0);
const float MAX = 10000.0;

// --------------------------------------------
// Propiedades del planeta (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// --------------------------------------------
const float EARTH_RADIUS = 1000.;
const float EARTH_ATMOSPHERE = 5.;
const float EARTH_CLOUDS = 1.;

// ---------------------------------------------------------------------
// Propiedades del anillo de asteroides del planeta (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// ---------------------------------------------------------------------
const float RING_INNER_RADIUS = 1500.;
const float RING_OUTER_RADIUS = 2300.;
const float RING_HEIGHT = 2.;

// --------------------------------------------------------------
// Propiedades de calidad de imagen muy baja (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// --------------------------------------------------------------
const int   ASTEROID_NUM_STEPS = 7;
const int	ASTEROID_NUM_BOOL_SUB = 4;
const int   RING_VOXEL_STEPS = 16;
const float ASTEROID_MAX_DISTANCE = .67; 
const int   FBM_STEPS = 3;
const int   ATMOSPHERE_NUM_OUT_SCATTER = 2;
const int   ATMOSPHERE_NUM_IN_SCATTER = 4;

// ----------------------------------------
// Propiedades del Sol (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// ----------------------------------------
const vec3  SUN_DIRECTION = vec3( .940721,  .28221626, .18814417 );
const vec3  SUN_COLOR = vec3(.3, .21, .165);

// -------------------------------------
// Caracteres de texto (by Pol Jeremias)
// https://www.shadertoy.com/view/Xst3zX
// -------------------------------------
float ch_sp = 0.0;
float ch_a = 712557.0;
float ch_e = 2018607.0;
float ch_g = 706922.0;
float ch_m = 1571693.0;
float ch_o = 711530.0;
float ch_r = 1760621.0;
float ch_v = 1497938.0;
float ch_1 = 730263.0;
float ch_2 = 693543.0;
float ch_3 = 693354.0;
float ch_4 = 1496649.0;
float ch_5 = 1985614.0;
float ch_6 = 707946.0;
float ch_7 = 1873042.0;
float ch_8 = 709994.0;
float ch_9 = 710250.0;
float ch_0 = 711530.0;

// --------------------------------------------------------
// Propiedades de los caracteres de texto (by Pol Jeremias)
// https://www.shadertoy.com/view/Xst3zX
// --------------------------------------------------------
#define CHAR_SIZE vec2(3, 7)
#define CHAR_SPACING vec2(8, 12)

#define STRWIDTH(c) (c * CHAR_SPACING.x)
#define STRHEIGHT(c) (c * CHAR_SPACING.y)

// --------------------------------------------------------------
// Tiempo para el movimiento y rotación de los asteroides(by TDM)
// https://www.shadertoy.com/view/ldSSzV
// --------------------------------------------------------------
float time;


// --------------------------------------
// Noise functions (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// --------------------------------------

float hash( const in float n ) {
    return fract(sin(n)*43758.5453123);
}
float hash( const in vec2 p ) {
	float h = dot(p,vec2(127.1,311.7));	
    return fract(sin(h)*43758.5453123);
}
float hash( const in vec3 p ) {
	float h = dot(p,vec3(127.1,311.7,758.5453123));	
    return fract(sin(h)*43758.5453123);
}
vec3 hash31( const in float p) {
	vec3 h = vec3(1275.231,4461.7,7182.423) * p;	
    return fract(sin(h)*43758.543123);
}
vec3 hash33( const in vec3 p) {
    return vec3( hash(p), hash(p.zyx), hash(p.yxz) );
}

float noise( const in  float p ) {    
    float i = floor( p );
    float f = fract( p );	
	float u = f*f*(3.0-2.0*f);
    return -1.0+2.0* mix( hash( i + 0. ), hash( i + 1. ), u);
}

float noise( const in  vec2 p ) {    
    vec2 i = floor( p );
    vec2 f = fract( p );	
	vec2 u = f*f*(3.0-2.0*f);
    return -1.0+2.0*mix( mix( hash( i + vec2(0.0,0.0) ), 
                     hash( i + vec2(1.0,0.0) ), u.x),
                mix( hash( i + vec2(0.0,1.0) ), 
                     hash( i + vec2(1.0,1.0) ), u.x), u.y);
}
float noise( const in  vec3 x ) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}

float tri( const in vec2 p ) {
    return 0.5*(cos(6.2831*p.x) + cos(6.2831*p.y));
   
}

const mat2 m2 = mat2( 0.80, -0.60, 0.60, 0.80 );

float fbm( in vec2 p ) {
    float f = 0.0;
    f += 0.5000*noise( p ); p = m2*p*2.02;
    f += 0.2500*noise( p ); p = m2*p*2.03;
    f += 0.1250*noise( p ); 
    
    return f/0.9375;
}

float fbm( const in vec3 p, const in float a, const in float f) {
    float ret = 0.0;    
    float amp = 1.0;
    float frq = 1.0;
    for(int i = 0; i < FBM_STEPS; i++) {
        float n = pow(noise(p * frq),2.0);
        ret += n * amp;
        frq *= f;
        amp *= a * (pow(n,0.2));
    }
    return ret;
}

// ---------------------------------------------
// Funciones de iluminación (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// ---------------------------------------------

float diffuse( const in vec3 n, const in vec3 l) { 
    return clamp(dot(n,l),0.,1.);
}

float specular( const in vec3 n, const in vec3 l, const in vec3 e, const in float s) {    
    float nrm = (s + 8.0) / (3.1415 * 8.0);
    return pow(max(dot(reflect(e,n),l),0.0),s) * nrm;
}

float fresnel( const in vec3 n, const in vec3 e, float s ) {
    return pow(clamp(1.-dot(n,e), 0., 1.),s);
}

// -----------------------------------------
// Funciones matemáticas(by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// -----------------------------------------

vec2 rotate(float angle, vec2 v) {
    return vec2(cos(angle) * v.x + sin(angle) * v.y, cos(angle) * v.y - sin(angle) * v.x);
}

float boolSub(float a,float b) { 
    return max(a,-b); 
}
float sphere(vec3 p,float r) {
	return length(p)-r;
}

// ---------------------------------
// Funciones de Intersección (by iq)
// ---------------------------------

vec3 nSphere( in vec3 pos, in vec4 sph ) {
    return (pos-sph.xyz)/sph.w;
}

float iSphere( in vec3 ro, in vec3 rd, in vec4 sph ) {
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
	return -b - sqrt( h );
}

float iCSphereF( vec3 p, vec3 dir, float r ) {
	float b = dot( p, dir );
	float c = dot( p, p ) - r * r;
	float d = b * b - c;
	if ( d < 0.0 ) return -MAX;
	return -b + sqrt( d );
}

vec2 iCSphere2( vec3 p, vec3 dir, float r ) {
	float b = dot( p, dir );
	float c = dot( p, p ) - r * r;
	float d = b * b - c;
	if ( d < 0.0 ) return vec2( MAX, -MAX );
	d = sqrt( d );
	return vec2( -b - d, -b + d );
}

vec3 nPlane( in vec3 ro, in vec4 obj ) {
    return obj.xyz;
}

float iPlane( in vec3 ro, in vec3 rd, in vec4 pla ) {
    return (-pla.w - dot(pla.xyz,ro)) / dot( pla.xyz, rd );
}

// --------------------------------------
// Asteroide (by TDM)
// https://www.shadertoy.com/view/ldSSzV
// --------------------------------------

const float ASTEROID_TRESHOLD 	= 0.001;
const float ASTEROID_EPSILON 	= 1e-6;
const float ASTEROID_DISPLACEMENT = 0.1;
const float ASTEROID_RADIUS = 0.13;

const vec3  RING_COLOR_1 = vec3(0.42,0.3,0.2);
const vec3  RING_COLOR_2 = vec3(0.51,0.41,0.32) * 0.2;

float asteroidRock( const in vec3 p, const in vec3 id ) {  
    float d = sphere(p,ASTEROID_RADIUS);    
    for(int i = 0; i < ASTEROID_NUM_BOOL_SUB; i++) {
        float ii = float(i)+id.x;
        float r = (ASTEROID_RADIUS*2.5) + ASTEROID_RADIUS*hash(ii);
        vec3 v = normalize(hash31(ii) * 2.0 - 1.0);
    	d = boolSub(d,sphere(p+v*r,r * 0.8));       
    }
    return d;
}

float asteroidMap( const in vec3 p, const in vec3 id) {
    float d = asteroidRock(p, id) + noise(p*4.0) * ASTEROID_DISPLACEMENT;
    return d;
}

float asteroidMapDetailed( const in vec3 p, const in vec3 id) {
    float d = asteroidRock(p, id) + fbm(p*4.0,0.4,2.96) * ASTEROID_DISPLACEMENT;
    return d;
}

void asteroidTransForm(inout vec3 ro, const in vec3 id ) {
    float xyangle = (id.x-.5)*time*2.;
    ro.xy = rotate( xyangle, ro.xy );
    
    float yzangle = (id.y-.5)*time*2.;
    ro.yz = rotate( yzangle, ro.yz );
}

void asteroidUnTransForm(inout vec3 ro, const in vec3 id ) {
    float yzangle = (id.y-.5)*time*2.;
    ro.yz = rotate( -yzangle, ro.yz );

    float xyangle = (id.x-.5)*time*2.;
    ro.xy = rotate( -xyangle, ro.xy );  
}

vec3 asteroidGetNormal(vec3 p, vec3 id) {
    asteroidTransForm( p, id );
    
    vec3 n;
    n.x = asteroidMapDetailed(vec3(p.x+ASTEROID_EPSILON,p.y,p.z), id);
    n.y = asteroidMapDetailed(vec3(p.x,p.y+ASTEROID_EPSILON,p.z), id);
    n.z = asteroidMapDetailed(vec3(p.x,p.y,p.z+ASTEROID_EPSILON), id);
    n = normalize(n-asteroidMapDetailed(p, id));
    
    asteroidUnTransForm( n, id );
    return n;
}

vec2 asteroidSpheretracing(vec3 ori, vec3 dir, vec3 id) {
    asteroidTransForm( ori, id );
    asteroidTransForm( dir, id );
    
    vec2 td = vec2(0.0);
    for(int i = 0; i < ASTEROID_NUM_STEPS; i++) {
        vec3 p = ori + dir * td.x;
        td.y = asteroidMap(p, id);
        if(td.y < ASTEROID_TRESHOLD) break;
        td.x += (td.y-ASTEROID_TRESHOLD) * 0.9;
    }
    return td;
}

vec3 asteroidGetStoneColor(vec3 p, float c, vec3 l, vec3 n, vec3 e) {
	return mix( diffuse(n,l)*RING_COLOR_1*SUN_COLOR, SUN_COLOR*specular(n,l,e,3.0), .5*fresnel(n,e,5.));    
}

// --------------------------------------------------
// Anillo de asteroides de cerca (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// --------------------------------------------------

const float RING_DETAIL_DISTANCE = 40.;
const float RING_VOXEL_STEP_SIZE = .03;

vec3 ringShadowColor( const in vec3 ro ) {
    if( iSphere( ro, SUN_DIRECTION, vec4( 0., 0., 0., EARTH_RADIUS ) ) > 0. ) {
        return vec3(0.);
    }
    return vec3(1.);
}

bool ringMap( const in vec3 ro ) {
    return ro.z < RING_HEIGHT/RING_VOXEL_STEP_SIZE && hash(ro)<.5;
}

vec4 renderRingNear( const in vec3 ro, const in vec3 rd ) { 
// find startpoint 
    float d1 = iPlane( ro, rd, vec4( 0., 0., 1., RING_HEIGHT ) );
    float d2 = iPlane( ro, rd, vec4( 0., 0., 1., -RING_HEIGHT ) );
   
    if( d1 < 0. && d2 < 0. ) return vec4( 0. );
    
    float d = min( max(d1,0.), max(d2,0.) );
    
    if( d > ASTEROID_MAX_DISTANCE ) return vec4( 0. );
    
    vec3 ros = ro + rd*d;
    
    // avoid precision problems..
    vec2 mroxy = mod(ros.xy, vec2(10.));
    vec2 roxy = ros.xy - mroxy;
    ros.xy -= roxy;
    ros /= RING_VOXEL_STEP_SIZE;
    ros.xy -= vec2(.013,.112)*time*.5;
    
	vec3 pos = floor(ros);
	vec3 ri = 1.0/rd;
	vec3 rs = sign(rd);
	vec3 dis = (pos-ros + 0.5 + rs*0.5) * ri;
	
    float alpha = 0., dint;
	vec3 offset = vec3(0.), id, asteroidro;
    vec2 asteroid;
    
	for( int i=0; i<RING_VOXEL_STEPS; i++ ) {
		if( ringMap(pos) ) {
            id = hash33(pos);
            offset = id*(1.-2.*ASTEROID_RADIUS)+ASTEROID_RADIUS;
            dint = iSphere( ros, rd, vec4(pos+offset, ASTEROID_RADIUS) );
            
            if( dint > 0. ) {
                asteroidro = ros+rd*dint-(pos+offset);
    	        asteroid = asteroidSpheretracing( asteroidro, rd, id );
				
                if( asteroid.y < .1 ) {
	                alpha = 1.;
        	    	break;	    
                }
            }

        }
		vec3 mm = step(dis.xyz, dis.yxy) * step(dis.xyz, dis.zzx);
		dis += mm * rs * ri;
        pos += mm * rs;
	}
    
    if( alpha > 0. ) {       
        vec3 intersection = ros + rd*(asteroid.x+dint);
        vec3 n = asteroidGetNormal( asteroidro + rd*asteroid.x, id );

        vec3 col = asteroidGetStoneColor(intersection, .1, SUN_DIRECTION, n, rd);

        intersection *= RING_VOXEL_STEP_SIZE;
        intersection.xy += roxy;
        col *= ringShadowColor( intersection );
         
	    return vec4( col, 1.-smoothstep(0.4*ASTEROID_MAX_DISTANCE, 0.5* ASTEROID_MAX_DISTANCE, distance( intersection, ro ) ) );
    }
    
	return vec4(0.);
}

// --------------------------------------------------
// Anillo de asteroides de lejos (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// --------------------------------------------------

float renderRingFarShadow( const in vec3 ro, const in vec3 rd ) {
    // intersect plane
    float d = iPlane( ro, rd, vec4( 0., 0., 1., 0.) );
    
    if( d > 0. ) {
	    vec3 intersection = ro + rd*d;
        float l = length(intersection.xy);
        
        if( l > RING_INNER_RADIUS && l < RING_OUTER_RADIUS ) {
            return .5 + .5 * (.2+.8*noise( l*.07 )) * (.5+.5*noise(intersection.xy));
        }
    }
    return 0.;
}

vec4 renderRingFar( const in vec3 ro, const in vec3 rd, inout float maxd ) {
    // intersect plane
    float d = iPlane( ro, rd, vec4( 0., 0., 1., 0.) );
    
    if( d > 0. && d < maxd ) {
        maxd = d;
	    vec3 intersection = ro + rd*d;
        float l = length(intersection.xy);
        
        if( l > RING_INNER_RADIUS && l < RING_OUTER_RADIUS ) {
            float dens = .5 + .5 * (.2+.8*noise( l*.07 )) * (.5+.5*noise(intersection.xy));
            vec3 col = mix( RING_COLOR_1, RING_COLOR_2, abs( noise(l*0.2) ) ) * abs(dens) * 1.5;
            
            col *= ringShadowColor( intersection );
    		col *= .8+.3*diffuse( vec3(0,0,1), SUN_DIRECTION );
			col *= SUN_COLOR;
            return vec4( col, dens );
        }
    }
    return vec4(0.);
}

vec4 renderRing( const in vec3 ro, const in vec3 rd, inout float maxd ) {
    vec4 far = renderRingFar( ro, rd, maxd );
    float l = length( ro.xy );

    if( abs(ro.z) < RING_HEIGHT+RING_DETAIL_DISTANCE 
        && l < RING_OUTER_RADIUS+RING_DETAIL_DISTANCE 
        && l > RING_INNER_RADIUS-RING_DETAIL_DISTANCE ) {
     	
	    float d = iPlane( ro, rd, vec4( 0., 0., 1., 0.) );
        float detail = mix( .5 * noise( fract(ro.xy+rd.xy*d) * 92.1)+.25, 1., smoothstep( 0.,RING_DETAIL_DISTANCE, d) );
        far.xyz *= detail;    
    }
    
	// are asteroids neaded ?
    if( abs(ro.z) < RING_HEIGHT+ASTEROID_MAX_DISTANCE 
        && l < RING_OUTER_RADIUS+ASTEROID_MAX_DISTANCE 
        && l > RING_INNER_RADIUS-ASTEROID_MAX_DISTANCE ) {
        
        vec4 near = renderRingNear( ro, rd );
        far = mix( far, near, near.w );
        maxd=0.;
    }
            
    return far;
}

// --------------------------------------
// Estrellas (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// --------------------------------------

vec4 renderStars( const in vec3 rd ) {
	vec3 rds = rd;
	vec3 col = vec3(0);
    float v = 1.0/( 2. * ( 1. + rds.z ) );
    
    vec2 xy = vec2(rds.y * v, rds.x * v);
    float s = noise(rds*134.);
    
    s += noise(rds*470.);
    s = pow(s,19.0) * 0.00001;
    if (s > 0.5) {
        vec3 backStars = vec3(s)*.5 * vec3(0.95,0.8,0.9); 
        col += backStars;
    }
	return   vec4( col, 1 ); 
} 

// --------------------------------------
// Atmospheric Scattering (by GLtracy)
// https://www.shadertoy.com/view/lslXDr
// --------------------------------------

const float ATMOSPHERE_K_R = 0.166;
const float ATMOSPHERE_K_M = 0.0025;
const float ATMOSPHERE_E = 12.3;
const vec3  ATMOSPHERE_C_R = vec3( 0.3, 0.7, 1.0 );
const float ATMOSPHERE_G_M = -0.85;

const float ATMOSPHERE_SCALE_H = 4.0 / ( EARTH_ATMOSPHERE );
const float ATMOSPHERE_SCALE_L = 1.0 / ( EARTH_ATMOSPHERE );

const float ATMOSPHERE_FNUM_OUT_SCATTER = float(ATMOSPHERE_NUM_OUT_SCATTER);
const float ATMOSPHERE_FNUM_IN_SCATTER = float(ATMOSPHERE_NUM_IN_SCATTER);

const int   ATMOSPHERE_NUM_OUT_SCATTER_LOW = 2;
const int   ATMOSPHERE_NUM_IN_SCATTER_LOW = 4;
const float ATMOSPHERE_FNUM_OUT_SCATTER_LOW = float(ATMOSPHERE_NUM_OUT_SCATTER_LOW);
const float ATMOSPHERE_FNUM_IN_SCATTER_LOW = float(ATMOSPHERE_NUM_IN_SCATTER_LOW);

float atmosphericPhaseMie( float g, float c, float cc ) {
	float gg = g * g;
	float a = ( 1.0 - gg ) * ( 1.0 + cc );
	float b = 1.0 + gg - 2.0 * g * c;
    
	b *= sqrt( b );
	b *= 2.0 + gg;	
	
	return 1.5 * a / b;
}

float atmosphericPhaseReyleigh( float cc ) {
	return 0.75 * ( 1.0 + cc );
}

float atmosphericDensity( vec3 p ){
	return exp( -( length( p ) - EARTH_RADIUS ) * ATMOSPHERE_SCALE_H );
}

float atmosphericOptic( vec3 p, vec3 q ) {
	vec3 step = ( q - p ) / ATMOSPHERE_FNUM_OUT_SCATTER;
	vec3 v = p + step * 0.5;
	
	float sum = 0.0;
	for ( int i = 0; i < ATMOSPHERE_NUM_OUT_SCATTER; i++ ) {
		sum += atmosphericDensity( v );
		v += step;
	}
	sum *= length( step ) * ATMOSPHERE_SCALE_L;
	
	return sum;
}

vec4 atmosphericInScatter( vec3 o, vec3 dir, vec2 e, vec3 l ) {
	float len = ( e.y - e.x ) / ATMOSPHERE_FNUM_IN_SCATTER;
	vec3 step = dir * len;
	vec3 p = o + dir * e.x;
	vec3 v = p + dir * ( len * 0.5 );

    float sumdensity = 0.;
	vec3 sum = vec3( 0.0 );

    for ( int i = 0; i < ATMOSPHERE_NUM_IN_SCATTER; i++ ) {
        vec3 u = v + l * iCSphereF( v, l, EARTH_RADIUS + EARTH_ATMOSPHERE );
		float n = ( atmosphericOptic( p, v ) + atmosphericOptic( v, u ) ) * ( PI * 4.0 );
		float dens = atmosphericDensity( v );
  
	    float m = MAX;
		sum += dens * exp( -n * ( ATMOSPHERE_K_R * ATMOSPHERE_C_R + ATMOSPHERE_K_M ) ) 
    		* (1. - renderRingFarShadow( u, SUN_DIRECTION ) );
 		sumdensity += dens;
        
		v += step;
	}
	sum *= len * ATMOSPHERE_SCALE_L;
	
	float c  = dot( dir, -l );
	float cc = c * c;
	
	return vec4( sum * ( ATMOSPHERE_K_R * ATMOSPHERE_C_R * atmosphericPhaseReyleigh( cc ) + 
                         ATMOSPHERE_K_M * atmosphericPhaseMie( ATMOSPHERE_G_M, c, cc ) ) * ATMOSPHERE_E, 
                	     clamp(sumdensity * len * ATMOSPHERE_SCALE_L,0.,1.));
}

float atmosphericOpticLow( vec3 p, vec3 q ) {
	vec3 step = ( q - p ) / ATMOSPHERE_FNUM_OUT_SCATTER_LOW;
	vec3 v = p + step * 0.5;
	
	float sum = 0.0;
	for ( int i = 0; i < ATMOSPHERE_NUM_OUT_SCATTER_LOW; i++ ) {
		sum += atmosphericDensity( v );
		v += step;
	}
	sum *= length( step ) * ATMOSPHERE_SCALE_L;
	
	return sum;
}

vec3 atmosphericInScatterLow( vec3 o, vec3 dir, vec2 e, vec3 l ) {
	float len = ( e.y - e.x ) / ATMOSPHERE_FNUM_IN_SCATTER_LOW;
	vec3 step = dir * len;
	vec3 p = o + dir * e.x;
	vec3 v = p + dir * ( len * 0.5 );

	vec3 sum = vec3( 0.0 );

    for ( int i = 0; i < ATMOSPHERE_NUM_IN_SCATTER_LOW; i++ ) {
		vec3 u = v + l * iCSphereF( v, l, EARTH_RADIUS + EARTH_ATMOSPHERE );
		float n = ( atmosphericOpticLow( p, v ) + atmosphericOpticLow( v, u ) ) * ( PI * 4.0 );
	    float m = MAX;
		sum += atmosphericDensity( v ) * exp( -n * ( ATMOSPHERE_K_R * ATMOSPHERE_C_R + ATMOSPHERE_K_M ) );
		v += step;
	}
	sum *= len * ATMOSPHERE_SCALE_L;
	
	float c  = dot( dir, -l );
	float cc = c * c;
	
	return sum * ( ATMOSPHERE_K_R * ATMOSPHERE_C_R * atmosphericPhaseReyleigh( cc ) + 
                   ATMOSPHERE_K_M * atmosphericPhaseMie( ATMOSPHERE_G_M, c, cc ) ) * ATMOSPHERE_E;
}

vec4 renderAtmospheric( const in vec3 ro, const in vec3 rd, inout float d ) {    
    // inside or outside atmosphere?
    vec2 e = iCSphere2( ro, rd, EARTH_RADIUS + EARTH_ATMOSPHERE );
	vec2 f = iCSphere2( ro, rd, EARTH_RADIUS );
        
    if(  iSphere( ro, rd, vec4(0,0,0,EARTH_RADIUS + EARTH_ATMOSPHERE )) < 0. ) return vec4(0.);

    if ( e.x > e.y ) {
        d = MAX;
        return vec4(0.);
    }
    d = e.y = min( e.y, f.x );

    return atmosphericInScatter( ro, rd, e, SUN_DIRECTION );
}

vec3 renderAtmosphericLow( const in vec3 ro, const in vec3 rd ) {    
    vec2 e = iCSphere2( ro, rd, EARTH_RADIUS + EARTH_ATMOSPHERE );
    e.x = 0.;
    return atmosphericInScatterLow( ro, rd, e, SUN_DIRECTION );
}

// --------------------------------------
// Seascape (by TDM)
// https://www.shadertoy.com/view/Ms2SD1
// --------------------------------------

const vec3  SEA_BASE = vec3(0.1,0.19,0.22);
const vec3  SEA_WATER_COLOR = vec3(0.8,0.9,0.6);

vec3 seaGetColor( const in vec3 n, vec3 eye, const in vec3 l, const in float att, 
                  const in vec3 sunc, const in vec3 upc, const in vec3 reflected) {  
    vec3 refracted = SEA_BASE * upc + diffuse(n,l) * SEA_WATER_COLOR * 0.12 * sunc; 
    vec3 color = mix(refracted,reflected,fresnel(n, -eye, 3.)*.65 );
    
    color += upc*SEA_WATER_COLOR * (att * 0.18);
    color += sunc * vec3(specular(n,l,eye,60.0));
    
    return color;
}

// --------------------------------------
// Nubes (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// --------------------------------------

vec4 renderClouds( const in vec3 ro, const in vec3 rd, const in float d, const in vec3 n, const in float land, 
                   const in vec3 sunColor, const in vec3 upColor, inout float shadow ) {
	vec3 intersection = ro+rd*d;
    vec3 cint = intersection*0.009;
    float rot = -.2*length(cint.xy) + .6*fbm( cint*.4,0.5,2.96 ) + .05*land;

    cint.xy = rotate( rot, cint.xy );

    vec3 cdetail = mod(intersection*3.23,vec3(50.));
    cdetail.xy = rotate( .25*rot, cdetail.xy );

    float clouds = 1.3*(fbm( cint*(1.+.02*noise(intersection)),0.5,2.96)+.4*land-.3);

    shadow = clamp(1.-clouds, 0., 1.);

    clouds = clamp(clouds, 0., 1.);
    clouds *= clouds;
    clouds *= smoothstep(0.,0.4,d);

    vec3 clbasecolor = vec3(1.);
    vec3 clcol = .1*clbasecolor*sunColor * vec3(specular(n,SUN_DIRECTION,rd,36.0));
    clcol += .3*clbasecolor*sunColor;
    clcol += clbasecolor*(diffuse(n,SUN_DIRECTION)*sunColor+upColor);  
    
    return vec4( clcol, clouds );
}

// --------------------------------------
// Planeta (by Reinder Nijhoff)
// https://www.shadertoy.com/view/4tjGRh
// --------------------------------------

vec4 renderPlanet( const in vec3 ro, const in vec3 rd, const in vec3 up, inout float maxd ) {
    float d = iSphere( ro, rd, vec4( 0., 0., 0., EARTH_RADIUS ) );

    vec3 intersection = ro + rd*d;
    vec3 n = nSphere( intersection, vec4( 0., 0., 0., EARTH_RADIUS ) );
    vec4 res;

    float mixDetailColor = 0.;
        
	if( d < 0. || d > maxd) {
      	return vec4(0.);
	}
    if( d > 0. ) {
	    maxd = d;
    }
    float att = 0.;
    
    if( dot(n,SUN_DIRECTION) < -0.1 ) return vec4( 0., 0., 0., 1. );
    
    float dm = MAX, e = 0.;
    vec3 col, detailCol, nDetail;
    
    // normal and intersection 
    e = fbm( .003*intersection+vec3(1.),0.4,2.96) + smoothstep(.85,.95, abs(intersection.z/EARTH_RADIUS));
    
    vec3 sunColor = .25*renderAtmosphericLow( intersection, SUN_DIRECTION).xyz;  
    vec3 upColor = 2.*renderAtmosphericLow( intersection, n).xyz;  
    vec3 reflColor = renderAtmosphericLow( intersection, reflect(rd,n)).xyz; 
                 
    // color  
    if( mixDetailColor < 1. ) {
        if( e < .45 ) {
            // sea
            col = seaGetColor(n,rd,SUN_DIRECTION, att, sunColor, upColor, reflColor);    
        } else {
            // planet (land) far
            float land1 = max(0.1, fbm( intersection*0.0013,0.4,2.96) );
            float land2 = max(0.1, fbm( intersection*0.0063,0.4,2.96) );
            float iceFactor = abs(pow(intersection.z/EARTH_RADIUS,13.0))*e;

            vec3 landColor1 = vec3(0.43,0.65,0.1) * land1;
            vec3 landColor2 = RING_COLOR_1 * land2;
            vec3 mixedLand = (landColor1 + landColor2)* 0.5;
            vec3 finalLand = mix(mixedLand, vec3(7.0, 7.0, 7.0) * land1 * 1.5, max(iceFactor+.02*land2-.02, 0.));

            col = (diffuse(n,SUN_DIRECTION)*sunColor+upColor)*finalLand*.75;
        }
    }
    
    if( mixDetailColor > 0. ) {
        col = mix( col, detailCol, mixDetailColor );
    }
        
    d = iSphere( ro, rd, vec4( 0., 0., 0., EARTH_RADIUS+EARTH_CLOUDS ) );
    if( d > 0. ) { 
        float shadow;
		vec4 clouds = renderClouds( ro, rd, d, n, e, sunColor, upColor, shadow);
        col *= shadow; 
        col = mix( col, clouds.rgb, clouds.w );
    }
    
    float m = MAX;
    col *= (1. - renderRingFarShadow( ro+rd*d, SUN_DIRECTION ) );

 	return vec4( col, 1. ); 
}

// --------------------------------------
// Lens flare (by musk)
// https://www.shadertoy.com/view/4sX3Rs
// --------------------------------------

vec3 lensFlare( const in vec2 uv, const in vec2 pos) {
	vec2 main = uv-pos;
	vec2 uvd = uv*(length(uv));
	
	float f0 = 1.5/(length(uv-pos)*16.0+1.0);
	
	float f1 = max(0.01-pow(length(uv+1.2*pos),1.9),.0)*7.0;

	float f2 = max(1.0/(1.0+32.0*pow(length(uvd+0.8*pos),2.0)),.0)*00.25;
	float f22 = max(1.0/(1.0+32.0*pow(length(uvd+0.85*pos),2.0)),.0)*00.23;
	float f23 = max(1.0/(1.0+32.0*pow(length(uvd+0.9*pos),2.0)),.0)*00.21;
	
	vec2 uvx = mix(uv,uvd,-0.5);
	
	float f4 = max(0.01-pow(length(uvx+0.4*pos),2.4),.0)*6.0;
	float f42 = max(0.01-pow(length(uvx+0.45*pos),2.4),.0)*5.0;
	float f43 = max(0.01-pow(length(uvx+0.5*pos),2.4),.0)*3.0;
	
	vec3 c = vec3(.0);
	
	c.r+=f2+f4; c.g+=f22+f42; c.b+=f23+f43;
	c = c*.5 - vec3(length(uvd)*.05);
	c+=vec3(f0);
	
	return c;
}

// -------------------------------------------------------
// Extracts bit b from the given number. (by Pol Jeremias)
// https://www.shadertoy.com/view/Xst3zX
// -------------------------------------------------------
float extract_bit(float n, float b)
{
	return floor(mod(floor(n / pow(2.0,floor(b))),2.0));   
}

// -------------------------------------------------------------------------
// Returns the pixel at uv in the given bit-packed sprite. (by Pol Jeremias)
// https://www.shadertoy.com/view/Xst3zX
// -------------------------------------------------------------------------
float sprite(float spr, vec2 size, vec2 uv)
{
    uv = floor(uv);
    //Calculate the bit to extract (x + y * width) (flipped on x-axis)
    float bit = (size.x-uv.x-1.0) + uv.y * size.x;
    
    //Clipping bound to remove garbage outside the sprite's boundaries.
    bool bounds = all(greaterThanEqual(uv,vec2(0)));
    bounds = bounds && all(lessThan(uv,size));
    
    return bounds ? extract_bit(spr, bit) : 0.0;
}

// --------------------------------------
// Prints a character. (by Pol Jeremias)
// https://www.shadertoy.com/view/Xst3zX
// --------------------------------------
float char(float ch, vec2 uv, inout vec2 cursor)
{
    float c = sprite(ch, CHAR_SIZE, 0.5 * (uv - cursor));
    cursor += vec2(CHAR_SPACING.x, 0.0);
    return c;
}

// ------------------------------------------
// Visualización de la información del juego
// ------------------------------------------

vec3 pintarIntegridadEstructural(vec3 fragColor, vec2 coordenada)
{
    vec3 color = fragColor;
    float x = coordenada.x * iResolution.y/iResolution.x;
    
    if (x > 0.9 && x < 0.93)
    {
	    vec4 danio = load(DANIO);
        float integridad = 0.5 - danio.x;
        if ((coordenada.y >= -0.5 && coordenada.y < integridad)
           || abs(coordenada.y) >= 0.5 && abs(coordenada.y) <= 0.51)
        {
            color.r = 0.5 - coordenada.y;
            color.g = coordenada.y + 0.5;
            color.b = 0.0;
        }
    }
    
    return color;
}

vec3 pintarDistanciaSalidaAnillo(vec3 fragColor, vec2 coordenada)
{
    vec3 color = fragColor;
    float x = coordenada.x * iResolution.y/iResolution.x;
    
    if (x < -0.9 && x > -0.93)
    {
	    vec4 posicion = load(POSICION);
        float y = posicion.z * 0.5 / RING_HEIGHT;
        if ((coordenada.y >= 0.0 && coordenada.y <= y) 
            || (coordenada.y <= 0.0 && coordenada.y >= y)
            || abs(coordenada.y) >= 0.5 && abs(coordenada.y) <= 0.51)
        {
            color.r = 2.0 * abs(coordenada.y);
            color.g = 1.0 - abs(coordenada.y) * 2.0;
            color.b = 0.0;
        }
    }
    
    return color;
}

float obtenerDigito(inout float distancia)
{
    float valorDigito = floor(fract(distancia) * 10.0);
    distancia *= 0.1;
    
    if (valorDigito == 1.0)
    {
        return ch_1;
    }
    else if (valorDigito == 2.0)
    {
        return ch_2;
    }
    else if (valorDigito == 3.0)
    {
        return ch_3;
    }
    else if (valorDigito == 4.0)
    {
        return ch_4;
    }
    else if (valorDigito == 5.0)
    {
        return ch_5;
    }
    else if (valorDigito == 6.0)
    {
        return ch_6;
    }
    else if (valorDigito == 7.0)
    {
        return ch_7;
    }
    else if (valorDigito == 8.0)
    {
        return ch_8;
    }
    else if (valorDigito == 9.0)
    {
        return ch_9;
    }
    else
    {
        return ch_0;
    }
}

vec3 pintarPuntuacion(vec3 fragColor, vec2 coordenada)
{
    float tamanio = 1.0;
    vec2 cursor = tamanio * vec2(0.0 + STRWIDTH(1.0), iResolution.y - STRHEIGHT(1.5));
    vec2 fragCoord = floor(coordenada * tamanio);
    
    vec4 posicion = load(POSICION);
    float distancia = 23008.4 - (distance(vec3(0.0, 0.0, 0.0), vec3(posicion)) * 10.0);
    float digito6 = obtenerDigito(distancia);
    float digito5 = obtenerDigito(distancia);
    float digito4 = obtenerDigito(distancia);
    float digito3 = obtenerDigito(distancia);
    float digito2 = obtenerDigito(distancia);
    float digito1 = obtenerDigito(distancia);

    float color = (char(digito1, fragCoord, cursor) + char(digito2, fragCoord, cursor) +
           char(digito3, fragCoord, cursor) + char(digito4, fragCoord, cursor) +
           char(digito5, fragCoord, cursor) + char(digito6, fragCoord, cursor));
    
    if (color > 0.0)
    {
        return vec3(color);
    }
    else
    {
        return vec3(fragColor);
    }
}

vec3 pintarGameOver(vec3 fragColor, vec2 coordenada)
{
    float tamanio = 0.25;
    vec2 cursor = tamanio * vec2(0.0 + STRWIDTH(21.0), iResolution.y - STRHEIGHT(16.0));
    vec2 fragCoord = floor(coordenada * tamanio);
    
    float color = (char(ch_g, fragCoord, cursor) + char(ch_a, fragCoord, cursor) +
           char(ch_m, fragCoord, cursor) + char(ch_e, fragCoord, cursor) +
           char(ch_sp, fragCoord, cursor) + char(ch_o, fragCoord, cursor) +
           char(ch_v, fragCoord, cursor) + char(ch_e, fragCoord, cursor) +
           char(ch_r, fragCoord, cursor));
    
    if (color > 0.0)
    {
        return vec3(color);
    }
    else
    {
        return vec3(fragColor);
    }
}


vec3 pintarCentro(vec3 fragColor, vec2 coordenada)
{
    vec3 color = fragColor;
    vec2 centro = vec2(0.0,0.0);
    
    if (distance(coordenada, centro) < 0.01)
    {
        color = vec3(1.0, 1.0, 0.0);
    }
    
    return color;
}

//---------------------
// Juego Asteroid game
//---------------------

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float proporcion = iResolution.x/iResolution.y;
    
    vec2 p = -1.0 + 2.0 * (fragCoord.xy) / iResolution.xy;
    p.x *= proporcion;
    
    // Se sitúa y orienta la nave (cámara)
    vec3 ro = vec3(load(POSICION));
    vec3 ta = vec3(load(TA));
    vec3 up = vec3(load(UP));

    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,up) );
    vec3 vv = normalize( cross(uu,ww));
    vec3 rd = normalize( -p.x*uu + p.y*vv + 2.2*ww );

    // Se pintan las estrellas
    float maxd = MAX;  
    vec3 col = renderStars( rd ).xyz;

    // Se pinta el planeta
    vec4 planet = renderPlanet( ro, rd, up, maxd );       
    if( planet.w > 0. ) col.xyz = planet.xyz;

    // Se pinta el efecto atmosférico del planeta
    float atmosphered = maxd;
    vec4 atmosphere = .85*renderAtmospheric( ro, rd, atmosphered );
    col = col * (1.-atmosphere.w ) + atmosphere.xyz; 

    // Se pinta el anillo de asteroides
    time = mod( iGlobalTime, 50. );
    vec4 ring = renderRing( ro, rd, maxd );
    col = col * (1.-ring.w ) + ring.xyz;

    // Se realiza el post-procesado de la imagen (lens flare)
    col = pow( clamp(col,0.0,1.0), vec3(0.4545) );
    col *= vec3(1.,0.99,0.95);   
    col = clamp(1.06*col-0.03, 0., 1.);      

    vec2 sunuv =  2.7*vec2( dot( SUN_DIRECTION, -uu ), dot( SUN_DIRECTION, vv ) );
    float flare = dot( SUN_DIRECTION, normalize(ta-ro) );
    col += vec3(1.4,1.2,1.0)*lensFlare(p, sunuv)*clamp( flare+.3, 0., 1.);

    // Se visualizan las colisiones
    vec4 colision = load(COLISION);
    
    if (colision.x > 0.0)
    {
        col += vec3(0.9, 0.0, 0.0);
    }
    
    // Se visualiza la información del juego
    if (iGlobalTime > 13.0)
    {
	    col = pintarIntegridadEstructural(col, p);
        col = pintarDistanciaSalidaAnillo(col, p);
        col = pintarPuntuacion(col, fragCoord);
        
        vec4 gameOver = load(GAME_OVER);
        if (gameOver.x > 0.5)
        {
            col = pintarGameOver(col, fragCoord);
        }
        
        col = pintarCentro(col, p);
    }
    
    fragColor = vec4( col ,1.0);
}