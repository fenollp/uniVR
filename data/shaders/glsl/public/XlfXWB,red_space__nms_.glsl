// Shader downloaded from https://www.shadertoy.com/view/XlfXWB
// written by shadertoy user mech4rhork
//
// Name: Red Space (NMS)
// Description: No Man's Sky inspired
#define PI				3.14159265359

#define GAMMA 			2.2
#define time			vec4( iGlobalTime*.125, iGlobalTime*.25, iGlobalTime*1., iGlobalTime*5. )
#define mouse 			vec2( iMouse.xy / iResolution.xy )
#define MAX_ITERATIONS	97
#define RENDER_INTERVAL	vec2( 0.1, 11000.0 )

#define MATERIAL_01		1.0
#define MATERIAL_02		2.0
#define MATERIAL_03		3.0
#define MATERIAL_04		4.0
#define MATERIAL_05		5.0
#define MATERIAL_06		6.0
#define MATERIAL_07 	7.0

#define SHADOWS
//#define SPACE_STATION
//#define FREIGHTER
//#define PLANET

//#define ASTEROID_FIELD // TODO


const float startDelta = RENDER_INTERVAL.x;
const float stopDelta = RENDER_INTERVAL.y;

// ________
// |||||||| gamma correction
vec3 toGamma( vec3 col ) {
	return pow( col, vec3( 1.0 / GAMMA ) );
}

// ________
// |||||||| transformations
mat3 rotate( mat3 mat, vec3 theta ) {
    float sx = sin( theta.x ), sy = sin( theta.y ), sz = sin( theta.z ),
        cx = cos( theta.x ), cy = cos( theta.y ), cz = cos( theta.z );
	return mat *
        mat3( 1.0, 0.0, 0.0, 0.0, cx, -sin( theta.x ), 0.0, sx, cx ) *
        mat3( cy, 0.0, sy, 0.0, 1.0, 0.0, -sy, 0.0, cy ) *
        mat3( cz, -sz, 0.0, sz, cz, 0.0, 0.0, 0.0, 1.0 );
}
vec3 rotate( vec3 p, vec3 theta ) {
    float  cx = cos( theta.x ), sx = sin( theta.x ), cy = cos( theta.y ),
        sy = sin( theta.y ), cz = cos( theta.z ), sz = sin( theta.z );
    p.yz *= mat2( cx, -sx, sx, cx ); p.xz *= mat2( cy, -sy, sy, cy ); p.xy *= mat2( cz, -sz, sz, cz );
    return p;
}

// ________
// |||||||| noise
// by Dave_Hoskins
float hash(float p) {
	vec2 p2 = fract(vec2(p) * vec2(443.8975,397.2973));
    p2 += dot(p2.yx, p2.xy+19.19);
	return fract(p2.x * p2.y);
}
// by iq
float noise( in vec3 x ) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*157.0 + 113.0*p.z;
    return mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                   mix( hash(n+157.0), hash(n+158.0),f.x),f.y),
               mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                   mix( hash(n+270.0), hash(n+271.0),f.x),f.y),f.z);
}
float fbm( vec3 p, vec3 scale, vec3 offset ) {
    const mat3 m = mat3( 0.00,  0.80,  0.60, -0.80,  0.36, -0.48, -0.60, -0.48,  0.64 );
    vec3 q = scale*p + offset;
    float f = 0.0;
   	f  = 0.5000*noise( q ); q = m*q*2.01;
   	f += 0.2500*noise( q ); q = m*q*2.02;
   	f += 0.1250*noise( q ); q = m*q*2.03;
   	f += 0.0625*noise( q ); q = m*q*2.01;
	return f;
}

