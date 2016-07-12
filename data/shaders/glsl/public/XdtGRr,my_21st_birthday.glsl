// Shader downloaded from https://www.shadertoy.com/view/XdtGRr
// written by shadertoy user 834144373
//
// Name: My 21st Birthday
// Description: Some bug,it's diffirent between shadertoy and glslsandbox.      My dream is to become a organic chemist,but I can only be seen.
//    [url]http://www.glslsandbox.com/e#28924.0[/url]
//    [url]http://www.glslsandbox.com/e#28925.0[/url]
//My 21st Birthday.glsl
//License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//Created by 834144373 (恬纳微晰) 祝元洪 2015/11/17
//Tags: Birthday, 3D, Raymarching,Happy Birthday,Milk and Edge.
//Original: https://www.shadertoy.com/view/XdtGRr
//
//-------Birthday(生日):11/18
//-----------------------------------------------------------------------------------------
#define PI 3.1415
//#define _PI 3.1415
#define _2PI 6.2830

float scale = 1.5 / 1000.0;
////////////////////
vec3 Rot(vec3 p,vec3 angles)
{
    vec3 c = cos(angles);
    vec3 s = sin(angles);
    
    mat3 rotX = mat3( 1.0, 0.0, 0.0, 0.0,c.x,s.x, 0.0,-s.x, c.x);
    mat3 rotY = mat3( c.y, 0.0,-s.y, 0.0,1.0,0.0, s.y, 0.0, c.y);
    mat3 rotZ = mat3( c.z, s.z, 0.0,-s.z,c.z,0.0, 0.0, 0.0, 1.0);
	    
    return p*rotX * rotY * rotZ;
}
vec3 Rotx(vec3 p,float angle){
    float c = cos(angle);
    float s = sin(angle);	
    return p*   mat3( c, s, 0.0,-s,c,0.0, 0.0, 0.0, 1.0);
}
vec3 Roty(vec3 p,float angle){
    float c = cos(angle);
    float s = sin(angle);	
    return p*mat3( c, 0.0,-s, 0.0,1.0,0.0, s, 0.0, c);
    //return p*mat3( c, s, 0.0,-s,c,0.0, 0.0, 0.0, 1.0);	
}

vec3 Twist( vec3 p ,float a,float b)
  {
      float c = cos(a*p.y);
      float s = sin(b*p.y);
      mat2  m = mat2(c,-s,s,c);
      vec3  q = vec3(m*p.xz,p.y);
      return q;
  }
vec2 plane(vec3 pos,float id){
	
	return vec2(pos.y,id);
}

vec2 plane_x(vec3 pos,float id){
	return vec2(pos.x,id);
}
vec2 plane_y(vec3 pos,float id){
	return vec2(pos.z,id);
}
vec2 sdPlane( vec3 p, vec4 n, float id )
{
  float d =  dot(p,n.xyz) + n.w;
  return vec2(d,id);
}

vec2 sphere( vec3 pos,float r,float id){
	float d = length(pos)-r;
	return vec2(d,id);
}

vec2 box( vec3 pos,vec3 xyz,float o,float id){
	float d = length( max(abs(pos)-xyz,0.0))-o;
	return vec2(d,id);
}

vec2 cylinder(vec3 pos,vec2 h,float id){

	vec2 d = abs(vec2(length(pos.xz),pos.y)) - h;
	
	return vec2(min(max(d.x,d.y),0.0) + length(max(d,0.0)),id);
}

vec2 torus(vec3 pos,vec2 h){
  vec2 q = vec2(length(pos.xz)-h.x,pos.y);
  return vec2(length(q)-h.y,1.);
}
//------------

float dfLine(vec2 start, vec2 end, vec3 p){
	start *= scale;
	end *= scale;
	vec2 line = end - start;
	float frac = dot(p.xy - start,line) / dot(line,line);
	
	float d = distance(start + line * clamp(frac, 0.0, 1.0), p.xy);
	
	float dd = length(vec2(d-0.,p.z-0.))-0.01;
	return dd;
}

