// Shader downloaded from https://www.shadertoy.com/view/4sy3Wd
// written by shadertoy user paniq
//
// Name: Convex Cone Tracing
// Description: Robust and fast conservative estimation of contours and surface limits of convex bodies using Newton-Raphson and a modification of the distance function to f(t) - t*C = 0, where C is the conic aperture.

#define MAX_STEPS 20

#define DAValue vec4

struct DAVec3 {
    DAValue x;
    DAValue y;
    DAValue z;
};

DAVec3 da_domain(vec3 p) {
	return DAVec3(
        DAValue(1.0,0.0,0.0,p.x),
        DAValue(0.0,1.0,0.0,p.y),
        DAValue(0.0,0.0,1.0,p.z));
}

DAValue da_const(float a) {
    return DAValue(0.0,0.0,0.0,a);
}

float safeinv(float x) {
    return (x == 0.0)?x:1.0/x;
}

DAValue da_sub(DAValue a, DAValue b) {
    return a - b;
}
DAValue da_sub(DAValue a, float b) {
    return DAValue(a.xyz, a.w - b);
}
DAValue da_sub(float a, DAValue b) {
    return DAValue(-b.xyz, a - b.w);
}

DAValue da_add(DAValue a, DAValue b) {
    return a + b;
}
DAValue da_add(DAValue a, float b) {
    return DAValue(a.xyz, a.w + b);
}
DAValue da_add(float a, DAValue b) {
    return DAValue(b.xyz, a + b.w);
}

DAValue da_mul(DAValue a, DAValue b) {
    return DAValue(a.xyz * b.w + a.w * b.xyz, a.w * b.w);
}
DAValue da_mul(DAValue a, float b) {
    return a * b;
}
DAValue da_mul(float a, DAValue b) {
    return a * b;
}

DAValue da_div(DAValue a, DAValue b) {
    return DAValue((a.xyz * b.w - a.w * b.xyz) / (b.w * b.w), a.w / b.w);
}
DAValue da_div(DAValue a, float b) {
    return a / b;
}
DAValue da_div(float a, DAValue b) {
    return DAValue((-a * b.xyz) / (b.w * b.w), a / b.w);
}

DAValue da_min(DAValue a, DAValue b) {
    return (a.w <= b.w)?a:b;
}
DAValue da_min(DAValue a, float b) {
    return (a.w <= b)?a:da_const(b);
}
DAValue da_min(float a, DAValue b) {
    return (a < b.w)?da_const(a):b;
}

DAValue da_max(DAValue a, DAValue b) {
    return (a.w >= b.w)?a:b;
}
DAValue da_max(DAValue a, float b) {
    return (a.w >= b)?a:da_const(b);
}
DAValue da_max(float a, DAValue b) {
    return (a > b.w)?da_const(a):b;
}

DAValue da_pow2 (DAValue a) {
    return DAValue(2.0 * a.w * a.xyz, a.w * a.w);
}

DAValue da_sqrt (DAValue a) {
    float q = sqrt(a.w);
    return DAValue(0.5 * a.xyz * safeinv(q), q);
}
        
DAValue da_abs(DAValue a) {
    return DAValue(a.xyz * sign(a.w), abs(a.w));
}
DAValue da_sin(DAValue a) {
    return DAValue(a.xyz * cos(a.w), sin(a.w));
}
DAValue da_cos(DAValue a) {
    return DAValue(-a.xyz * sin(a.w), cos(a.w));
}
DAValue da_log(DAValue a) {
    return DAValue(a.xyz / a.w, log(a.w));
}
DAValue da_exp(DAValue a) {
    float w = exp(a.w);
    return DAValue(a.xyz * w, w);
}


DAValue da_length(DAValue x,DAValue y) {
    float q = length(vec2(x.w,y.w));
    return DAValue((x.xyz * x.w + y.xyz * y.w) * safeinv(q), q);
}
DAValue da_length(DAValue x,DAValue y,DAValue z) {
    float q = length(vec3(x.w,y.w,z.w));
    return DAValue((x.xyz * x.w + y.xyz * y.w + z.xyz * z.w) * safeinv(q), q);
}

