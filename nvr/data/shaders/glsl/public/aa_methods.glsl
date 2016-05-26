// Shader downloaded from https://www.shadertoy.com/view/XsSXDt
// written by shadertoy user eiffie
//
// Name: AA Methods
// Description: Why use your graphics card's features when you can write incredibly over complex code to do the same? Here is a comparison of some of the AA methods I've tried.
// AA Methods by eiffie
// A comparison of some of the crazy AA methods I've used.
// v2 added the FAKE_AA method

// USE_STANDARD_AA: is a typical 2x2 method but I've added some features to
//   push the ray a bit farther...
//   ADD_RAYS_CAN_BE_FEADERS: If a raymarch dies before coming within two pixels
//     then the next rays start at that point. Instead of being used as samples they
//     are used to "fead" the other rays.
//   ADD_AUTO_OVERSTEP: Pushes the march faster and backs up if it bumps its head.
//   ADD_BISECT_ERROR: When you bump your head back up half way.
//  Also I calc the pixel occlusion so edges are near perfect! The downside is it still
//  unrolls to 4X the number of instructions.

//  USE_EDGE_DETECT_AA: This is the same AA used in "Wood Scraps" only a bit better
//    implementation with up to 4 edges being drawn per ray. For each edge the pixel 
//    coverage is calculated and the edges are drawn back to front. This method is fast
//    (one ray march, 4 lighting calculations) but totally fails on really complex surfaces. 

//  USE_FAKE_AA: Only the first edge and most occluding surface are used to calc pixel 
//    coverage. One extra set of lighting calculations is needed. If no first edge is detected 
//    the second lighting calc is offset by half a pixel. Because the second
//    lighting calc is always performed it runs slower than the 4 edge detect!

//  USE_CHEAP_AA: Only the closest surface is used to calc pixel occlusion. No extra
//    distance estimates are needed but it only smooths the outer edges.

//uncomment one AA type...
//#define USE_STANDARD_AA
	#define ADD_RAYS_CAN_BE_FEADERS
	#define ADD_AUTO_OVERSTEP
	#define ADD_BISECT_ERROR
//#define USE_EDGE_DETECT_AA
#define USE_FAKE_AA
//#define USE_CHEAP_AA

//for the green line treatment uncomment this...
//#define COMPARE_TO_NO_AA

#define time iGlobalTime
#define size iResolution
#define MAX_DIST 10.0