//Distance to the edge of a circle.
float dfCircle(vec2 origin, float radius, vec3 p)
{
	origin *= scale;
	radius *= scale;
	
	float d =  abs(length(p.xy - origin) - radius);
	
	float dd = length(vec2(d,p.z))-0.01;
	return dd;
}

//Distance to an arc.
float dfArc(vec2 origin, float start, float sweep, float radius, vec3 p)
{
	origin *= scale;
	radius *= scale;
	p.xy -= origin;
	p.xy *= mat2(cos(start), sin(start),-sin(start), cos(start));
	
	float offs = (sweep / 2.0 - 3.14);
	float ang = mod(atan(p.y, p.x) - offs, 6.28) + offs;
	ang = clamp(ang, min(0.0, sweep), max(0.0, sweep));
	
	float d =  distance(radius * vec2(cos(ang), sin(ang)), p.xy);
	
	float dd = length(vec2(d,p.z))-0.01;
	return dd;
	
}
//------------



/////////////////////////////////
vec2 Min( vec2 d1, vec2 d2 ){
  return (d1.x < d2.x) ? d1 : d2;
}

vec2 Smin(vec2 d1,vec2 d2,float c){
	float a = abs(1. - abs(d1.x-d2.x));
	vec2 b = Min(d1,d2);
	float d = b.x - exp(-a)/c;
	return vec2(d,b.y);
}
vec2 smin(vec2 a, vec2 b, float k) {
	float h = clamp(0.5 + 0.5 * (b.x - a.x) / k, 0.0, 1.0);
	float id = Min(a,b).y;
	float d = mix(b.x, a.x, h) - k * h * (1.0 - h);
	return vec2(d,id);
}

vec2 smooth_min (vec2 d1, vec2 d2, float k) {    //inigo quile's min
    	float a = pow(d1.x, k), b= pow(d2.x, k);
    	float d = pow((a*b)/(a + b), 1.0/k);
	return vec2(d,Min(d1,d2).y);
}

vec2 Max( vec2 d1, vec2 d2 )
{
  return (d1.x > d2.x) ? d1 : d2;
}

vec2 Smax( vec2 d1, vec2 d2 )
{
  return (-d1.x > d2.x) ? d1*vec2(-1,1) : d2;
}
/////////////////////////////////

vec3 opAngRep( vec3 p, float a, float off){
	vec2 polar   = vec2(atan(p.y, p.x), length(p.xy));
	     polar.x = mod (polar.x + a / 2.0 + off, a) - a / 2.0;
	return vec3(polar.y * vec2(cos(polar.x),sin(polar.x)), p.z);
}

vec3 insAngObj(vec3 p,vec3 to,float r,float k){
	float an = atan(p.z,p.x)*4.;
	
	p.xz = abs(p.xz);
	p -= vec3(1.4);
	return p;
}

vec2 _6( vec3 p, vec2 h ,float id)
{
    vec3 q = abs(p);
    return vec2(max(q.z-h.y,max((q.x*0.866025+q.y*0.5),q.y)-h.x),id);
}
//////////////////////////


vec2 superTwist(vec3 p,float r,float Vertics,float Edges,float id){
	float edgeAngle  = _2PI / Edges;
	float vertexAngle  = _2PI / Vertics;
	vec3 angrep = opAngRep(p, vertexAngle, 0.0);	
	     angrep = opAngRep(angrep.xzy - vec3(r,0,0), edgeAngle, atan(p.y,p.x) * 2. );
	vec2 d = sdPlane(angrep, normalize(vec4(2., .0, 0.0, -0.1)),id);
	return vec2(d.x,id);
}

