// Shader downloaded from https://www.shadertoy.com/view/lstSD7
// written by shadertoy user acterhd
//
// Name: Global Illumination 2.3.2
// Description: I trying caustics and reflected light with direct sampling.
//    Update 24.04.2016
//    
// Simple path tracer. Created by Reinder Nijhoff 2014
// @reindernijhoff
//
// https://www.shadertoy.com/view/4tl3z4
//

// ReMake:
// Path Tracer v2 by acterhd


//Параметры трассировки
#define EYEPATHLENGTH 4
#define LIGHTPATHLENGTH 4
#define SAMPLES 8

//Количество проб на попадание к свету (по сути ранк)
#define LIGHTPROBES 8 

#define DOF
#define MOTIONBLUR
#define MOTIONBLURFPS 12.

#define ANIMATENOISE
#define SHOWSPLITLINE

//Цвета
#define LIGHTCOLOR vec3(16.86, 10.76, 8.2)*4.0
#define WHITECOLOR vec3(.7295, .7355, .729)*0.7
#define GREENCOLOR vec3(.117, .4125, .115)*0.7
#define REDCOLOR vec3(.611, .0555, .062)*0.7

//Не рекомендую отключать, так как тесты не проводились
#define FULLBOX

// Виды сцен (по умолчанию мокрый пол)
// БУДТЕ БДИТЕЛЬНЫ! С Каустикой есть баги. Она может быть не достаточно яркая. А может быть я ошибаюсь и мне кажется. :)
#define REFRACTIVE

//Константы
#define eps 0.001


//Рандом

vec2 seed;

