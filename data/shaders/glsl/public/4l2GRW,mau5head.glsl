// Shader downloaded from https://www.shadertoy.com/view/4l2GRW
// written by shadertoy user danyo
//
// Name: mau5head
// Description: My first ray marcher!
#define PRECISION 0.0001
#define DEPTH 20.0
#define STEPS 125
#define PI 3.1415926535897932384626433832795
#define OCCLUSION_SAMPLES 8.0
#define OCCLUSION_FACTOR .5

#define BPM 128.0
#define SEC_PER_MIN 60.0

vec3 eye = vec3(0.0);
vec3 light = vec3(0.0,8.0,8.0);
#define LIGHT_COLOR vec3(1.0)
#define LIGHT_AMBIENT vec3(0.05)

mat3 rotmat;

bool hit = false;
struct sMaterial
{
    float metallic;
    float roughness;
    float fresnel_pow;
    vec3 color;
};
sMaterial mat_white = sMaterial(0.0, 5.0, 1.0, vec3(1.0));
sMaterial mat_red = sMaterial(0.0, 1.0, 1.0, vec3(1.0, 0.0, 0.0));
struct sHit
{
    float d;
    sMaterial material;
};
sHit map(vec3);

vec3 getNormal(vec3 p)
{
    vec2 e=vec2(PRECISION,0);
    return(normalize(vec3(map(p+e.xyy).d-map(p-e.xyy).d
                          ,map(p+e.yxy).d-map(p-e.yxy).d
                          ,map(p+e.yyx).d-map(p-e.yyx).d)));}

// ROTATION FUNCTIONS TAKEN FROM
//https://www.shadertoy.com/view/XsSSzG
mat3 xrotate(float t) {
	return mat3(1.0, 0.0, 0.0,
                0.0, cos(t), -sin(t),
                0.0, sin(t), cos(t));
}

mat3 yrotate(float t) {
	return mat3(cos(t), 0.0, -sin(t),
                0.0, 1.0, 0.0,
                sin(t), 0.0, cos(t));
}

mat3 zrotate(float t) {
    return mat3(cos(t), -sin(t), 0.0,
                sin(t), cos(t), 0.0,
                0.0, 0.0, 1.0);
}


mat3 rotate( vec3 r ){
 
   return xrotate( r.x ) * yrotate( r.y ) * zrotate( r.z );
    
}

float udBox( vec3 p, vec3 b )
{
  return length(max(abs(p)-b,0.0));
}

