// Shader downloaded from https://www.shadertoy.com/view/MsKGWy
// written by shadertoy user eiffie
//
// Name: Racing Concept (in car)
// Description: This is a 3d version of Racing Concept by Imp5. (link in comments) I tried to keep it close to the original and fast.
//This is a 3d version (by eiffie) of Racing Concept originally found @https://www.shadertoy.com/view/lsK3RK by Imp5

//The original header...
// GLSL Racing Concept
// Created by Alexey Borisov / 2016
// License: GPLv2

//v2 with updates from the originator

//change this for speed/quality
const int ITERS = 78;

const float OFFSET = 0.1;
const float IS_INITED = 0.5;
const float CAR_POSE = 1.5;
const float CAR_VEL = 2.5;
const float DEBUG_DOT = 3.5;
const float CAR_PROGRESS = 4.5;

const float LAPS = 6.0;

const float carLength = 0.045;
const float carWidth = 0.02;
const float carHeight = 0.02;

const vec2 finishDir = vec2(1, 1.5);

vec2 track_distort(vec2 pos)
{
    pos *= 0.5;    
    pos -= vec2(cos(pos.y * 2.4), sin(pos.x * 2.0 - 0.3 * sin(pos.y * 4.0))) * 0.59;
    return pos;
}

float track_val(vec2 pos)
{
    pos = track_distort(pos);
    return abs(1.0 - length(pos)) * 8.0 - 1.0;
}

vec4 car_color_from_index(int i)
{
    return abs(vec4(cos(float(i) * 6.3) - 0.1, cos(float(i) * 82.0) - 0.1, cos(float(i) * 33.0) - 0.1, 1.0));
}

vec2 rotate(vec2 v, float angle) {return cos(angle)*v+sin(angle)*vec2(v.y,-v.x);}

float DEC(in vec3 p){
	p.z=-p.z;
	p/=0.07;
	p.y-=0.16;
	float r=length(p.zy+vec2(0.0,0.73))-0.7;
	p.z+=0.05;
	float d=max(r,length(max(vec3(0.0),abs(p)-vec3(0.27*sqrt(abs(p.y))-0.02,0.26,0.35)))-0.14);
	p.z=abs(p.z);
	p.yz+=vec2(0.35,-0.26);
	r=length(p.zy);
	d=max(d,0.1-r);
	p.x=abs(p.x)-0.25;
	d=min(d,length(max(vec2(0.0),abs(vec2(r,p.x))-vec2(0.06,0.02)))-0.02);
	return d*0.06;
}
void CarCol(in vec3 p, float od, inout vec3 col){
	p.z=-p.z;
	p/=0.07;
	p.z+=0.05;
	p.z=abs(p.z);
	p.yz+=vec2(0.19,-0.26);
	float r=length(p.zy);
	if(r<0.09)col+=smoothstep(0.04,0.06,r);
	else col*=(0.5+0.5*smoothstep(0.0,0.01,abs(p.y-0.24)-0.06));
    p.x=abs(p.x)-0.2;
    if(length(p.xy)<0.025)col.r+=1.0;
}
int id;
vec3 scar;
float DE(in vec3 z0){
	vec2 p=z0.xz*8.0;
	float g=-0.05+(sin(p.x+sin(p.y*1.7))+sin(p.y+sin(p.x*1.3)))*0.01; // <<<<<<
    float c=track_val(z0.xz);
    float dg=(z0.y+g*smoothstep(0.0,3.0,c)) * 6.0; // <<<<<<<<
	float d=2.0;
	scar=vec3(-1.0);//saved car position
	for(int carIdx=1;carIdx<8;carIdx++){
		vec4 carPose = texture2D(iChannel0, vec2(CAR_POSE, float(carIdx)+0.5) / iResolution.xy);
		mat2 mx=mat2(carPose.w,carPose.z,-carPose.z,carPose.w);
		vec3 v=z0-vec3(carPose.x,carHeight,carPose.y);
		v.xz=mx*v.xz;
		float d2=length(max(abs(v)-vec3(carWidth,carHeight,carLength),0.0));
		if(d2<d){d=d2;scar=v;id=carIdx;}
	}
	if(d<0.025){//now find distance to the actual car model
		d=DEC(scar);
	} 
	if(dg<d){id=0;d=dg;}
	return d;
}
vec3 sky(vec3 rd){
	return mix(vec3(0.5,0.4,0.3),vec3(0.4,0.5,0.7),0.5+rd.y+cos(rd.x*3.14159)*0.5);
}
vec4 scene(vec3 ro, vec3 rd){
	float t=0.0,d,od=1.0;
	for(int i=0;i<ITERS;i++){
		t+=d=DE(ro+rd*t);
		if(d<0.0001 || t>3.0)break;
		od=d;
	}
	t=min(t,3.0);
	vec3 col=sky(rd);
	if(d<0.1){
		float dif=1.0-clamp(d/od,0.0,0.8);
		vec3 so=ro+rd*t;
		vec3 scol=vec3(0.0);
		if(id==0){
			float c=track_val(so.xz);
			vec3 grnd=vec3(0.3+10.0*so.y,1.0,0.7-12.0*so.y)+texture2D(iChannel1,so.xz*0.1).rgb*0.3;
			if(rd.y<0.0){
				float tmax=-ro.y/rd.y;
				so.xz=ro.xz+rd.xz*tmax;
			}
			vec3 trk=vec3(0.4)+texture2D(iChannel1,so.xz).rgb*0.1;
			trk = mix(trk, vec3(1.0), clamp(dot(normalize(finishDir), normalize(so.xz)) * 10000.0 - 9999.0, 0.0, 1.0));
			scol=mix(trk,grnd,clamp(c*20.0,0.0,1.0));
			d=DEC(scar);
			scol*=clamp(0.3+d*100.0,0.0,1.0);
		}else{
			scol=car_color_from_index(id).rgb;
			CarCol(scar,d,scol);
		}
		scol*=dif;
		col=mix(scol,col,t/3.0);
	}
	return vec4(col*1.5,1.0);
}

