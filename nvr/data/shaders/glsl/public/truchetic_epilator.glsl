// Shader downloaded from https://www.shadertoy.com/view/XljXzh
// written by shadertoy user Kuukunen
//
// Name: Truchetic Epilator
// Description: Messing around with two of WAHa_06x36's shaders, for something even worse.
// if you have problems running this, you can try to adjust the iterations
#define Iterations 35
#define Thickness 0.1
#define SuperQuadPower 8.0
#define Fisheye 1.2

float rand(vec3 r) { return fract(sin(dot(r.xy,vec2(1.38984*sin(r.z),1.13233*cos(r.z))))*653758.5453); }

float phase1;
float phase2;
float phase3;
float phase4;
float phase5;
vec3 phase;


float truchetarc(vec3 pos)
{
	float r=length(pos.xy);
//	return max(abs(r-0.5),abs(pos.z-0.5))-Thickness;
//	return length(vec2(r-0.5,pos.z-0.5))-Thickness;
	return pow(pow(abs(r-0.5),SuperQuadPower)+pow(abs(pos.z-0.5),SuperQuadPower),1.0/SuperQuadPower)-Thickness;
}

float truchetcell(vec3 pos)
{
	return min(min(
	truchetarc(pos),
	truchetarc(vec3(pos.z,1.0-pos.x,pos.y))),
	truchetarc(vec3(1.0-pos.y,1.0-pos.z,pos.x)));
}

vec3 texat(vec3 pos)
{
	pos = pos*0.6;
	/*
	vec3 uv=vec3(sin(pos.x),sin(pos.y),sin(pos.z));
	float s1=texture2D(iChannel0,vec2(uv.x,1.0)).x;
	float s2=texture2D(iChannel0,vec2(uv.y,1.0)).x;
	float s3=texture2D(iChannel0,vec2(uv.z,1.0)).x;
	vec3 col=vec3(
	(texture2D(iChannel0,vec2(0.0,0.1)).x-0.5)*2.0,
	(texture2D(iChannel0,vec2(0.4,0.4)).x-0.5)*2.0,
	(texture2D(iChannel0,vec2(0.5,0.6)).x-0.5)*2.0);
	//if(abs(s1-s2)<0.1)
		return vec3(vec3(1.0-abs(s1-s2+s3)/0.5)*col);
	//else return vec3(vec3(0.0));
	*/
	//pos = pos*1.0;
	vec3 uv=vec3(sin(pos.x)/2.0+0.5,sin(pos.y)/2.0+0.5,sin(pos.z)/2.0+0.5);
	//vec3 uv=pos;
	float s1=texture2D(iChannel0,vec2(uv.x,1.0)).x;
	float s2=texture2D(iChannel0,vec2(uv.y,1.0)).x;
	float s3=texture2D(iChannel0,vec2(uv.z,1.0)).x;
	vec3 col=vec3(
	(phase1-0.5)*2.0,
	(phase2-0.5)*2.0,
	(phase4-0.5)*2.0);
	//if(abs(s1-s2)<0.1)
		return vec3(vec3(1.0-abs(s1-s2+s3)/0.4)*col);
	//else return vec3(vec3(0.0));
/*
	vec2 uv=fragCoord.xy/iResolution.xy;
	float s1=texture2D(iChannel0,vec2(uv.x,1.0)).x;
	float s2=texture2D(iChannel0,vec2(uv.y,1.0)).x;
	vec3 col=vec3(
	(texture2D(iChannel0,vec2(0.0,0.1)).x-0.5)*2.0,
	(texture2D(iChannel0,vec2(0.0,0.2)).x-0.5)*2.0,
	1.0);
	if(abs(s1-s2)<0.1) fragColor=vec4(vec3(1.0-abs(s1-s2)/0.1)*col,1.0);
	else fragColor=vec4(vec3(0.0),1.0);
*/
}

float distfunc(vec3 pos)
{
	pos = vec3(pos.x+sin(pos.y/2.0)+0.6*sin(pos.y/2.3*sin(iGlobalTime/5.0)*4.0)+0.6*sin(pos.y/2.1*sin(iGlobalTime/5.0)*8.0),
			   pos.y+sin(pos.z/2.0)+0.6*sin(pos.y/2.2*sin(iGlobalTime/4.0)*3.0)+0.6*sin(pos.y/2.2*sin(iGlobalTime/7.0)*8.2),
			   pos.z+sin(pos.x/2.0)+0.6*sin(pos.y/2.1*sin(iGlobalTime/5.3)*5.5)+0.6*sin(pos.y/2.3*sin(iGlobalTime/8.0)*8.1));
	vec3 cellpos=fract(pos);
	vec3 gridpos=floor(pos);

	float rnd=rand(gridpos);

	if(rnd<1.0/8.0) return truchetcell(vec3(cellpos.x,cellpos.y,cellpos.z));
	else if(rnd<2.0/8.0) return truchetcell(vec3(cellpos.x,1.0-cellpos.y,cellpos.z));
	else if(rnd<3.0/8.0) return truchetcell(vec3(1.0-cellpos.x,cellpos.y,cellpos.z));
	else if(rnd<4.0/8.0) return truchetcell(vec3(1.0-cellpos.x,1.0-cellpos.y,cellpos.z));
	else if(rnd<5.0/8.0) return truchetcell(vec3(cellpos.y,cellpos.x,cellpos.z));
	else if(rnd<6.0/8.0) return truchetcell(vec3(cellpos.y,1.0-cellpos.x,cellpos.z));
	else if(rnd<7.0/8.0) return truchetcell(vec3(1.0-cellpos.y,cellpos.x,cellpos.z));
	else  return truchetcell(vec3(1.0-cellpos.y,1.0-cellpos.x,cellpos.z));
}

