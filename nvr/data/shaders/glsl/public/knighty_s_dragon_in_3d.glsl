// Shader downloaded from https://www.shadertoy.com/view/4ll3Dn
// written by shadertoy user eiffie
//
// Name: knighty's dragon in 3d
// Description: 3d dragon ifs from Knighty's code found here:
//    [url=https://www.shadertoy.com/view/MsBXW3]https://www.shadertoy.com/view/MsBXW3[/url]
//this is an attempted 3d version of knighty's excellent dragon ifs indexed DE

//original at: https://www.shadertoy.com/view/MsBXW3
////////////////////////////////////////////////////////////////////////////////
// Distance estimation for dragon IFS. by knighty (nov. 2014).
////////////////////////////////////////////////////////////////////////////////

//play with these to see how they effect speed/accuracy...
#define DEPTH 9
#define REFINEMENT_STEPS 36


#define time iGlobalTime
#define size iResolution

#define ITER_NUM pow(2., float(DEPTH))
//Bounding radius to bailout. must be >1. higher values -> more accurate but slower (try 1000)
//for raymarching a value of 2 or 4 is enought in principle. A vuale of 1 (when REFINE_DE is undefined) will show the bounding circle and its transformations
//I found 1.5 (with a slider) to be the fastest trade off between DE speed and March speed - eiffie
#define BR2BO 1.5

mat3 rmx1,rmx2;//the scaled rotations are in these matrices - eiffie
vec3  A0   = vec3(1.,-1., 0.);//1st IFS's transformation similatrity
vec3  F0   = vec3(-1.,0.,0.);//fixed point of 1st IFS's transformation.
vec3  T0; //Translation term Computed in ComputeBC().
float scl0 = length(A0);//scale factor of the 1st IFS's 

//2nd IFS's transformation.
vec3  A1   = vec3(-1.,-1.,0.);
vec3  F1   = vec3(1.,0.,0.);
vec3  T1;
float scl1 = length(A1);

float Findex=0.;//mapping of IFS point to [0,1[
float minFindex=0.;//for colouring
float BR;//Computed in ComputeBC(). Bounding circle radius. The smaller, the better (that is faster) but it have to cover the fractal (actually it have to cover it's images under the transforms)
float BO;//Computed in ComputeBC(). Bailout value. it should be = (BR*s)^2 where s>1. bigger s give more accurate results but is slower.

mat3 matRight(vec3 rt){//like a scaled lookat matrix given the right hand dir - eiffie
	float r=length(rt);
	rt=normalize(rt);
	vec3 up=normalize(cross(vec3(0.0,0.0,1.0),rt));
	return r*mat3(rt,up,cross(rt,up));
}
vec3 Cmult(vec3 a, vec3 b){
	return b*matRight(a);//i couldn't think of a better way to do the scaled rotation :( - eiffie
} 

//Compute bounding circle
void ComputeBC(){
    //Compute bounding circle center w.r.t. fixed points
    float ss0=length(vec3(1.,0.,0.)-A0);
    float ss1=length(vec3(1.,0.,0.)-A1);
    float s= ss1*(1.-scl0)/(ss0*(1.-scl1)+ss1*(1.-scl0));
    vec3 C=F0+s*(F1-F0);
    //Translate the IFS in order to center the bounding circle at (0,0)
    F0-=C;
    F1-=C;
    //Pre-compute translations terms
    T0 = Cmult(vec3(1.,0.,0.)-A0,F0);
    T1 = Cmult(vec3(1.,0.,0.)-A1,F1);
    //Bounding circle radius
    BR = -ss0*length(F0)/(1.-scl0);
    //
    BO = BR*BR*BR2BO;
	rmx1=matRight(A0);rmx2=matRight(A1);//compute the scaled rotation mats - eiffie
}
void SetupDragon(float t){
    vec3 rot=vec3(cos(t*0.3)*vec2(cos(t),sin(t)),sin(t*0.3));
	//vec3 rot=vec3(vec2(cos(t),sin(t)),0.0);
    A1=Cmult(rot,A0);
    ComputeBC();
}
//Computes distance to the point in the IFS which index is the current index.
//lastDist is a given DE. If at some level the computed distance is bigger than lastDist
//that means the current index point is not the nearest so we bail out and discard all
//children of the current index point.
//We also use a static Bail out value to speed things up a little while accepting less accurate DE.

float dragonSample(vec3 p, float lastDist){
	float q=Findex;//Get the index of the current point
	float dd=1.;//running scale
	float j=ITER_NUM;
	for(int i=0; i<DEPTH; i++){
		float l2=dot(p,p);
		//float temp=BR+lastDist*dd;//this is to avoid computing length (sqrt)
		//if(l2>0.001+temp*temp || l2>BO) break;//since BO is so tight this didn't seem to help?? - eiffie
		if(l2>BO) break;
		//get the sign of the translation from the binary representation of the index
		q*=2.;
		float sgn=floor(q); q=fract(q); j*=.5;
		if(sgn==0.){p=p*rmx1+T0;dd*=scl0;}
		else {p=p*rmx2+T1;dd*=scl1;}
	}
	//update current index. it is not necessary to check the next j-1 points.
	//This is the main optimization
	Findex = ( Findex + j/ITER_NUM );
	float d=(length(p)-BR)/dd;//distance to current point
	if(d<lastDist) minFindex=Findex;
	return min(d,lastDist);
}

float DE(vec3 p){
	Findex=0.0;
	//Get an estimate. not necessary, but it's faster this way.
	float d=length(p)+0.5;
	//refine the DE
	for(int i=0; i<REFINEMENT_STEPS; i++){//experiment: try other values
	// In principle max number of iteration should be ITER_NUM but we actually
	//do much less iterations. Maybe less than O(DEPTH^2). Depends also on scl.
		d=dragonSample(p,d);
		if(Findex>=1.) break;
	}
	return d;
}
float rnd(vec2 c){return fract(sin(dot(vec2(1.317,19.753),c))*413.7972);}
float rndStart(vec2 fc){
	return 0.5+0.5*rnd(fc);
}
mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	SetupDragon(time);
	vec3 ro=vec3(0.0,0.0,3.0);
	vec3 rd=lookat(-ro)*normalize(vec3((2.0*fragCoord.xy-size.xy)/size.y,1.0));
	float t=DE(ro)*rndStart(fragCoord.xy),d=0.0,dm=100.0,tm,px=1.0/size.y;
	for(int i=0;i<32;i++){
		t+=d=DE(ro+rd*t);
		if(d<dm){dm=d;tm=t;}
		if(t>6.0 || d<px)break;
	}
	vec3 col=vec3(0.5+0.5*rd.y);
	if(dm<px*4.0){
		ro+=rd*tm;
		vec2 e=vec2(0.5*px,0.0);
		vec3 N=normalize(vec3(DE(ro+e.xyy),DE(ro+e.yxy),DE(ro+e.yyx))-vec3(DE(ro-e.xxx*0.577)));
		vec3 L=normalize(vec3(0.4,0.7,-0.2));
		col=0.75+0.25*sin(vec3(15.,6.5,3.25)*minFindex);
		col*=(0.5+0.5*dot(N,L));
	}
	fragColor = vec4(col,1.0);
	
}
