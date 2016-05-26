// Shader downloaded from https://www.shadertoy.com/view/Mll3W2
// written by shadertoy user jimbo00000
//
// Name: @party 2015 invite
// Description: [url]http://atparty-demoscene.net/[/url] Come and check out the North American Demoscene in Boston on June 19-22, 2015 at MIT's Stata center. Featuring Brian Peiris of [url=https://github.com/brianpeiris/RiftSketch]RiftSketch[/url] fame!
// Come attend @party 2015 June 19-22 in Boston at MIT!
// Start the party manually by uncommenting below if you don't want to wait.
//#define PARTY_ON

// @party will take place June 19-22 2015 6PM
vec4 atPartyDate = vec4(2015., (6.-1.), 19., 18.*60.*60.);

float t = 3.*iGlobalTime;
float party = 0.;

// math
const float PI = 3.14159265359;
const float DEG_TO_RAD = PI / 180.0;
mat3 rotationX(float t) {
    float ct=cos(t), st=sin(t);
    return mat3(1., 0.,  0.,  0., ct, -st,  0., st,  ct);}
mat3 rotationY(float t) {
    float ct=cos(t), st=sin(t);
    return mat3(ct, 0., st,  0., 1., 0.,  -st, 0., ct);}
mat3 rotationZ(float t) {
    float ct=cos(t), st=sin(t);
    return mat3(ct, -st, 0.,  st, ct, 0.,  0., 0., 1.);}
mat3 rotationXY(vec2 angle) {
	vec2 c = cos(angle);
	vec2 s = sin(angle);
	return mat3(
		c.y    ,  0.0, -s.y,
		s.y*s.x,  c.x,  c.y*s.x,
		s.y*c.x, -s.x,  c.y*c.x);
}

mat3 getMouseRotMtx()
{
    float f= .05;
    vec2 a = .5*vec2(.3,.2);
    vec2 o = vec2(.2,-.2);
    return rotationXY(-o+a*vec2(sin(f*t), cos(f*t)));
    
	// Use shadertoy mouse uniform
    vec4 m = iMouse;
    vec2 mm = m.xy - abs(m.zw);
    vec2 rv = 0.01*mm;
	mat3 rotmtx = rotationY(rv.x) * rotationX(-rv.y);
    return rotmtx;
}


// libiq

// exponential smooth min (k = 32);
float smine( float a, float b, float k )
{
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
}

// polynomial smooth min (k = 0.1);
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

////////////// DISTANCE FUNCTIONS
//
// Primitives from http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
//
float udBox( vec3 p, vec3 b )
{
  return length(max(abs(p)-b,0.0));
}
float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}
float udRoundBox( vec3 p, vec3 b, float r )
{
    return length(max(abs(p)-b,0.0))-r;
}
float sdPlane( vec3 p, vec4 n )
{
    // n must be normalized
    return dot(p,n.xyz) + n.w;
}

//
// Composites
//
float rollprism(vec3 pos)
{
    return max(
        udRoundBox(pos, vec3(2.,1.4,5.), 3.5),
        -sdPlane(pos, vec4(normalize(vec3(-1.,0.,0.)),3.))
        );
}

float rollprism2(vec3 pos)
{
    return max(
        udRoundBox(pos, vec3(2.,2.,5.), 7.5),
        -udRoundBox(pos, vec3(2.,2.,15.), 5.5)
        );
}

float atsign(vec3 pos)
{
    float d = min(
        rollprism(pos-vec3(1.,0.,0.)),
        rollprism2(pos)
        );
    d = smin(d,
             sdBox(pos-vec3(4.2,-3.5,0.), vec3(3.5,1.4,5.))
            ,1.);    
    d = max(d, -sdBox(pos-vec3(6.,-8.4,0.), vec3(6.,3.5,12.))); // chop horiz
    
    // chop off front and back
    float w = 0.;//1.+sin(t);
    d = max(d, -sdPlane(pos                 , vec4(vec3(0.,0.,-1.),0.)));
    d = max(d, -sdPlane(pos-vec3(0.,0.,-1.5-w), vec4(vec3(0.,0.,1.),0.)));
    return d;
}

float attail(vec3 pos)
{
    float s = -0.+0.5*pow((1.+0.1*pos.x),1.7);
    return sdBox(pos, vec3(5.,0.8+s,.6+s));
}

float at(vec3 pos)
{
    // dance
    float p = 0.02*party;
    pos = rotationY(p*pos.y*sin(3.*t)) * pos;
    pos = rotationX(p*pos.y*sin(5.*t)) * pos;
    
    return min(
        atsign(pos),
        attail(
            rotationY(-.03*(pos.x+7.)) *
            (pos-vec3(3.,-8.5,.0)))
        );
}

float DE_atlogo( vec3 pos )
{
	mat3 rotmtx = getMouseRotMtx();
	pos = rotmtx * pos;
	float d2 = 9999.;
	return min(d2, at(pos));
}


