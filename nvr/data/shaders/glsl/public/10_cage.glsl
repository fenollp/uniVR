// Shader downloaded from https://www.shadertoy.com/view/MstGzN
// written by shadertoy user yiwenl
//
// Name: 10_Cage
// Description: cage
float time = iGlobalTime * 3.0;
const float PI      = 3.141592657;
// const float maxDist = 5.0;



//	TOOLS
vec2 rotate(vec2 pos, float angle) {
	float c = cos(angle);
	float s = sin(angle);

	return mat2(c, s, -s, c) * pos;
}

float rep(float p, float c) {	return mod(p, c) - 0.5*c;	}
vec2 rep(vec2 p, float c) {		return mod(p, c) - 0.5*c;	}

vec2 repAng(vec2 p, float n) {
    float ang = 2.0*PI/n;
    float sector = floor(atan(p.x, p.y)/ang + 0.5);
    p = rotate(p, sector*ang);
    return p;
}

vec3 repAngS(vec2 p, float n) {
    float ang = 2.0*PI/n;
    float sector = floor(atan(p.x, p.y)/ang + 0.5);
    p = rotate(p, sector*ang);
    return vec3(p.x, p.y, mod(sector, n));
}


//	GEOMETRY
float sphere(vec3 pos, float radius) {
	return length(pos) - radius;
}

float sdBox( vec3 p, vec3 b ) {
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}


float displacement(vec3 p) {
	 return sin(20.0*p.x+time)*sin(20.0*p.y+time*.25)*sin(20.0*p.z+time*.33);
}

vec2 map(vec3 pos) {
	float colorIndex = 0.0;
	vec3 posBelt     = pos;
	posBelt.yz 		 = rotate(posBelt.yz, time*.1);
	posBelt.yz       = repAng(posBelt.yz, 12.0);
	posBelt.xz       = repAng(posBelt.xz, 36.0*10.0);
	posBelt.z        -= 1.0;
	float d          = sdBox(posBelt, vec3(1.0, .05, .01));

	float r          = .90+pow(sin(time), 5.0)*.05;
	float dSphere    = sphere(pos, r);
	dSphere += displacement(pos*.15) * .05;
	if(dSphere < d) {
		d = dSphere;
		colorIndex = 1.0;
		
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
const float lightWeight0 = 0.15;

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
	vec3 baseColor = vec3(0.0);
	vec3 env = vec3(.0);
	if(colorIndex == 0.0) {
		baseColor = vec3(1.0, 1.0, .96) * .05;
		env      = envLight(normal, dir, iChannel0)*.1;
	} else {
		baseColor = vec3(.25, 0.0, .0);
		env      = envLight(normal, dir, iChannel0);
	}

	vec3  lig     = normalize( lightPos0 );
	float shadow  = softshadow(pos, lig, 0.02, 2.5 );
	float _ao     = ao(pos, normal);
	vec3 _diffuse = diffuse(normal, normalize(lightPos0)) * lightColor0 * lightWeight0;
	_diffuse      += diffuse(normal, normalize(lightPos1)) * lightColor1 * lightWeight1;
	return vec4(vec3(baseColor+env+_diffuse)*_ao*shadow, 1.0);	
	
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
    float t = 4.0;
    float y = sin(time*.25) * .5 + .65;
    vec3 pos = vec3( cos(t)*r, y, 0.5 + sin(t)*r );
	vec3 ta = vec3( 0.0, 0.0, 0.0 );
    mat3 ca = setCamera( pos, ta, 0.0 );
	vec3 dir = ca * normalize( vec3(uv,1.5) );
    
    float grey = length(uv*0.75);
	grey = (1.0 - grey * .25) * .25;
    
    vec4 color = vec4(0.0);
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