// Shader downloaded from https://www.shadertoy.com/view/MscXzS
// written by shadertoy user cornusammonis
//
// Name: Lung Morphogenesis Glass
// Description: Wait a few seconds for it to get started. 3D raymarched reaction-diffusion, using a propagating L1 distance field. Mouse controls the camera, spacebar resets.
/*
	
	Lung Morphogenesis Glass 

	This is a reaction-diffusion model of lung morphogenesis, raymarched using a propagating
    L1 distance field, and rendered with a glass shader. 

    For more information on the lung morphogenesis model see this paper:

	http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0102718

	Buffer A contains the 3D reaction-diffusion system, and Buffer B contains the gradients
    of the reaction-diffusion system (used to improve the stability). 
	Buffer C contains a propagating distance field derived from a 3D level set (3D contours) 
	on the voxel data in Buffer A. 

	Packing and volume sampling is based on Paniq's Light Propagation Volume shadertoy here:

	https://www.shadertoy.com/view/XdtSRn
    

*/

#define AA_SAMPLES 1
#define SCALE 0.18

#define PI 3.14159265359

const vec3 size = vec3(48.0);

float packfragcoord2 (vec2 p, vec2 s) {
    return floor(p.y) * s.x + p.x;
}
vec2 unpackfragcoord2 (float p, vec2 s) {
    float x = mod(p, s.x);
    float y = (p - x) / s.x + 0.5;
    return vec2(x,y);
}
float packfragcoord3 (vec3 p, vec3 s) {
    return floor(p.z) * s.x * s.y + floor(p.y) * s.x + p.x;
}
vec3 unpackfragcoord3 (float p, vec3 s) {
    float x = mod(p, s.x);
    float y = mod((p - x) / s.x, s.y);
    float z = (p - x - floor(y) * s.x) / (s.x * s.y);
    return vec3(x,y+0.5,z+0.5);
}

vec4 fetch(vec3 p) {
    p = clamp(p, vec3(0.5), size - 0.5);
    float posidx = packfragcoord3(p, size);
    vec2 uv = unpackfragcoord2(posidx, iChannelResolution[0].xy) / iChannelResolution[0].xy;
    return texture2D(iChannel0, uv);    
}

// branchless range check
float inrange(float x, float min, float max) {
    return abs(0.5 * (sign(max - x)  + sign(x - min)));   
}

float inrange(vec3 x, vec3 min, vec3 max) {
    return inrange(x.x, min.x, max.x) * inrange(x.y, min.y, max.y) * inrange(x.z, min.z, max.z);  
}

// bounding box
bool box(vec3 ro, vec3 rd, vec3 lb, vec3 rt, out float t) {
    vec3 inv = 1.0 / rd;
    
    vec3 t0 = (lb - ro) * inv;
    vec3 t1 = (rt - ro) * inv;
    
    vec3 max0 = max(t0, t1);
    vec3 min0 = min(t0, t1);
    
    float tmax = min(min(max0.x, max0.y), max0.z);
    float tmin = max(max(min0.x, min0.y), min0.z);

    t = tmin;

    return (tmax < 0.0 || tmin > tmax) ? false : true;
}

vec2 sample_trilin(vec3 p) {
    p = p * size;
    const vec3 off = vec3(0.5);
    float inr = inrange(p, off, size - off);
    vec3 pc = clamp(p, off, size - off);

    vec2 e = vec2(0.0,1.0);
    vec4 p000 = fetch(pc + e.xxx);
    vec4 p001 = fetch(pc + e.xxy);
    vec4 p010 = fetch(pc + e.xyx);
    vec4 p011 = fetch(pc + e.xyy);
    vec4 p100 = fetch(pc + e.yxx);
    vec4 p101 = fetch(pc + e.yxy);
    vec4 p110 = fetch(pc + e.yyx);
    vec4 p111 = fetch(pc + e.yyy);

    vec3 w = fract(pc);

    vec3 q = 1.0 - w;

    vec2 h = vec2(q.x,w.x);
    vec4 k = vec4(h*q.y, h*w.y);
    vec4 s = k * q.z;
    vec4 t = k * w.z;
        
    vec4 tril = 
          p000*s.x + p100*s.y + p010*s.z + p110*s.w
        + p001*t.x + p101*t.y + p011*t.z + p111*t.w;
    
    return vec2(tril.x, inr);

}

vec3 rayToTexture( vec3 p ) {
    return (p*SCALE + vec3(0.5,0.5,0.5));
}

vec2 doModel( vec3 p ) {
    p = rayToTexture(p);
    return sample_trilin(p);  
}

bool doBox( vec3 ro, vec3 rd, out float t ) {
    ro = rayToTexture(ro);
    vec3 b = vec3(0.0);
    bool res = box(ro, rd, b, 1.0 - b, t);
    t = (1.0/SCALE) * t;
    return res;
}

vec2 calcIntersection( in vec3 ro, in vec3 rd )
{
	const float maxd = 10.0;           // max trace distance
	const float precis = 1.0;          // precision of the intersection
    float h = precis*2.0;
    float t = 0.0;
	float res = -1.0;
    float wentInside = 0.0;
    for( int i=0; i<200; i++ )          // max number of raymarching iterations is 90
    {
        if( h<precis||t>maxd ) {
            wentInside = 1.0;
            break;
        }
        float d = doModel(ro+rd*t).x;
        float inside = doModel(ro+rd*t).y;
        if (inside < 0.5) {
        	t += 0.01;    
        } else {
            t += 0.01 * d;
            h = d;
        }
    }

    if( t<maxd ) return vec2(t, wentInside);
    return vec2(res, 0.0);
}