// ________
// |||||||| primitives - from iq
float sdPlane( vec3 p, vec4 n ) {
    n = normalize( n );
    return dot( p, n.xyz ) + n.w;
}
float sdBox( vec3 p, vec3 b ) {
	vec3 d = abs( p ) - b;
  	return min( max( d.x, max( d.y, d.z ) ), 0.0 ) + length( max( d, 0.0 ) );
}
float sdSphere( vec3 p, float s ) {
    return length( p ) - s;
}
float sdHexPrism( vec3 p, vec2 h ) {
    vec3 q = abs( p );
    float d1 = q.z - h.y;
    float d2 = max( ( q.x * 0.866025 + q.y * 0.5 ), q.y ) - h.x;
    return length( max( vec2( d1, d2), 0.0 ) ) + min( max( d1, d2 ), 0.0 );
}
float sdTriPrism( vec3 p, vec2 h ) {
    vec3 q = abs( p );
    float d1 = q.z - h.y;
    float d2 = max( q.x * 0.866025 + p.y * 0.5, - p.y ) - h.x * 0.5;
    return length( max( vec2( d1, d2 ),0.0 ) ) + min( max( d1, d2 ), 0.0 );
}
float sdCone( vec3 p, vec3 c ) {
    vec2 q = vec2( length( p.xz ), p.y );
    float d1 = -p.y - c.z;
    float d2 = max( dot( q, c.xy ), p.y );
    return length( max( vec2( d1, d2 ), 0.0 ) ) + min( max( d1, d2 ), 0.0 );
}

