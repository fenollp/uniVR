// Shader downloaded from https://www.shadertoy.com/view/lssGDX
// written by shadertoy user eiffie
//
// Name: Quadrics
// Description: Ray tracing goo.
// Quadrics by eiffie, just tired of raytraced spheres and planes
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

const int AA=2, MaxBounces=6;
const float fov = 2.0,maxDepth=10.0;
const vec3 sunColor=vec3(1.0,0.9,0.8),skyColor=vec3(0.5,0.5,0.7);
vec3 sunDir=normalize(vec3(0.1,0.1,-1.0));
const vec3 ior=vec3(1.0,1.52,1.0/1.52);//w=1.33,g=1.52,d=2.42

#define time iGlobalTime
#define size iResolution
#define tex iChannel0

struct material {vec3 color;float refrRefl,spec,specExp;}mtrl;
struct hit {float t;vec3 n,p;};//hit time, normal and untransformed position (for texturing)
struct intersect {hit h1,h2;bool bInside;int obj;}intr;

hit bogusHit=hit(maxDepth,vec3(0.0),vec3(0.0));
const mat3 idm=mat3(1.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,1.0);

float fRay=0.0;
vec3 ro,rd;
mat3 rmx;

intersect Quadric(vec3 p, vec3 abc, float r, int obj){//Ax^2 + By^2 + Cz^2 - r = 0 
	hit h1=bogusHit,h2=bogusHit;
	vec3 e=rmx*ro-p,dr=rmx*rd;//transform 
	float A=dot(abc*dr,dr),B=2.0*dot(abc*e,dr),C=dot(abc*e,e)-abs(r)*r,inner=B*B-4.0*A*C;		
	if(inner<0.0){//throw out if not inside (if inside your looking thru the middle of a cylinder etc.)
		if(C<0.0){h1=hit(-maxDepth,vec3(1.0),vec3(0.0));h2=hit(maxDepth,vec3(1.0),vec3(0.0));}
	}else {
		inner=sqrt(inner);
		vec2 t=vec2(-B-inner,-B+inner)/(2.0*A);
		if(t.x>t.y){if(t.y>0.0)t.x=-maxDepth; else t.y=maxDepth;}//below inverse transform the normals (rotate back)
		h1=hit(t.x,normalize(abc*(e+dr*t.x))*rmx,e+dr*t.x);h2=hit(t.y,normalize(abc*(e+dr*t.y))*rmx,e+dr*t.y);	
	}
	return intersect(h1,h2,C<0.0,obj);
}

void Sort(inout intersect i1, in intersect i2){//if the second object is closer and not behind, switch
	if(i2.h1.t<i1.h1.t && i2.h2.t>0.0)i1=i2;
}

/*void Intersection(inout intersect i1, in intersect i2){
	if(i2.h1.t>i1.h1.t)i1.h1=i2.h1;
	if(i2.h2.t<i1.h2.t)i1.h2=i2.h2;
	if(i1.h2.t<i1.h1.t){i1.h1.t=i1.h2.t=maxDepth;i1.obj=-1;}//no intersection
	i1.bInside=(i1.h1.t<0.0 && i1.h2.t>0.0);
}*/

mat3 matPyr(vec3 rot){vec3 c=cos(rot),s=sin(rot);//orient the mat3 (pitch yaw roll)
	return mat3(c.z*c.y+s.z*s.x*s.y,s.z*c.x,-c.z*s.y+s.z*s.x*c.y,-s.z*c.y+c.z*s.x*s.y,c.z*c.x,s.z*s.y+c.z*s.x*c.y,c.x*s.y,-s.x,c.x*c.y);
}
mat3 rm2;//=matPyr(vec3(0.0,0.0,time));
vec3 ABC;//=vec3(sin(time*0.21),sin(time*0.34),0.8+sin(time*0.13)*0.2);
vec3 goo;
float radius;//=sin(time*0.2)*0.5;
void Trace(){
	intr.h1.t = maxDepth; intr.bInside=false; intr.obj = -1;rmx=idm;//reset
	Sort(intr, Quadric(vec3(0.0,0.0,3.0),vec3(0.0,0.0,1.0),1.0,0) );
	rmx=rm2;
	Sort(intr, Quadric(goo,ABC,radius,1) );
}

