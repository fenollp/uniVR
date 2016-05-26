// Shader downloaded from https://www.shadertoy.com/view/Xs3GWn
// written by shadertoy user yiwenl
//
// Name: 12_gears
// Description: gears
const int NUM_ITER = 140;
const float maxDist  = 4.0;

float time = iGlobalTime * 2.0;
const float PI      = 3.141592657;

const vec3 grdColor0 = vec3(0.16, 0.537, 0.8);
const vec3 grdColor1 = vec3(1.0, 1.0, 1.0);
const vec3 grdColor2 = vec3(0.564, 0.415, 0.0);
const vec3 grdColor3 = vec3(0.851, 0.623, 0.0);
const vec3 grdColor4 = vec3(1.0, 1.0, 1.0);


vec3 getGradient(float x) {
    float p = 0.0;
    if(x < 0.5) {
        p = x/0.5;
        return mix(grdColor0, grdColor1, p);
    } else if(x < 0.52) {
        p = (x-0.5)/0.02;
        return mix(grdColor1, grdColor2, p);
    } else if(x < 0.64) {
        p = (x-0.52)/0.12;
        return mix(grdColor2, grdColor3, p);
    } else {
        p = (x-0.64)/0.36;
        return mix(grdColor3, grdColor4, p);
    }
    
    return vec3(0.0);
}

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

float rep(float p, float c) {	return mod(p, c) - 0.5*c;	}
vec2 rep(vec2 p, float c) {		return mod(p, c) - 0.5*c;	}
vec3 rep(vec3 p, float c) {		return mod(p, c) - 0.5*c;	}

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

float box( vec3 p, vec3 b ) {
	vec3 d = abs(p) - b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float cylinder( vec3 p, vec2 h ) {
	vec2 d = abs(vec2(length(p.xz),p.y)) - h;
	return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float torus(vec3 p, float ri, float ro) {
    vec2 q = vec2(length(p.xz) - ri, p.y);
    return length(q) - ro;
}

const float size = 2.0;

float displacement(vec3 p) {
	return sin(20.0*p.x+time*.232)*sin(20.0*p.y+time*.25)*sin(20.0*p.z+time*.33);
}


vec2 gear(vec3 p, float rotation) {
	float colorIndex = 1.0;
	float boxSize = .08;
	float ringSize = .65;
    float numTeeth = 10.0;
	vec3 p0 = p;
	
	p0.xz = rotate(p0.xz, time*.2*rotation);
	if(rotation < 0.0) {
		p0.xz = rotate(p0.xz, PI/numTeeth);
	}
	p0.xz = repAng(p0.xz, numTeeth);

	p0.z -= ringSize+boxSize;

	float d = box(p0+vec3(0.0, 0.0, -.06), vec3(boxSize, boxSize, boxSize));
	float dTorus = torus(p, ringSize, boxSize-.01);

	if(dTorus < d) {
		colorIndex = 0.0;
	}

	d = smin(d, dTorus, 13.0);
	return vec2(d, colorIndex);
}

vec2 map(vec3 pos) {
    pos.xy = rotate(pos.xy, time*.1);
    pos.xz = rotate(pos.xz, time*.1);
    
	vec3 p0 = pos;
	p0.xy = repAng(p0.xy, 4.0);
	p0.y -= 2.0;
	vec2 g0 = gear(p0, 1.0);

	vec3 p1 = pos;
	p1.xy = rotate(p1.xy, PI/4.0);
	p1.xy = repAng(p1.xy, 4.0);
	p1.y -= 2.0;
	vec2 g1 = gear(p1, -1.0);

	if(g0.x < g1.x) {
		return g0;
	} else {
		return g1;
	}
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
const float lightWeight0 = 0.5;

const vec3 lightPos1 = vec3(-1.0, -0.75, -.6);
const vec3 lightColor1 = vec3(.96, .96, 1.0);
const float lightWeight1 = 0.25;

float ao( in vec3 pos, in vec3 nor ){
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.06*float(i)/4.0;
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

vec4 getColor(vec3 pos, vec3 dir, vec3 normal, float colorIndex, mat3 ca) {
	vec3 p = pos + vec3(sin(time*.25) * .5, cos(time*.05), .0);
	float n = displacement(pos);
	vec3 baseColor = vec3(0.0);
	vec3 env = vec3(0.0);
	float shadowOffset = 1.0;
	if(colorIndex < .5) {
		float a = atan(p.y, p.x);
		float r = length(p.xy);
		float g = sin(a*3.0+r*5.0-time + sin(time * .1) * 5.0) + cos(r*13.0-a*10.0 - time + cos(time*.25) * 2.0);
		g = r * g;

		g = sin(g* 2.0) * .5 + .5;
		g = mod(g - time*.1, 1.0);
        vec3 grdColor = getGradient(g);
		baseColor = mix(vec3(g), grdColor, .5);
		env 	 = envLight(normal, dir, iChannel1);
	} else {
		vec3 p = ca*pos;
		shadowOffset = 0.0;
		env 	 = envLight(normal, dir, iChannel0);
		baseColor = vec3(1.0, 1.0, .96);
	}

	
	vec3  lig     = normalize( lightPos0 );
	float shadow  = softshadow(pos, lig, 0.02, 2.5 );
	shadow        = mix(shadow, 1.0, .75);
	float _ao     = ao(pos, normal);
	return vec4(vec3(baseColor + env)*_ao*shadow, 1.0);	
	
}


mat3 setCamera( in vec3 ro, in vec3 ta, float cr ) {
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = -1.0 + uv * 2.0;
    uv.x *= iResolution.x / iResolution.y;
    
    //	GRADIENT BACKGROUND
    float g = 1.0 - clamp(length(uv)/2.0, 0.0, 1.0);
    g *= .25;
    
    //	CAMERA POSITION/LOOK AT CENTER
    float r = 6.0;
    float t = 4.0+iMouse.x*.05;
    float y = sin(time*.25) * .5 + .65;
    vec3 pos = vec3( cos(t)*r, y, 0.5 + sin(t)*r );
	vec3 ta = vec3( 0.0, 0.0, 0.0 );
    mat3 ca = setCamera( pos, ta, 0.0 );
	vec3 dir = ca * normalize( vec3(uv,1.5) );
    
	vec4 color = vec4(vec3(g), 1.0);
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
		color = getColor(pos, dir, normal, colorIndex, ca);
	}
    
	fragColor = color;
}