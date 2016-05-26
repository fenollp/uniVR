// Shader downloaded from https://www.shadertoy.com/view/XsdGzs
// written by shadertoy user Varcho
//
// Name: Julia3D
// Description: julia set visualization
//    
#define EPSILON 0.01
#define BOUNDING_RAD 3.0
#define TEX_SCALE 10.0

vec3 getNormal(vec3 pos, vec4 c, float k);

vec4 quatMultiply(vec4 a, vec4 b) {
    return vec4(a.x * b.x - a.y * b.y - a.z * b.z - a.w * b.w, 
                a.y * b.x + a.x * b.y - a.w * b.z + a.z * b.w, 
                a.z * b.x + a.w * b.y + a.x * b.z - a.y * b.w, 
                a.w * b.x - a.z * b.y + a.y * b.z + a.x * b.w);
}

float intersectJulia(vec3 ro, vec3 rd, vec4 c, float k) {
    float t = 0.0;
    float d = 0.0;
    for (int i = 0; i < 300; i++) {
        vec4 z = vec4(ro, k);
    	vec4 zp = vec4(1., 0.0, 0.0, 0.0);
        
        // iterate to find distance
        for (int j = 0; j < 15; j++) {
        	zp = 2.0 * quatMultiply(z, zp);
            z = quatMultiply(z, z) + c;
            if( dot( z, z ) > 100.0 ) {
            	break; 
            }
        }
        float norm_z = length(z);
    	t = (.5 * norm_z * log(norm_z)) / length(zp);
        d+=t;
        ro += rd * t;
        if (t < EPSILON || dot(ro, ro) > BOUNDING_RAD) {
        	break;
        }
    }
    if (t <EPSILON) {
    	return d;
    } else {
    	return -1.0;
    }
}

vec3 getColor(vec3 pos, vec3 view, vec3 n, vec4 c, float k) {
    vec3 light1 = normalize(vec3(1., 1., 1.));
    vec3 light2 = vec3(0., 1., 0.);
    vec3 light3 = vec3(0., 0., 1.);
    
    vec3 norm = getNormal(pos, c, k);
    float t1 = intersectJulia(pos + 10. * EPSILON * light1, 
                              -light1, c, k);
    float shadowed1 = 1.0;
    if (t1 < 0.0) {
    	shadowed1 = 0.0;
    } 
    shadowed1 = smoothstep(-0.0, 0.01, t1);
    
    return shadowed1 * vec3(max(dot(norm, light1), 0.0)) * vec3(1., 0., 0.)
        + .6 * abs(n) + .6 *abs(pos);
}

vec3 getBackgroundColor(vec3 dir) {
    float n = dot(dir, vec3(0., 1., 0.));
    vec3 red = smoothstep(.3, .4, n) * vec3(.81, 0.06, 0.15);
    vec3 white = smoothstep(.4, .3, abs(n)) * vec3(1.0);
    vec3 green = smoothstep(.3, .4, -n) * vec3(0.0, 0.61, 0.28);
    return vec3(.1);//red + white + green;
}

vec3 getNormal(vec3 pos, vec4 c, float k) {
    
    vec4 zp = vec4(pos, k);
	float DELTA = 0.001;
    
    // use basic central differences to find normal
    vec4 nxp = zp + vec4(DELTA, 0.0, 0.0, 0.0);
    vec4 nxm = zp - vec4(DELTA, 0.0, 0.0, 0.0);
    vec4 nyp = zp + vec4(0.0, DELTA, 0.0, 0.0);
    vec4 nym = zp - vec4(0.0, DELTA, 0.0, 0.0);
    vec4 nzp = zp + vec4(0.0, 0.0, DELTA, 0.0);
    vec4 nzm = zp - vec4(0.0, 0.0, DELTA, 0.0);
    
    // iterate to determine divergence <- need better description
    for (int i = 0; i < 10; i++) {
    	nxp = quatMultiply(nxp, nxp) + c;
        nxm = quatMultiply(nxm, nxm) + c;
        nyp = quatMultiply(nyp, nyp) + c;
        nym = quatMultiply(nym, nym) + c;
        nzp = quatMultiply(nzp, nzp) + c;
        nzm = quatMultiply(nzm, nzm) + c;
    }
        
    // grad = length of vectors
    return normalize(vec3(length(nxp) - length(nxm),
                         length(nyp) - length(nym),
                         length(nzp) - length(nzm)));//));
}