float sdTorus( vec3 p, vec2 t ) {
    return length( vec2( length( p.xz ) - t.x, p.y ) ) - t.y;
}
// ----
vec2 opS( vec2 d1, vec2 d2 ) {
    return ( -d2.x > d1.x ) ? vec2( -d2.x, d2.y ) : d1;
}
vec2 opU( vec2 d1, vec2 d2 ) {
	return ( d1.x < d2.x ) ? d1 : d2;
}
vec2 opI( vec2 d1, vec2 d2 ) {
	return ( d1.x > d2.x ) ? d1 : d2;
}
// ----
vec2 udPyramid( vec3 p, vec2 s ) {
    vec3 e = vec3( abs( p.x ), p.y, abs( p.z ) ) - vec3( 0.0, -s.x, 0.0 );
    vec3 up = vec3( 0.0, 1.0, 0.0 );
    float an = PI/4.0 * s.y * 0.05;
    vec2 d = vec2( sdPlane( e - vec3( 0.0, -2.0 * s.x, 0.0 ), vec4( rotate( up, vec3( 0.0, 0.0, PI ) ), 1.0 ) ), 7.1 );   
   	d = opI(d, vec2(
            sdPlane( e, vec4( rotate( up, vec3( an, 0.0, 0.0 ) ), 1.0 ) ),
            7.1 ) );
    d = opI(d, vec2(
            sdPlane( e, vec4( rotate( up, vec3( 0.0, 0.0, -an ) ), 1.0 ) ),
            7.1 ) );
    d = opI(d, vec2(
            sdPlane( e - vec3( 0.0, -2.0 * s.x, 0.0 ), vec4( rotate( up, vec3( 0.0, 0.0, PI ) ), 1.0 ) ),
            7.1 ) );   
    return d;
}
vec2 udPyramid2( vec3 p, vec2 s ) {    
    vec3 e = vec3( abs( p.x ), p.y, abs( p.z ) ) - vec3( 0.0, -s.x, 0.0 );
    vec3 up = vec3( 0.0, -1.0, 0.0 );
    float an = ( -PI/2.0 + PI/4.0 ) * s.y * 0.05;
    vec2 d = vec2(
        sdPlane( e - vec3( 0.0, 2.0 * s.x, 0.0 ), vec4( rotate( up, vec3( 0.0, 0.0, PI ) ), 1.0 ) ),
        7.1 );
   	d = opI(d, vec2(
            sdPlane( e, vec4( rotate( up, vec3( an, 0.0, 0.0 ) ), 1.0 ) ),
            7.1 ) );
    d = opI(d, vec2(
            sdPlane( e, vec4( rotate( up, vec3( 0.0, 0.0, -an ) ), 1.0 ) ),
            7.1 ) );
    return d;
}
vec2 sdCockpit( vec3 p ) {
    vec2 d = vec2( 1e10, -100.0 );
 	vec3 s;
    //vec2 handle = 2.0 * mouse - 1.0;
    
    s = vec3( abs( p.x ), p.yz );
    d = opU( d, vec2(
        sdBox( rotate( s - vec3( 1.75, 0.0, 2.4 ), vec3( PI/6.0, 0.0, PI/6.5 ) ), vec3( 0.08, 2.0, 0.09 ) ),
        3.1 ) );
    d = opS( d, vec2(
        sdBox( rotate( s - vec3( 1.68, 0.044, 2.383 ), vec3( PI/6.0, 0.0, PI/6.5 ) ), vec3( 0.04, 1.9, 0.045 ) ),
        3.1 ) );
    
    d = opU( d, vec2(
        sdBox( rotate( s - vec3( 1.66, -2.2, 2.5 ), vec3( 0.0, -PI/7.0, 0.0 ) ), vec3( 0.25, 0.9, 2.8 ) ),
        3.1 ) );
    d = opS( d, vec2(
        sdBox( rotate( s - vec3( 1.4, -1.07, 2.5 ), vec3( 0.0, -PI/7.0, 0.0 ) ), vec3( 0.3, 0.3, 2.8 ) ),
        3.1 ) );
    
    d = opU( d, vec2(
        sdBox( s - vec3( 0.0, 1.57, 1.57 ), vec3( 3.0, 0.1, 0.05 ) ),
        3.1 ) );
    d = opU( d, vec2(
        sdHexPrism( rotate( s - vec3( 1.0, -1.0, 2.85 ), vec3( PI/40.0, 0.0, 0.0 ) ), vec2( 0.5, 0.2 ) ),
        3.1 ) );
    d = opU( d, vec2(
        sdHexPrism( rotate( s - vec3( 0.0, -1.96, 2.8 ), vec3( -PI/32.0, 0.0, 0.0 ) ), vec2( 1.55, 0.33 ) ),
        3.1 ) );
    d = opU( d, vec2(
        sdBox( rotate( s - vec3( 2.2, 1.4, 1.91 ), vec3( -PI/6.0, 0.0, -PI/6.5 ) ), vec3( 0.05, 0.485, 0.03 ) ),
        3.1 ) );
    /*d = opU( d, vec2(
        sdBox( rotate( s - vec3( 1.65, -1.1, 2.92 ), vec3( -PI/6.0, -PI/20.0, -PI/8.0 ) ), vec3( 0.03, 0.6, 0.07 ) ),
        3.1 ) );*/
    d = opU( d, vec2(
        sdBox( rotate( s - vec3( 1.85, -1.15, 2.5), vec3( -PI/8.0, -PI/8.0, -PI/6.0 ) ), vec3( 0.03, 0.85, 0.08 ) ),
        3.1 ) );
    /*d = opU( d, vec2(
        sdBox( rotate( s - vec3( 2.0, -2.05, 0.27 ), vec3( -PI/6.0, PI/9.0, -PI/16.0 ) ), vec3( 0.1, 1.4, 1.1 ) ),
        3.1 ) );*/ // R
    d = opU( d, vec2(
        sdBox( rotate( s - vec3( 0.0, -3.2, 1.9 ), vec3( PI/4.0, 0.0, 0.0 ) ), vec3( 1.484, 1.2, 2.1 ) ),
        3.1 ) );
    
    // monitors
    d = opU( d, vec2(
        sdBox( rotate( s - vec3( 0.0, -1.13, 2.6 ), vec3( PI/4.0, 0.0, 0.0 ) ), vec3( 0.99, 0.3, 0.025 ) ),
        5.1 ) );
    d = opU( d, vec2(
        sdBox( rotate( s - vec3( 0.53, -1.42, 2.0 ), vec3( -PI/4.0, 0.0, 0.0 ) ), vec3( 0.47, 0.5, 0.05 ) ),
        6.1 ) );
    
    // top
    s = mod( vec3( abs( p.x * 1.33 ) - 0.2, p.yz - vec2( 0.1 * step( 0.99, abs( p.x ) ), 0.0 ) ), vec3( 2.0, 0.0, 0.0 ) ) - 0.15;
    d = opU( d, vec2(
        sdBox( rotate( s - vec3( 0.2, 1.39, 1.58 ), vec3( PI/4.0, 0.0, 0.0 ) ), vec3( 1.4, vec2( 0.1 ) ) ),
        3.1 ) );
    
    // buttons
    s = mod( vec3( abs( p.x * 6.0 ) - 0.88, p.yz - vec2( 0.5 * step( 0.99, abs( p.x ) ), 0.0 ) ), vec3( 2.0, 0.0, 0.0 ) ) - 0.074;
    d = opU( d, vec2(
        sdBox( rotate( s - vec3( 0.0, 1.41, 1.59 ), vec3( PI/4.0, 0.0, 0.0 ) ), vec3( 0.67, 0.06, 0.099 ) ),
        4.1 ) );
    
    return d;
}
vec2 sdFreighter( vec3 p ) {
    vec2 d = vec2( 1e10, -100.0 );
 	//vec3 s;
    vec2 handle = 2.0 * mouse - 1.0;
    
    /*d = opU( d, vec2(
        sdBox( p, vec3( 35.0, 15.0, 125.0 ) ),
        7.1 ) );*/
    p *= 1.1;
    d = opU( d, vec2(
        sdTriPrism( rotate( p * vec3( 0.5, 2.0, 1.0 ), vec3( PI, 0.0, 0.0 ) ), vec2( 23.0, 125.0 ) ),
        7.1 ) );
    d = opU( d, vec2(
        sdBox( p - vec3( 0.0, 10.0, 60.0 ), vec3( 20.0, 33.0, 20.0 ) ),
        7.1 ) );
    d = opU( d, vec2(
        sdBox( p - vec3( 0.0, 40.0, 60.0 ), vec3( 1.5, 30.0, 1.5 ) ),
        7.1 ) );
    
    return d;
}
vec2 sdSpaceStation( vec3 p ) {
    vec2 d = vec2( 1e10, -100.0 );
 	//vec3 s;
    //vec2 handle = 2.0 * mouse - 1.0;
    
    d = opU( d, udPyramid( p, vec2( 39.0, 24.0 ) ) );
    d = opU( d, udPyramid2( p - vec3( 0.0, -155.0, 0.0 ), vec2( 40.0, 24.75 ) ) );
    d = opU( d, vec2(
        sdSphere( p - vec3( 0.0, -69.5, 0.0 ), 26.8 ),
        7.1 ) );
    d = opU( d, vec2(
        sdSphere( p - vec3( 0.0, -45.5, 0.0 ), 10.6 ),
        7.1 ) );
    
    d = opS( d, vec2(
        sdBox( p - vec3( 0.0, -186.5, 0.0 ), vec3( 17.0 ) ),
        7.1 ) );
    
    d = opU( d, vec2(
        sdBox( p - vec3( 0.0, -169.5, 0.0 ), vec3( 13.8, 6.2, 13.8 ) ),
        7.1 ) );
    d = opU( d, vec2(
        sdBox( p - vec3( 0.0, -175.5, 0.0 ), vec3( 4.0, 15.0, 4.0 ) ),
        7.1 ) );
    
    return d;
}
vec2 sdAsteroidField( vec3 p ) { // TODO
    return vec2( 0.0 );
}

