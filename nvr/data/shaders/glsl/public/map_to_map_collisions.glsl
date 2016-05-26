// Shader downloaded from https://www.shadertoy.com/view/ldG3Wh
// written by shadertoy user eiffie
//
// Name: map to map collisions
// Description: How to check if 2 distance estimates collide.
//map to map collisions by eiffie
//It is easy to check collisions between a sphere and a distance estimated object
//but what about 2 distance estimates. It is pretty easy too if you don't need 
//great accuracy.
vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}

float tym;
vec2 offset;
float DE(vec2 p){
	p=rotate(p-offset,tym);
	return min(length(p)-0.2,length(max(abs(p)-vec2(0.5,0.05),0.0)));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord){
	vec2 uv=2.0*(fragCoord.xy/iResolution.xy-0.5);
	float y=0.1+0.25*sin(iGlobalTime*1.4);
	vec2 p=vec2(-0.35,-0.35);
	float dp=length(p-uv)-0.01;
	tym=iGlobalTime;
	offset=vec2(0.3,y);
	float d1=DE(uv);
	tym=iGlobalTime*1.3;
	offset=vec2(-0.35,-0.35);
	float dp2=length(p-uv)-0.01;
	d1=min(d1,DE(uv));
	vec2 psave=p;
	
	for(int i=0;i<4;i++){// i changed it to ping-ponging between the surfaces
		tym=iGlobalTime; // should be more robust
		offset=vec2(0.3,y);
		float d=DE(p);
		vec2 e=vec2(d,0.0);
		vec2 N=normalize(vec2(DE(p-e)-DE(p+e),DE(p-e.yx)-DE(p+e.yx)))*d;
		if(N==N)p+=N;
		dp=min(dp,length(p-uv)-0.01);
		
		psave=p;
		
		tym=iGlobalTime*1.3;//switch the the 2nd distance estimate and do the same
		offset=vec2(-0.35,-0.35);
		d=DE(p);
		e=vec2(d,0.0);
		N=normalize(vec2(DE(p-e)-DE(p+e),DE(p-e.yx)-DE(p+e.yx)))*d;
		if(N==N)p+=N;
		dp2=min(dp2,length(p-uv)-0.01);
	}
	
	
	vec3 col=vec3(smoothstep(0.0,0.01,d1));
	col=mix(vec3(0.0,1.0,0.0),col,smoothstep(0.0,0.01,dp));
	col=mix(vec3(0.0,0.0,1.0),col,smoothstep(0.0,0.01,dp2));
	col=mix(vec3(1.0,0.0,0.0),col,smoothstep(0.0,0.01,length(p-uv)+length(p-psave)-0.03));
	fragColor=vec4(col,1.0);
}