void getMaterial(){
	if( intr.obj == 0 ){//plane
		vec2 xy=intr.h1.p.xy*0.5;
		vec3 c=texture2D(tex,xy).rgb;
		mtrl.color = c.rbg;mtrl.refrRefl=0.1;mtrl.spec=1.0;mtrl.specExp=64.0;
		float dx=c.b-texture2D(tex,xy-vec2(0.004,0.0)).b,dy=c.b-texture2D(tex,xy-vec2(0.0,0.004)).b;
		intr.h1.n=normalize(intr.h1.n+vec3(dx,dy,0.0));
	}else {
		mtrl.color=vec3(1.0,1.0,0.9);mtrl.refrRefl=-1.0;mtrl.spec= 1.0;mtrl.specExp= 256.0;//glass
	}
}

vec3 getBackground( in vec3 rdir ){
	return clamp(skyColor+rd*0.25+sunColor*(pow(max(0.0,dot(rdir,sunDir)),2.0)*0.25+pow(max(0.0,dot(rdir,sunDir)),80.0)*0.75),0.0,1.0);
}
 
vec3 scene() {// find color of scene
	vec3 fcol=vec3(1.0),acol=vec3(0.0);
	intr.obj = 0;
	for(int i=0; i<MaxBounces; i++ ){// bounce loop
		if(intr.obj < 0)continue;
		Trace();//get distance into scene
		if(intr.obj >= 0){//hit something
			bool bInside=intr.bInside;
			if(bInside){intr.h1=intr.h2;intr.h1.n*=-1.0;}
			intr.h1.t=max(0.0,intr.h1.t);
			ro += rd * intr.h1.t;// advance ray position to hit point
			getMaterial();//match material properties to item hit
			vec3 nor=intr.h1.n;
			vec3 refl=reflect(rd,nor),newRay=refl;//setting up for a new ray direction and defaulting to a reflection
			if(mtrl.refrRefl<0.0){//if the material refracts use the fresnel eq.
				vec3 refr=refract(rd,nor,(bInside)?ior.y:ior.z);//calc the probabilty of reflecting instead
				vec2 ca=vec2(dot(nor,rd),dot(nor,refr)),n=(bInside)?ior.yx:ior.xy,nn=vec2(n.x,-n.y);
				if(fRay>0.5*(pow(dot(nn,ca)/dot(n,ca),2.0)+pow(dot(nn,ca.yx)/dot(n,ca.yx),2.0))){newRay=refr;nor=-nor;}
				fcol*=mtrl.color;
			}else if(mtrl.refrRefl<=fRay){
				newRay=sunDir;
				fcol*=mix(mtrl.color*max(0.2,dot(nor,sunDir)*0.8),vec3(1.0),pow(max(0.0,dot(refl,newRay)),mtrl.specExp)*mtrl.spec);
				acol+=fcol*0.1;
			}else{//these have perfect reflections
				fcol*=mtrl.color;
			}
			rd=newRay;
			ro += rd * 0.0001;//pushs away/thru the surface
			if(dot(fcol,fcol)<0.01)intr.obj = -1;//bail out since light energy is low
		}
	}
	return clamp(acol+fcol*getBackground(rd),0.0,1.0);//light the scene
}	

mat3 lookat(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,normalize(up)));return mat3(rt,cross(rt,fw),fw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {//for slow accumulation (needs alphaAccum.anim)
	vec3 clr=vec3(0.0);
    rm2=matPyr(vec3(0.0,0.0,time));
    ABC=vec3(sin(time*0.21),sin(time*0.34),0.8+sin(time*0.13)*0.2);
    radius=sin(time*0.2)*0.5;
	goo=sin(vec3(fragCoord.xy/iResolution.xy*10.0,0.0)+vec3(time))*0.15;
	const vec3 ey=vec3(0.0,-1.0,-1.5);
	mat3 rotCam=lookat(vec3(0.0,1.25,2.0),vec3(0.0,1.0,0.0));
	const float aa = float(AA),iaa = 1.0/aa;
	for(int i=0;i<AA*AA;i++){
		vec2 xy = vec2(mod(float(i),aa),floor(float(i)*iaa+iaa*0.5))*iaa;
		vec2 pxl = (-size.xy+2.0*(fragCoord.xy+xy))/size.y;
		ro = ey;
		rd = rotCam * normalize( vec3( pxl, fov ) );
		clr+=scene();
		fRay+=iaa*iaa;
	}
	clr*=iaa*iaa;
	fragColor = vec4(clr,1.0);
}
