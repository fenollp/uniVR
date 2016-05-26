// Shader downloaded from https://www.shadertoy.com/view/4tXSR4
// written by shadertoy user dys129
//
// Name: Analytic Area Light 
// Description: http://research.microsoft.com/en-us/um/people/johnsny/papers/arealights.pdf for reference solution (Arvo 1995)
//    http://pascal.lecocq.home.free.fr/publications/lecocq_i3D2016_specularAreaLighting.pdf for Accurate Analytic Approximation
#define PI 3.14159265359

#define MAT_ID_LIGHT 3.
#define saturate(a) clamp(a, 0.,1.)

/*
Set USE_APPROX to 0 to use reference solution (Arvo 1995)
Set USE_APPROX to 1 to use Siggraph 2015: Accurate Analytic Approximations for Real-Time Specular Area Lighting
*/
#define USE_APPROX 1

//0 - for triangle area light
//1 - for quad area light
#define AREA_LIGHT_TYPE 0

vec3 lightClr = vec3(1.0, 0.0, 0.0);

//specular power
const int N = 65; 

#if AREA_LIGHT_TYPE==0
#define NUM_VERTS 3
vec3 get_arr(int i)
{  
 	if(i == 0) return vec3(0.1,  0.01, 0.01);  
 	if(i == 1) return vec3(-0.5, 2.0,  0.02);
 	if(i == 2) return vec3(0.5, 2.0,0.03);
    
   	return vec3(0.);
}
#elif AREA_LIGHT_TYPE==1
#define NUM_VERTS 6
vec3 get_arr(int i)
{  
 	if(i == 0) return vec3(1.0,  0.1, 0.0);  
 	if(i == 1) return vec3(-1.0, 0.1,  0.0);
 	if(i == 2) return vec3(-1.0, 2.0,0.0);
    
    if(i == 5) return vec3(-1.0,  2.0, 0.0);  
 	if(i == 3) return vec3(1.0, 2.0,  0.0);
 	if(i == 4) return vec3(1.0, 0.1,0.0);
    
   	return vec3(0.);
}
#endif


float plane( vec3 p )
{
	return p.y;
}

float sphere(vec3 ro, float r)
{
 return length(ro) - r;   
}

float sdBox(vec3 p, vec3 b) {
	vec3 d = abs(p) - b;
	return min(max(d.x, max(d.y, d.z)), 0.) + length(max(d, 0.));
}

vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}

float dot2( in vec3 v ) { return dot(v,v); }
float udTriangle( vec3 p, vec3 a, vec3 b, vec3 c )
{
    vec3 ba = b - a; vec3 pa = p - a;
    vec3 cb = c - b; vec3 pb = p - b;
    vec3 ac = a - c; vec3 pc = p - c;
    vec3 nor = cross( ba, ac );

    return sqrt(
    (sign(dot(cross(ba,nor),pa)) +
     sign(dot(cross(cb,nor),pb)) +
     sign(dot(cross(ac,nor),pc))<2.0)
     ?
     min( min(
     dot2(ba*clamp(dot(ba,pa)/dot2(ba),0.0,1.0)-pa),
     dot2(cb*clamp(dot(cb,pb)/dot2(cb),0.0,1.0)-pb) ),
     dot2(ac*clamp(dot(ac,pc)/dot2(ac),0.0,1.0)-pc) )
     :
     dot(nor,pa)*dot(nor,pa)/dot2(nor) );
}

vec2 scene(vec3 ro)
{
    vec2 polygon = vec2(1000.0, 0.);
    
    for(int i = 0; i < NUM_VERTS; i += 3)
    {
    	polygon = opU(polygon, vec2(udTriangle(ro, get_arr(i), get_arr(i+1), get_arr(i+2)), MAT_ID_LIGHT));
    }
    vec2 pl0 = vec2(plane(ro), 0.0);

 return opU(polygon, pl0);  
}