// ________
// |||||||| scene
vec2 map( vec3 p ) {
    vec2 d = vec2( 1e10, -100.0 );
    vec3 s;
    vec2 handle = mouse;
    
    // cockpit
    d = opU( d, sdCockpit( p ) );
    
    // space station
    #ifdef SPACE_STATION
    d = opU( d, sdSpaceStation( rotate( p - vec3( -79.0, 212.0, 428.0 ), vec3( -PI/15.0, -PI/2.9, -PI/7.2 ) ) ) );
    #endif
    
    // freighter
    #ifdef FREIGHTER
    d = opU( d, vec2( sdFreighter( rotate( p - vec3( 165.0, 85.0, 550.0 ), vec3( PI/6.5, PI/3.25, -PI/16.0 ) ) ) ) );
    #endif
    
    // planet
    #ifdef PLANET
    d = opU( d, vec2( sdSphere( p - vec3( 6900.0, 750.0, 7450.0 ), 950.0 ), 2.1 ) );
    #endif
        
    // asteroid field TODO
    #ifdef ASTEROID_FIELD
    // TODO
    #endif
    
    // debug
    /*d = opU( d, vec2(
        sdBox( rotate( p - vec3( -100.0, -180.0, 400.0 ), vec3( -PI/2.0, 0.0, 0.0 ) ), vec3( 50.0, 1200.0, 50.0 ) ), // TEST BOX
        1.1 ) );
    d = opU( d, vec2(
        sdBox( rotate( p - vec3( 100.0, -180.0, 400.0 ), vec3( 0.0, 0.0, 0.0 ) ), vec3( 20.0, 250.0, 20.0 ) ), // TEST BOX
        1.1 ) );
    d = opU( d, vec2(
        sdPlane( p - vec3( 0.0, -200.0, 0.0 ), vec4( 0.0, 1.0, 0.0, 1.0 ) ),
        1.1 ) );*/
    
    return d;
}

