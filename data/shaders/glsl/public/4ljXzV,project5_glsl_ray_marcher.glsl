// Shader downloaded from https://www.shadertoy.com/view/4ljXzV
// written by shadertoy user ziyezhou
//
// Name: Project5-GLSL-Ray-Marcher
// Description: add sphere tracing with over relaxation
// ======================= Global Definition =======================
#define DEPTH_VIEW 0
#define ITERATION_VIEW 0
#define Point3 vec3
#define Vector3 vec3
#define Vector2 vec2
#define lerp mix
#define mat4x4 mat4
#define MAX_T 20.0
#define MIN_T 1.0
#define MAX_ITER 50
#define Over_relaxation_factor 1.0 
float maxComponent(vec3 v) { return max(v.x, max(v.y, v.z)); }
float maxComponent(vec2 v) { return max(v.x, v.y); }

float saturate(float x) { return clamp(x, 0.0, 1.0); }


// ======================= Matrix Basic =======================

//part from G3D Innovation Engine’s g3dmath.glsl

mat4x4 identity4x4() {
    return mat4x4(1,0,0,0,
                  0,1,0,0,
                  0,0,1,0,
                  0,0,0,1);
}

/** Constructs a 4x4 translation matrix, assuming T * v multiplication. */
mat4x4 translate4x4(Vector3 t) {
    return mat4x4(1,0,0,0,
                  0,1,0,0,
                  0,0,1,0,
                  t,1);
}

/** Constructs a 4x4 Y->Z rotation matrix, assuming R * v multiplication. a is in radians.*/
mat4x4 pitch4x4(float a) {
    return mat4x4(1, 0, 0, 0,
                  0,cos(a),-sin(a), 0,
                  0,sin(a), cos(a), 0,
                  0, 0, 0, 1);
}

/** Constructs a 4x4 X->Y rotation matrix, assuming R * v multiplication. a is in radians.*/
mat4x4 roll4x4(float a) {
    return mat4x4(cos(a),-sin(a),0,0,
                  sin(a), cos(a),0,0,
                  0,0,1,0,
                  0,0,0,1);
}

/** Constructs a 4x4 Z->X rotation matrix, assuming R * v multiplication. a is in radians.*/
mat4x4 yaw4x4(float a) {
    return mat4x4(cos(a),0,sin(a),0,
                  0,1,0,0,
                  -sin(a),0,cos(a),0,
                  0,0,0,1);
}

mat4x4 scale4x4(vec3 m_scale)
{
	return mat4x4(m_scale.x,0,0,0,
                  0,m_scale.y,0,0,
                  0,0,m_scale.z,0,
                  0,0,0,1);
}

// ======================= Operations on Distance Estimators =======================

float unionDistance(float d1, float d2) {
	return min(d1, d2);
}

float intersectionDistance(float d1, float d2) {
	return max(d1, d2);
}

float subtractionDistance(float d1, float d2) {
	return max(d1, -d2);
}

float smin(float a, float b, float blendRadius) {
    float c = saturate(0.5 + (b - a) * (0.5 / blendRadius));
    return lerp(b, a, c) - blendRadius * c * (1.0 - c);
}

float blendDistance(float d1, float d2, float blendRadius)
{
    return smin(d1, d2, blendRadius);
}

// ======================= Primitive Sign Distance Function =======================

// simple primitive
float sdPlane( Point3 pos )
{
    return pos.y;
}

float sdTerrain(Point3 pos )
{
	return  pos.y - 0.3*sin(2.0*pos.x)*cos(pos.z);
}

float sdSphere( Point3 pos, Point3 center , float r )
{
    return length(pos - center)-r;
}

float sdBox(Point3 X, Point3 C, vec3 b) 
{
	
	vec3 d = abs(X - C) - b;
	return min(maxComponent(d), 0.0) + length(max(d, vec3(0, 0, 0)));
}

float sdRoundedBox(Point3 X, Point3 C,Vector3 b, float r) 
{
	return length(max(abs(X - C) - b, Vector3(0, 0, 0))) - r;
}