vec3 gradient(vec3 pos)
{
	const float eps=0.0001;
	float mid=distfunc(pos);
	return vec3(
	distfunc(pos+vec3(eps,0.0,0.0))-mid,
	distfunc(pos+vec3(0.0,eps,0.0))-mid,
	distfunc(pos+vec3(0.0,0.0,eps))-mid);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float pi=3.141592;

	vec2 coords=(2.0*fragCoord.xy-iResolution.xy)/length(iResolution.xy);

	phase1 = texture2D(iChannel0,vec2(0.0,0.0)).x;
	phase2 = texture2D(iChannel0,vec2(0.5,0.0)).x;
	phase3 = texture2D(iChannel0,vec2(1.0,0.0)).x;
	phase4 = texture2D(iChannel0,vec2(0.6,0.0)).x;
	phase5 = texture2D(iChannel0,vec2(0.2,0.0)).x;
	phase=vec3(phase1, phase2, phase3);

    float a=iGlobalTime/5.0;
	mat3 m=mat3(
	0.0,1.0,0.0,
	-sin(a),0.0,cos(a),
	cos(a),0.0,sin(a));
	m*=m;
	m*=m;
	

	vec3 dir = normalize(vec3(1.4*coords,-1.0+Fisheye*(coords.x*coords.x+coords.y*coords.y)));
	vec3 ray_dir=m*dir;
	vec3 pv = m*normalize(vec3(dir.z, dir.z, -dir.x-dir.y));
	mat3 ll = mat3(
		0.0, ray_dir.z, -ray_dir.y,
		-ray_dir.z, 0.0, ray_dir.x,
		ray_dir.y, -ray_dir.x, 0.0);
	//float rot = sqrt(phase5)-sqrt(phase2)*1.5-sqrt(phase3)*1.5;
	//if(rot < 0.0) rot = 0.0;
	//pv = normalize(pv*(mat3(1.0) + sin(a*3.0)*ll + ((1.0 - cos(a*3.0))*(ll*ll))));

	float t=iGlobalTime/5.0;
	vec3 ray_pos=vec3(
    2.0*(sin(t+sin(2.0*t)/2.0)/2.0+0.5),
    2.0*(sin(t-sin(2.0*t)/2.0-pi/2.0)/2.0+0.5),
    2.0*((-2.0*(t-sin(4.0*t)/4.0)/pi)+0.5+0.5));
	vec3 shads = vec3(0.0);
	float dist2 = 0.0;

	float i=float(Iterations);
	for(int j=0;j<Iterations;j++)
	{
		float dist=distfunc(ray_pos)+0.1;
		dist2 += dist;
		ray_pos+=dist*ray_dir;
		//ray_pos += rot*pv*dist*0.5;

		if(abs(dist)<0.101) { shads += texat(ray_pos)*0.2; }
	}

	float vignette=pow(1.0-length(coords),0.3);
	float light=vignette;

	float z=ray_pos.z/2.0;
//	vec3 col=(sin(vec3(z,z+pi/3.0,z+pi*2.0/3.0))+2.0)/3.0;
//	vec3 col=(cos(ray_pos/2.0)+2.0)/3.0;
	vec3 col=vec3(
		(cos(ray_pos/2.0+phase1*10.0+iGlobalTime*1.0)+2.0).x,
		(cos(ray_pos/2.0+phase2*10.0+iGlobalTime*1.5)+2.0).x,
		(cos(ray_pos/2.0+phase3*10.0+iGlobalTime*2.0)+2.0).x
		)/3.0;
	col += shads;
	col = col*light;
	float collen = length(col);
	vec3 unsat = vec3(collen);
	float base = phase1*1.5;
	if(base > 1.0) base = 1.0;
	fragColor=vec4((1.0-base)*unsat*0.8+base*col,1.0);
	//fragColor=vec4(sqrt(phase5)-sqrt(phase2)*1.5-sqrt(phase3)*1.5);
/*
	fragColor=vec4(
	(texture2D(iChannel0,fragCoord.xy/iResolution.xy)).x,
	0.0,//(texture2D(iChannel0,coords+vec2(0.5,0.5)*1.0)).x,
	0.0,//(texture2D(iChannel0,coords+vec2(0.5,0.5)*1.0)).x,
	1.0);*/
	/*
	vec2 p = fragCoord.xy/iResolution.xy;
	if(p.x < 0.5 && p.y < 0.5) fragColor=vec4(texat(vec3(p.x*pi*2.0, p.y*pi*2.0, 0.0)),1.0)*2.0;
	else if(p.x >= 0.5 && p.y < 0.5) fragColor=vec4(texat(vec3(p.x*pi*2.0, p.y*pi*2.0, pi*0.33)),1.0)*2.0;
	else if(p.x >= 0.5 && p.y >= 0.5) fragColor=vec4(texat(vec3(p.x*pi*2.0, p.y*pi*2.0, pi*0.66)),1.0)*2.0;
	else fragColor=vec4(texat(vec3(p.x*pi*2.0, p.y*pi*2.0, pi)),1.0)*2.0;
*/
}