vec4 getMaterial(float mat_id)
{
	if(mat_id == 0.0) return vec4(1.0, 1.0, 1.0, 0.0);
    else if(mat_id == 1.0) return vec4(0.0, 1.0, 0.0, 0.0);
    else if(mat_id == 2.0) return vec4(1.0, 0.0, 0.0, 0.0);  
    else if(mat_id == MAT_ID_LIGHT) return vec4(1.0, 1.0, 1.0, 0.0);
        return vec4(0.0);
}

vec3 calcNormal( in vec3 pos )
{
	vec3 eps = vec3( 0.01, 0.0, 0.0 );
	vec3 nor = vec3(
	    scene(pos+eps.xyy).x - scene(pos-eps.xyy).x,
	    scene(pos+eps.yxy).x - scene(pos-eps.yxy).x,
	    scene(pos+eps.yyx).x - scene(pos-eps.yyx).x );
	return normalize(nor);
}


float cosine_sine_power_integral_sum(float theta,float cos_theta,float sin_theta,
int n,float a,float b)
{
    float f = a*a + b*b;
    float g = a*cos_theta + b*sin_theta;
    float gsq = g*g;
    float asq = a*a;
    float h = a*sin_theta - b*cos_theta;
    float T,Tsum;
    float l,l2;
    int start;
    /* initial conditions for recurrence */
    //if (n&1) {
    /*T = h+b;
    l = gsq*h;
    l2 = b*asq;
    start = 1;*/
    /*} else { */
    T = theta;
    l = g*h;
    l2 = b*a;
    start = 0;
    //}
    Tsum = T;
    for (int i = 2; i <= N-1; i += 2) 
    {
        T = (l + l2 + f*(float(i)-1.)*T)/float(i);
        l *= gsq;
        l2 *= asq;
        Tsum += T;
    }
    return Tsum;
}

float P(float theta, float a)
{
	return 1.0 / (1.0 + a * theta * theta);    
}

float I_org(float theta, float c, float n)
{
    float cCos = c * cos(theta);
    return (pow(cCos, n+2.) - 1.0) / (cCos * cCos  - 1.)-1.0;
}

float evaluateXW(float c, float n)
{
	return PI/4.*pow(1. - pow(c - c /(n-1.), 2.5), 0.45);   
}


float shd_edge_contribution_approx(vec3 v0, vec3 v1, vec3 n, int e)
{
   float f;
    float cos_theta,sin_theta;
    vec3 q = cross(v0,v1);
    sin_theta = length(q);
    q = normalize(q);
    cos_theta = dot(v0,v1);
    
    if (e == 1) {
        f = acos(cos_theta);
    } else {
        vec3 w;
        float theta;
        theta = acos(cos_theta);
        w = cross(q,v0);
       
        float a = dot(v0,n);
        float b = dot(w,n);
        float x = theta;
        float delta = atan(b, a);
        float c = sqrt(a*a + b*b);
        
        float xw = evaluateXW(c, float(N));
        
        float bias = -0.01; //?
        
        float s = (pow(c, float(e)+2.) - 1.) / (c*c - 1.)-1.;
        float Io = I_org(xw, c, float(e));
        
        float A = (s-Io)/(Io*(xw + bias)*(xw + bias));
 
        float integral =  1. / sqrt(A) * atan(sqrt(A) * x , (1. - A * delta * (x - delta))); 
        
        float vShift = P(PI/2., A);
        float d = 1. - vShift;
        float sNorm = s / d;
                        
        f  = sNorm * (integral - x * vShift)+x;
        f = max(theta,f);
    }
return f*dot(q,n); 
}

float shd_edge_contribution(vec3 v0,vec3 v1,vec3 n,int e)
{
    float f;
    float cos_theta,sin_theta;
    vec3 q = cross(v0,v1);
    sin_theta = length(q);
    q = normalize(q);
    cos_theta = dot(v0,v1);
    
    if (e == 1) {
        f = acos(cos_theta);
    } else {
        vec3 w;
        float theta;
        theta = acos(cos_theta);
        w = cross(q,v0);
        f = cosine_sine_power_integral_sum(theta,cos_theta,sin_theta,e-1,dot(v0,n),dot(w,n));
    }
return f * dot(q,n);
}