vec2 candle(vec3 pos){
	vec3 p0,p1,p2,p3,p4;
	
	p0 = pos;
		p0.xz = abs(p0.xz)-0.5;
	p1 = Roty(pos,PI/3.);
		p1.xz = abs(p1.xz)-0.5;
	p2 = Roty(pos,PI/6.);
		p2.xz = abs(p2.xz)-0.5;
	
	p3 = pos;
    	p3.xz = abs(p3.xz)-0.21;
																																				   //p3.xz = abs(p3.xz)-0.3;
	p4 = Roty(pos,PI/4.);
		p4.xz = abs(p4.xz)-0.21;
	
	vec2 d0 = box	   ( p0	,vec3(0.,0.4,0.)*0.4,0.00, 	1.);
	vec2 d1 = box	   ( p1	,vec3(0.,0.4,0.)*0.4,0.00, 	1.1); 
	vec2 d2 = box	   ( p2	,vec3(0.,0.4,0.)*0.4,0.00, 	1.2);
	
	vec2 d3 = box	   ( p3	,vec3(0.,0.65,0.)*0.4,0.004, 	1.3);
	vec2 d4 = box	   ( p4	,vec3(0.,0.65,0.)*0.4,0.004, 	1.4);
	
	vec2 d;
		d = Min(d0,d1);	
		d = Min(d,d2);
	
		d = Min(d,d3);
		d = Min(d,d4);

		d = Min(d,box( pos,vec3(0.,0.9,0.)*0.4,0.008, 1.5));
	return d;
}

float _2_1(vec3 p){
	float dist = 1.;
	p *= 0.4;
	p.xy -= vec2(-0.5,.2);
		
	dist = min(dist, dfLine( vec2(300.000,0.000),vec2(200.000,0.000), p));
	dist = min(dist, dfLine(vec2(216.371,26.726), vec2(272.714,55.457), p));
	dist = min(dist, dfArc(vec2(250.000,100.000),5.184, 4.241, 50.000, p));
	dist = min(dist, dfArc(vec2(230.000,0.000),2.042, 1.099, 30.000, p));
	
	p.xy -= vec2(0.4,0.);
	dist = min(dist, dfLine(vec2(150.000,150.000),vec2(150.000,0.000), p));
	return dist;
}

//85654359
vec2 otherthing(vec3 pos){
	//pos.y *= 2.2;
	
	//vec2 d = sphere(pos-vec3(0.,-0.45,0.1),.06,8.);
	float d = _2_1(pos);
	return vec2(d,8.);
}

vec2 thing(vec3 pos){
	//lifang red
	vec2 d1 = candle(pos-vec3(0.,-0.022,0.)); 
	//cylinder  table
	vec2 d2 = cylinder(pos-vec3(0.,-1.,0.),	vec2(1.8,.001),		2.) - vec2(0.01*sin(pos.x*_2PI*6.)+0.01*sin(pos.z*_2PI*4.),0.);
	//lifang blue
	//vec2 d3 = box     (pos-vec3(1.,-0.7,1.),		vec3(1.,1.,1.)*0.2,  0.,  	3.);
	
	//yuanzhu  zi se 
	vec2 d5 = cylinder(pos-vec3(0.,-.6,0.),	vec2(0.7,.28),			5.);
	vec2 d5_1= cylinder(pos-vec3(0.,-1.,0.),	vec2(0.8,0.1),			5.);
	
	//table
	vec2 d6 = cylinder(pos-vec3(0.,-1.02,0.),	vec2(1.85,0.02),		6. );
	
	//super
	vec2 d7 = superTwist(pos.xzy-vec3(0.,0.,-0.35),0.67,16.,8.,7.);
		//s.x += 0.01*sin(pos.x*3.*_2PI);
		d5 = Min(d7,d5);
	//cho
	//vec2 d8 = otherthing(pos);
	/////
	vec2 d =  Min(d1,d2);
	
	     d = Min(d,d6);
	    // d = Min(d,superTwist(pos.xzy-vec3(0.,1.,0.),0.7,10.,6.,1.));
	    //d = Max(d,s);
	     //d = Min(d,d8);
	return Min(d,Smin(d5,d5_1,8.));
}