mat3 lookat(vec3 fw){
	fw=normalize(fw);vec3 rt=normalize(cross(fw,vec3(0.0,1.0,0.0)));return mat3(rt,cross(rt,fw),fw);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
    
	vec4 carPose=texture2D(iChannel0, vec2(CAR_POSE, 0) / iResolution.xy);
    vec3 ro=vec3(carPose.x,carHeight*1.1,carPose.y); // <<<<<<<<<<<<<
	vec3 rd=vec3((fragCoord-0.5*iResolution.xy)/iResolution.x,1.0);rd.x=-rd.x;
	rd=lookat(vec3(carPose.z,-0.002,carPose.w))*normalize(rd);
	vec4 color = scene(ro,rd);
    
    if (fragCoord.y < iResolution.y * 0.08)
    {            
        vec2 uv = fragCoord.xy / iResolution.xx;
        
        color = mix(color, vec4(0.0, 0.0, 0.0, 1.0),
                    clamp(1.0 - max(abs(uv.y - 0.02) * 200.0, abs(uv.x - 0.5) * 210.0 - 100.0), 0.0, 1.0));
        
        for (int i = 0; i < 8; i++)
        {
            float carIdx = float(i) + OFFSET;
            vec4 carProgress = texture2D(iChannel0, vec2(CAR_PROGRESS, carIdx) / iResolution.xy);
            vec2 pos = vec2(0.02 + clamp(carProgress.x / LAPS, 0.0, 1.0) * 0.96, 0.02);
            vec4 carColor = car_color_from_index(i);

            float rad = (i == 0) ? 80.0 : 150.0;
            
            float k = clamp(4.0 - length((uv - pos) * rad) * 3.0, 0.0, 1.0);
            color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), k);
            k = clamp(4.0 - length((uv - pos) * rad * 1.15) * 3.0, 0.0, 1.0);
            color = mix(color, carColor, k);

        }
    }

    // start lights
    {
    	vec4 carProgress = texture2D(iChannel0, vec2(CAR_PROGRESS, 0) / iResolution.xy);
        if (carProgress.w < 1.4)
        {
        	vec2 uv = (iResolution.xy - fragCoord.xy) / iResolution.xx;
            
            for (int i = 0; i < 3; i++)
            {            
                vec4 lightColor = carProgress.w >= 1.0 ? vec4(0.0, 1.0, 0.0, 1.0) :
                	vec4(carProgress.w > float(i + 1) / 3.0 ? 1.0 : 0.0, 0.0, 0.0, 1.0);
                vec2 pos = vec2(0.5 - float(i - 1) * 0.1, 0.1);
                float rad = 25.0;
                float k = clamp(17.0 - length((uv - pos) * rad) * 16.0, 0.0, 1.0);
                color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), k);
                k = clamp(17.0 - length((uv - pos) * rad * 1.15) * 16.0, 0.0, 1.0);
                color = mix(color, lightColor, k);
            }
        }
    }
     vec4 carProgress = texture2D(iChannel0, vec2(CAR_PROGRESS, 0.5) / iResolution.xy);
	if(carProgress.y>0.0){
		vec2 uv = 5.0*fragCoord.xy / iResolution.xx;
		vec2 h=sin(2.0*vec2(uv.x,uv.x+uv.y)+iGlobalTime);
		uv+=h*0.1;
		vec2 p=fract(uv)-vec2(0.5);
		vec3 chk=mix(vec3(0.25),vec3(1.0),smoothstep(0.0,0.01,sign(p.x*p.y)*min(abs(p.x),abs(p.y))));
		color.rgb=mix(chk,color.rgb,0.8+0.2*(h.x+h.y));
    	}
	fragColor = color; //vec4(0, is_key_pressed(KEY_A), 0, 1);
}