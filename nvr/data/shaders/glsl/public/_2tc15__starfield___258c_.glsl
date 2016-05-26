// Shader downloaded from https://www.shadertoy.com/view/ltXXDN
// written by shadertoy user aiekick
//
// Name: [2TC15] Starfield! (258c)
// Description: Reduced version of [url=https://www.shadertoy.com/view/ltXSDN]Starfield![/url]
//    
//    908c to 271c

// 258 by FabriceNeyret2
#define r(o) fract(sin(vec4(6,9,1,o)*i) * 9e2)
void mainImage(out vec4 f, vec2 v )  {
    f-=f;
	float t = iGlobalTime;
    
  	for (float i=0.; i < 20.; i+=.1) 
        r(5.*t).w > .98 ? f 
        : f +=   r(0)/8e2
             / pow(
                  length(
                     v/iResolution.y 
                      - 3.*fract( r(5).zw 
                                  + (sin(t/vec2(1,2))+cos(t/vec2(5,3)))* (r(0).x+1.)/6.
                    )           )
               , 1.2 );  
}

/* 272 by Coyote
#define r(o) fract(sin(o*i) * 9e2)
void mainImage(inout vec4 f, vec2 v ) 
{
	vec4 t = iGlobalTime / vec4(1,5,2,3);
  	for (float i=0.; i < 2e2; i++) 
        f += pow(
                  length(
                     v/iResolution.y 
                      - 3.*fract(r(vec2(.1,.5)) + (sin(t.xz)+cos(t.yw)) * (r(.6)+1.)/6.)
                    )
               , -1.2) / 8e2
            * r(vec4(.6,.9,.1,0)) 
            * ( r(.5*t.x) > .98?.5:1.);  
}
*/

/* 280 by FabriceNeyret2
#define r(o) fract(sin(o*i) * 9e2)
void mainImage(inout vec4 f, vec2 v ) 
{
	vec4 t = iGlobalTime * vec4(1,.2,.5,.3);
  	for (float i=0.; i < 200.; i++) 
        f += pow(
                  length(
                     v/iResolution.y 
                      - 3.*fract(r(vec2(.1,.5)) + (sin(t.xz)+cos(t.yw)) * (r(.6)+1.)/6.)
                    )
               , -1.2) / 8e2
            * r(vec4(.6,.9,.1,0)) 
            * ( r(.5*t.x) > .98?.5:1.);  
}
*/
/* 342 by FabriceNeyret2
#define r(o) fract(sin(o*i) * 937.)
void mainImage(out vec4 f, vec2 v )
{
    vec4 t = iGlobalTime * vec4(1,.21,.52,.36);
    f=t-t;//bug if not init on glsl mode
	vec2 q = sin(t.xz)+cos(t.yw);
    for (float i=0.; i<200.; i++) 
    {
        vec2 p = mod(vec2(r(.12),r(.5))*3. + q * (t.y = r(0.63)*.5+.5), 3.);
        t.z =  pow(length(v/iResolution.y-p), -1.2) / 8e2;
        f += vec4(r(.654), r(.953), r(.123),1) * (r(.589*t.x) > r(.868)+.8?t.z * .5:t.z);
    }
}
*/
    
/* 409 by me
#define r(o) fract(sin(dot(o*vec2(i) ,vec2(32.9898,78.233))) * 43758.5453)
void mainImage(out vec4 f, vec2 v )
{
    vec4 t = iGlobalTime * vec4(1,.21,.52,.36);
    f=t-t;//bug if not init on glsl mode
	vec2 q = vec2(sin(t.x)+cos(t.y), sin(t.z)+cos(t.w));
    for (float i=0.; i<200.; i++) 
    {
        vec2 p = mod(vec2(r(.12),r(.5))*3. + q * (t.y = r(0.63)*.5+.5), 3.);
        t.z = 2e-3 * pow(length(v/iResolution.y-p), -1.2) * t.y;
        f.rgb += vec3(r(.654), r(.953), r(.123)) * (r(.589*t.x) > r(.868)+.8?t.z * .5:t.z);
    }
}
*/

/* original 908 by Kos   
vec2 aspect;
vec2 uv;
vec2 pan;

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(32.9898,78.233))) * 43758.5453);
}

float rand1(float i) {
    return rand(vec2(i, i));
}

vec4 star(int n) {
    float fn = float(n);
    vec2 p = vec2(
        rand1(0.12+float(n))* 3.,
        rand1(0.5+float(n)) * 3.);
   	float pf = rand1(fn*0.63)*0.5+0.5;
    p += pan*pf;
    p = mod(p, 3.);
    p -= vec2(0.5);
    
    vec3 rgb = vec3(
        rand1(0.654*fn),
        rand1(0.953*fn),
        rand1(0.123*fn));
    
    float blink = rand1(0.868*fn)+0.8;
    
    float dist = length(uv-p);
	
    float i;    
    i = 0.002 * pow(length(uv-p), -1.2) * pf;
    
    if (rand1(0.589*fn*iGlobalTime) > blink) {
        i *= 0.5;
    }
    
    return vec4(rgb*i, 1);

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    aspect = iResolution.xy / min(iResolution.x, iResolution.y);
	uv = fragCoord.xy / min(iResolution.x, iResolution.y);
    
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
    fragColor = vec4(0);
    
    pan = vec2(sin(iGlobalTime)+cos(iGlobalTime*0.21),
               sin(iGlobalTime*0.52)+cos(iGlobalTime*0.36));
    
    for (int i=0; i<200; ++i) {
        fragColor += star(i);
    }
    
    
}
*/