vec2 evp(vec3 pos){
	vec2 d = vec2(1.);
	
	//plane blue
	vec2 d0 = sdPlane (pos-vec3(0.,-4.,0.),normalize(vec4(0.,1.,0.,0.)),		4. );
	vec2 d0_1 = plane_x(pos-vec3(-6.4,0.,0.),					4.1);
	vec2 d0_2 = plane_y(pos-vec3(0.,0.,-6.4),					4.2);
		
	d = Min(Min(d0,d0_1),d0_2);
	
	//d = Min(d,d1);
	
	return d;
}
	
vec2 obj(vec3 pos){
	
	vec2 d0 = thing(pos-vec3(0.,0.5,0.));
	vec2 d1 = evp(pos);
	vec2 d  = Min(d0,d1);
	return d;
}

vec2 dis(vec3 pos,vec3 p){
	float dd = 1.;
	vec2 d  ;
	for(int i = 0;i<64;++i){
		vec3 sphere = pos+dd*p;
		d = obj(sphere);
		dd += d.x;
		if(d.x<0.02 || dd>20.)break;
	}
	return vec2(dd,d.y);
}

vec3 normal(in vec3 surface){
	vec2 offset = vec2(0.01,0.);
	vec3 nDir   = vec3(
		obj(surface + offset.xyy).x,
		obj(surface + offset.yxy).x,
		obj(surface + offset.yyx).x
	)-obj(surface).x;
	
	return normalize(nDir);
}
////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
float My_edge_shadow(vec3 surface, vec3 lig_p,float mintd, float maxdd, float k0,float k1) {
	float start_d = mintd;
	float d = 0.0;
	float mind = 1.0;
	for(int i = 0; i < 20; i++) {		
		d = obj(surface + start_d*lig_p).x;
		mind = min(mind, exp(d*k0)/k1 );
		start_d += d;
		if(start_d > maxdd) break;
	}
	return mind;
}

float My_milk_shadow(vec3 surface, vec3 lig_p,float mintd, float maxdd, float k0,float k1,float k3) {
	float start_d = mintd;
	float d = 0.0;
	float mind = 1.0;
	for(int i = 0; i < 20; i++) {		
		d = obj(surface + start_d*lig_p).x;
		mind = min(mind, abs(log(d*k0+k3))/k1 );
		start_d += d;
		if(start_d > maxdd) break;
	}
	return mind;
}