//
// lighting and shading
//
vec3 shading( vec3 v, vec3 n, vec3 eye ) {
	float shininess = 16.0;
	vec3 ev = normalize( v - eye );
	vec3 ref_ev = reflect( ev, n );	
	vec3 final = vec3( 0.0 );
	// disco light
	{
		vec3 light_pos   = vec3( 1.0, 10.0, 30.0 );
        float p = party;
		vec3 light_color = vec3(p*sin(3.*t), p*sin(3.3*t), p*sin(4.*t));
		vec3 vl = normalize( light_pos - v );
	
		float diffuse  = 0.;//max( 0.0, dot( vl, n ) );
		float specular = max( 0.0, dot( vl, ref_ev ) );
		specular = pow( specular, shininess );
		
		final += light_color * ( diffuse + specular ); 
	}
	
	// white light
	{
		vec3 light_pos   = vec3( 10.0, 20.0, -10.0 );
		//vec3 light_pos   = vec3( -20.0, -20.0, -20.0 );
		vec3 light_color = vec3( 1.);//0.3, 0.7, 1.0 );
		vec3 vl = normalize( light_pos - v );
	
        shininess = 8.;
		float diffuse  = 0.;//max( 0.0, dot( vl, n ) );
		float specular = max( 0.0, dot( vl, ref_ev ) );
		specular = pow( specular, shininess );
		
		final += light_color * ( diffuse + specular ); 
	}

	return final;
}

// get gradient in the world
vec3 gradient( vec3 pos ) {
	const float grad_step = 0.31;
	const vec3 dx = vec3( grad_step, 0.0, 0.0 );
	const vec3 dy = vec3( 0.0, grad_step, 0.0 );
	const vec3 dz = vec3( 0.0, 0.0, grad_step );
	return normalize (
		vec3(
			DE_atlogo( pos + dx ) - DE_atlogo( pos - dx ),
			DE_atlogo( pos + dy ) - DE_atlogo( pos - dy ),
			DE_atlogo( pos + dz ) - DE_atlogo( pos - dz )	
		)
	);
}

// ray marching
float ray_marching( vec3 origin, vec3 dir, float start, float end ) {
	const int max_iterations = 255;
	const float stop_threshold = 0.001;
	float depth = start;
	for ( int i = 0; i < max_iterations; i++ ) {
		float dist = DE_atlogo( origin + dir * depth );
		if ( dist < stop_threshold ) {
			return depth;
		}
		depth += dist;
		if ( depth >= end) {
			return end;
		}
	}
	return end;
}

// get ray direction from pixel position
vec3 ray_dir( float fov, vec2 size, vec2 pos ) {
	vec2 xy = pos - size * 0.5;

	float cot_half_fov = tan( ( 90.0 - fov * 0.5 ) * DEG_TO_RAD );	
	float z = size.y * 0.5 * cot_half_fov;
	
	return normalize( vec3( xy, -z ) );
}


vec3 getSceneColor_atlogo( in vec3 ro, in vec3 rd )
{
	const float clip_far = 100.0;
	float depth = ray_marching( ro, rd, -10.0, clip_far );
	if ( depth >= clip_far ) {
        return vec3(1.);
	}
	vec3 pos = ro + rd * depth;
	vec3 n = gradient( pos );
	return shading( pos, n, ro );
}



//
// The cube
//
mat3 getCubeMtx()
{
    return rotationY(.8+party*pow(abs(sin(PI*2.*iGlobalTime)),5.)) * rotationX(.3);
}

float DE_cube( vec3 pos )
{
	pos = getCubeMtx() * pos;
	return udRoundBox(pos, vec3(1.5), .15);
}

vec3 shade_cube(vec3 v, vec3 n, vec3 ntx, vec3 eye) {
	vec3 ev = normalize(v - eye);
	vec3 final = vec3(0.);
    vec3 light_pos = vec3(-10.,20.,40.);
    vec3 vl = normalize(light_pos - v);
    float diffuse = max(0.0, dot( vl, n ));
    final += 1.3 * diffuse; 
	// transform normals with the cube to find flat faces/edges
	float px = abs(dot(ntx,vec3(1.,0.,0.)));
	float py = abs(dot(ntx,vec3(0.,1.,0.)));
	float pz = abs(dot(ntx,vec3(0.,0.,1.)));
    float p = max(px,max(py,pz));
    final *= smoothstep(0.9,1.,length(p));
    return final;
}

vec3 grad_cube(vec3 pos) {
	const float gs = 0.02;
	const vec3 dx = vec3(gs, 0., 0.);
	const vec3 dy = vec3(0., gs, 0.);
	const vec3 dz = vec3(0., 0., gs);
	return normalize( vec3(
			DE_cube(pos + dx) - DE_cube(pos - dx),
			DE_cube(pos + dy) - DE_cube(pos - dy),
			DE_cube(pos + dz) - DE_cube(pos - dz)	
		));
}

float raymarch_cube(vec3 origin, vec3 dir, float start, float end) {
	const int max_iterations = 64;
	const float stop_threshold = 0.01;
	float depth = start;
	for (int i=0; i<max_iterations; i++) {
		float dist = DE_cube(origin + dir*depth);
		if (dist < stop_threshold) return depth;
		depth += dist;
		if (depth >= end) return end;
	}
	return end;
}

