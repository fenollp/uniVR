// Shader downloaded from https://www.shadertoy.com/view/XlsXRn
// written by shadertoy user squid
//
// Name: squid - Planets
// Description: Strange colored planets in space. Best in Fullscreen, also less dense 
#define GRADIENT_DELTA 0.5
#define FUDGE_FACTOR 0.5
#define COMPARE_FUDGE_FACTOR 0.2


#define time iGlobalTime
#define size iResolution

//code here is from iq(Distance Functions + shading), effie(DDE), Dave_Hoskins(hash), dgreensp(fbm)
//also very simular to "Spinning Rings"

float sdTorus( vec3 p, vec2 t )
{
  return length( vec2(length(p.xz)-t.x,p.y) )-t.y;
}

mat3 rotateY(float r)
{
    vec2 cs = vec2(cos(r), sin(r));
    return mat3(cs.x, 0, cs.y, 0, 1, 0, -cs.y, 0, cs.x);
}

mat3 rotateZ(float r)
{
    vec2 cs = vec2(cos(r), sin(r));
    return mat3(cs.x, cs.y, 0., -cs.y, cs.x, 0., 0., 0., 1.);
}

#define MOD2 vec2(443.8975,397.2973)
#define MOD3 vec3(443.8975,397.2973, 491.1871)
#define MOD4 vec4(443.8975,397.2973, 491.1871, 470.7827)
float hash13(vec3 p)
{
	p  = fract(p * MOD3);
    p += dot(p.xyz, p.yzx + 19.19);
    return fract(p.x * p.y * p.z);
}

vec3 hash32(vec2 p)
{
	vec3 p3 = fract(vec3(p.xyx) * MOD3);
    p3 += dot(p3.zxy, p3.yxz+19.19);
    return fract(vec3(p3.x * p3.y, p3.x*p3.z, p3.y*p3.z));
}
vec3 hash33(vec3 p)
{
	p = fract(p * MOD3);
    p += dot(p.zxy, p+19.19);
    return fract(vec3(p.x * p.y, p.x*p.z, p.y*p.z));
}
vec4 hash43(vec3 p)
{
	vec4 p4 = fract(vec4(p.xyzx) * MOD4);
    p4 += dot(p4.wzxy, p4+19.19);
    return fract(vec4(p4.x * p4.y, p4.x*p4.z, p4.y*p4.w, p4.x*p4.w));
}
vec3 opRep( vec3 p, vec3 c )
{
    return mod(p,c)-0.5*c;
}

vec2 opU( vec2 d1, vec2 d2 )
{
	return (d1.x<d2.x) ? d1 : d2;
}
float sdSphere( vec3 p, float s )
{
    return length(p)-s;
}
vec2 map( in vec3 pos )
{
    vec3 c = vec3(16.);
    vec3 q = opRep(pos, c);
    vec4 h = hash43( floor(pos/c-(.5*c)) )*2. - 1.;
    float rad = h.y*.5 + .5;
    vec3 ctr = q-vec3(sin(h.z)*cos(h.w),cos(h.z)*sin(h.w),sin(h.z))*(6.5);
    vec2 res = vec2(
        sdSphere(ctr , rad), h.x);
    if(h.y > 0.8)  {
    	mat3 r = rotateY(iGlobalTime*h.z*.2)*rotateZ(iGlobalTime*h.w*.2);
        res = opU(res, vec2(sdTorus(ctr*r, vec2(rad*3., 0.01)), 20.));
    }
    return res;
}


float DE(vec3 p0)
{
    return map(p0).x;
}

vec2 DDE(vec3 p, vec3 rd){
	float d1=DE(p);
  	//return vec2(d1,d1*COMPARE_FUDGE_FACTOR);
	float dt=GRADIENT_DELTA*log(d1+1.0);
	float d2=DE(p+rd*dt);
	dt/=max(dt,d1-d2);
	return vec2(d1,FUDGE_FACTOR*log(d1*dt+1.0));
}

float rndStart(vec2 co){return fract(sin(dot(co,vec2(123.42,117.853)))*412.453);}

mat3 lookat(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,up));return mat3(rt,cross(rt,fw),fw);
}

