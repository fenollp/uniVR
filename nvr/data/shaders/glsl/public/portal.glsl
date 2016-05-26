// Shader downloaded from https://www.shadertoy.com/view/lsSGRz
// written by shadertoy user HLorenzi
//
// Name: Portal
// Description: A one-way raymarched portal! The camera will travel between both worlds. It will look back rapidly in order to show the one-way-ness of the portal. It also features a nice glow effect I tried to create. (Some code from iq) Got kinda broken recently...
// Comment to turn off for faster rendering!
//#define SHADOWS 1
#define GLOW 1
#define SPECULAR 1

// Increase for bigger glow effect (which also gets a little bugged...)!
#define GLOW_AMOUNT 4.0

// Reduce for accuracy-performance trade-off!
#define RAYMARCH_ITERATIONS 40
#define SHADOW_ITERATIONS 60

// Increase for accuracy-performance trade-off!
#define SHADOW_STEP 2.0




void fUnionMat(inout float curDist, inout float curMat, float dist, in float mat)
{
	if (dist < curDist) {
		curMat = mat;
		curDist = dist;
	}
}

float fSubtraction(float a, float b)
{
	return max(-a,b);
}

float fIntersection(float d1, float d2)
{
    return max(d1,d2);
}

float fUnion(float d1, float d2)
{
    return min(d1,d2);
}

float pSphere(vec3 p, float s)
{
	return length(p)-s;
}

float pRoundBox(vec3 p, vec3 b, float r)
{
 	return length(max(abs(p)-b,0.0))-r;
}

float pTorus(vec3 p, vec2 t)
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float distf(int world, vec3 p, inout float m)
{
	float d = 0.0;
	m = 0.0;
	
	if (world == 0) {
		d = 16.0 + p.z;
		m = 1.0;
		
		fUnionMat(d, m, pSphere(vec3(24,22,4) + p, 12.0), 4.0);
		fUnionMat(d, m, pRoundBox(vec3(6,-35,4) + p, vec3(4,4,11), 1.0), 4.0);
		fUnionMat(d, m, pRoundBox(vec3(19,-15,0) + p, vec3(4,4,15), 1.0), 4.0);
		fUnionMat(d, m, pRoundBox(vec3(-12,20,12) + p, vec3(7,7,7), 1.0), 4.0);
	} else {
		d = 16.0 + p.z;
		m = 2.0;
		
		fUnionMat(d, m, pRoundBox(vec3(15,35,6) + p, vec3(4,12,9), 1.0), 5.0);
		fUnionMat(d, m, pRoundBox(vec3(-10,35,10) + p, vec3(15,3,5), 1.0), 5.0);
		fUnionMat(d, m, pRoundBox(vec3(15,-35,6) + p, vec3(12,6,15), 1.0), 5.0);
	}
	
	float portal = pTorus(p, vec2(12,1));
	
	fUnionMat(d, m, portal, 3.0);
	
	return d;
}

float distf2(int world, vec3 p, inout float m)
{
	float d = 0.0;
	m = 0.0;
	
	if (world == 0) {
		d = 16.0 + p.z;
		m = 1.0;
		
		fUnionMat(d, m, pSphere(vec3(24,22,4) + p, 12.0), 4.0);
		fUnionMat(d, m, pRoundBox(vec3(6,-35,4) + p, vec3(4,4,11), 1.0), 4.0);
		fUnionMat(d, m, pRoundBox(vec3(19,-15,0) + p, vec3(4,4,15), 1.0), 4.0);
		fUnionMat(d, m, pRoundBox(vec3(-12,20,12) + p, vec3(7,7,7), 1.0), 4.0);
	} else {
		d = 16.0 + p.z;
		m = 2.0;
		
		fUnionMat(d, m, pRoundBox(vec3(15,35,6) + p, vec3(4,12,9), 1.0), 5.0);
		fUnionMat(d, m, pRoundBox(vec3(-10,35,10) + p, vec3(15,3,5), 1.0), 5.0);
		fUnionMat(d, m, pRoundBox(vec3(15,-35,6) + p, vec3(12,6,15), 1.0), 5.0);
	}
	
	return d;
}


vec3 normalFunction(int world, vec3 p)
{
	const float eps = 0.01;
	float m;
    vec3 n = vec3( (distf(world,vec3(p.x-eps,p.y,p.z),m) - distf(world,vec3(p.x+eps,p.y,p.z),m)),
                   (distf(world,vec3(p.x,p.y-eps,p.z),m) - distf(world,vec3(p.x,p.y+eps,p.z),m)),
                   (distf(world,vec3(p.x,p.y,p.z-eps),m) - distf(world,vec3(p.x,p.y,p.z+eps),m))
				 );
    return normalize( n );
}