float udRoundBox( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

float sdCone( vec3 p, vec2 c )
{
	// c must be normalized
	float q = length(p.xy);
	return dot(c,vec2(q,p.z));
}

float sdTorus(vec3 p, vec2 t) 
{
    vec2 q = vec2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdTriPrism( vec3 p, vec2 h )
{
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}
float sdCappedCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdPlane( vec3 p, vec4 n )
{
  // n must be normalized
  return dot(p,n.xyz) + n.w;
}

float opU( float d1, float d2 )
{
    return min(d1,d2);
}

float opS( float d1, float d2 )
{
    return max(-d1,d2);
}

float opI( float d1, float d2 )
{
    return max(d1,d2);
}
	
// polynomial smooth min (k = 0.1);
float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return mix( b, a, h ) - k*h*(1.0-h);
}

vec3 opCheapBend( vec3 p , float k)
{
    float c = cos(k*p.y);
    float s = sin(k*p.y);
    mat2  m = mat2(c,-s,s,c);
    vec3  q = vec3(m*p.xy,p.z);
    return q;

}
vec2 hash( vec2 p ) 
{                       // rand in [-1,1]
    p = vec2( dot(p,vec2(127.1,311.7)),
              dot(p,vec2(269.5,183.3)) );
    return -1. + 2.*fract(sin(p+20.)*53758.5453123);
}

sHit map( in vec3 p )
{
    vec3 q = p*rotmat;
    
    //some animation
    q = q / vec3(pow(1.0 + 0.25*sin(PI*fract(iGlobalTime*BPM/SEC_PER_MIN)),2.0));
        
    float mouth = sdTriPrism(zrotate(PI)*q+vec3(-0.866025, -0.5, 0.0), vec2(1.0, 1.5)); //TODO: should be wedge with 50deg edge?
    
    float eyes = opU(sdSphere(q+vec3(0.5,-0.5,0.5), 4.5/14.0),sdSphere(q+vec3(0.5,-0.5,-0.5), 4.5/14.0));
    float head = opS(eyes, opS(mouth, sdSphere(q, 1.0)));
    float teeth = opI(mouth, sdSphere(q, 0.95));

    vec3 ear_p = opCheapBend(q, 0.1); //this causes a strange artifact in soft shadows on my laptop but not my PC?
    //not sure how to fix it but I like the curved ears too much to remove it
    float ear_angle = 70.0 * PI/180.0;
    vec2 ear_size = vec2(0.9,0.1);
    float ears_center = opU(sdCappedCylinder(zrotate(ear_angle)*ear_p+vec3(-1.1, 0.0, -1.1), ear_size)
                     ,sdCappedCylinder(zrotate(ear_angle)*ear_p+vec3(-1.1, 0.0, 1.1), ear_size));
    float ears_edge = opU(sdTorus(zrotate(ear_angle)*ear_p+vec3(-1.1, 0.0, -1.1), ear_size)
                     ,sdTorus(zrotate(ear_angle)*ear_p+vec3(-1.1, 0.0, 1.1), ear_size));
    float ears = opS(head, opU(ears_center,ears_edge));
    
    float walls = opU(sdPlane(p + vec3(0.0, 0.0, 4.0), normalize(vec4(0.0, 0.0, 1.0, 1.0)))
                      ,sdPlane(p + vec3(0.0, 4.0, 0.0), normalize(vec4(0.0, 1.0, 0.0, 1.0)))) + 0.001;
    
    float result = 1e10;
    result = opU(result, head);
    result = opU(result, teeth);
    result = opU(result, eyes);
    result = opU(result, ears);
    result = opU(result, walls);
    
    sHit hit;
    hit.d = result;
    if(result == head || result == ears)
        hit.material = mat_red;
    else
        hit.material = mat_white;
        
    return hit;
}

vec3 march( in vec3 ro, in vec3 rd)
{
    float t=0.0,d;
    
    for(int i=0;i<STEPS;i++)
    {
        d=map(ro+rd*t).d;
        if(abs(d)<PRECISION){hit=true;}
        if(hit==true||t>DEPTH){break;}
        t+=d;
    }
    
    return ro+rd*t;
}

float shadow_march( in vec3 ro, in vec3 rd)
{
    float t=0.01,d;
    
    for(int i=0;i<STEPS;i++)
    {
        d = map(ro + rd*t).d;
        if( d < 0.0001 )
            return 0.0;
        t += d;
    }
    return 1.0;
}

float soft_shadow_march( in vec3 ro, in vec3 rd, float k)
{
    float res = 1.0;
    float t=0.01;//.0001*sin(PI*fract(iGlobalTime));
    float d;
    
    for(int i=0;i<STEPS;i++)
    {
        d = map(ro + rd*t).d;
        if( d < PRECISION )
            return 0.0;
        res = min( res, k*d/t );
        t += d;
    }
    return res;
}

/*  taken from Hamneggs https://www.shadertoy.com/view/4dj3Dw
	Calculates the ambient occlusion factor at a given point in space.
	Uses IQ's marched normal distance comparison technique.
*/
float calcOcclusion(vec3 pos, vec3 surfaceNormal)
{
	float result = 0.0;
	vec3 normalPos = vec3(pos);
	for(float i = 0.0; i < OCCLUSION_SAMPLES; i+=1.0)
	{
		normalPos += surfaceNormal * (1.0/OCCLUSION_SAMPLES);
		result += (1.0/exp2(i)) * (i/OCCLUSION_SAMPLES)-map(normalPos).d;
	}
	return 1.0-(OCCLUSION_FACTOR*result);
}

//some code borrowed from https://www.shadertoy.com/view/XsfXWX#
float phong(vec3 l, vec3 e, vec3 n, float power) {
    float nrm = (power + 8.0) / (PI * 8.0);
    return pow(max(dot(l,reflect(e,n)),0.0), power) * nrm;
}

vec3 getColor(vec3 p)
{	
    sHit hit_obj = map(p);
    sMaterial material = hit_obj.material;
	vec3 n = getNormal(p);
	vec3 l = normalize(light-p);
	vec3 light_color = vec3(0);
    //vec3 cubemap = textureCube(iChannel0,-n).xyz;   
    
    //float shadow = shadow_march(p, l);
    float shadow = soft_shadow_march(p, l, 50.0);
    // Diffuse lighting
    light_color += LIGHT_COLOR * vec3(shadow) * max(dot(n, l), 0.0);
    
	float occlusion = calcOcclusion(p, n);
    light_color += LIGHT_AMBIENT * occlusion;
    
    vec3 diffuse = light_color * max(dot(n, l), 0.0);
    // fresnel
    //float fresnel = max(1.0 - dot(n,p), 0.0);
    //fresnel = pow(fresnel,material.fresnel_pow);    

    // specular
    float power = 1.0 / max(material.roughness * 0.4,0.01);
    vec3 spec = light_color * phong(-l,p,n,power);
    //reflection -= spec;

    // diffuse
    //vec3 diff = diffuse;
    //diff = mix(diff * material.color,reflection,fresnel);        

    //vec3 color = mix(diff,reflection * material.color,material.metallic) + spec;
    return diffuse * material.color + spec;
}

//uncomment below to enable mouse moving
//#define MOUSE_MOVE
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;    
    vec2 p = -1.0 + 2.0*uv;
    p.x *= iResolution.x / iResolution.y;
    
#ifdef MOUSE_MOVE
    vec2 mouse = iMouse.xy/ iResolution.xy;	
    rotmat = xrotate((mouse.y)*4.0*PI)*yrotate((mouse.x)*4.0*PI + PI / 2.0); 
#else
	float tb = iGlobalTime * BPM / SEC_PER_MIN / 4.0 + 1.0; //+1.0 to start at 2nd rotation cuz i like it best
    float percent = fract(tb);
    vec2 current = 2.0 * texture2D(iChannel0, vec2(floor(tb) / 64.0, floor(tb) / 32.0)).rg - 1.0;
    vec2 next = 2.0 * texture2D(iChannel0, vec2(floor(tb + 1.0) / 64.0, floor(tb+1.0) / 32.0)).rg - 1.0;
    vec2 final = mix(current, next, smoothstep(0.75, 1.0, percent));
    rotmat = xrotate(final.x)*yrotate(final.y + PI / 2.0);
#endif
    
    vec3 view = normalize(vec3( p, -1.0 ));
    vec3 eye = vec3( 0.0, 0.0, 3.0 );
    //view *= rotmat;
	//eye *= rotmat;
    
    vec3 pos = march(eye,view);
    vec3 col = vec3(0);
    
    if (hit == true) 
    { 
        col = getColor(pos); 
    }
    else
    {
        //col = pow( textureCube( iChannel0, view ).xyz, vec3(2.0) );
    }
    
	fragColor = vec4(col,1.0);
}