highp float rand(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

float hash1() {
    float rnd = rand(seed);
    seed += 0.1;
    return rnd;
}

vec2 hash2() {
    float rnd = rand(seed);
    seed += 0.1;
    float rnd2 = rand(seed);
    seed += 0.1;
    return vec2(rnd, rnd2);
}

vec3 hash3() {
    float rnd = rand(seed);
    seed += 0.1;
    float rnd2 = rand(seed);
    seed += 0.1;
    float rnd3 = rand(seed);
    seed += 0.1;
    return vec3(rnd, rnd2, rnd3);
}


// Геометрические фигуры

vec3 nSphere( in vec3 pos, in vec4 sph ) {
    return (pos-sph.xyz)/sph.w;
}

float iSphere( in vec3 ro, in vec3 rd, in vec4 sph ) {
    vec3 oc = ro - sph.xyz;
    float b = dot(oc, rd);
    float c = dot(oc, oc) - sph.w * sph.w;
    float h = b * b - c;
    if (h < 0.0) return -1.0;

	float s = sqrt(h);
	float t1 = -b - s;
	float t2 = -b + s;

	return t1 < 0.0 ? t2 : t1;
}

vec3 nPlane( in vec3 ro, in vec4 obj ) {
    return obj.xyz;
}

float iPlane( in vec3 ro, in vec3 rd, in vec4 pla ) {
    return (-pla.w - dot(pla.xyz,ro)) / dot( pla.xyz, rd );
}

float sdPlane( vec3 p, vec4 n )
{
    return dot(p,n.xyz) + n.w;
}


// Рандомный вектор

vec3 cosWeightedRandomHemisphereDirection( const vec3 n ) {
  	vec2 r = hash2();

	vec3  uu = normalize( cross( n, vec3(0.0,1.0,1.0) ) );
	vec3  vv = cross( uu, n );

	float ra = sqrt(r.y);
	float rx = ra*cos(6.2831*r.x);
	float ry = ra*sin(6.2831*r.x);
	float rz = sqrt( 1.0-r.y );
	vec3  rr = vec3( rx*uu + ry*vv + rz*n );

    return normalize( rr );
}

vec3 randomSphereDirection() {
    vec2 r = hash2()*6.2831;
	vec3 dr=vec3(sin(r.x)*vec2(sin(r.y),cos(r.y)),cos(r.x));
	return normalize(dr);
}

vec3 randomHemisphereDirection( const vec3 n ) {
	vec3 dr = randomSphereDirection();
	return normalize(dot(dr,n) * dr);
}


// Источник света

vec4 lightSphere;

void initLightSphere( float time ) {
	lightSphere = vec4( 3.0+2.*sin(time),2.8+2.*sin(time*0.9),3.0+4.*cos(time*0.7), 0.5 );
}

vec3 sampleLight() {
    vec3 n = randomSphereDirection() * (lightSphere.w);
    return lightSphere.xyz + n;
}


// Вся сцена

void _intersect(in vec3 ro, in vec3 rd, inout vec3 normal, inout vec2 res, inout float t){
#ifdef REFRACTIVE
 	t = iPlane( ro, rd, vec4( 0.0, 1.0, 0.0,0.0 ) ); if( t>eps && t<res.x ) { res = vec2( t, 1. ); normal = vec3( 0., 1., 0.); }
#else 
    t = iPlane( ro, rd, vec4( 0.0, 1.0, 0.0,0.0 ) ); if( t>eps && t<res.x ) { res = vec2( t, 6. ); normal = vec3( 0., 1., 0.); }
#endif
	t = iPlane( ro, rd, vec4( 0.0, 0.0,-1.0,8.0 ) ); if( t>eps && t<res.x ) { res = vec2( t, 1. ); normal = vec3( 0., 0.,-1.); }
    t = iPlane( ro, rd, vec4( 1.0, 0.0, 0.0,0.0 ) ); if( t>eps && t<res.x ) { res = vec2( t, 2. ); normal = vec3( 1., 0., 0.); }
#ifdef FULLBOX
    t = iPlane( ro, rd, vec4( 0.0,-1.0, 0.0,5.49) ); if( t>eps && t<res.x ) { res = vec2( t, 1. ); normal = vec3( 0., -1., 0.); }
    t = iPlane( ro, rd, vec4(-1.0, 0.0, 0.0,5.59) ); if( t>eps && t<res.x ) { res = vec2( t, 3. ); normal = vec3(-1., 0., 0.); }
#endif
	t = iSphere( ro, rd, vec4( 1.5,1.0, 2.7, 1.0) ); if( t>eps && t<res.x ) { res = vec2( t, 1. ); normal = nSphere( ro+t*rd, vec4( 1.5,1.0, 2.7,1.0) ); }
#ifdef REFRACTIVE
    t = iSphere( ro, rd, vec4( 4.0,1.0, 4.0, 1.0) ); if( t>eps && t<res.x ) { res = vec2( t, 6. ); normal = nSphere( ro+t*rd, vec4( 4.0,1.0, 4.0,1.0) ); }
#else 
    t = iSphere( ro, rd, vec4( 4.0,1.0, 4.0, 1.0) ); if( t>eps && t<res.x ) { res = vec2( t, 1. ); normal = nSphere( ro+t*rd, vec4( 4.0,1.0, 4.0,1.0) ); }
#endif
}

vec2 intersectDirect( in vec3 ro, in vec3 rd, inout vec3 normal ) {
	vec2 res = vec2( 1e20, -1.0 );
    float t;

	_intersect(ro, rd, normal, res, t);
    return res;
}

vec2 intersect( in vec3 ro, in vec3 rd, inout vec3 normal ) {
	vec2 res = vec2( 1e20, -1.0 );
    float t;

	_intersect(ro, rd, normal, res, t);
    t = iSphere( ro, rd, lightSphere ); if( t>eps && t<res.x ) { res = vec2( t, 0.0 );  normal = nSphere( ro+t*rd, lightSphere ); }

    return res;
}


// Материалы

vec3 matColor( const in float mat ) {
#ifdef REFRACTIVE
	vec3 nor = vec3(1.0, 1.0, 1.0);
#else 
    vec3 nor = vec3(1.0, 1.0, 1.0);
#endif
    
	if( mat<3.5 ) nor = REDCOLOR;
    if( mat<2.5 ) nor = GREENCOLOR;
	if( mat<1.5 ) nor = WHITECOLOR;
	if( mat<0.5 ) nor = LIGHTCOLOR;

    return nor;
}

bool matIsSpecular( const in float mat ) {
    return mat > 4.5;
}

bool matIsLight( const in float mat ) {
    return mat < 0.5;
}


// Структура пути света

struct LightPath {
    vec3 normal;
    vec3 position;
    vec3 direct;
    vec3 indirect;
    float dist;
    float coef;
    float ior;
    int type;
};
 
LightPath lightPath[6];
LightPath getLightPath(in int index){
    if(index == 1) return lightPath[1];
    if(index == 2) return lightPath[2];
    if(index == 3) return lightPath[3];
    if(index == 4) return lightPath[4];
    if(index == 5) return lightPath[5];
    return lightPath[0];
}


// Получения луча с поверхности

vec3 getBRDFRay( inout vec3 n, const in vec3 rd, const in float m, inout bool specularBounce) {
    specularBounce = false;

    vec3 r = cosWeightedRandomHemisphereDirection( n );
    if(  !matIsSpecular( m ) ) {
        return r;
    } else {
        specularBounce = true;

        float n1, n2, ndotr = dot(rd,n);

        if( ndotr > 0. ) {
            n1 = 1.; n2 = 1.3333;
            n = -n;
        } else {
            n2 = 1.; n1 = 1.3333;
        }

        float r0 = (n1-n2)/(n1+n2); r0 *= r0;
		float fresnel = r0 + (1.-r0) * pow(1.0-abs(ndotr),5.);

        vec3 ref;
#ifdef REFRACTIVE
        ref = normalize(refract( rd, n, n2/n1 ));
        //ref = reflect(rd, n);
#else
        ref = normalize(reflect(rd, n));
#endif
        
        return ref;
	}
}


// Функция для вращения точки относительно нулевой оси

mat4 rotationMatrix(vec3 axis, float angle)
{
    axis = normalize(axis);
    float s = sin(angle);
    float c = cos(angle);
    float oc = 1.0 - c;

    return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
                oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
                oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
                0.0,                                0.0,                                0.0,                                1.0);
}