// s: width, height, depth, thickness
// r: xy corner radius, z corner radius
DAValue sdSuperprim(DAVec3 p, vec4 s, vec2 r) {
    DAValue dx = da_sub(da_abs(p.x),s.x);
    DAValue dy = da_sub(da_abs(p.y),s.y);
    DAValue dz = da_sub(da_abs(p.z),s.z);
    DAValue q = 
        da_add(
            da_length(
                da_max(da_add(dx, r.x), 0.0),
                da_max(da_add(dy, r.x), 0.0)),
            da_min(-r.x,da_max(dx,dy)));
    return da_add(
                da_length(
                    da_max(da_add(q, r.y),0.0),
                    da_max(da_add(dz, r.y),0.0)),
                da_min(-r.y,da_max(q,dz)));
}

// example parameters
#define SHAPE_COUNT 10.0
void getfactor (int i, out vec4 s, out vec2 r) {
    //i = 8;
    if (i == 0) { // cube
        s = vec4(1.0);
        r = vec2(0.0);
    } else if (i == 1) { // corridor
        s = vec4(vec3(1.0),0.25);
        r = vec2(0.0);
    } else if (i == 2) { // pipe
        s = vec4(vec3(1.0),0.25);
        r = vec2(1.0,0.0);
    } else if (i == 3) { // cylinder
        s = vec4(1.0);
        r = vec2(1.0,0.0);
	} else if (i == 4) { // pill
        s = vec4(1.0,1.0,2.0,1.0);
        r = vec2(1.0);
    } else if (i == 5) { // sphere
        s = vec4(1.0);
        r = vec2(1.0);
    } else if (i == 6) { // pellet
        s = vec4(1.0,1.0,0.25,1.0);
        r = vec2(1.0,0.25);
    } else if (i == 7) { // torus
        s = vec4(1.0,1.0,0.25,0.25);
        r = vec2(1.0,0.25);
    } else if (i == 8) { // sausage mouth
        s = vec4(2.0,0.5,0.25,0.25);
        r = vec2(0.5,0.25);
    } else if (i == 9) { // beveled O
        s = vec4(0.7,1.0,1.0,0.25);
        r = vec2(0.125);
	}
}


void doCamera( out vec3 camPos, out vec3 camTar, in float time, in float mouseX )
{
    float an = 1.5 + sin(time * 0.1) * 0.7;
	camPos = vec3(4.5*sin(an),2.0,4.5*cos(an));
    camTar = vec3(0.0,0.0,0.0);
}

vec3 doBackground( void )
{
    return vec3( 0.0, 0.0, 0.0);
}

// polynomial smooth min (k = 0.1);
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

DAValue doobject (DAVec3 p, float k) {
    float u = smoothstep(0.0,1.0,smoothstep(0.0,1.0,fract(k)));
    int s1 = int(mod(k,SHAPE_COUNT));
    int s2 = int(mod(k+1.0,SHAPE_COUNT));
    
    vec4 sa,sb;
    vec2 ra,rb;
    getfactor(s1,sa,ra);
    getfactor(s2,sb,rb);
    
    return  sdSuperprim(DAVec3(p.z, p.y, p.x), mix(sa,sb,u), mix(ra,rb,u));
}

bool interior;

DAValue doModel( DAVec3 p ) {
    float k = iGlobalTime*0.5;
    DAValue d = doobject(p, k);
    return d;
}

float calcIntersection( in vec3 ro, in vec3 rd, vec2 pixel, float bias, out int steps )
{
	const float maxd = 20.0;           // max trace distance
	//float precis = 0.86602540378444 * max(pixel.y,pixel.x);        // precission of the intersection
    float precis = 0.70710678118655 * max(pixel.y,pixel.x);        // precission of the intersection
    DAValue h;
    float t = 0.0;
	float res = -1.0;
    steps = 0;
    float tc = (bias > 0.0)?0.0:1.0;
    
    for( int i=0; i<MAX_STEPS; i++ )          // max number of raymarching iterations is 90
    {
        steps = i;
        DAValue dt = DAValue(1.0,0.0,0.0,t);
        DAValue px = da_add(ro.x, da_mul(rd.x, dt));
        DAValue py = da_add(ro.y, da_mul(rd.y, dt));
        DAValue pz = da_add(ro.z, da_mul(rd.z, dt));
	    h = doModel(DAVec3(px,py,pz));
        // apply conic shearing
        h = da_sub(h, da_mul(dt, bias*precis));
        // compute step size towards root
        float st = abs(h.w) / max(-h.x,0.0);        
        t += st;
    	if((abs(h.w) <= 1e-6) || (t > maxd)) {
            break;
        }
    }
    
    if (abs(h.w) <= 1e-3)
		res = t;
    return res;
}