void seg_plane_intersection(vec3 v0, vec3 v1, vec3 n, out vec3 q)
{
 vec3 vd;
 float t;
 vd = v1 - v0;
 t = -dot(v0,n)/(dot(vd, n));
 q = v0 + t * vd;
}

float shd_polygonal(vec3 p, vec3 n, bool spc)
{
    int i,i1;
    int J = 0;
    float sum = 0.;
    vec3 ui0,ui1; /* unnormalized vertices of edge */
    vec3 vi0,vi1; /* unit-length vector vertices of edge */
    int belowi0 = 1,belowi1 = 1; /* flag for whether last vertex was below point’s "horizon" */
    /* find first vertex above horizon */
    for (int j = 0; j < NUM_VERTS; j++) {
        vec3 u;
        u = get_arr(j) - p;
        if (dot(u,n) >= 0.0) {
            ui0 = u;
            vi0 = u;
            vi0 = normalize(vi0);
            belowi0 = 0;
            J = j;
            break;
        }
    } 
    
    if (J >= NUM_VERTS) return 0.;
    
    i1 = J;
	for (int i = 0; i < NUM_VERTS; i++) 
    {
        i1++;
        if (i1 >= NUM_VERTS) i1 = 0;
        
        ui1 = get_arr(i1) - p;
        belowi1 = int(dot(ui1,n) < 0.);
        
        if (belowi1 == 0) {
            vi1 = ui1;
            vi1 = normalize(vi1);
        }
 
        if (belowi0!=0 && belowi1==0) {
            vec3 vinter;
            seg_plane_intersection(ui0,ui1,n,vinter);
            vinter = normalize(vinter+0.01);                        
            sum += shd_edge_contribution(vi0,vinter,n,1);            
            vi0 = vinter;
        }  else if (belowi0==0 && belowi1!=0) {
            seg_plane_intersection(ui0,ui1,n,vi1);
            vi1 = normalize(vi1);
        }
     	int K = spc ? N : 1;
        #if USE_APPROX
       	if (belowi0==0 || belowi1==0) sum += shd_edge_contribution_approx(vi0,vi1,n,K);
        #else
        if (belowi0==0 || belowi1==0) sum += shd_edge_contribution(vi0,vi1,n,K);
        #endif
        
		ui0 = ui1;
		vi0 = vi1;
		belowi0 = belowi1;
    }
    
    if (sum < 0.) sum = -sum;
    
    return sum / (2.0 * PI);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{     
    vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;
   // vec2 mo = -1.0 + 2.0 * iMouse.xy/iResolution.xy;
   

    vec3 ro = vec3(6.0 * sin(iGlobalTime), 2.2, 6.0 * cos(iGlobalTime));

	vec3 ta = vec3(0.0, 0.0, 0.0);
    vec3 ww = normalize( ta - ro);
    vec3 uu = normalize(cross( vec3(0.0,1.0,0.0), ww ));
    vec3 vv = normalize(cross(ww,uu));
    vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );
    
    
    float t = 1.0;
    vec4 clr = vec4(0.0);
    for(int i =0; i<64; i++)
    {
        vec2 hit = scene(ro+t*rd);
        float eps = 0.001;
        if(hit.x < eps)
        {
            vec4 mat = getMaterial(hit.y);
            if(hit.y ==  MAT_ID_LIGHT)
            {
                clr.rgb = lightClr;
                break;
            }
                 
        	vec3 pos = ro + t*rd;
        	vec3 nrm = calcNormal( pos );
        	vec3 rfl = reflect( rd, nrm );   
             vec3 test_out;           
            float diff = shd_polygonal(pos, nrm, false);
            
            
            float spc = saturate(shd_polygonal(pos, rfl, true));
			clr.rgb = lightClr * (diff+spc) * mat.rgb;
            break;
        }
        
        t += max(hit.x, 0.001);
    }
   
    clr.rgb = pow(clr.rgb, vec3(1.0 / 2.2));
    
	fragColor = clr;
}