// ________
// |||||||| raymarching
vec2 castRay( vec3 ro, vec3 rd ) {
    vec2 delta = vec2( startDelta, -100.0 );
    float maxDist = 0.002;
    for( int i = 0; i < MAX_ITERATIONS; i++ ) {
        vec2 dist = map( ro + rd * delta.x );
        if( dist.x <= maxDist || dist.x > stopDelta ) break;
        delta = vec2( delta.x + dist.x, dist.y );
    }
    return delta;
}

vec3 calcNormal( vec3 pos, float delta ) {
    vec2 unit = vec2( 1.0, 0.0 );
    return normalize( vec3(
        map( pos + unit.xyy * delta ).x - map( pos - unit.xyy * delta ).x,
        map( pos + unit.yxy * delta ).x - map( pos - unit.yxy * delta ).x,
        map( pos + unit.yyx * delta ).x - map( pos - unit.yyx * delta ).x
    ) );
}

// from "Star Nest" by Kali  --  https://www.shadertoy.com/view/XlfGRj
// ------------------------------
// Copyright Pablo Román Andrioli
// ------------------------------
vec3 StarNest_by_Kali() {
    
    // parameters
    #define iterations 	15
	#define formuparam 	0.53
	#define volsteps 	11
	#define stepsize 	0.25
	#define zoom   		0.500
	#define tile   		0.850
	#define speed  		0.010 
	#define brightness 	0.0015
	#define darkmatter 	0.300
	#define distfading 	0.730
	#define saturation 	0.99
    
	//get coords and direction
	vec2 uv=gl_FragCoord.xy/iResolution.xy-.5;
	uv.y*=iResolution.y/iResolution.x;
	vec3 dir=vec3(uv*zoom,1.);

	//mouse rotation
	float a1=.5+0.7151277;
	float a2=.8+0.2445;
	mat2 rot1=mat2(cos(a1),sin(a1),-sin(a1),cos(a1));
	mat2 rot2=mat2(cos(a2),sin(a2),-sin(a2),cos(a2));
	dir.xz*=rot1;
	dir.xy*=rot2;
	vec3 from=vec3(0.0,0.0,100.5);
	from.xz*=rot1;
	from.xy*=rot2;
	
	//volumetric rendering
	float s=0.1,fade=1.;
	vec3 v=vec3(0.);
	for (int r=0; r<volsteps; r++) {
		vec3 p=from+s*dir*.5;
		p = abs(vec3(tile)-mod(p,vec3(tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		if (r>6) fade*=1.-dm; // dark matter, don't render near
		v+=fade;
		v+=vec3(s*s*s*s,s*s,s)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		s+=stepsize;  
	}
	v=mix(vec3(length(v)),v,saturation); //color adjust
	return vec3(v*.01);
}

float getFog( float dist ) {
    return 1.0 - exp( -dist * dist * 0.000003 );
}

vec3 getSkyColor( vec3 lig, vec3 rd ) {    
    vec3 uv = vec3( gl_FragCoord.xy / iResolution.xy, 10.335454 ) + vec3( -1.0, 0.05, 0.03 );
    
    vec3 red = vec3( 0.67, 0.02, 0.01 );
    vec3 color = red; // vec3( 0.89, 0.021, 0.02 ); // background
        
    float sun = 2.2 * pow( clamp( dot( rd, lig )*1.0055, 0.0, 1.0 ), 260.0 );
    float halo = 3.0 * pow( clamp( sqrt( dot( rd, lig ) ), 0.0, 1.0 ), 150.0 ); // 0.8 * pow( clamp( length( lig - rd ), 0.0, 1.0 ), 0.99 );
    vec3 stars = StarNest_by_Kali();
    
    // noise
    float n = fbm( uv, vec3( 8.6 ), vec3( 0.0 ) );
    n *= fbm( uv, vec3( 2.0, n*1.14, 5.0 ), vec3( n * 3.112 ) );
    float n2 = exp(-n*n*21.0);
    
    color *= 0.5 + n2;
    color = mix( color, stars * vec3( 1.0, 0.5, 0.6 ), n );
    color += 0.5 * red;
    color += 0.8 * halo + 0.4 * halo * red;
    color += sun * vec3( 0.94, 0.93, 0.85 );
    
    /*
    color *= vec3( n*n, 0.1 * n, n );
    //color += 0.033 * mix( stars, color, 1.0 - halo * 10.0 );
    color.gb *= n;
    color += sun * vec3( 0.94, 0.93, 0.81 );
    color += 0.95 * vec3( 0.89, 0.021, 0.02 ) * (0.77 + sun);*/
    
    //return vec3( exp(-n*n*25.0) * stars * vec3( 0.99, 0.025, 0.01 ) );
	return color;
}

// by iq
float calcSoftShadow( in vec3 ro, in vec3 rd, in float mint, in float tmax, in int samples ) {
	float res = 1.0;
    float t = mint;
    float stepDist = ( tmax - mint ) / float( samples );
    for( int i = 0; i < 32; i++ ) {
		float h = map( ro + rd * t ).x;
        res = min( res, 8.0 * h / t );
        t += clamp( h, stepDist, 1e10 );
        if( h < 0.001 || t > tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );
}
// by iq
float calcAO( in vec3 pos, in vec3 nor ) {
	float occ = 0.0;
    float sca = 1.0;
    for( int i = 0; i < 4; i++ ) {
        float hr = 0.01 + 0.03 * float( i );
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -( dd - hr ) * sca;
        sca *= 0.99;
    }
    return clamp( 1.0 - 4.0 * occ, 0.0, 1.0 );    
}
float calcSSS( in vec3 pos, in vec3 lig ) {
    float sss = 0.0;
    float sca = 1.0;
    for( int i = 0; i < 4; i++ ) {
        float delta = 0.01 + 0.03 * float( i );
        vec3 sspos = pos + lig * delta;
        float dist = map( sspos ).x;
        sss += -( dist - delta ) * sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 4.0*sss, 0.0, 1.0 );
}

// ________
// |||||||| rendering <_______________________________________________________________
vec3 render( vec3 ro, vec3 rd ) {
    vec3 color = vec3( 0.0 );
    
    vec2 res = castRay( ro, rd );
    float dist = res.x;
	float material = res.y;
    vec3 pos = ro + rd * dist;
    
    vec3 lightDir = normalize( vec3( 0.93, 0.5, 3.0 ) );
    vec3 lightColor = vec3( 1.0, 0.942, 0.77 );
    vec3 skyColor = getSkyColor( lightDir, rd );
    vec3 ambientColor = vec3( 0.89, 0.021, 0.02 );
    
    if( dist > stopDelta )
        return getSkyColor( lightDir, rd );
    else {
    	vec3 nor = calcNormal( pos, 0.001);
    
    	float dif = clamp( dot( nor, lightDir ), 0.0, 1.0 ), dif2;
    	float spe = pow( clamp( dot( reflect( -lightDir, nor ), -rd ), 0.0, 1.0 ), 10.0 );
    	float amb = 1.0;
    	float fre = pow( clamp( 1.0 + dot( nor, rd ), 0.0, 1.0 ), 5.0 );
        
        vec3 brdf = vec3( 0.0 );
        
        if( material - MATERIAL_01 < 0.5 ) { // MATERIAL : space station
            color = vec3( 0.27, 0.25, 0.34 ) * 0.4;
            //dif *= calcSoftShadow( pos, lightDir, 0.1, 10.0, 4 );
            
            brdf += 1.2 * dif * lightColor; // lambert
    		brdf += 1.2 * spe * lightColor * dif; // blinn phong
    		brdf += 0.1 * amb * ambientColor; // ambient
    		brdf += 1.0 * fre * lightColor; // fresnel schlick
            
            color *= brdf;
            color = mix( color, vec3( 0.89, 0.021, 0.02 ) * 100.0 / dist, getFog( dist ) ); // fog
        }
        
        else if( material - MATERIAL_02 < 0.5 ) { // MATERIAL : planet            
            float n = fbm( pos, vec3( 2.0, 10.0, 2.0 ) * 0.0006, vec3( -6.0 ) );
            n += 0.5 * fbm( vec3( n * pos.x, pos.y, n * pos.z ) * 0.0006, vec3( 5.0 ), vec3( 0.0 ) );
            
            color = vec3( n * n );
            nor = calcNormal( pos, 0.01);
            vec3 pll = vec3( -1.0, 0.5, 2.5 ); // planet light
            float dif2 = clamp( dot( nor, pll ), 0.0, 1.0 );
            fre += mix( fre, 0.7, step( 0.25, fre ) );
            
            brdf += 1.45 * dif2 * lightColor; // lambert
    		brdf += 1.9 * spe * lightColor * dif; // blinn phong
    		brdf += 0.2 * amb * ambientColor; // ambient
    		brdf += 1.4 * fre * vec3( 0.5, 1.0, 0.8 ) * lightColor; // fresnel schlick
            
            color *= brdf;
        }
        
        else if( material - MATERIAL_03 < 0.5 ) { // MATERIAL : cockpit
            color = vec3( 0.08 );
            vec3 cpl = vec3( 0.0, -1.0, -0.5 ); // cockpit light
            float dif2 = clamp( dot( nor, cpl ), 0.0, 1.0 );
            float occ = calcAO( pos, nor );
            #ifdef SHADOWS
            dif *= calcSoftShadow( pos, lightDir, 0.02, 1.0, 8 );
            #endif
            
            brdf += 1.9 * dif * lightColor; // lambert
    		brdf += 1.5 * spe * ambientColor * dif; // blinn phong
    		brdf += 0.2 * amb * ambientColor * occ; // ambient
    		brdf += 0.3 * fre * ambientColor * occ; // fresnel schlick
            brdf += 0.6 * dif2 * ambientColor; // lambert
            
            color *= brdf;
        }
        
        else if( material - MATERIAL_04 < 0.5 ) { // MATERIAL : cockpit / buttons / yellow
            color = vec3( 1.0, 0.9, 0.16 );
            vec3 cpl = vec3( 0.0, -1.0, -0.5 ); // cockpit light direction
            float dif2 = clamp( dot( nor, cpl ), 0.0, 1.0 );
            
            brdf += 0.2 * dif2 * lightColor; // lambert
    		brdf += 1.0 * amb * ambientColor; // ambient
            brdf += 0.15; // emission
            
            color *= brdf;
        }
        
        else if( material - MATERIAL_05 < 0.5 ) { // MATERIAL : cockpit / monitors / orange
            color = vec3( 0.5, 0.184, 0.184 );
            vec3 cpl = vec3( 0.0, -1.0, -0.5 ); // cockpit light direction
            float dif2 = clamp( dot( nor, cpl ), 0.0, 1.0 );
            
            brdf += 0.4 * dif2 * lightColor; // lambert
    		brdf += 0.8 * amb * ambientColor; // ambient
            brdf += 0.05; // emission
            
            color *= brdf;
        }
        
        else if( material - MATERIAL_06 < 0.5 ) { // MATERIAL : cockpit / monitors / black
            return vec3( 0.0 );
        }
        
        else if( material - MATERIAL_07 < 0.5 ) { // MATERIAL : dark / metallic
            color = vec3( 0.07, 0.07, 0.09 );
            float sss = calcSSS( pos, lightDir );
            
            brdf += 1.3 * dif * lightColor; // lambert
    		brdf += 1.3 * spe * ambientColor * dif; // blinn phong
    		brdf += 0.5 * amb * ambientColor; // ambient
    		brdf += 1.2 * fre * ambientColor; // fresnel schlick
            brdf += 1.1 * sss * lightColor; 
            
            color *= brdf;
        }
        
        else { // DEFAULT MATERIAL
            return vec3( 1.0, 0.0, 1.0 );
        }
    }
    
    
    return color;
}

// ________
// |||||||| camera
mat3 getCameraMatrix( vec3 camFow ) {
    vec3 forward = normalize( camFow );
    vec3 up = normalize( vec3( 0.0, 1.0, 0.0 ) );
    vec3 right = normalize( cross( up, forward ) );
    
    mat3 mat = mat3( right, up, forward );
    
    // shaky cam effect / mouse animation
    mat = rotate(
        mat,
        vec3(
            //0.005 * PI * sin( iGlobalTime * 4.0 ) - ( iMouse.xy / iResolution.xy ).y * PI * 0.3,
            0.002 * PI * sin( iGlobalTime * 2.0 ),
            0.001 * PI * ( cos( iGlobalTime * 1.0 ) + sin( iGlobalTime * 1.0 ) ) - 0.2 * ( 2.0 * mouse.x - 1.0 ) * mouse.y,
            0.0 * PI * cos( iGlobalTime*2.0 ) ) );
    
    return mat;
}

void mainImage( out vec4 o, in vec2 i ) {
	vec2 uv = i.xy / iResolution.xy;
    vec2 pixel = uv * 2.0 - 1.0;
    float viewRatio = iResolution.x / iResolution.y;
    pixel.x *= viewRatio;
    
    float deltaRot = mouse.x * PI * 2.0;

    //vec3 camPos = vec3( -7.0 * cos( deltaRot ) - 2.0 * mouse.y, 0.0 + mouse.y * 6.0, -7.0 * sin( deltaRot ) - 2.0 * mouse.y );
    //vec3 camFow = vec3( 1.0 * cos( deltaRot ), 0.0, 1.0 * sin( deltaRot ) );
    vec3 camPos = vec3( 0.0, 0.125, -1.0 );
    vec3 camFow = vec3( 0.0, 0.0, 1.0 );
    mat3 camMat = getCameraMatrix( camFow );
    
    vec3 rayDir = camMat * normalize( vec3( pixel, viewRatio + ( 0.5 * mouse.y - 0.1 ) ) );
    
    // scene
    vec3 color = render( camPos, rayDir );
    
    // vignette
    vec2 q = uv, c = q - 0.5;
    q += length( c ) * c * 2.0;
    float vig = 0.0 + 0.92 * clamp(
        pow( 1.0 - 0.4 * length( ( q - vec2( 0.5, 0.25 ) ) * vec2( viewRatio * 0.5, 1.5 ) ), 1.1 ),
        0.0, 1.0 );
    vig *= 0.4 + pow( uv.x * uv.y * ( 1.0 - uv.x ) * ( 1.0 - uv.y ), 0.1 );
    
    color *= vig;
    color *= vec3( 1.17, 0.51, 0.53 );
    
    o = vec4( toGamma( color ), 1.0 );
}