vec3 calcNormal( in vec3 pos )
{
    DAValue d = doModel(da_domain(pos));
    return d.xyz;
}

mat3 calcLookAtMatrix( in vec3 ro, in vec3 ta, in float roll )
{
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(roll),cos(roll),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    return mat3( uu, vv, ww );
}

bool dorender( out float dist, out int steps, out vec3 position, in vec2 fragCoord, in vec2 resolution, in float bias)
{
    vec2 p = (-resolution.xy + 2.0*fragCoord.xy)/resolution.y;

    //-----------------------------------------------------
    // camera1
    //-----------------------------------------------------
    
    // camera movement
    vec3 ro, ta;
    doCamera( ro, ta, iGlobalTime, 0.0 );

    // camera matrix
    mat3 camMat = calcLookAtMatrix( ro, ta, 0.0 );  // 0.0 is the camera roll
    
	// create view ray
	vec3 rd = normalize( camMat * vec3(p.xy,2.0) ); // 2.0 is the lens length

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------

	vec3 col = doBackground();

	// raymarch
    float t = calcIntersection( ro, rd, 1.0 / resolution, bias, steps );
    dist = t;
    if( t>-0.5 )
    {
        // geometry
        position = ro + t*rd;
        return true;
	}
    return false;
}

vec3 hue2rgb (float hue) {
    return clamp(abs(mod(hue * 6.0 + vec3(0.0,4.0,2.0),6.0) - 3.0) - 1.0,0.0,1.0);
}

// maps n=0 to blue, n=1 to red, n=0.5 to green
vec3 normhue (float n)  {
    return hue2rgb((1.0 - clamp(n,0.0,1.0)) * 0.66667);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord)
{
    
    float dist;
    float dist_inner;
    float dist_outer;
    
    interior = false;
    vec2 resolution = iResolution.xy;
    vec3 pos;
    int steps;
    bool hit = dorender(dist, steps, pos, fragCoord, resolution, 1.0);
    
    float K = 16.0;
    vec2 uv = fragCoord / iResolution.xy;
    vec2 hresolution = floor((iResolution.xy + (K - 1.0)) / K);
    vec2 hfragCoord = floor(uv * hresolution) + 0.5;
    interior = false;
    vec3 pos_inner;
    int steps_inner;
    bool hit_inner = dorender(dist_inner, steps_inner, pos_inner, hfragCoord, hresolution, -1.0);
    interior = false;
    vec3 pos_outer;
    int steps_outer;
    bool hit_outer = dorender(dist_outer, steps_outer, pos_outer, hfragCoord, hresolution, 1.0);
    
    fragColor = vec4(vec3(0.0),1.0);
    if (hit_outer) {
        if (hit_inner) {
            if (hit) {
	        	vec3 nor = calcNormal(pos);
            	fragColor = vec4((nor*0.5+0.5)*0.5,1.0);
            } else {
                // must not happen
                fragColor = vec4(vec3(1.0),1.0);
            }
        } else if (hit)
            fragColor.g = 1.0;	
        else
        	fragColor.r = 1.0;
	} else if (hit) {
        // must not happen
        fragColor = vec4(vec3(1.0),1.0);
    }

    if (hit) {
        // outer shell always closer than surface
        if (dist < dist_outer)
            fragColor = vec4(1.0,0.7,0.0,1.0);
       	// inner shell always contained within surface
        else if (hit_inner && (dist_inner < dist))
            fragColor = vec4(1.0,0.7,1.0,1.0);
    }
    //fragColor = vec4(normhue(dist_inner - dist),1.0);
}