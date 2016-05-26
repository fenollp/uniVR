// Shader downloaded from https://www.shadertoy.com/view/4syGW1
// written by shadertoy user eiffie
//
// Name: Citrus Rat Traversal
// Description: This probably has another name but could it be better than &quot;Citrus Rat&quot;?
//Citrus Rat Traversal by eiffie
//The impatient citrus rat wants to get to the orange as quickly as possible but it
//doesn't have the intelligence to plan a route or remember where it has been past
//the last branch. How does it find the orange every time and often in the
//shortest time?

//1. Start going up.
//2. If going up take the branch that seems to point towards the orange (local min)
//3. If it gets too far away go back down.
//4. If going down you come to a branch look to see which way you came down.
//   a) If you came down from the direction of the orange take the opposite branch up.
//   b) If not keep going down.

//Even though the citrus rat doesn't need to remember his moves I still had to use
//a stack... I hate rats.

//Actually this search method although not optimal does work on any problem where
//you make decisions that can be ranked best to worst. Those solutions
//that are local minimums are reached quickly, others are reached eventually.

//I tried it on the parametric curve from iq and it took 100 touchs compared
//to 35 for a march with "fudging" so it is nothing magical.
//https://www.shadertoy.com/view/MsKGDz

//v2 Improved the logic (not the rat's, my own)

#define DEPTH 6.
#define MIN_DIST 0.01
#define load(a) texture2D(iChannel0,(vec2(a,0.0)+0.5)/iResolution.xy)

float IDX,DONE;//index and branch done bit stacks for ease
void clear(){IDX=1.;DONE=0.;}//to get a usable index number start at 1
bool push(bool bLeft, bool bDone){
	IDX=IDX*2.0+(bLeft?1.0:0.0);
	DONE=DONE*2.0+(bDone?1.0:0.0);
	return IDX>pow(2.0,DEPTH)-0.5;
}
void pop(out bool bLeft, out bool bDone){
	IDX/=2.0;bLeft=(fract(IDX)>0.0);IDX=floor(IDX);
	DONE/=2.0;bDone=(fract(DONE)>0.0 || IDX<0.5);DONE=floor(DONE);
}

//tree config
float scl1,scl2,BO;
mat2 mx1,mx2;

void setup(){
	vec4 st=load(0);
	scl1=st.z;scl2=st.w;
	BO=1.0/(min(scl1,scl2)-1.0);BO*=BO;
	mx1=mat2(cos(st.x),sin(st.x),-sin(st.x),cos(st.x));
	mx2=mat2(cos(st.y),sin(st.y),-sin(st.y),cos(st.y));
}

//do transformations with each push/pop, scale,rot space and offset by constant 
bool Push(inout vec3 p, bool bLeft, bool bDone){
	if(bLeft){p*=scl1;p.xy=p.xy*mx1;}
	else {p*=scl2;p.xy=mx2*p.xy;}
	p.y-=1.0;
	return push(bLeft, bDone);
}
void Pop(inout vec3 p, out bool bLeft, out bool bDone){//reverse transform
	pop(bLeft, bDone);
	p.y+=1.0;
	if(bLeft){p.xy=mx1*p.xy;p/=scl1;}
	else {p.xy=p.xy*mx2;p/=scl2;}
}

float Branch(vec3 p){return length(vec3(p.x,p.y-clamp(p.y,-1.0,0.0),p.z))-0.05+p.y*0.025;}

float Tree(vec2 p0){
	vec3 p=vec3(p0,1.0);//p.z is scale
	clear();
	
	//these two control the rats behavior
	bool bLeft;//should the rat use the left branch?
	bool bDown=false;//is the rat ascending?	
	float dm=Branch(vec3(p.xy,0.0)); //minimum distance to branchs
	for(int i=0;i<99;i++){
        if(dm<MIN_DIST || IDX<0.5)break;//we hit the surface or ran out of tree
		if(bDown){
			Pop(p,bLeft,bDown); //drop down a level
			if(bDown)continue; //if this level is also done keep popping
			bDown=true; bLeft=!bLeft;//the rat came down so go up wrong side
		}
		bDown=Push(p,bLeft,bDown); //move up a branch and see if we hit the end
		dm=min(Branch(vec3(p.xy,0.0))/p.z,dm);//save nearest length to branch for drawing
		bLeft=(p.x<0.0); //find the best direction
		if(dot(p.xy,p.xy)>BO)bDown=true;//this branch is out of range so back down 
	}
	return dm;
}

vec2 Rat(vec2 uv){
	vec4 p=load(1);
	p.xy+=texture2D(iChannel1,uv).xy*0.03;
	return vec2(length(uv-p.zw)-0.05,length(uv-p.xy)-0.05);
}
void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec2 uv=4.0*(fragCoord.xy/iResolution.xy-vec2(0.5,0.4));
	setup();
	float d=Tree(uv);
	vec2 d2=Rat(uv);
	vec3 col=vec3(smoothstep(0.0,0.01,d));
	col=mix(vec3(0.85,0.75,0.0),col,smoothstep(0.0,0.01,d2.x));
	col=mix(vec3(0.5,0.0,0.0)+texture2D(iChannel1,uv).rgb*0.5,col,smoothstep(0.0,0.01,d2.y));
	fragColor=vec4(col,1.0);
}