vec3 calcNormal( in vec3 pos )
{
	// precision of the normal computation
    const float eps = 0.01;           

    const vec3 v1 = vec3( 1.0,-1.0,-1.0);
    const vec3 v2 = vec3(-1.0,-1.0, 1.0);
    const vec3 v3 = vec3(-1.0, 1.0,-1.0);
    const vec3 v4 = vec3( 1.0, 1.0, 1.0);

	return normalize( v1*doModel( pos + v1*eps ).x + 
					  v2*doModel( pos + v2*eps ).x + 
					  v3*doModel( pos + v3*eps ).x + 
					  v4*doModel( pos + v4*eps ).x );
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

// filmic gamma function by Paniq
vec3 ff_filmic_gamma3(vec3 linear) {
    vec3 x = max(vec3(0.0), linear-0.004);
    return (x*(x*6.2+0.5))/(x*(x*6.2+1.7)+0.06);
}

vec3 texCube(vec3 rd) {
 	return pow(textureCube(iChannel1, rd * vec3(1.0, -1.0, 1.0)).xyz, vec3(2.0));   
}

// Fresnel factor from TambakoJaguar's Diamond Test shader here: https://www.shadertoy.com/view/XdtGDj
// see also: https://en.wikipedia.org/wiki/Schlick's_approximation
float fresnel(vec3 ray, vec3 norm, float n2)
{
   float n1 = 1.0;
   float angle = clamp(acos(-dot(ray, norm)), -3.14/2.15, 3.14/2.15);
   float r0 = pow((n1-n2)/(n1+n2), 2.);
   float r = r0 + (1. - r0)*pow(1. - cos(angle), 5.);
   return clamp(0., 1.0, r);
}

void doCamera( out vec3 camPos, out vec3 camTar, in float time, in vec4 m ) {
    if (max(m.z, m.w) <= 0.0) {
    	float an = 1.5 + sin(time * 0.1) * 4.0;
		camPos = vec3(6.5*sin(an), 0.0 ,6.5*cos(an));
    	camTar = vec3(0.0,0.0,0.0);        
    } else {
    	float an = 10.0 * m.x - 5.0;
		camPos = vec3(6.5*sin(an),10.0 * m.y - 5.0,6.5*cos(an));
    	camTar = vec3(0.0,0.0,0.0);
    }
}

vec3 doBackground( void ) {
    return vec3( 0.0, 0.0, 0.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    vec4 m = vec4(iMouse.xy/iResolution.xy, iMouse.zw);
    
    // camera movement
    vec3 ro, ta;
    doCamera( ro, ta, iGlobalTime, m );
    
    // camera matrix
    mat3 camMat = calcLookAtMatrix( ro, ta, 0.0 );  // 0.0 is the camera roll
    
    // delta for antialiasing
    float dh = (0.666 / iResolution.y);

	vec3 colmin, colmax, colavg, colavg2, col = vec3(0.0);
    
    vec3 cols[AA_SAMPLES];
    
    const float rads = 6.283185 / float(AA_SAMPLES);
    
    for (int i = 0; i < AA_SAMPLES; i++) {
        
        // create view ray
        vec2 dxy = dh * vec2(cos(float(i) * rads), sin(float(i) * rads));
        vec3 rd = normalize( camMat * vec3(p.xy + dxy,2.0)); // 2.0 is the lens length
		vec3 tc = texCube(rd);
        
        float t;
        if (doBox(ro, rd, t)) {
        	ro = ro + t * rd;
            
            // raymarch
        	vec2 res = calcIntersection( ro, rd );
            if (res.y == 0.0) {
            	t = -1.0;    
            } else {
            	t = res.x;    
            }
        } else {
        	t = -1.0;    
        }
        

        if( t>-0.5 )
        {
            // geometry
            vec3 pos = ro + t*rd;
            vec3 nor = calcNormal(pos);
            
            // vec3 tc = doLighting( pos, nor, rd, t, mal );
            vec3 refl = texCube(reflect(rd, nor));
            vec3 refr = texCube(refract(rd, nor, 0.7));
            float f = fresnel( rd, nor, 1.2 );
            float atten = sqrt(abs(dot(rd, nor)));
            
            tc = mix(atten * refr, refl, f);
        }
        
        if (i == 0) {
            colmin = tc;   
            colmax = tc; 
        }

        colmin = min(colmin, tc);
        colmax = max(colmax, tc);
        colavg += tc;
        cols[i] = tc;
    }
    
    colavg /= float(AA_SAMPLES);
    
    /* 
		Outlier rejection, cleans up some artifacts when AA is used.
        This process could be iterated an arbitrary number of times
		to get convergence, but doing it twice seems to be sufficient.
    */ 
    float sum = 0.0;
    for (int i = 0; i < AA_SAMPLES; i++) {
    	vec3 x = cols[i];
        float w = exp(-length(x - colavg) / 0.2);
        colavg2 += w * x;
        sum += w;
    }
    
    colavg2 /= sum;
    
    float sum2 = 0.0;
    for (int i = 0; i < AA_SAMPLES; i++) {
    	vec3 x = cols[i];
        float w = exp(-length(x - colavg2) / 0.2);
        col += w * x;
        sum2 += w;
    }
    
    col /= sum2;

	col = ff_filmic_gamma3(col);
	   
    fragColor = vec4( col, 1.0 );
}