vec4 raymarch(float world, vec3 from, vec3 increment)
{
	const float maxDist = 200.0;
	const float minDist = 0.1;
	const int maxIter = RAYMARCH_ITERATIONS;
	
	float dist = 0.0;
	
	float material = 0.0;
	
	float glow = 1000.0;
	
	for(int i = 0; i < maxIter; i++) {
		vec3 pos = (from + increment * dist);
		float distEval = distf(int(world), pos, material);
		
		if (distEval < minDist) {
			break;
		}
		
		#ifdef GLOW
		if (material == 3.0) {
			glow = min(glow, distEval);
		}
		#endif
		
		
		if (length(pos.xz) < 12.0 && 
			pos.y > 0.0 &&
			(from + increment * (dist + distEval)).y <= 0.0) {
			if (world == 0.0) {
				world = 1.0;
			} else {
				world = 0.0;
			}
		}
		dist += distEval;
	}
	
	
	if (dist >= maxDist) {
		material = 0.0;
	}
	
	return vec4(dist, material, world, glow);
}

float shadow(float world, vec3 from, vec3 increment)
{
	const float minDist = 1.0;
	
	float res = 1.0;
	float t = 1.0;
	for(int i = 0; i < SHADOW_ITERATIONS; i++) {
		float m;
        float h = distf2(int(world), from + increment * t,m);
        if(h < minDist)
            return 0.0;
		
		res = min(res, 4.0 * h / t);
        t += SHADOW_STEP;
    }
    return res;
}

vec4 getPixel(float world, vec3 from, vec3 to, vec3 increment)
{
	vec4 c = raymarch(world, from, increment);
	
	vec3 hitPos = from + increment * c.x;
	vec3 normal = normalFunction(int(c.z),hitPos);
	vec3 lightPos = -normalize(hitPos + vec3(0,0,-4));
	
	float diffuse = max(0.0, dot(normal, -lightPos)) * 0.5 + 0.5;
	float shade = 
		#ifdef SHADOWS
			shadow(c.z, hitPos, lightPos) * 0.5 + 0.5;
		#else
			1.0;
		#endif
	float specular = 0.0;	
		#ifdef SPECULAR
		if (dot(normal, -lightPos) < 0.0) {
			specular = 0.0;
		} else {
			specular = pow(max(0.0, dot(reflect(-lightPos, normal), normalize(from - hitPos))), 5.0);
		}
		#endif
	
	
	vec4 m = vec4(0,0,0,1);
	
	if (c.y == 1.0) {
		m = mix(vec4(1,0.1,0.2,1), vec4(1,0.3,0.6,1), sin(hitPos.x) * sin(hitPos.y)) *
			clamp((100.0 - length(hitPos.xy)) / 100.0, 0.0, 1.0);
	} else if (c.y == 2.0) {
		m = mix(vec4(0.1,0.2,1,1), vec4(0.5,0.5,1,1), sin(hitPos.x)) *
			clamp((100.0 - length(hitPos.xy)) / 100.0, 0.0, 1.0);
	} else if (c.y == 3.0) {
		m = vec4(1,1,1,1);	
	} else if (c.y == 4.0) {
		m = (fract(hitPos.x / 3.0) < 0.5 ? vec4(1,0.1,0.2,1) : vec4(1,0.3,0.6,1));
	} else if (c.y == 5.0) {
		m = (fract(hitPos.x / 3.0) < 0.5 ? vec4(0.1,0.4,1,1) : vec4(0.4,0.6,1,1));
	}
	
	
	return mix(vec4(1,1,1,1), (m * diffuse + vec4(1,1,1,1) * specular) * shade, clamp(c.w / GLOW_AMOUNT, 0.0, 1.0));
	
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
	// Camera
	
	vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
	p.x *= -iResolution.x/iResolution.y;
    vec2 mo = iMouse.xy/iResolution.xy;

	// camera	
	float dist = 50.0;
	
	vec3 ta = vec3(cos(iGlobalTime / 2.0) * 8.0,
					sin(iGlobalTime / 2.0 + 2.0) * 12.0,
				   4.0);
	vec3 ro = vec3(50.0 + cos(iGlobalTime / 2.0) * dist,sin(iGlobalTime / 2.0) * dist * 1.5,
				   4.0);
	
	// camera tx
	vec3 cw = normalize( ta-ro );
	vec3 cp = vec3( 0.0, 0.0, 1.0 );
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
	vec3 rd = normalize( p.x*cu + p.y*cv + 2.5*cw );
	
	float world;
	if (cos(-iGlobalTime / 4.0) > 0.0) {
		world = 0.0;
	} else {
		world = 1.0;
	}
	
	fragColor = getPixel(world, ro, ta, rd);
}