vec3 getCubeColor(in vec3 ro, in vec3 rd) {
	const float clip_far = 100.0;
	float depth = raymarch_cube(ro, rd, 0., clip_far);
	if ( depth >= clip_far )
		return getSceneColor_atlogo(ro,rd);
    vec3 pos = ro + rd * depth;
	vec3 ne = grad_cube(pos);
    vec3 ntx = getCubeMtx() * ne;
	return shade_cube(pos, ne, ntx, ro);
}


// ---- 8< ---- GLSL Number Printing - @P_Malin ---- 8< ----
// Creative Commons CC0 1.0 Universal (CC-0) 
// https://www.shadertoy.com/view/4sBSWW

float DigitBin(const in int x)
{
    return x==0?480599.0:x==1?139810.0:x==2?476951.0:x==3?476999.0:x==4?350020.0:x==5?464711.0:x==6?464727.0:x==7?476228.0:x==8?481111.0:x==9?481095.0:0.0;
}

float PrintValue(const in vec2 vPixelCoords, const in vec2 vFontSize, const in float fValue, const in float fMaxDigits, const in float fDecimalPlaces)
{
    vec2 vStringCharCoords = (gl_FragCoord.xy - vPixelCoords) / vFontSize;
    if ((vStringCharCoords.y < 0.0) || (vStringCharCoords.y >= 1.0)) return 0.0;
	float fLog10Value = log2(abs(fValue)) / log2(10.0);
	float fBiggestIndex = max(floor(fLog10Value), 0.0);
	float fDigitIndex = fMaxDigits - floor(vStringCharCoords.x);
	float fCharBin = 0.0;
	if(fDigitIndex > (-fDecimalPlaces - 1.01)) {
		if(fDigitIndex > fBiggestIndex) {
			if((fValue < 0.0) && (fDigitIndex < (fBiggestIndex+1.5))) fCharBin = 1792.0;
		} else {		
			if(fDigitIndex == -1.0) {
				if(fDecimalPlaces > 0.0) fCharBin = 2.0;
			} else {
				if(fDigitIndex < 0.0) fDigitIndex += 1.0;
				float fDigitValue = (abs(fValue / (pow(10.0, fDigitIndex))));
                float kFix = 0.0001;
                fCharBin = DigitBin(int(floor(mod(kFix+fDigitValue, 10.0))));
			}		
		}
	}
    return floor(mod((fCharBin / pow(2.0, floor(fract(vStringCharCoords.x) * 4.0) + (floor(vStringCharCoords.y * 5.0) * 4.0))), 2.0));
}

// ---- 8< -------- 8< -------- 8< -------- 8< ----

// NOT general, only works until June
vec4 getCountdown(vec4 then, vec4 now)
{
    int md[6];md[1]=31;md[2]=28;md[3]=31;md[4]=30;md[5]=31;
    int totalDays = int(then.z);
    if (int(then.y) == int(now.y))
    {
        totalDays -= int(now.z);
    }
    else
    {
        for (int i=1; i<6; ++i)
        {
            if (i >= int(now.y+1.)) totalDays += md[i];
        }
        totalDays -= int(now.z);
    }
    if (now.w > then.w) totalDays -=1;
    
    float secs = now.w;
    float ds = then.w - now.w;
    float hours = mod(ds / (60.0 * 60.0), 24.0);
    float minutes = mod(ds / 60.0, 60.0);
    float seconds = mod(ds, 60.0);
    return vec4(float(totalDays), float(hours), minutes, seconds);
}

vec3 getTextColor(vec3 bgcol)
{    
    vec4 cd = getCountdown(atPartyDate, iDate);
	vec2 vFontSize = vec2(2.*8.0, 2.*15.0); // Multiples of 4x5 work best
    vec2 loc = vec2(-10., 10.);
    vec3 c = vec3(0.);
	vec3 fc = bgcol;
    fc = mix(fc, c, PrintValue(loc+vec2(0.,0.), vFontSize, cd.x, 4.0, 0.0));
    fc = mix(fc, c, PrintValue(loc+vec2(50.,0.), vFontSize, cd.y, 4.0, 0.0));
    fc = mix(fc, c, PrintValue(loc+vec2(100.,0.), vFontSize, cd.z, 4.0, 0.0));
    fc = mix(fc, c, PrintValue(loc+vec2(150.,0.), vFontSize, cd.w, 4.0, 0.0));
    return fc;
}

vec3 getSceneColor(in vec3 ro, in vec3 rd)
{
    vec3 bgcol = getCubeColor(ro,rd);
	return getTextColor(bgcol);
}


#ifndef RIFTRAY
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 testDate = iDate;
    vec4 cd = getCountdown(atPartyDate, testDate);
    float daysleft = cd.x;
    party = 1.-clamp(daysleft/14.,0.,1.);
    
#ifdef PARTY_ON
	party = 1.;
#endif

	// default ray dir/origin
	vec3 dir = ray_dir( 45.0, iResolution.xy, fragCoord.xy );
	vec3 eye = vec3( 0.0, 0.0, 30.0 );	
	fragColor = vec4( getSceneColor( eye, dir ), 1.0 );
}
#endif