vec3 rotatePoint(vec3 u, vec3 v, vec3 p){
	float cos_theta = dot(normalize(u), normalize(v));
    if(cos_theta > 0.9999){
        return p;
    } else 
    if(cos_theta < -0.9999){
        return -p;
    } else {
        float angle = acos(cos_theta);
     	vec3 w = normalize(cross(u, v));
        return (rotationMatrix(w, angle) * vec4(p, 1.0)).xyz;   
    }
    return p;
}


// Функция для трассировки света

bool traceLight( in vec3 ro, in vec3 rd, inout int bounces ) {
    bool specularBounce = true;
    bounces = 1;
    
    LightPath lp;
    lp.direct = rd;
    lp.indirect = rd;
    lp.normal = vec3(0.0);
    lp.position = ro;
    lightPath[0] = lp;
    
    for(int i=1;i<LIGHTPATHLENGTH+1;i++){
    	LightPath lp;
        lp.indirect = vec3(0.0);
        lp.dist = 0.0;
        lp.direct = vec3(0.0);
        lp.normal = vec3(0.0);
        lp.position = vec3(0.0);
        lightPath[i] = lp;
    }
    
    for(int i=1;i<LIGHTPATHLENGTH+1;i++){
        vec3 normal;
        vec2 res = intersectDirect( ro, rd, normal );
        vec3 ind = rd;
        ro = ro + res.x * rd;
        rd = getBRDFRay( normal, rd, res.y, specularBounce );
        
        LightPath lp;
        lp.indirect = ind;
        lp.dist = res.x;
        lp.direct = rd;
        lp.normal = normal;
        lp.position = ro;
        lightPath[i] = lp;
        
        if(!specularBounce) { //Если это диффуз то прекратить трассировку света
            break;
            return false;
        }
        bounces++;
    }

    return true;
}

// Функция для установления виртуальной точки света