vec3 normal(vec3 p)
{
    vec2 eps = vec2(.001, 0.);
    return normalize(vec3(
        DE(p+eps.xyy) - DE(p-eps.xyy),
        DE(p+eps.yxy) - DE(p-eps.yxy),
        DE(p+eps.yyx) - DE(p-eps.yyx)));
}

float noise(vec3 x) {
    vec3 p = floor(x);
    vec3 f = fract(x);
    f = f*f*(3.-2.*f);
	
    float n = p.x + p.y*157. + 113.*p.z;
    
    vec4 v1 = fract(753.5453123*sin(n + vec4(0., 1., 157., 158.)));
    vec4 v2 = fract(753.5453123*sin(n + vec4(113., 114., 270., 271.)));
    vec4 v3 = mix(v1, v2, f.z);
    vec2 v4 = mix(v3.xy, v3.zw, f.y);
    return mix(v4.x, v4.y, f.x);
}

float fnoise(vec3 p) {
  // random rotation reduces artifacts
  p = mat3(0.28862355854826727, 0.6997227302779844, 0.6535170557707412,
           0.06997493955670424, 0.6653237235314099, -0.7432683571499161,
           -0.9548821651308448, 0.26025457467376617, 0.14306504491456504)*p;
  return dot(vec4(noise(p), noise(p*2.), noise(p*4.), noise(p*8.)),
             vec4(0.5, 0.25, 0.125, 0.06));
}
vec3 compute_color(vec3 ro, vec3 rd, float t)
{
    vec3 p = ro+rd*t;
    vec3 l = normalize(vec3(0., .7, .2));
    vec3 nor = normal(p);
    vec3 ref = reflect(rd, nor);
    
    float m = map(p).y;
    vec3 c = vec3(0.);
    if(m == 20.) {
        c = vec3(pow(fnoise(p*vec3(2.,1.,1.)),1.4)*.3);
    } else {
		c = mix(vec3(1., .2, 0.), vec3(.1, .3, .8), m+.05)*(pow(fnoise(p),2.6)*2.+.3); //hsv2rgb(vec3(.1+m*.2, 1.3, .9));
    }
     
    
    
    float dif = clamp( dot( nor, l ), 0.0, 1.0 );
   	float fre = pow( clamp(1.0+dot(nor,rd),0.0,1.0), 2.0 );
    
    
    vec3 v = vec3(0.);
    v += .6*vec3(dif);
    v += .3*fre*vec3(.6, .7, .8);
 	return c*v;
}

vec4 pixel(vec2 pxx)
{
    float pxl=4.0/size.y;//find the pixel size
	float tim=time*0.08+(iMouse.x/size.x)*5.;
	
	//position camera
	vec3 ro=vec3(cos(tim),0.5+(iMouse.y/size.y)*2.-1.,sin(tim))*50.4;
	vec3 rd=normalize(vec3((2.0*pxx-size.xy)/size.y,2.0));
	rd=lookat(-ro,vec3(0.0,1.0,0.0))*rd;
	//ro=eye;rd=normalize(dir);
	vec3 bcol=vec3(1.0);
	//march
	
	float t=DDE(ro,rd).y*rndStart(pxx),d,od=1.0;
    bool hit = false;
	for(int i=0;i<240;i++){
		vec2 v=DDE(ro+rd*t,rd);
		d=v.x;
		float px=pxl*(1.0+t);
		if(d<px){
            hit = true;
            break;
		}
		od=d;
		t+=v.y;//d;
		if(t>150.0)break;
	}
    return hit ? vec4(compute_color(ro, rd, t), 1.) : 
    			 vec4(vec3(.01 + pow(hash13(rd), 3000.)), 1.) ;//hsv2rgb(vec3(.45, 1., rd.y*.7 + .5)).xyzz*.2;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){

    vec2 xy = (fragCoord.xy/size.xy);
	float v = .6 + 0.4*pow(20.0*xy.x*xy.y*(1.0-xy.x)*(1.0-xy.y), 0.5);
	fragColor=pow(pixel(fragCoord.xy)*v, vec4(1./2.2));

} 