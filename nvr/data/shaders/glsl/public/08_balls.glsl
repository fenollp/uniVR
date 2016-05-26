// Shader downloaded from https://www.shadertoy.com/view/4tBXDd
// written by shadertoy user yiwenl
//
// Name: 08_balls
// Description: 08s
float time = iGlobalTime * .5;

vec2 rotate(vec2 pos, float angle) {
	float c = cos(angle);
	float s = sin(angle);

	return mat2(c, s, -s, c) * pos;
}


float iSphere(vec3 pos, float radius) {
    return length(pos) - radius;
}


float map(vec3 pos) {
   
    float s1 = iSphere(pos - vec3(sin(iGlobalTime*.55)*1.85, cos(iGlobalTime*.19) * 0.95, sin(iGlobalTime*.91) * 1.21) * .7, 1.6451);
    float s2 = iSphere(pos - vec3(cos(iGlobalTime*.43)*1.55, sin(iGlobalTime*.38) * 1.12, cos(iGlobalTime*.76) * 1.67) * 1.1, 1.564821);
    float s3 = iSphere(pos - vec3(sin(iGlobalTime*.26)*2.52, cos(iGlobalTime*.57) * 0.56, sin(iGlobalTime*.12) * 1.58) * .9, 1.98441);
    float s4 = iSphere(pos - vec3(sin(iGlobalTime*.97)*1.72, sin(iGlobalTime*.22) * 0.81, cos(iGlobalTime*.34) * 0.97) * 1.2, 1.12373);
    float s5 = iSphere(pos - vec3(sin(iGlobalTime*.62)*1.47, cos(iGlobalTime*.76) * 0.73, sin(iGlobalTime*.75) * 1.45) * 1.3, 1.2748186);
        
    return min(s1, min(s2, min(s3, min(s4, s5))));
}

float map(vec3 pos, out int index) {
   
    float s1 = iSphere(pos - vec3(sin(iGlobalTime*.55)*1.85, cos(iGlobalTime*.19) * 0.95, sin(iGlobalTime*.91) * 1.21) * .7, 1.6451);
    float s2 = iSphere(pos - vec3(cos(iGlobalTime*.43)*1.55, sin(iGlobalTime*.38) * 1.12, cos(iGlobalTime*.76) * 1.67) * 1.1, 1.564821);
    float s3 = iSphere(pos - vec3(sin(iGlobalTime*.26)*2.52, cos(iGlobalTime*.57) * 0.56, sin(iGlobalTime*.12) * 1.58) * .9, 1.98441);
    float s4 = iSphere(pos - vec3(sin(iGlobalTime*.97)*1.72, sin(iGlobalTime*.22) * 0.81, cos(iGlobalTime*.34) * 0.97) * 1.2, 1.12373);
    float s5 = iSphere(pos - vec3(sin(iGlobalTime*.62)*1.47, cos(iGlobalTime*.76) * 0.73, sin(iGlobalTime*.75) * 1.45) * 1.3, 1.2748186);
    
    index = 0;
    float d = s1;
    if(s2 < d) {
        index = 1;
        d = s2;
    }
    if(s3 < d) {
        index = 2;
        d = s3;
    }
    if(s4 < d) {
        index = 3;
        d = s4;
    }
    if(s5 < d) {
        index = 4;
    }

        
    return min(s1, min(s2, min(s3, min(s4, s5))));
}


const float PI = 3.141592657;


vec3 computeNormal(vec3 pos) {
	vec2 eps = vec2(0.01, 0.0);

	vec3 normal = vec3(
		map(pos + eps.xyy) - map(pos - eps.xyy),
		map(pos + eps.yxy) - map(pos - eps.yxy),
		map(pos + eps.yyx) - map(pos - eps.yyx)
	);
	return normalize(normal);
}


float ao( in vec3 pos, in vec3 nor ){
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos );
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 envLight(vec3 normal, vec3 dir) {
	vec3 eye = -dir;
	vec3 r = reflect( eye, normal );
    float m = 2. * sqrt( pow( r.x, 2. ) + pow( r.y, 2. ) + pow( r.z + 1., 2. ) );
    vec3 color = textureCube( iChannel0, r ).rgb;
	float power = 15.0;
	color.r     = pow(color.r, power);
	color       = color.rrr;
    return color;
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 getColor(vec3 pos, vec3 dir, vec3 normal, int index) {
	vec3 orgPos  = pos;
	float t      = float(index);
	float rnd    = rand(vec2(t));
	float fixRnd = mix(rnd, 1.0, .75);
	
	pos.xz       = rotate(pos.xz, rnd * 3.0);
	pos.yz       = rotate(pos.yz, rnd * 3.0);
	
	float base   = sin(pos.y*15.0*fixRnd-time*0.5)*.5 + .5;
	base         = smoothstep(.5, .6, base);
	
	float _ao    = ao(orgPos, normal);
	vec3 env     = envLight(normal, dir);
	return vec4(vec3(base+env)*_ao, 1.0);
	// return vec4(vec3(_ao*env)+grey, 1.0);
}

mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
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
    
    vec3 pos = vec3( -0.5+3.5*cos(0.1*time + 6.0), 1.0 + 2.0, 0.5 + 5.5*sin(0.1*time + 6.0) );
	vec3 ta = vec3( 0.0, 0.0, 0.0 );
    mat3 ca = setCamera( pos, ta, 0.0 );
	vec3 dir = ca * normalize( vec3(uv,1.5) );
    
    float grey = length(uv*0.75);
	grey = (1.0 - grey * .25) * .25;
    
    vec4 color = vec4(vec3(grey), 1.0);
	float prec = pow(.1, 5.0);
	float d;
	bool hit = false;
	int index = -1;
	
	for(int i=0; i<NUM_ITER; i++) {
		d = map(pos, index);						//	distance to object

		if(d < prec) {						// 	if get's really close, set as hit the object
			hit = true;
		}

		pos += d * dir;						//	move forward by
		if(length(pos) > maxDist) break;
	}


	if(hit) {
		color = vec4(1.0);
		vec3 normal = computeNormal(pos);
		color = getColor(pos, dir, normal, index);
	}
    
	fragColor = color;
}