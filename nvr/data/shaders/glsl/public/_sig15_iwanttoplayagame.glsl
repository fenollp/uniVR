// Shader downloaded from https://www.shadertoy.com/view/XlsSDM
// written by shadertoy user EvilRyu
//
// Name: [SIG15]IWantToPlayAGame
// Description: Jigsaw puppet mask from movie &quot;saw&quot;
//    
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
// [SIG15] I want to play a game
//         
// by EvilRyu.

// "I want to play a game": A line in the movie <Saw> attributed to the 
// serial killer jigsaw. He would often greet his victims via a sound recording and this
// mask on TV.



#define MTL_EYE 2.0
#define MTL_CHEEK 3.0
#define MTL_JAW 4.0
#define MTL_HAIR 5.0
#define MTL_ORBIT 6.0

float g_d;
float g_mtl_id;
vec3 g_eye_pos;
vec3 g_upper_lip_pos;
vec3 g_lower_lip_pos;
vec3 g_cheek_pos;
vec3 g_hair_offset = vec3(0.0, -2.2, 0.8);
float g_hair_scale = 2.0;

void rp_rotate_y(inout vec3 p, float a)
 { 
    float c,s;vec3 q=p; 
    c = cos(a); s = sin(a); 
    p.x = c * q.x + s * q.z; 
    p.z = -s * q.x + c * q.z;
 } 

void rp_rotate_z(inout vec3 p, float a) 
{ 
    float c,s;vec3 q=p; 
    c = cos(a); s = sin(a); 
    p.x = c * q.x - s * q.y; 
    p.y = s * q.x + c * q.y;
} 


void rp_rotate_x(inout vec3 p, float a) 
{ 
    float c,s;vec3 q=p; 
    c = cos(a); s = sin(a);
    p.y = c * q.y - s * q.z; 
    p.z = s * q.y + c * q.z; 
} 


//-----------distance functions from iq----------------
float sphere(vec3 p, float r)
{
    return length(p) - r;
}

float round_box( vec3 p, vec3 b, float r )
{
  return length(max(abs(p)-b,0.0))-r;
}

float smin(float a, float b, float k)
{
    float h = clamp(0.5+0.5*(b-a)/k, 0.0, 1.0);
    return mix(b, a, h) - k*h*(1.0-h);
}

float torus(vec3 p, vec2 t)
{
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}

