// Shader downloaded from https://www.shadertoy.com/view/XdfGDs
// written by shadertoy user WAHa_06x36
//
// Name: Drill #1
// Description: It's a drill. It's drilling.
//    
//    Maybe I kind of ripped off mrdiv a bit here.
const float epsilon=0.02;
const float pi=3.141592;

float dist(vec3 pos)
{
	pos.z-=0.2;
	float d=abs(pos.x)+abs(pos.y)+abs(0.5*pos.z)-sqrt(3.0);
	pos.xy=mat2(cos(pi/8.0),sin(pi/8.0),-sin(pi/8.0),cos(pi/8.0))*pos.xy;
	d=min(d,abs(pos.x)+abs(pos.y)+abs(0.5*pos.z)-sqrt(3.0));
	pos.xy=mat2(cos(pi/8.0),sin(pi/8.0),-sin(pi/8.0),cos(pi/8.0))*pos.xy;
	d=min(d,abs(pos.x)+abs(pos.y)+abs(0.5*pos.z)-sqrt(3.0));
	pos.xy=mat2(cos(pi/8.0),sin(pi/8.0),-sin(pi/8.0),cos(pi/8.0))*pos.xy;
	d=min(d,abs(pos.x)+abs(pos.y)+abs(0.5*pos.z)-sqrt(3.0));
	return d/2.0;
}

int intersect_object(vec3 dir,vec3 pos,out float t,out vec3 normal)
{
	t=0.0;
	for(int i=0;i<128;i++)
	{
		float d=dist(pos+dir*t);
		t+=d;
		if(d<0.0001)
		{
			normal=normalize(vec3(
				dist(pos+dir*t+vec3(epsilon,0.0,0.0))-d,
				dist(pos+dir*t+vec3(0.0,epsilon,0.0))-d,
				dist(pos+dir*t+vec3(0.0,0.0,epsilon))-d
			));
			return 1;
		}
		if(t>7.0) return 0;
	}
	return 0;
}

vec3 environment(vec3 dir)
{
	vec3 rgb=textureCube(iChannel0,vec3(dir.x,dir.y,-dir.z)).xzz;
	return pow(rgb,vec3(1.0,2.0,4.0))*(1.0+0.1*sin(iGlobalTime*32.3));
}

mat3 inv;

mat3 transpose(mat3 m)
{
		return mat3(m[0][0],m[1][0],m[2][0],
			    m[0][1],m[1][1],m[2][1],
			    m[0][2],m[1][2],m[2][2]);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 position=(2.0*fragCoord.xy-iResolution.xy)/max(iResolution.x,iResolution.y);

//	float a=sin(iGlobalTime*0.3*2.0);
//	float b=iGlobalTime*0.2*2.0;
	float a=0.5+sin(iGlobalTime*39.0)*0.015;
	float b=-0.5+sin(iGlobalTime*21.0)*0.015;
	mat3 rot=mat3(
		       cos(iGlobalTime*3.0),sin(iGlobalTime*3.0),0.0,
		      -sin(iGlobalTime*3.0),cos(iGlobalTime*3.0),0.0,
	          0.0,    0.0,   1.0);
	rot*=mat3( cos(b),0.0,-sin(b),
		          0.0,1.0,    0.0,
		       sin(b),0.0, cos(b));
	rot*=mat3(1.0,    0.0,   0.0,
		      0.0, cos(a),sin(a),
		      0.0,-sin(a),cos(a));

	const int sqrtsamples=8;
	const float camdistance=5.0;
	 float focaldistance=4.0+0.0*sin(iGlobalTime*5.0);
	const float lensfactor=0.2;
	const float camfactor=1.0;

	vec3 col=vec3(0.0);
	float samples=0.0;

	for(int y=0;y<sqrtsamples;y++)
	for(int x=0;x<sqrtsamples;x++)
	{
		vec2 lens=2.0*(vec2(float(x),float(y))+0.5)/float(sqrtsamples)-1.0;

		if(dot(lens,lens)>1.0) continue;
		
		samples+=1.0;

		vec3 pos=vec3(lens*lensfactor,-camdistance);
		vec3 focalpoint=vec3(position*focaldistance*camfactor,focaldistance-camdistance);
		vec3 dir=normalize(focalpoint-pos);

		inv=transpose(rot);
		vec3 localdir=rot*dir;
		vec3 localpos=rot*pos;

		float t;
		vec3 localnormal;
		int hit=intersect_object(localdir,localpos,t,localnormal);
		if(hit!=0)
		{
			vec3 localreflecteddir=localdir-localnormal*2.0*dot(localdir,localnormal);
			vec3 reflecteddir=inv*localreflecteddir;
			col+=environment(reflecteddir);
		}
		else
		{
			col+=environment(dir);
		}
	}
	float vignette=pow(1.0-0.1*dot(position,position),2.0);
	fragColor=vec4(col/samples*vignette*1.2,1.0);
}
