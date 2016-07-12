// Shader downloaded from https://www.shadertoy.com/view/4dcSzB
// written by shadertoy user Daedelus
//
// Name: My Raymarching Template
// Description: Raymarching template to avoid always writing the same setup.
/**
Simple scene that displays a raymarched sphere on a floor at (0,0,0)

Includes "Noise value 3D" by IQ

Includes minified HG_SDF by Mercury (mercury.sexy/hg_sdf) 
to have all primitives & spatial operators without taking up too much space; 
omitted platonic solids because the original code uses arrays and I was lazy.

Some functions are converted to macros because they would be even smaller when preprocessed.

Another macro, _M, is really filling up almost identical code as to make the result even smaller,
this breaks Shader_Minifier by CTRL_ALT_TEST, just so you know. 

Additionally a lot of float constants are suffixed with '.' to support WebGL

Cntains a simple Gradient() function (without normalize, so only works on real linear SDF functions).
as well as basic diffuse top light, distance fog and horizon gradient.

Use in any way you like, I in no way can take any credit for this.

I tried to be basic & brief, no lighting shadows ao or reflections, no functions where not necessary (texture, trace, shade).
**/

#define PI 3.14159265359
const float _1=.57735026919;
const vec2 _A=normalize(vec2(2.61803398875, 1));
const vec2 _B=normalize(vec2(1,1.61803398875));
float fSphere(vec3 p,float r){return length(p)-r;}
float fPlane(vec3 p,vec3 n,float d){return dot(p,n)+d;}
float fBoxCheap(vec3 p,vec3 b){vec3 q=(abs(p)-b);return max(max(q.x,q.y),q.z);}
float fBox(vec3 p,vec3 b){vec3 q,d=abs(p)-b;q=min(d,0.);return length(max(d,0.))+max(max(q.x,q.y),q.z);}
float fBox2Cheap(vec2 p,vec2 b){vec2 q=abs(p)-b;return max(q.x,q.y);}
float fBox2(vec2 p,vec2 b){vec2 q,d=abs(p)-b;q=min(d,0.);return length(max(d,0.))+max(q.x,q.y);}
float fCorner(vec2 p){vec2 q=min(p,0.);return length(max(p,0.))+max(q.x,q.y);}
float fBlob(vec3 p){p=abs(p);if(p.x<max(p.y,p.z))p=p.yzx;if(p.x<max(p.y,p.z))p=p.yzx;float l=length(p),b=max(max(max(dot(p,vec3(_1)),dot(p.xz,_A)),dot(p.yx,_B)),dot(p.xz,_B));return l-1.5-.15*cos(min(sqrt(1.01-b/l)*4.*PI,PI));}
float fCylinder(vec3 p,float r,float h){return max(length(p.xz)-r,abs(p.y)-h);}
float fCapsule(vec3 p,float r,float c){return mix(length(p.xz)-r,length(vec3(p.x,abs(p.y)-c,p.z))-r,step(c,abs(p.y)));}
float fLineSegment(vec3 p,vec3 a,vec3 b){vec3 c=b-a;float t=clamp(dot(p-a,c)/dot(c,c),0.,1.);return length(c*t+a-p);}
float fCapsule(vec3 p,vec3 a,vec3 b,float r){return fLineSegment(p,a,b)-r;}
float fTorus(vec3 p,float i,float r){return length(vec2(length(p.xz)-r,p.y))-i;}
float fCircle(vec3 p,float r){return length(vec2(p.y,length(p.xz)-r));}
float fDisc(vec3 p,float r){float l=length(p.xz)-r;return l<0.?abs(p.y):length(vec2(p.y,l));}
float fHexagonCircumcircle(vec3 p,vec2 h){vec3 q=abs(p);return max(q.y-h.y,max(q.x*0.866+q.z*.5,q.z)-h.x);}
float fHexagonIncircle(vec3 p,vec2 h){return fHexagonCircumcircle(p,vec2(h.x*0.866,h.y));}
float fCone(vec3 p,float r,float h){vec2 t,m,q=vec2(length(p.xz),p.y);t=q-vec2(0.,h);m=normalize(vec2(h,r));float j=dot(t,vec2(m.y,-m.x)),d=max(dot(t,m),-q.y);if(q.y>h&&j<0.)d=max(d,length(t));if(q.x>r&&j>length(vec2(h,r)))d=max(d,length(q-vec2(r,0.)));return d;}
void pR(inout vec2 p,float a){p=cos(a)*p+sin(a)*vec2(p.y,-p.x);}
void pR45(inout vec2 p){p=(p+vec2(p.y,-p.x))*sqrt(.5);}
float pMod1(inout float p,float s){float c=floor((p/s)+.5);p=(fract((p/s)+.5)-.5)*s;return c;}
float pModMirror1(inout float p,float s){float c=pMod1(p,s);p*=mod(c,2.)*2.-1.;return c;}
float pModSingle1(inout float p,float s){float c=floor((p/s)+.5);if(p>=0.)p=(fract((p/s)+.5)-.5)*s;return c;}
float pModInterval1(inout float p,float s,float b,float x){float c=pMod1(p,s);if(c>x){p+=s*(c-x);c=x;}if(c<b){p+=s*(c-b);c=b;}return c;}
float pModPolar(inout vec2 p,float t){float g=6.28318530718/t,a=atan(p.y,p.x)+g*.5,r=length(p),c=floor(a/g);a=mod(a,g)-g*.5;p=vec2(cos(a),sin(a))*r;if(abs(c)>=t*.5)c=abs(c);return c;}
vec2 pMod2(inout vec2 p,vec2 s){vec2 c=floor((p/s)+.5);p=(fract((p/s)+.5)-.5)*s;return c;}
vec2 pModMirror1(inout vec2 p,vec2 s){vec2 c=pMod2(p,s);p*=mod(c,2.)*2.-1.;return c;}
vec2 pModGrid2(inout vec2 p,vec2 size){vec2 c=floor((p+size*.5)/size);p=mod(p+size*.5,size)-size*.5;p*=mod(c,2.)*2.-vec2(1);p-=size*.5;if(p.x>p.y)p.xy=p.yx;return floor(c*.5);}
vec3 pMod3(inout vec3 p,vec3 s){vec3 c=floor((p/s)+.5);p=(fract((p/s)+.5)-.5)*s;return c;}
float pMirror(inout float p,float d){float s=(p<0.)?-1.:1.;p=abs(p)-d;return s;}
vec2 pMirrorOctant (inout vec2 p,vec2 dist){vec2 s=vec2((p.x<0.)?-1.:1.,(p.y<0.)?-1.:1.);pMirror(p.x,dist.x);pMirror(p.y,dist.y);if(p.y>p.x)p.xy=p.yx;return s;}
float pReflect(inout vec3 p,vec3 n,float o){float t=dot(p,n)+o;if(t<0.){p=p-(t+t)*n;}return (t<0.)?-1.:1.;}
float fOpUnionChamfer(float a,float b,float r){return min(min(a,b),(a-r+b)*sqrt(.5));}
float fOpIntersectionChamfer(float a,float b,float r){return max(max(a,b),(a+r+b)*sqrt(.5));}
#define fOpDifferenceChamfer(a,b,r) fOpIntersectionChamfer(a,-b,r)
float fOpUnionRound(float a,float b,float r){vec2 u=max(vec2(r-a,r-b),0.);return max(r,min(a,b))-length(u);}
float fOpIntersectionRound(float a,float b,float r){vec2 u=max(vec2(r+a,r+b),0.);return min(-r,max(a,b))+length(u);}
float fOpDifferenceRound(float a,float b,float r){return fOpIntersectionRound(a,-b,r);}
#define _M(S) (float a,float b,float r,float n){float c,m=min(a,b);if(a>r||b>r)return S*m;vec2 p=vec2(a,b);c=r*1.41421356237/(n*2.-0.58578643762);pR45(p);
float fOpUnionColumns _M(1.)p.x+=0.70710678118*-r+c*1.41421356237;if(mod(n,2.)==1.)p.y+=c;pMod1(p.y,c*2.);return min(min(min(length(p)-c,p.x),a),b);}
float fOpDifferenceColumns _M(-1.)p.y+=c;p.x-=0.70710678118*(r+c);if(mod(n,2.)==1.)p.y+=c;pMod1(p.y,c*2.);return-min(min(max(-length(p)+c,p.x),a),b);}
#define fOpIntersectionColumns(a,b,r,n) fOpDifferenceColumns(a-b,r,n)
float fOpUnionStairs(float a,float b,float r,float n){float s=r/n;float u=b-r;return min(min(a,b),.5*(u+a+abs(mod(u-a+s,2.*s)-s)));}
#define fOpIntersectionStairs(a,b,r,n) -fOpUnionStairs(-a,-b,r,n)
#define fOpDifferenceStairs(a,b,r,n) -fOpUnionStairs(-a,b,r,n)
float fOpUnionSoft(float a,float b,float r){float e=max(r-abs(a-b),0.);return min(a,b)-e*e*.25/r;}
float fOpPipe(float a,float b,float r){return length(vec2(a,b))-r;}
float fOpEngrave(float a,float b,float r){return max(a,(a+r-abs(b))*sqrt(.5));}
float fOpGroove(float a,float b,float ra,float rb){return max(a,min(a+ra,rb-abs(b)));}
float fOpTongue(float a,float b,float ra,float rb){return min(a,max(a-ra,abs(b)-rb));}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+0.5)/256.0, -100.0 ).yx;
	return mix( rg.x, rg.y, f.z );
}