float sdTorus(Point3 X, Point3 C, float R, float r)  // R for outer radius  r for inner radius
{
	return length(vec2(length(X.xz - C.xz) - r, X.y - C.y)) - R;
}

float pow8(float x) 
{
    x *= x; // xˆ2
    x *= x; // xˆ4
    return x * x;
}
float length8(Vector2 v) 
{
	return pow(pow8(v.x) + pow8(v.y), 1.0 / 8.0);
}

float sdWheel(Point3 X, Point3 C, float r, float R) // R for outer radius  r for inner radius
{
	return length8(Vector2(length(X.xz - C.xz) - r, X.y - C.y)) - R;
}

float sdCylinder(Point3 X, Point3 C, float r, float e) 
{
    Vector2 d = abs(Vector2(length(X.xz - C.xz), X.y - C.y)) - Vector2(r, e);
    return min(maxComponent(d), 0.0) + length(max(d, Vector2(0, 0)));
}


//primitive with Operations

float sdDoubleSphere(Point3 X) {
	return subtractionDistance(sdSphere(X, Point3(-0.5, 1, 0), 1.0),
	sdSphere(X, Point3(0.5, 1, 0), 1.0));
}


float sdRepeatSphere(Point3 X , vec3 v) //v as period
{
    return sdSphere((mod(X,v)) - v*0.5, vec3(0.0,0.5,0),0.5);
}

float sdDoubleRepeatSphere(Point3 X , vec3 v1, vec3 v2) //v as period
{
    return sdSphere(mod( (mod(X,v1)) - v1*0.5,v2) - v2*0.5, vec3(0.0,0.25,0),0.25);
}
    

// primitive with transformation

float sdSpere_trans(vec3 pos, mat4 trans, mat4 inv_trans, float det_trans)
{
  
    vec3 new_pos = (inv_trans * vec4(pos,1.0)).xyz;
    
    return sdSphere(new_pos,vec3(0.0,0.5,0.0),0.5)*det_trans;
    
    
}


float sdBox_trans(vec3 pos, mat4 trans, mat4 inv_trans, float det_trans)
{
  
    vec3 new_pos = (inv_trans * vec4(pos,1.0)).xyz;
    
    return sdBox(new_pos,vec3(0.0,1.0,0.0),vec3(0.5,0.5,0.5))*det_trans;
    
    
}





// ======================= Util =======================


vec2 CompareDis( vec2 d1, vec2 d2 )
{
    return (d1.x<d2.x) ? d1 : d2;
}




vec2 GetMinDis( in vec3 pos ) // compute the min dis to the primitive in the scene
{
    vec2 res =CompareDis( vec2( sdPlane(pos), 1.0 ),
	            			//vec2(sdBox(pos, vec3(0.0,0.6,0.0),vec3(0.5)) , 46.9));
                         //vec2 (sdBox_trans( pos , yaw4x4(iGlobalTime),yaw4x4(-iGlobalTime),1.0 ), 46.9));
                         
                         vec2( sdDoubleRepeatSphere( pos , vec3(1.0,0.0,0.0) , vec3(0.0,0.0,1.0)), 46.9 ) );  
        
        //vec2(sdTerrain(pos),2.0);
        
        
    return res;
}


vec3 castRay_naive( in vec3 ro, in vec3 rd )
{
    float tmin = MIN_T;
    float tmax = MAX_T;
    
    float precis = 0.002;
    float t = tmin;
    float m = -1.0;
    
    int i_ret = 0;
    for( int i = 0 ; i<20000 ;i++)
    {
        vec2 res = GetMinDis( ro+rd*t );
        m = res.y;
        i_ret = i;
        if( res.x<precis || t>tmax ) break;
        t += 0.001;
      
    }

    if( t>tmax ) m=-1.0;
    return vec3( t, m, i_ret );
}


