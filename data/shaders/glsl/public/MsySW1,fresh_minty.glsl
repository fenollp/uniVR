// Shader downloaded from https://www.shadertoy.com/view/MsySW1
// written by shadertoy user netgrind
//
// Name: FRESH MINTY
// Description: final pass from a colab between connor bell and myself.
//    full video, lerping between passes - https://www.youtube.com/watch?v=bMonV2q6b10
// hyper tweaked copy of https://www.shadertoy.com/view/Xds3zN by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// part of a colab between connor bell and cale bradbury

//increase steps for higher detail, will run slower
#define steps 30

//how foggy the zone is
#define fog 1.1

float size = .1;
float anim = -iGlobalTime*.1;

float sdSphere( vec3 p, float s )
{
  return length(p)-s;
}

float sdTriPrism( vec3 p, vec2 h )
{
    vec3 q = abs(p);
    return max(q.z-h.y,max(q.x*0.866025+p.y*0.5,-p.y)-h.x*0.5);
}

float sdBox( vec3 p, vec3 b )
{
  vec3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) +
         length(max(d,0.0));
}

float sdCylinder( vec3 p, vec2 h )
{
  vec2 d = abs(vec2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdPlane( vec3 p )
{
return p.y;
}

vec2 opU( vec2 d1, vec2 d2 )
{
return (d1.x<d2.x) ? d1 : d2;
}
float opU( float d1, float d2 )
{
return (d1<d2) ? d1 : d2;
}

vec2 opS( vec2 d1, vec2 d2 )
{
    return ((d2.x<d1.x)) ? d2 : d1;
}
float opS( float d1, float d2 )
{
    return max(-d2,d1);
}

vec2 rotate(vec2 v, float a){
float t = atan(v.y,v.x)+a;
    float d = length(v);
    v.x = cos(t)*d;
    v.y = sin(t)*d;
    return v;
}
vec2 stretch(vec2 v, float s){
float t = atan(v.y,v.x);
    float d = length(v);
    d +=d*s;
    v.x = cos(t)*d;
    v.y = sin(t)*d;
    return v;  
}

vec2 gif9(in vec3 pos){
    pos.x = abs(mod(pos.x, size*4.)-size*2.);
    pos.y = 0.-abs(mod(abs(pos.y), size*4.)-size*2.);
 	pos.z = abs(mod(pos.z-size, size*4.)-size*2.);
    
    vec2 res = vec2(sdBox(pos+vec3(0.,-size,0.), vec3(100.,.1,100.)), 1.1);
    res = opU(res, vec2(sdBox(pos, vec3(size)), 2.));
    res = opU(res, vec2(sdBox(pos+vec3(0., size, 0.), vec3(size*.5,size,size*.5)), 3.));
//res = opU(res, vec2(sdBox(pos, vec3(size*1.5, size*0.5, size*1.5)), 2.5));

    res = opU(res, vec2(sdBox(pos, vec3(size*2.5, size*0.5, size*1.5)), 2.5));    
    res = opU(res, vec2(sdBox(pos, vec3(size*0.5, size*0.6, size*1.55)), 3.5));
    res = opU(res, vec2(sdBox(pos, vec3(size*2.5, size*0.6, size*.25)), 3.5));
    res = opU(res, vec2(sdBox(pos, vec3(size*.4, size*0.5, size*2.)), 2.5));    
res = opU(res, vec2(sdBox(pos, vec3(size*2., size*0.25, size*1.55)), 4.5));
res = opU(res, vec2(sdBox(pos, vec3(size*0.5, size*0.25, size*2.)), 4.5));

    float s = sdBox(vec3(pos.x,mod(pos.y-.55,size*.4),pos.z), vec3(size*.7, size*0.2, size*.7));
    s = opS(s, sdBox(vec3(pos.x,mod(pos.y-.55,size*.4),pos.z), vec3(size*.3, size*0.3, size*.3)));
    res.x = opS(res.x,s);
    res.x = opS(res.x,sdBox(pos+vec3(-size*1.5,size*.55,0.),vec3(size*.15,size*.3,1.)));
    
   	res = opU(res,vec2(sdBox(pos+vec3(-size*1.5,size*0.35,0.),vec3(size*.15,size*.25,size*1.5)), 2.));

    float box = sdBox(pos+vec3(-size*.9, size*1.2, -size*.95), vec3(size*.1,size*1.1,size*.05));
    res = opU(res, vec2(box,2.));
    
    res = opU(res,vec2(sdBox(pos+vec3(-size*2.,size*.3,0.),vec3(size*.15,size*.3,size*1.55)), 3.5));
    res = opU(res,vec2(sdBox(pos+vec3(0.,size*.3,0.),vec3(size*.1,size*.3,size*2.)), 3.5));
    
    //res.x = opS(res.x,sdSphere(pos+vec3(-size*2.,size*.5,0.),size*1.5));
    s = sdSphere(pos+vec3(-size*2.,size*.5,-size*2.),size*1.);
    
    //res.x = opS(res.x,sdBox(pos+vec3(-size*2.,0.,-size*2.),vec3(size*1.2,size*.4,size*.3)));
   	s = opU(s,sdBox(vec3(pos.x-size*.9,mod(pos.y,size*.3),pos.z-size*.95),vec3(size*.11,size*.1,size*.051)));
    s = opU(s,sdBox(vec3(pos.x,pos.y-size,mod(pos.z+size*.25,size*.2)),vec3(size*10.,size*.8,size*.1)));
    res.x = opS(res.x,s);
    
   	s = sdTriPrism(pos+vec3(-size*2.,-size*.2,-size*2.),vec2(size*2.5, size*0.1));
s = opS(s, sdSphere(pos+vec3(-size*2.,-size*.1,-size*2.5),size*1.25));

    res = opU(res, vec2(s, 2.));

    res = opU(res, vec2(sdBox(pos-vec3(0.,0.,size*2.), vec3(size*0.8, size*0.8, size*.1)), 3.5));
 
    res = opU(res, vec2(sdBox(pos-vec3(0.,0.,size*2.), vec3(size*0.05, size*2., size*.15)), 3.5));
 	res = opU(res, vec2(sdBox(pos-vec3(size*0.75,-size*1.5,size*2.), vec3(size*0.05, size*.5, size*.1)), 1.5));
 
    box = sdBox(pos+vec3(-size*.9, size*1.2, -size*.95), vec3(size*.05,size*1.1,size*.025));
    res = opU(res, vec2(box,3.5));
    
    box = sdCylinder(pos.yxz+vec3(size*2.,0.,0.),vec2(size*.4,size*4.));
    res.x = opS(res.x,box);
    box = sdCylinder(pos.yxz+vec3(size*2.,0.,-size*2.),vec2(size*.09,size*4.));
    res.x = opS(res.x,box);
    box = sdCylinder(pos.yxz+vec3(size*1.7,0.,-size*2.),vec2(size*.06,size*4.));
    res.x = opS(res.x,box);
    box = sdCylinder(pos.yxz+vec3(size*1.5,0.,-size*2.),vec2(size*.03,size*4.));
    res.x = opS(res.x,box);
    
    res = opU(res, vec2(box, 3.5));
    
    box = sdBox(pos+vec3(0.,0.,-size*1.3),vec3(size*.2,1.,size*.1));
    res.x = opS(res.x,box);
    
    res = opU(res, vec2(box, 1.5));
    res = opU(res, vec2(sdCylinder(pos, vec2(size*0.5, size*2.)), 2.));
    
    s = sdSphere(pos+vec3(-size*2.,-size*1.,-size*2.),size*1.);
    s = opS(s,sdBox(vec3(pos.x,pos.y-size*2.,-mod(pos.z+size*.15,size*.2)),vec3(size*10.,size*2.8,size*.1)));
	vec2 ii = vec2(s, 3.5);
    res = opU(res,ii);
    
    res = opU(res,vec2(sdBox(pos+vec3(-size*2.,size*.25,0.),vec3(size*.05,size*.4,size*0.6)), 2.));
    
    box = sdCylinder(pos.yxz+vec3(size*2.,-size*.5,0.),vec2(size*.3,size*.2));
    box =opU(box, sdCylinder(pos.yxz+vec3(size*2.,-size*.5,0.),vec2(size*.2,size*.4)));
    box =opU(box, sdCylinder(pos.yxz+vec3(size*2.,0.,0.),vec2(size*.1,size*4.)));
    res.x = opS(res.x,box);
    
    return res;
}
#define loop 4.

vec2 map( in vec3 pos ){
    float t = -anim;
    
    float s = t;
    s = mod(s,loop)-(loop*.5);
    s = clamp(s*.5,0.,1.);   
    
    t/=loop;
    vec2 res = gif9(pos);
    return res;
}

vec2 castRay( in vec3 ro, in vec3 rd )
{
    float tmin = 0.0;
    float tmax = 100.0;
 
    float t = tmin;
    float m = -1.0;
    for( int i=0; i<steps; i++ )
    {
   vec2 res = map( ro+rd*t );
        if(  t>tmax ) break;
        t += res.x;
   m = res.y;
    }

    if( t>tmax ) m=-1.0;
    return vec2( t, m );
}

vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 calcNormal( in vec3 pos ){
vec3 eps = vec3( 0.0001, 0.0, 0. );
vec3 nor = vec3(
   map(pos+eps.xyy).x - map(pos-eps.xyy).x,
   map(pos+eps.yxy).x - map(pos-eps.yxy).x,
   map(pos+eps.yyx).x - map(pos-eps.yyx).x );
return normalize(nor);
}

float calcAO( in vec3 pos, in vec3 nor )
{
float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<10; i++ ) {
        float hr = 0.01 + 0.006*float(i);
        vec3 aopos =  nor * hr + pos;
        float dd = map( aopos ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.6;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}

vec3 render( in vec3 ro, in vec3 rd )
{ 
    vec3 col = vec3(1.0);
    vec2 res = castRay(ro,rd);
    vec3 pos = ro + res.x*rd;
    vec3 nor = calcNormal(pos);
    float ao = calcAO(pos,nor);
    
    const vec3 a = vec3(.5, .1, .5);
    const vec3 b = vec3(.5, .1, .5);
    const vec3 c = vec3(.3, 1.4, 0.);
    const vec3 d = vec3(.5, .0, .25);
    col = palette(res.y, a, b, c, d);
	col = 1.0-(col+(1.0-ao))*(1.0-res.x*fog)*.85;
	return vec3( clamp(col,0.0,1.0) );
}
mat3 setCamera( in vec3 ro, in vec3 ta, float cr )
{
	vec3 cw = normalize(ta-ro);
	vec3 cp = vec3(sin(cr), cos(cr),0.0);
	vec3 cu = normalize( cross(cw,cp) );
	vec3 cv = normalize( cross(cu,cw) );
    return mat3( cu, cv, cw );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy/iResolution.xy;
    vec2 p = -1.0+2.0*q;
	p.x *= iResolution.x/iResolution.y;
    
	vec3 ro = vec3( 0.,0.,anim );
	vec3 ta = ro+vec3( 0.,0.,1. );
    mat3 ca = setCamera( ro, ta, 0.0 );    
    
    float warp =.666;    
    float fov = 70.0;
    float rayZ = tan ((90. - 0.5 * fov) * 0.01745329252);
	vec3 rd = normalize( vec3(p.xy,-rayZ) )*ca;
    rd = vec3(rd.xy,sqrt (1.0 - warp * warp) * (rd.z + warp));
    rd = normalize(rd);
    
    vec3 col = render( ro, rd );

    fragColor=vec4( col, 1.0 );
}