bool bColoring=false;//i luv globals
vec3 mcol,offset;
float scale,mr;
float DE(in vec3 z0){//menger sponge by menger
	vec4 z=vec4(z0,1.0)/clamp(dot(z0,z0),mr,1.0);//with a ballfold
	for (int n = 0; n <4; n++) {
		z = abs(z);
		if (z.x<z.y)z.xy = z.yx;
		if (z.x<z.z)z.xz = z.zx;
		if (z.y<z.z)z.yz = z.zy;
		z = z*scale;
		z.xyz -= offset*(scale-1.0);
		if(bColoring && n==2)mcol+=vec3(0.5)+sin(z.xyz)*0.4;
		if(z.z<-0.5*offset.z*(scale-1.0))z.z+=offset.z*(scale-1.0);
	}
	return (length(max(abs(z.xyz)-vec3(1.0),0.0))-0.05)/z.w;
}
float rndStart(vec2 co){return 0.8+0.2*fract(sin(dot(co,vec2(123.42,117.853)))*412.453);}
float ShadAO(vec3 ro, vec3 rd, float px, vec2 fragCoord){//pretty much IQ's SoftShadow
	float res=1.0,d,t=4.0*px*rndStart(fragCoord.xy);
	for(int i=0;i<12;i++){
		d=max(0.0,DE(ro+rd*t))+0.01;
		res=min(res,d/t);
		t+=d;
	}
	return res;
}
mat3 lookat(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,up));return mat3(rt,cross(rt,fw),fw);
}
vec3 light_dir,light_col=vec3(1.0,0.0,0.0);
vec3 Light(vec3 so, vec3 rd, float px, float dist, vec2 fragCoord){
	vec2 v=vec2(0.5*px,0.0);//px is really pixelSize*t
    so-=rd*(px-dist);
	mcol=vec3(0.0);
	bColoring=true;//take color samples
	vec3 norm=normalize(vec3(-DE(so-v.xyy)+DE(so+v.xyy),-DE(so-v.yxy)+DE(so+v.yxy),-DE(so-v.yyx)+DE(so+v.yyx)));
	bColoring=false;//crappy lighting below
	vec3 diffuse_col=mcol/6.0+vec3(-0.125,0.0,0.125)*dot(norm,rd);
	float shad=ShadAO(so,light_dir,px,fragCoord),dif=dot(norm,light_dir)*0.5+0.5;
	float spec=0.25*pow(max(0.0,dot(light_dir,reflect(rd,norm))),0.25);
	dif=clamp(min(dif,shad)+0.15,0.0,1.0);
	return diffuse_col*dif+light_col*spec*shad;
}
vec4 shape(float t){
	t=mod(t,9.0);
	if(t<1.0)return vec4(0.865,1.24,1.48,2.38);
	if(t<2.0)return vec4(1.54,-0.02,0.7,2.4);
	if(t<3.0)return vec4(0.785,1.1,0.46,2.47);
	if(t<4.0)return vec4(0.86,0.7,0.1,2.13);
	if(t<5.0)return vec4(0.9,1.485,0.54,2.04);
	if(t<6.0)return vec4(1.3,-0.02,-0.14,1.79);
	if(t<7.0)return vec4(2.0,-0.3,0.42,2.05);
	if(t<8.0)return vec4(1.0,1.0,1.0,3.0);
	return vec4(2.0,0.56,-0.44,2.31);
}
void ShapeIt(float t){
	t/=3.0;
	vec4 sh=mix(shape(t),shape(t+0.1),smoothstep(0.9,1.0,fract(t)));
	scale=sh.w;offset=sh.xyz;mr=0.56+sqrt(abs(fract(t)-0.5)*0.4);
}
vec3 getRay(int RAY,float zoom,vec2 fragCoord){//creates the unrotated camera ray
	vec2 aa=vec2(floor((float(RAY)+0.1)*0.5),mod(float(RAY),2.0));
	return normalize(vec3((2.0*fragCoord.xy+aa-size.xy)/size.y,zoom));
}
void mainImage( out vec4 fragColor, in vec2 fragCoord ){
	float zoom=5.0,px=2.0/(size.y*zoom),MIN_DIST=px*0.01;//find the pixel size
	float time2=time*0.1,tim=sin(time2)*1.5;//anim junk
	light_dir=normalize(vec3(0.4+sin(time2*5.0-tim),0.7,0.5+sin(time2+tim)*0.7));
	ShapeIt(time*0.5+tim);
	//position camera
	vec3 ro=vec3(sin(tim),0.75+0.25*sin(time2*1.3),cos(tim))*(4.25+0.75*sin(time2*1.7));
	vec3 rd,up=normalize(vec3(sin(time+tim)*0.3,1.0,0.0));
	mat3 cam=lookat(-ro,up);
	
	vec3 col=vec3(0.0),bcol=vec3(fragCoord.y/size.y);
	float t=DE(ro)*rndStart(fragCoord.xy)*0.75,d;
	
#ifdef USE_STANDARD_AA
	float t0=t;
#ifdef ADD_RAYS_CAN_BE_FEADERS
	bool bSavedDepth=false;
#else
	bool bSavedDepth=true;
#endif
	vec3 closest[4];
	for(int RAY=0;RAY<4;RAY++){
		closest[RAY]=vec3(1000.0,0.0,0.0);
		rd=cam*getRay(RAY,zoom);
		float pd=10.0,os=0.0,step=0.0;
		t=t0;
		for(int i=0;i<48;i++){
			d=DE(ro+rd*t);
#ifdef ADD_AUTO_OVERSTEP
			if(d>os){		//we have NOT stepped over anything
				os=0.4*d*d/pd;//calc overstep based on ratio of this step to last
				step=d+os;	//add in the overstep
				pd=d;	//save this step length for next calc
			}else{
#ifdef ADD_BISECT_ERROR	
				os*=0.5;step=-os;	//remove half of overstep
				if(os>0.0001)d=1.0;//don't bail
				else step=d+os;
#else
				step=-os;d=1.0;pd=10.0;os=0.0;//remove ALL of overstep
#endif
			}
#else
			step=d; //normal march
#endif			
			if(d<closest[RAY].x)closest[RAY]=vec3(d,t,float(bSavedDepth));
			if(!bSavedDepth && d<2.0*px*t){bSavedDepth=true;t0=t-2.0*px*t;}
			t+=step;
			if(t>MAX_DIST || d<MIN_DIST)break;//hard stop
		}
		if(!bSavedDepth)t0=t-2.0*px*t;
	}
	if(bSavedDepth){
		float hit=0.0;
		for(int RAY=3;RAY>=0;RAY--){
			if(closest[RAY].x<px*closest[RAY].y){
				vec3 rd=cam*getRay(RAY,zoom);
				vec3 scol=Light(ro+rd*closest[RAY].y,rd,px*closest[RAY].y,closest[RAY].x);
				vec3 bgc=bcol;
				if(!bool(closest[RAY].z))bgc=col/hit;
				scol=mix(scol,bgc,clamp(closest[RAY].x/(px*closest[RAY].y),0.0,1.0));
				col+=scol;
				hit+=1.0;
			}else{
				if(bool(closest[RAY].z)){
					col+=bcol;hit+=1.0;
				}
			}
		}
		col/=hit;
	}else col=bcol;
#elif defined USE_EDGE_DETECT_AA
	rd=cam*getRay(0,zoom);
	//march
	t=DE(ro)*rndStart(fragCoord.xy);d=1.0;
	float od=1000.0;//last dist
	bool bGrab=false;//should we save the depth
	vec4 hit=vec4(-1.0);//we will grab up to 4 depths that are local mins
	for(int i=0;i<64;i++){
		d=DE(ro+rd*t);
		if(d>od){//we are moving away from the surface
			if(bGrab && od<px*(t-od) && hit.x<0.0){//we want to draw this edge, it occludes the pixel
				hit.x=t-od;//save the depth
				hit=hit.yzwx;//push
				bGrab=false;//do not save any more depths for this edge
			}
		}else bGrab=true;//we are approaching a new edge so get ready to save it
		od=d;t+=d;//save the old dist and march
		if(t>MAX_DIST || od<MIN_DIST)break;//hard stop
	}
	if(od<px*(t-d)){//if we stopped before leaving an edge save it
		if(hit.x>0.0)hit=hit.wxyz;//write over the last entry, not the first
		hit.x=t-d;hit=hit.yzwx;
	}
	
	//composite
	col=bcol;
	for(int i=0;i<4;i++){//play back the hits and mix the color samples
		hit=hit.wxyz;//pop
		if(hit.x>0.0){
			float ds=DE(ro+rd*hit.x);
			if(ds<px*hit.x)//if close enough mix in the surface coloring
				col=mix(Light(ro+rd*hit.x,rd,px*hit.x,ds),col,clamp(ds/(px*hit.x),0.0,1.0));
		}
	}
#elif defined USE_FAKE_AA
	rd=cam*getRay(0,zoom,fragCoord);
	float dm=100.0,tm=0.0,df=100.0,tf=0.0,od=1000.0;
	for(int i=0;i<64;i++){
		d=DE(ro+rd*t);
		if(df==100.0){//save the first edge
			if(d>od){//we are moving away from the surface
				if(od<px*(t-od)){//we want to draw this edge, it occludes the pixel
					df=od;tf=t-od;//save the depth
				}
			}
			od=d;//remember the old distance
		}
		if(d<dm){tm=t;dm=d;}//and save the max occluder
		t+=d;
		if(t>MAX_DIST || d<MIN_DIST)break;//hard stop
	}
	col=bcol;//add the lighting
	if(dm<px*tm){//max occluder (min distance)
		col=mix(Light(ro+rd*tm,rd,px*tm,dm,fragCoord),col,clamp(dm/(px*tm),0.0,1.0));
	}
	float p=0.0;
	if(df==100.0 || tm==tf){//if no first edge then do a jittered lighting calc
		ro+=cam*vec3(0.5,0.5,0.0)*px*tm;tf=tm;df=dm;p=0.5;//not really jittered :(
	}
	col=mix(Light(ro+rd*tf,rd,px*tf,df,fragCoord),col,clamp(p+df/(px*tf),0.0,1.0));

#elif defined USE_CHEAP_AA
	rd=cam*getRay(0,zoom);
	float dm=100.0,tm=0.0;
	for(int i=0;i<64;i++){
		t+=d=DE(ro+rd*t);
		if(d<dm){tm=t;dm=d;}
		if(t>MAX_DIST || d<MIN_DIST)break;//hard stop
	}
	if(dm<2.0*px*tm){
		col=mix(Light(ro+rd*tm,rd,px*tm,dm),bcol,clamp(dm/(px*tm),0.0,1.0));
	}else col=bcol;
#endif
#ifdef COMPARE_TO_NO_AA
	rd=cam*getRay(0,zoom);
	if(fragCoord.x>size.x*0.5){//for comparison
		if(d<10.0*px*t)col=Light(ro+rd*t,rd,px*t,d);//single hit
		else col=bcol;
	}
	col=mix(vec3(0.0,1.0,0.0),col,smoothstep(0.0,1.0,abs(fragCoord.x-size.x*0.5)));
#endif
	fragColor=vec4(col,1.0);
}