vec3 castRay( in vec3 ro, in vec3 rd )  //using the distance aided method
{
    float tmin = MIN_T;
    float tmax = MAX_T;
	float minStep = 0.0001;
    
    float precis = 0.002;
    float t = tmin;
    float m = -1.0;
    
   	int i_ret = 0;
    for( int i = 0 ; i<MAX_ITER; i++ )
    {
        vec2 res = GetMinDis( ro+rd*t );
        m = res.y;
        i_ret = i;
        if( res.x<precis || t>tmax ) break;
        t += max(res.x,minStep);
       
        
    }

    if( t>tmax ) m=-1.0;
    return vec3( t, m, i_ret);
}


vec3 castRay_over_relax( in vec3 ro, in vec3 rd )  //using the distance aided method
{
	float tmin = MIN_T;
    float tmax = MAX_T;
	float minStep = 0.0001;
    
    float precis = 0.002;
    float t = tmin;
    float m = -1.0;
    
   	int i_ret = 0;
    
	float old_dis = 0.0;
	float dt  = 0.0;
	
	bool is_over_relax = true;

	for( int i = 0 ; i<MAX_ITER+1; i++ )
    {
        
		vec2 res = GetMinDis( ro+rd*t );
        
		if(is_over_relax)
		{
			if(abs(res.x) + abs(old_dis) < dt ) // check over relax condition & over relax fail 
			{
					is_over_relax = false;
					t = t - dt + dt/Over_relaxation_factor; // start from the new pos
                continue;
					
			}
		}
	
		m = res.y;
        i_ret = i;

        if( res.x<precis || t>tmax ) break;
        
		if(is_over_relax)
		{
			dt  =max(res.x*Over_relaxation_factor,minStep);
			old_dis = abs(res.x);
		}
		else
		{
			dt  =max(res.x,minStep);
		}
		
        t += dt;
        
    }

    if( t>tmax) m=-1.0;
    return vec3( t, m, i_ret);
}


vec3 calcNormal( in vec3 pos )
{
    vec3 eps = vec3( 0.001, 0.0, 0.0 );
    vec3 nor = vec3(
        GetMinDis(pos+eps.xyy).x - GetMinDis(pos-eps.xyy).x,
        GetMinDis(pos+eps.yxy).x - GetMinDis(pos-eps.yxy).x,
        GetMinDis(pos+eps.yyx).x - GetMinDis(pos-eps.yyx).x );
    return normalize(nor);
}


// ======================= Lightning =======================