float fresnel(vec3 dir,vec3 normal,float k){
	return pow(max(0.,dot(dir,normal)),k);
}
float My_specular(vec3 vDir,vec3 lig, vec3 normal,float k){
	vec3 h = normalize(-vDir+lig);
		float spe = fresnel(h,normal,k);
	return spe;
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void mainImage(out vec4 color,in vec2 coord) {

	vec2 uv = (coord.xy - iResolution.xy/2.)/iResolution.y;
	vec2 mo = (iMouse.xy/iResolution.xy-vec2(0.5,0.))*vec2(10.,1.);
	
	float t1 = -.4;// - min(mo.y*1.3,.4);
	float t2 = iGlobalTime*0.1;
	float t3 = 0.;

	//ppppp
	vec3 p = normalize(vec3(uv,2.));
		p = Rot(p,vec3(t1,t2+mo.x,t3));
		//p = Rotx(p,mo.y);
	//
	vec3 campos = vec3(0.,0.,-6.8);
		campos = Rot(campos,vec3(t1,t2+mo.x,t3));	
		//campos = Rotx(campos,mo.y);
	//
	vec2 dd = dis(campos,p);
	
	vec3 col = vec3(0.8);
	if(dd.x<20.){
		vec3 surface = campos + dd.x*p;
		vec3 lig  	= normalize(vec3(1.,1.,-1.));
		//vec3 lig2 	= normalize(vec3(-1.,1.,-1.));
		
		//vec3 nDir 	= normal(surface);
		//float diff  	= max(0.,dot(lig2 ,nDir));
		//float diff2 	= max(0.,dot(lig,nDir));
		//float spe 	= My_specular(p,lig,nDir,5.);
		//float sh  	= My_edge_shadow(surface,lig,.13,1.,8.,3.);
		//float ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
        float sh,ssh;
		if(dd.y == 1. ){
			 sh  = My_edge_shadow(surface,lig,.13,1.,8.,3.);
			 ssh = My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(1.,1.,.9)*max(sh,ssh);
		}
		else if(dd.y == 1.1){
			 sh  = My_edge_shadow(surface,lig,.13,1.,8.,3.);
			 ssh = My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(.9,1.,1.)*max(sh,ssh);
		}
		else if(dd.y == 1.2){
			 sh  	= My_edge_shadow(surface,lig,.13,1.,8.,3.);
			 ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(1.,.9,1.)*max(sh,ssh);
		}
		else if(dd.y == 1.3){
			 sh  	= My_edge_shadow(surface,lig,.13,1.,8.,3.);
			 ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(1.,1.,1.)*max(sh,ssh);
		}
		else if(dd.y == 1.4){
			 sh  	= My_edge_shadow(surface,lig,.13,1.,8.,3.);
			 ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(0.9,.9,1.)*max(sh,ssh);
		}
		else if(dd.y == 1.5){
			 sh  	= My_edge_shadow(surface,lig,.13,1.,8.,3.);
			 ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(0.9,1.+(sin(iGlobalTime)+1.)*0.8,0.9)*max(sh,ssh);
		}
		else if(dd.y == 2.){
			 ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);			
			col = vec3(0.6,0.6,0.6)*ssh;
		}
		//if(dd.y == 3.){col = vec3(0.,1.,1.)*sh;}
		
		else if(dd.y == 4.){
			 ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(.7,0.6,.7)*ssh/1.2;
		}
		else if(dd.y == 4.1){col = vec3(1.,.5,0.);}
		else if(dd.y == 4.2){col = vec3(.5,.5,0.);}
	
		else if(dd.y == 5.){
			 sh  	= My_edge_shadow(surface,lig,.13,1.,8.,3.);
			 ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(1.,1.,1.)*max(ssh,sh);
		}
				
		else if(dd.y == 6. ){
			vec3  nDir 	= normal(surface);
			float diff  	= max(0.,dot(lig,nDir));
			float spe 	= My_specular(p,lig,nDir,5.);
			 sh  	= My_edge_shadow(surface,lig,.13,1.,8.,3.);	
			float c = mix(diff,pow(1.-diff,2.),0.7);
			      c = mix(c,spe,.7);
			col = vec3(1.)*mix(c,sh,0.2);
		}
		else if(dd.y == 7.){
			ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(0.94,1.,1.)*(ssh);				
		}
		else if(dd.y == 8.){
			//col = vec3(1.,0.,0.)*(spe+diff);
			//surface.xz *= 10.;
		    ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
			col = vec3(1.1,1.,1.4)*ssh;//0.2*mix(vec3(1.7,0.6,0.2),vec3(1.8,1.8,1.2)*2.0,smoothstep(0.7,0.9,0.5+0.7*cos(surface.x*10.0+sin(surface.z*5.0))))+0.06*vec3(1.0,1.0,0.5);
			//col *= diff;
			
		}
		
		//you can uncomment this to see the milk_edge rend
        //float sh  = My_edge_shadow(surface,lig,.13,1.,8.,3.);
		//float ssh	= My_milk_shadow(surface-vec3(0.01,-0.,-0.0),lig,.13,1.,20.,2.5,6.3);
		//col = vec3(max(sh,shh));
	}
	
	color = vec4(col, 1.0 );

}