float fField(vec3 point, out float material)
{
    material = 0.0;
	float distance = min(point.y, length(point) - 1.0);
    
    return distance;
}

float fField(vec3 point)
{
    float stub;
	return fField(point, stub);
}

vec3 Gradient(vec3 intersection, float distance)
{
    vec2 epsilon = vec2(0.01, 0.0);
    return (vec3(fField(intersection + epsilon.xyy),
    fField(intersection + epsilon.yxy),
    fField(intersection + epsilon.yyx))
        - distance) / epsilon.x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
    uv.x *= iResolution.x / iResolution.y;
    
    const float FOV_BIAS = 0.2;
    const int RAY_STEPS = 100;
    const float NEAR_CLIP = 0.5;
    const float FAR_CLIP = 100.0;
    const vec3 SKY = vec3(0.1, 0.5, 1.0);
    const vec3 HORIZON = vec3(1.0, 1.0, 0.8);
    
    vec3 normal, intersection, origin = vec3(0.0, 1.0, -10.0), direction = vec3(0.0, 0.0, 1.0);
    pR(direction.xz, uv.x * FOV_BIAS);
    pR(direction.yz, uv.y * FOV_BIAS);
    
    float material, distance, totalDistance = NEAR_CLIP;
    for(int i =0 ;  i < RAY_STEPS; ++i)
    {
        intersection = origin + direction * totalDistance;
        distance = fField(intersection, material);
        totalDistance += distance;
        if(distance <= 0.0 || totalDistance >= FAR_CLIP)
            break;
    }
    
    normal = Gradient(intersection, distance);
    vec3 color = vec3(1.0) * (normal.y * 0.5 + 0.5);
    
    float fog = min(totalDistance / FAR_CLIP, 1.0);
    vec3 skyColor = mix(HORIZON, SKY, pow(abs(direction.y), 0.25));
    
	fragColor = vec4(mix(color, skyColor, fog), 1.0);
}