float computeAO( in vec3 pos, in vec3 nor ) //compute the ambient occlusion
{
    float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ ) //sample over normal direction
    {
        float hr = 0.01 + 0.12*float(i)/4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = GetMinDis( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }

    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

float softshadow( in vec3 ro, in vec3 rd, in float tmin, in float tmax ) //compute the softshadow
{
    float res = 1.0;
    float t = tmin;
    for( int i=0; i<10; i++ ) //sample over the rd direction
    {
        float h = GetMinDis( ro + rd*t ).x;
        res = min( res, 5.0*h/t );
        t += clamp( h, 0.02, 0.10 );
        
		
		if( h<0.001 || t>tmax ) break;
    }
    return clamp( res, 0.0, 1.0 );

}




// ======================= Starter Code  =======================

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(0.8, 0.9, 1.0); // Sky color
    //vec3 res = castRay_over_relax(ro,rd);
    vec3 res = castRay(ro,rd);
    //vec3 res = castRay_naive(ro,rd);
    float t = res.x;
    float m = res.y;
    float num_iter = res.z;
    
    
     #if(DEPTH_VIEW)
    
    	if( m>-0.5 )  // Ray intersects a surface
        {
            return vec3(1.0 - (t - MIN_T) /(MAX_T - MIN_T));
        }
    	else
        {
            return vec3(0.0);
        }
    
    #endif
    
    #if(ITERATION_VIEW)
        
    	if( m>-0.5 )  // Ray intersects a surface
            {
                float max_iter_f = float (MAX_ITER);
                return vec3(num_iter/max_iter_f);
            }
            else
            {
                return vec3(0.0);
            }
    
    #endif
    
    
    
    
    if( m>-0.5 )  // Ray intersects a surface
    {
        vec3 pos = ro + t*rd;
        vec3 nor = calcNormal( pos );
        vec3 ref = reflect( rd, nor );
        
        // material        
        col = 0.45 + 0.3*sin( vec3(0.05,0.08,0.10)*(m-1.0) );
        
        if( m<1.5 )
        {
            float f = mod( floor(5.0*pos.z) + floor(5.0*pos.x), 2.0);
            col = 0.4 + 0.1*f*vec3(1.0);
        }
        
        if( m == 2.0)
        {
            col = vec3(182.0/255.0,87.0/255.0, 29.0/255.0) + 0.2*vec3(0.6)*sin(2.0*pos.x)*cos(pos.z) ;
            float r = texture2D( iChannel0, mod(pos.xz,256.0) ).x;
            
            
            col+= r*vec3(0.3);
            
        }

        // lighitng        
       	//float occ  =1.0;//= computeAO( pos, nor );
        float occ  = computeAO( pos, nor );
        vec3  lig = normalize( vec3(-0.6, 0.7, -0.5) );
        float amb = clamp( 0.5+0.5*nor.y, 0.0, 1.0 );
        float dif = clamp( dot( nor, lig ), 0.0, 1.0 );
        float dom = smoothstep( -0.1, 0.1, ref.y );
        float fre = pow( clamp(1.0+dot(nor,rd),0.0,1.0), 2.0 );
        float spe = pow(clamp( dot( ref, lig ), 0.0, 1.0 ),16.0);
        
        dif *= softshadow( pos, lig, 0.02, 2.5 );
        dom *= softshadow( pos, ref, 0.02, 2.5 );

        vec3 m_brdf = vec3(0.0);
        m_brdf += 1.20*dif*vec3(0.90,0.90,0.90);
        m_brdf += 1.20*spe*vec3(0.90,0.90,0.90)*dif;
        m_brdf += 0.30*amb*vec3(0.50,0.70,1.00)*occ;
        m_brdf += 0.40*dom*vec3(0.50,0.70,1.00)*occ;
        m_brdf += 0.40*fre*vec3(1.00,1.00,1.00)*occ;
        m_brdf += 0.02;
        col = col*m_brdf;

        col = mix( col, vec3(0.8,0.9,1.0), 1.0-exp( -0.005*t*t ) ); // add fog
    }
      
     	return vec3( clamp(col,0.0,1.0) );
    
    

   
}

mat3 setCamera(in vec3 ro, in vec3 ta, float cr) {
    // Starter code from iq's Raymarching Primitives
    // https://www.shadertoy.com/view/Xds3zN

    vec3 cw = normalize(ta - ro);
    vec3 cp = vec3(sin(cr), cos(cr), 0.0);
    vec3 cu = normalize(cross(cw, cp));
    vec3 cv = normalize(cross(cu, cw));
    return mat3(cu, cv, cw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Starter code from iq's Raymarching Primitives
    // https://www.shadertoy.com/view/Xds3zN

    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x / iResolution.y;
    vec2 mo = iMouse.xy / iResolution.xy;

    float time = 15.0 + iGlobalTime;

    // camera
    vec3 ro = vec3(
            -0.5 + 3.5 * cos(0.1 * time + 6.0 * mo.x),
            1.0 + 2.0 * mo.y,
            0.5 + 3.5 * sin(0.1 * time + 6.0 * mo.x));
    vec3 ta = vec3(-0.5, -0.4, 0.5);

    // camera-to-world transformation
    mat3 ca = setCamera(ro, ta, 0.0);

    // ray direction
    vec3 rd = ca * normalize(vec3(p.xy, 2.0));

    // render
    vec3 col = render(ro, rd);

    col = pow(col, vec3(0.4545));

    fragColor = vec4(col, 1.0);
}