vec3 reflection(in vec3 point, in int bounces){
    LightPath path = getLightPath(0);
	vec3 rdirect = path.direct;
    vec3 rpoint = point;
    vec3 ddirect = path.direct;
    vec3 dpoint = path.position;
    for(int i=1;i<10;i++){
		vec3 rlpoint = rpoint - dpoint;
        rpoint = dpoint + rotatePoint(ddirect, rdirect, rlpoint);
        
        if(i >= bounces) break;
        
        LightPath path = getLightPath(i);
        dpoint = path.position;
        ddirect = path.direct;
    }
    return rpoint;
}

 
LightPath shadowPath[6];
LightPath getShadowPath(in int index){
    if(index == 1) return shadowPath[1];
    if(index == 2) return shadowPath[2];
    if(index == 3) return shadowPath[3];
    if(index == 4) return shadowPath[4];
    if(index == 5) return shadowPath[5];
    return shadowPath[0];
}


// Функция теневой трассировки к свету

float rayPointDistance(vec3 point, vec3 origin, vec3 direct){
	return length(cross(direct, point - origin));
}

bool intersectShadow( in vec3 _ro, in vec3 _rd, in vec3 _light, inout vec3 lcolor, in int _bounces, inout int obounces) {
    bool specularBounce = true;
    
    vec3 ro = _ro;
    vec3 rd = _rd;
    vec3 light = _light;
    int bounces = _bounces;
    
    obounces = 1;
    lcolor = vec3(1.0);
    LightPath lp;
    lp.direct = rd;
    lp.indirect = rd;
    lp.normal = vec3(0.0);
    lp.position = ro;
    shadowPath[0] = lp;
    
    
    for(int i=1;i<LIGHTPATHLENGTH+1;i++){
    	LightPath lp;
        lp.indirect = vec3(0.0);
        lp.dist = 0.0;
        lp.direct = vec3(0.0);
        lp.normal = vec3(0.0);
        lp.position = vec3(0.0);
        shadowPath[i] = lp;
    }

    for(int i=1;i<LIGHTPATHLENGTH+1;i++){
        vec3 normal;
        vec2 res = intersect( ro, rd, normal );
        vec3 ind = rd;
        vec3 ino = ro;
        ro = ro + res.x * rd;
		rd = getBRDFRay( normal, rd, res.y, specularBounce );
        
        
        LightPath lp;
        lp.indirect = ind;
        lp.dist = res.x;
        lp.direct = rd;
        lp.normal = normal;
        lp.position = ro;
        shadowPath[i] = lp;
        
        lcolor *= matColor( res.y );
        if( 
            matIsLight( res.y ) 
            && rayPointDistance(light, ino, ind) < 0.1
        ) { //Если свет, то вернуть значение освещенности
            return true;
        }
    	if(!specularBounce || i > bounces) { //Закончить трассировку если диффуз или превышено число скачков
            return false;
        }
        
        obounces++;
    }
    
    return false;
}



vec3 refShadow(in vec3 point, in int bounces){
    LightPath path = getShadowPath(bounces);
	vec3 rdirect = -path.indirect;
    vec3 rpoint = point;
    vec3 ddirect = -path.indirect;
    vec3 dpoint = path.position;
    for(int i=1;i<10;i++){
		vec3 rlpoint = rpoint - dpoint;
        rpoint = dpoint + rotatePoint(ddirect, rdirect, rlpoint);
        
        if(i >= bounces) break;
        
        LightPath path = getShadowPath(bounces - i);
        dpoint = path.position;
        ddirect = -path.indirect;
    }
    return rpoint;
}




// Трассировка пути с прямым освещением

