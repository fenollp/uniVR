// Shader downloaded from https://www.shadertoy.com/view/Xlf3zf
// written by shadertoy user eiffie
//
// Name: DDE
// Description: Marching thru an iso-mess using an extra DE calc to slow the march down only where needed. Left side is just a fudge factor slowing errrything down. It both penetrates and fails to march to the surface. Right side is perfection! :)
//DDE by eiffie (directional distance estimate using a gradient)
//The idea is to find a method of optimal marching when analytic gradients fail (or are unknown).
//This isn't it! But it is a first step. :)

//We need to know how the surface changes in the direction we are marching so the first term is
//how far ahead we should look based on an initial DE check. It is critical and highly dependant.
//Second term is still a neccessary fudge factor :( 
//Third term is for comparison (left side). 
#define GRADIENT_DELTA 0.4
#define FUDGE_FACTOR 0.5
#define COMPARE_FUDGE_FACTOR 0.2


#define time iGlobalTime
#define size iResolution


float DE(vec3 p0)
{
	vec3 p=p0+sin(p0.yzx*4.0+2.4*sin(p0.zxy*5.0+time)+time*0.7)*0.5;
	float d=length(p)-1.0;
	return d;
}
vec2 fragCoord;
vec2 DDE(vec3 p, vec3 rd){
	float d1=DE(p);
    if(fragCoord.x<size.x*0.5)return vec2(d1,d1*COMPARE_FUDGE_FACTOR);
	float dt=GRADIENT_DELTA*log(d1+1.0);
	float d2=DE(p+rd*dt);
	dt/=max(dt,d1-d2);
	return vec2(d1,FUDGE_FACTOR*log(d1*dt+1.0));
}

float rndStart(vec2 co){return fract(sin(dot(co,vec2(123.42,117.853)))*412.453);}

mat3 lookat(vec3 fw,vec3 up){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,up));return mat3(rt,cross(rt,fw),fw);
}

void mainImage( out vec4 fragColor, in vec2 iFragCoord ){
	float pxl=4.0/size.y;//find the pixel size
	float tim=time*0.3;
	fragCoord = iFragCoord;
	//position camera
	vec3 ro=vec3(cos(tim),0.5,sin(tim))*3.0;
	vec3 rd=normalize(vec3((2.0*fragCoord.xy-size.xy)/size.y,2.0));
	rd=lookat(-ro,vec3(0.0,1.0,0.0))*rd;
	//ro=eye;rd=normalize(dir);
	vec3 bcol=vec3(1.0);
	//march
	
	float t=DDE(ro,rd).y*rndStart(fragCoord.xy),d,od=1.0;
	vec4 col=vec4(0.0);//color accumulator
	for(int i=0;i<64;i++){
		vec2 v=DDE(ro+rd*t,rd);
		d=v.x;//DE(ro+rd*t);
		float px=pxl*(1.0+t);
		if(d<px){
            vec3 mcol=0.5*abs(sin((ro+rd*t)*30.0));
			mcol+=mcol.gbr;
			mcol*=max(0.0,1.0-d/od)*10.0*exp(-t);
			if(d<0.0){
				fragColor=vec4(1.0,0.0,0.0,1.0);
				return;
			}
			float alpha=(1.0-col.w)*clamp(1.0-d/(px),0.0,1.0);
			col+=vec4(clamp(mcol,0.0,1.0),1.0)*alpha;
			if(col.w>0.9)break;
		}
		od=d;
		t+=v.y;//d;
		if(t>10.0)break;
	}
	col.rgb+=bcol*(1.0-clamp(col.w,0.0,1.0));

	fragColor=vec4(col.rgb,1.0);
} 