// Shader downloaded from https://www.shadertoy.com/view/XstGz4
// written by shadertoy user yiwenl
//
// Name: Dreaming
// Description: dreaming ? 
float time = iGlobalTime * 1.0;
const float PI      = 3.141592657;
// const float maxDist = 5.0;



//	TOOLS
vec2 rotate(vec2 pos, float angle) {
	float c = cos(angle);
	float s = sin(angle);

	return mat2(c, s, -s, c) * pos;
}

float smin( float a, float b, float k ) {
    float res = exp( -k*a ) + exp( -k*b );
    return -log( res )/k;
}

float smin( float a, float b ) {	return smin(a, b, 7.0);	}

//	GEOMETRY
float sphere(vec3 pos, float radius) {
	return length(pos) - radius;
}

float capsule(vec3 p, float r, float c) {
	return mix(length(p.xz)-r, length(vec3(p.x,abs(p.y)-c,p.z))-r, step(c,abs(p.y)));
}

float cone( in vec3 p, in vec3 c ) {
    vec2 q = vec2( length(p.xz), p.y );
    vec2 v = vec2( c.z*c.y/c.x, -c.z );
    vec2 w = v - q;
    vec2 vv = vec2( dot(v,v), v.x*v.x );
    vec2 qv = vec2( dot(v,w), v.x*w.x );
    vec2 d = max(qv,0.0)*qv/vv;
    return sqrt( dot(w,w) - max(d.x,d.y) )* sign(max(q.y*v.x-q.x*v.y,w.y));
}

float plane(vec3 pos) {
	return pos.y;
}


vec2 map(vec3 pos) {
	float colorIndex       = 0.0;
	vec3 orgPos            = pos;
	pos.y                  -=.1;
	pos.xz                 = rotate(pos.xz, time*10.0);
	float r                = sin(time*.5) * .5 + .5;
	r                      = smoothstep(0.6, 1.0, r) * .015 + .003;
	pos.yz                 = rotate(pos.yz, r);
	
	float dCenter          = capsule(pos, .1, 1.0);
	float t                = 0.0;
	if(abs(pos.y) < 1.2) t = (pos.y + 1.2) / 2.0;
	dCenter                += t * .02;
	
	vec3 negPos            = pos;
	negPos.y               *= -1.0;
	float dLowerCone       = cone(negPos+vec3(0.0, -.9, 0.0), vec3(.5, .65, .65));
	float d                = smin(dCenter, dLowerCone);
	
	vec3 diskPos           = pos+vec3(0.0, .25, 0.0);
	diskPos.y              *= 10.0;
	float dDisk            = sphere(diskPos, 1.0);
	d                      = smin(d, dDisk);
	
	float dUpperCone       = cone(pos+vec3(0.0, -.25, 0.0), vec3(.5, .5, .5));
	d                      = smin(d, dUpperCone);
	
	float dFloor           = plane(orgPos+vec3(0.0, 1.0, 0.0));
	// d                   = min(dFloor, d);
	if(dFloor < d) {
	colorIndex             = 1.0;
		d                  = dFloor;
	}
	
	
	return vec2(d, colorIndex);
}

vec3 computeNormal(vec3 pos) {
	vec2 eps = vec2(0.001, 0.0);

	vec3 normal = vec3(
		map(pos + eps.xyy).x - map(pos - eps.xyy).x,
		map(pos + eps.yxy).x - map(pos - eps.yxy).x,
		map(pos + eps.yyx).x - map(pos - eps.yyx).x
	);
	return normalize(normal);
}


//	LIGHTING
const vec3 lightPos0 = vec3(-0.6, 0.7, -0.5);
const vec3 lightColor0 = vec3(1.0, 1.0, .96);
const float lightWeight0 = 0.85;

const vec3 lightPos1 = vec3(-1.0, -0.75, -.6);
const vec3 lightColor1 = vec3(.96, .96, 1.0);
const float lightWeight1 = 0.15;

float ao( in vec3 pos, in vec3 nor ){
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 envLight(vec3 normal, vec3 dir, samplerCube tex) {
	vec3 eye    = -dir;
	vec3 r      = reflect( eye, normal );
	vec3 color  = textureCube( tex, r ).rgb;
	float power = 10.0;
	color.r     = pow(color.r, power);
	color       = color.rrr;
    return color;
}


float softshadow( in vec3 ro, in vec3 rd, in float mint, in float tmax ) {
	float res = 1.0;
    float t = mint;
    for( int i=0; i<16; i++ ) {
		float h = map( ro + rd*t ).x;
        res = min( res, 8.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );
}


float diffuse(vec3 normal, vec3 light) {
	return max(dot(normal, light), 0.0);
}

vec4 getColor(vec3 pos, vec3 dir, vec3 normal, float colorIndex) {
	if(colorIndex == 0.0) {
		float a       = fract(atan(pos.z, pos.x) * 3.0 + time*15.0);
		a             = smoothstep(0.25, 0.3, abs(a-.5));
		vec3 grd      = vec3(1.0, 1.0, .96) * .95 * a;
		float _ao     = ao(pos, normal);
		vec3 env      = envLight(normal, dir, iChannel1);
		vec3 envBlur  = envLight(normal, dir, iChannel1);
		float mixture = sin(time*.2) * .5 + .5;
		env           = mix(env, envBlur, mixture);
		vec3 _diffuse = diffuse(normal, normalize(lightPos0)) * lightColor0 * lightWeight0;
		return vec4(vec3(grd+env+_diffuse)*_ao, 1.0);	
	} else {
		vec3  lig      = normalize( lightPos0 );
		float shadow   = softshadow(pos, lig, 0.02, 2.5 );
		shadow         = mix(shadow, 1.0, .5);
		vec4 baseColor = vec4(1.0, 1.0, .96, 1.0);
		baseColor.rgb  *= shadow;
		return baseColor;
	}
	
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr ) {
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

const int NUM_ITER = 100;
const float maxDist  = 5.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = -1.0 + uv * 2.0;
    uv.x *= iResolution.x / iResolution.y;
    
    float r = 3.0;
    float t = time*0.1;
    float y = sin(time*.25) * .5 + .65;
    vec3 pos = vec3( cos(t)*r, y, 0.5 + sin(t)*r );
	vec3 ta = vec3( 0.0, 0.0, 0.0 );
    mat3 ca = setCamera( pos, ta, 0.0 );
	vec3 dir = ca * normalize( vec3(uv,1.5) );
    
    float grey = length(uv*0.75);
	grey = (1.0 - grey * .25) * .25;
    
    vec4 color = vec4(1.0, 1.0, .96, 1.0);
	float prec = pow(.1, 7.0);
	float d;
	float colorIndex = 0.0;
	bool hit = false;
	
	for(int i=0; i<NUM_ITER; i++) {
		vec2 result = map(pos);						//	distance to object
		d = result.x;
		colorIndex = result.y;

		if(d < prec) {						// 	if get's really close, set as hit the object
			hit = true;
		}

		pos += d * dir;						//	move forward by
		if(length(pos) > maxDist) break;
	}


	if(hit) {
		color = vec4(1.0);
		vec3 normal = computeNormal(pos);
		color = getColor(pos, dir, normal, colorIndex);
	}
    
	fragColor = color;
}