float tri_prism(vec3 p, vec2 h)
{
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float box(vec3 p, vec3 b)
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float capsule(vec3 p, vec3 a, vec3 b, float r)
{
    vec3 pa = p - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}
//----------------------------------------------------------------------


//---------------------fur shader from simesgreen-----------------------
//https://www.shadertoy.com/view/XsfGWN#
const float g_uv_scale = 1.0;
const float g_fur_depth = 0.2;
const int g_fur_layers = 64;
const float g_ray_step = g_fur_depth*2.0 / float(g_fur_layers);
const float g_fur_threshold = 0.7;
const float g_shininess = 50.0;
float hair(vec3 p);

vec2 cartesian2spherical(vec3 p)
{       
    float r = length(p);
    float t = (r - (1.0 - g_fur_depth)) / g_fur_depth;    
    p /= r; 
    vec2 uv = vec2(atan(p.y, p.x), acos(p.z));
    uv.y -= t*0.3;  // curl down
    return uv;
}

float fur_density(vec3 pos, out vec2 uv)
{
     // should to apply the same transformation in distance function
    vec3 p = pos;
    rp_rotate_y(p, -floor(4.0*sin(3.0-3.0*smoothstep(3.,6.,mod(iGlobalTime,24.0)))) * 0.1);
    p+=g_hair_offset;
    p.z*=3.0;
    
    
    uv = cartesian2spherical(p.xzy); 
    vec4 tex = texture2D(iChannel0, uv*g_uv_scale);
   
    // thin out hair
    float density = smoothstep(g_fur_threshold, 1.0, tex.x);
    
    float r = (length(p) - g_hair_scale)*0.5;
    float t = (r - (1.0 - g_fur_depth)) / g_fur_depth;
    
    // fade out along length
    float len = tex.y;
    density *= smoothstep(len, len-0.2, t);

    return density; 
}

vec3 fur_normal(vec3 pos, float density)
{
    float eps = 0.01;
    vec3 n;
    vec2 uv;
    n.x = fur_density(vec3(pos.x+eps, pos.y, pos.z), uv ) - density;
    n.y = fur_density(vec3(pos.x, pos.y+eps, pos.z), uv ) - density;
    n.z = fur_density(vec3(pos.x, pos.y, pos.z+eps), uv ) - density;
    return normalize(n);
}

vec3 fur_shade(vec3 pos, vec2 uv, vec3 ro, float density)
{
    // lighting
    const vec3 L = vec3(0, 1, 0);
    vec3 V = normalize(ro - pos);
    vec3 H = normalize(V + L);

    vec3 N = -fur_normal(pos, density);
    float diff = max(0.0, dot(N, L)*0.5+0.5);
    float spec = pow(max(0.0, dot(N, H)), g_shininess);
    
    // base color
    vec3 color = vec3(0.1);

    // darken with depth
    float r = length(pos);
    float t = (r - (1.0 - g_fur_depth)) / g_fur_depth;
    t = clamp(t, 0.0, 1.0);
    float i = t*0.5+0.5;
        
    return color*diff*i + vec3(spec*i);
}       
//---------------------------------------------------------------------

float hash(vec2 p)
{
    p=fract(p*vec2(5.3983,5.4472));
    p+=dot(p.yx,p.xy+vec2(21.5351,14.3137));
    return fract(p.x*p.y*95.4337);
}

float noise(vec2 p)
{
    vec2 f;
    f=fract(p);
    p=floor(p);
    f=f*f*(3.0-2.0*f);
    return mix(mix(hash(p),hash(p+vec2(1.0,0.0)),f.x),
               mix(hash(p+vec2(0.0,1.0)),hash(p+vec2(1.0,1.0)),f.x),f.y);
}


float jaw(vec3 p, vec3 ds, float s)
{
    p.y += 1.73;
    p.z -= 1.37;
    rp_rotate_x(p, 0.3);
    float d0 = round_box(p, vec3(s*sin((1.0-p.y)), 0.4, 1.0)+ds, 0.1);
    p.x = abs(p.x) - 0.18;
    p.z -= 0.3;
    p.y +=0.3;
    float d1 = capsule(p, vec3(0.0, 0.0, 0.0), vec3(0.0, 0.5, -0.23), 0.07);
    
    return smin(d0, d1, 0.2);
}

float nose(vec3 p)
{
    p.y += 0.6;
    p.z -= 1.25;
    float d0 = round_box(p, vec3(0.01, 
                                 0.4, 
                                 atan((1.0-p.y*2.)*(1.0-p.y*p.y*2.))*0.45), 0.05);
   
    p.z -= 0.3;
    p.y += 0.4;
    p.x = abs(p.x) - 0.02;
    float d1 = capsule(p, vec3(0.0, 0.0, 0.0), vec3(0.3, 0.15, -0.4)*0.4, 0.07);
    return smin(d0/2., d1, 0.2);
}

float cheek(vec3 p)
{
    p.y += 0.7;
    p.z -= 1.1;
    p.x = abs(p.x) - 0.7;
    float d0 = capsule(p + vec3(1.0, -0.15, 0.0), vec3(0.0, 0.0, -0.1), vec3(1.1, -0.1, 0.0), 0.35);
    return d0;
}

float orbit(vec3 p)
{
    p.y += 0.16;
    p.z -= 1.23;
    p.x = abs(p.x) - 0.5;
    rp_rotate_z(p, -0.2);
    rp_rotate_y(p, -0.4);
    float d0 = round_box(p, vec3(0.24, 0.04, 0.24), 0.13);
    
    return d0;
}

float eye(vec3 p)
{
    p.y += 0.19;
    p.z -= 0.9;
    p.x = abs(p.x) - 0.47;
    float d0 = sphere(p, 0.28);
    return d0;
}

float brow_ridge(vec3 p)
{
    p.y += 0.2;
    p.z -= 0.4;
    p.x = abs(p.x) - 0.2;
    rp_rotate_z(p, -0.3);
    rp_rotate_x(p, 0.3);
    
    float d0 = torus(p, vec2(0.83, 0.07));
    return d0;
}


float hair(vec3 p)
{
    return (length(p*vec3(1.0, 1.0, 3.0)) - g_hair_scale)*0.5;
}

float head(vec3 p)
{
    vec3 tp = p;
    rp_rotate_x(tp, 0.3);
    tp.y -= 1.7;
    tp.z -= 0.6;
    float d0 = round_box(tp, vec3(0.87*(0.3*sin(tp.y)+0.5), 
                                 0.6,
                                 0.04+(tp.y*0.15+0.1)), 0.4);
    tp = p;
    tp.y -= 3.0;
    tp.z += .599;
    float d1 = sphere(tp, 1.0);
    float d2 = brow_ridge(tp);
    float d3 = orbit(tp);
    float d4 = cheek(tp);
    float d5 = nose(tp);
    float d6 = jaw(tp, vec3(0.0), 0.4);
    
    // movement of jaw
    vec3 jp = tp + vec3(0.0, 
                        0.015*floor(2.0*sin(46.0*smoothstep(7.0,12.0,mod(iGlobalTime,12.0)))),
                        0.2);
    float d7 = jaw(jp, vec3(-0.01, -0.1, -0.9), 0.3);
    float d8 = eye(tp);
    float d10 = sphere(p + vec3(0.0, -2.2, 2.2), 2.25);
    float d9 = hair(p + g_hair_offset);
    
    float d = smin(d1, d0, 0.5);
    d = smin(d, d2, 0.3);
    if(d4 < d) { g_mtl_id = MTL_CHEEK;g_cheek_pos = p;}
     d = smin(d, d4, 0.2);
    d = max(d, -d3);
    d = max(d, -d6);
    if(d7 < d) { d = d7; g_mtl_id = MTL_JAW; g_lower_lip_pos = jp;}
    d = max(d, -d10);
    d-=  texture2D(iChannel0, tp.xy*0.1-vec2(0.3, 0.3)).y*0.025;
    if(d5 < d) { g_mtl_id = 1.0;}
    d = smin(d, d5, 0.2);
    
    if(d8 < d) {d = d8; g_mtl_id = MTL_EYE; g_eye_pos = p;}
    g_upper_lip_pos = p;
        
    if(d9 < d) {d = d9;g_mtl_id = MTL_HAIR;}
    
    return d;
}

float f(vec3 p)
{ 
    g_mtl_id = 1.0;
    rp_rotate_y(p, -floor(4.0*sin(3.0-3.0*smoothstep(3.,6.,mod(iGlobalTime,24.0))))*0.1);
    float d0 = head(p); 
   
    return d0;
} 

vec3 normal(in vec3 pos)
{
    vec3 eps = vec3(0.001,0.0,0.0);
    return normalize(vec3(
           f(pos+eps.xyy) - f(pos-eps.xyy),
           f(pos+eps.yxy) - f(pos-eps.yxy),
           f(pos+eps.yyx) - f(pos-eps.yyx)));
}


float softshadow(vec3 ro, vec3 rd, float k )
{ 
    float s=1.0,h=0.0; 
    float t = 0.01;
    for(int i=0; i < 30; ++i)
    { 
        h=f(ro+rd*t); 
        if(h<0.001)return 0.02; 
        s=min(s, k*max(h, 0.0)/t); 
        t+=h; 
    } 
    return s; 
} 

vec3 lighting(vec3 ro, vec3 rd, vec3 pos,
    vec3 upper_lip_pos, vec3 lower_lip_pos,
    vec3 cheek_pos, vec3 eye_pos, float mtl_id)
{
    vec3 l0_dir = normalize(vec3(0.6, -0.5, 0.5));
    vec3 l0_col = vec3(1.0, 1.0, 1.0);
    vec3 n = normal(pos);
    vec3 material = vec3(1.0);

    vec3 col = vec3(0.0);

    float sha = softshadow(pos+l0_dir*0.01, l0_dir, 20.0);
    float dif = max(0.0, dot(l0_dir, n)); 
    float spe = max(0.0, pow(clamp(dot(l0_dir, reflect(rd, n)), 0.0, 1.0), 20.0)); 

    // texturing for different parts
    if(upper_lip_pos.y < 1.8 && upper_lip_pos.y > 1.68 &&
      upper_lip_pos.x > -0.8 && upper_lip_pos.x < 0.8 && upper_lip_pos.z > 0.0)
    {
        upper_lip_pos.x=abs(upper_lip_pos.x);
        material -= vec3(0.5, 1.0, 1.0)*pow(smoothstep(0.0, 0.05, (upper_lip_pos.y-1.6)*
                                                 pow((1.2-upper_lip_pos.x), 4.0)), 10.0);
        clamp(material, 0.0, 1.0);
    }

    if(mtl_id == MTL_JAW)
    {
        float t = mod(lower_lip_pos.y, 2.3)-0.92;
        material -= vec3(0.5, 1.0, 1.0)*
                    pow(smoothstep(0.00, 0.005, t) * smoothstep(0.085, .08, t), 40.0);
            clamp(material, 0.0, 1.0);
    }
    
    if(mtl_id == MTL_CHEEK)
    {
        cheek_pos.x = abs(cheek_pos.x) - 0.7;
        rp_rotate_y(cheek_pos, -0.7);
        
        if(cheek_pos.z > 0.62)
        {
            float t=mod(cheek_pos.z, 0.0554); 
            material -= vec3(0.5, 1.0, 1.0)*
                    pow(smoothstep(0.00, 0.03, t) * smoothstep(0.085, .08, t), 40.0);
            clamp(material, 0.0, 1.0);
        }
    }
    
    col += 4.0 * l0_col * dif * material * sha;
    col += 3.0 * spe * vec3(1.0);
    col += textureCube(iChannel1, n).xyz;
   
    if(mtl_id == MTL_EYE)
    {
        float t=mod(eye_pos.z, 0.493);
 
        col = vec3(1.7, 0.2, 0.0)*
              pow(smoothstep(0.0, 0.065, t) * smoothstep(0.085, .08, t), 10.0);
        col += vec3(4.0)*spe;
    }
    
    
    return col;
}


vec4 scene(vec3 ro, vec3 rd)
{
    vec3 bg = vec3(0.0);
    vec3 p=ro; 
    
    vec4 c = vec4(0.0);
    float t = 1.0;
    float d = 1.0;
    
    // raymarching
    for(int i = 0; i < 48; i++)
    {
        if( d < 0.003 || t > 20.0 )
            break;
        d = f(ro + rd*t);
        t += d;
    }
    if( t>20.0) t=-1.0;
    
     if(t > 0.0)
     {
         // raymarching for hair
         if(g_mtl_id == MTL_HAIR)
         {
             c=vec4(0.0);
             vec3 pos = ro + rd * t;
            // ray-march into volume
            for(int i=0; i<g_fur_layers; i++) 
            {
                vec4 sample_col;
                vec2 uv;
                
                sample_col.a = fur_density(pos, uv);
                if (sample_col.a > 0.0) 
                {
                    if (c.a > 0.95) {} // for windows...
                    else
                    {
                    	sample_col.rgb = fur_shade(pos, uv, ro, sample_col.a);
                    	sample_col.rgb *= sample_col.a;
                    	c = c + sample_col*(1.0 - c.a);
                    }
                }
                pos += rd*g_ray_step;
            }
         }
         else
         {
               p = ro + t * rd;
              
               c.xyz = lighting(ro, rd, p, 
                              g_upper_lip_pos, g_lower_lip_pos,
                              g_cheek_pos, g_eye_pos, g_mtl_id);
               c.xyz *= 0.2;
                
               c.xyz=mix(c.xyz,bg, 1.0-exp(-0.01*t*t)); 
         }
    } 
    return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{ 
    vec2 q=fragCoord.xy/iResolution.xy; 
    vec2 uv = -1.0 + 2.0*q; 
    uv.x*=iResolution.x/iResolution.y; 
     
    vec3 ro = vec3(0.0, 0.55, 1.0)*5.5;
    vec3 ta = vec3(0.0, 0.0, -20.0);

    vec3 cf = normalize(ta - ro); 
    vec3 cs = normalize(cross(cf,vec3(0.0,1.0,0.0))); 
    vec3 cu = normalize(cross(cs,cf)); 
    vec3 rd = normalize(uv.x*cs + uv.y*cu + 3.0*cf); 

    vec4 c = scene(ro, rd);
    vec3 col = c.xyz;
    // post
    col = clamp(col*0.5+0.5*col*col*1.6,0.0,1.0);
    col *= vec3(0.95,1.35,1.05);
    col *= 0.7+0.3*sin(10.0*iGlobalTime+q.y*1000.0);
    col *= 0.8+0.2*sin(1100.0*iGlobalTime);
    col += hash(q*iGlobalTime) * 0.05;
    col=pow(clamp(col,0.0,1.0),vec3(0.45)); 
    col=mix(col, vec3(dot(col, vec3(0.33))), -0.5);  // satuation
    col*=1.5 * pow(16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y),0.7);  // vigneting
 	col *= smoothstep( 0.0, 8.0, iGlobalTime );	
    if(abs(uv.x)>1.2) col=vec3(0.0);
    fragColor = vec4(col,c.a);
}