vec3 traceEyePath( in vec3 ro, in vec3 rd, const in bool directLightSampling ) {
    vec3 tcol = vec3(0.);
    vec3 fcol = vec3(1.);

    //Подготовиться к трассировке света
    vec3 olight = sampleLight( );
    vec3 ocenter = lightSphere.xyz;
    vec3 ldir = cosWeightedRandomHemisphereDirection(normalize(olight - ocenter));
    
    //Трассировка света и получения виртуальной точки
    int bounces = 1;
    traceLight(olight, ldir, bounces);
    vec3 light = reflection(olight, bounces);
    vec3 center = reflection(ocenter, bounces);
    
    for( int j=0; j<EYEPATHLENGTH; ++j ) {
        vec3 normal;
		bool specularBounce = true;
        
        //Нахождение пересечения
        vec2 res;
        if(directLightSampling){
            res = intersectDirect( ro, rd, normal );
        } else {
            res = intersect( ro, rd, normal );
        }
        if( res.y < -0.5 ) {
            return tcol;
        }
        
        //Установление луча
        ro = ro + res.x * rd;
        rd = getBRDFRay( normal, rd, res.y, specularBounce );
		fcol *= matColor( res.y );
        
        //Если обычный патч трейсинг, то завершить на источнике света
       	if( matIsLight( res.y ) && !directLightSampling ) {
            tcol += fcol;
            return tcol;
        }
		
        //Если есть прямое освещение и это не диэлектрик, то провести сэмплинг прямого света
        if(directLightSampling && !specularBounce){
            vec3 rlight = light;
            vec3 rcenter = center;
            vec3 nld = normalize(rlight - ro);
            int ibounces = bounces;
            vec3 rcol = vec3(0.0);
			int rcon = 0;

            for(int i=0;i<LIGHTPROBES;i++){
                int obounces = 1;
                vec3 lcolor = vec3(1.0);
                
                if(intersectShadow( ro, nld, olight, lcolor, ibounces, obounces)) {
                    rcenter = refShadow(ocenter, obounces);
                    float cos_a_max = sqrt(1. - clamp(lightSphere.w * lightSphere.w / dot(rcenter-ro, rcenter-ro), 0., 1.));
                    float weight = 2. * (1. - cos_a_max);
                    rcol = clamp((fcol * lcolor) * (weight * clamp(dot( nld, normal ), 0., 1.)), 0., 1.);
                }
                
                rlight = refShadow(olight, obounces);
                rcenter = refShadow(ocenter, obounces);
                if(
                    obounces != ibounces+1 || 
                    rayPointDistance(rlight, ro, nld) < 0.01
                ) {
                    break;
                }
                nld = normalize(rlight - ro);
                
            }

            tcol += clamp(rcol / max(float(rcon), 1.0), 0., 1.);
        }
    }
    return tcol;
}


// Основная программа

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
    seed = fragCoord.xy + iGlobalTime / 1000.0;

	vec2 q = fragCoord.xy / iResolution.xy;

	float splitCoord = (iMouse.x == 0.0) ? iResolution.x/2. + iResolution.x*cos(iGlobalTime*1.0) : iMouse.x;
    bool directLightSampling = fragCoord.x < splitCoord;

    vec2 p = -1.0 + 2.0 * (fragCoord.xy) / iResolution.xy;
    p.x *= iResolution.x/iResolution.y;

    vec3 ro = vec3(2.78, 2.73, -8.00);
    vec3 ta = vec3(2.78, 2.73,  0.00);
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));

    vec3 col = vec3(0.0);
    vec3 tot = vec3(0.0);
    vec3 uvw = vec3(0.0);

    for( int a=0; a<SAMPLES; a++ ) {

        vec2 rpof = 4.*(hash2()-vec2(0.5)) / iResolution.xy;
	    vec3 rd = normalize( (p.x+rpof.x)*uu + (p.y+rpof.y)*vv + 3.0*ww );

#ifdef DOF
	    vec3 fp = ro + rd * 12.0;
   		vec3 rof = ro + (uu*(hash1()-0.5) + vv*(hash1()-0.5))*0.125;
    	rd = normalize( fp - rof );
#else
        vec3 rof = ro;
#endif

        initLightSphere( iGlobalTime );
		//initLightSphere( 549.3 );
        
        col = traceEyePath( rof, rd, directLightSampling );
        tot += col;
        seed = mod( seed*1.1234567893490423, 13. );
    }
    tot /= float(SAMPLES);

#ifdef SHOWSPLITLINE
	if (abs(fragCoord.x - splitCoord) < 1.0) {
		tot.x = 1.0;
	}
#endif

	tot = pow( clamp(tot,0.0,1.0), vec3(0.45) );

    fragColor = vec4( tot, 1.0 );
}