// basic sphere intersection to determine if raymarching necessary
float intersectSphere(in vec3 ro, in vec3 rd) {
   float B, C, d, t0, t1, t;
   float radius = BOUNDING_RAD;
   B = 2. * dot( ro, rd );
   C = dot( ro, ro ) - radius;
   d = sqrt( B*B - 4. *C );
   t0 = ( -B + d ) * 0.5;
   t1 = ( -B - d ) * 0.5;
   t = min( t0, t1 );
   return t;
}


//takes in 3d point (which lies on ray)..
// and returns closest distance to point
float map( in vec3 p )
{   
    // ground plane
	float plane =  p.y+2.0;
    return plane;
}

//start with original poin (ro), and original direction (rd)
// then iterate the point along the ray 
// with each iteration move the point x units along the ray
// where x is the distance from the point to the closest object in the scene (via map)
// once x is small enough, then an intersection can be assumed
float intersect( in vec3 ro, in vec3 rd )
{
	const float maxd = 40.0;
	float h = 1.0;
    float t = 0.0;
    for( int i=0; i<80; i++ )
    {
        if( h<0.001 || t>maxd ) break;
	    h = map( ro+rd*t );
        t += h;
    }

    if( t>maxd ) t=-1.0;
	
    return t;
}

vec3 calcNormal( in vec3 pos )
{
    vec3 eps = vec3(0.001,0.0,0.0);
    //use epsilon-delta limit to approximate normal
	return normalize( vec3(
           map(pos+eps.xyy) - map(pos-eps.xyy),
           map(pos+eps.yxy) - map(pos-eps.yxy),
           map(pos+eps.yyx) - map(pos-eps.yyx) ) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{    
    vec2 q = fragCoord.xy/iResolution.xy;
	vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;
    
    float theta = iGlobalTime/5.0;
    mat3 rotMat = mat3(cos(theta), 0.0, sin(theta),
                      0.0, 1.0, 0.0,
                      -sin(theta), 0.0, cos(theta));
    
    vec3 view = vec3(0.0, 0.0, -1.);
	vec3 rd = normalize( vec3(p,-1.) );
    
    view = view * rotMat;
    rd = rd * rotMat;
    
    vec3 ro = -3. * view;
    vec3 eye = ro;
    vec3 col = getBackgroundColor(rd);
    vec4 mu = vec4(abs(sin(iGlobalTime / 3.0)),
                       .8 * sin(iGlobalTime / 5.0),
                       .5 * sin(iGlobalTime / 7.0),
                       .5 * sin(iGlobalTime / 11.0));
        
    mu = vec4(sin(iGlobalTime),cos(iGlobalTime),.0,.0);
    float k = 0.0;
    bool s_inter = false;
    bool j_inter = false;
    
    float t = intersectSphere(ro, rd);
    if (t > 0.0) {
        s_inter = true;
        // update ro to be on radius of bounding sphere
        ro += t * rd;
        
        // k is chosen somewhat arbitrarily to limit 4D quaternion space
        // to 3D Euclidean
        t = intersectJulia(ro, rd, mu, k);
        if (t > 0.0) {
            j_inter = true;
        	ro += t * rd;
            vec3 norm = getNormal(ro, mu, k);
            col = getColor(ro, eye, norm, mu, k);
        } 
    } 
   	
    // Ground plane coloring
    if (!j_inter) {
    	float t = intersect(ro, rd);
        if (t > 0.) {
            ro += t * rd;
            vec3 norm = calcNormal(ro);
            ro = ro + EPSILON * norm;
            
            // trace towards ground plane
            col = ro;
            t = intersectJulia(ro, vec3(1., 2., 0.), mu, k);
            
            col = texture2D( iChannel0, ro.xz / TEX_SCALE ).xyz;
            if (t > -0.1) {
            	col *= .6;
            }
            
        }
    }
    fragColor = vec4(col, 1.0 );
}