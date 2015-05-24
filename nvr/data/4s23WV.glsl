// Shader downloaded from https://www.shadertoy.com/view/4s23WV
// written by shadertoy user mu6k
//
// Name: Edge Detect
// Description: Derivative based edge detection. dFdx() and dFdy() are applied to the surface normal. It will detect discontinuities in the normal.
/*by musk License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

	Derivative based edge detection. 
	dFdx() and dFdy() are applied to the surface normal. 
	It will detect discontinuities in the normal.

*/

//functions that build rotation matrixes
mat2 rotate_2D(float a){float sa = sin(a); float ca = cos(a); return mat2(ca,sa,-sa,ca);}
mat3 rotate_x(float a){float sa = sin(a); float ca = cos(a); return mat3(1.,.0,.0,    .0,ca,sa,   .0,-sa,ca);}
mat3 rotate_y(float a){float sa = sin(a); float ca = cos(a); return mat3(ca,.0,sa,    .0,1.,.0,   -sa,.0,ca);}
mat3 rotate_z(float a){float sa = sin(a); float ca = cos(a); return mat3(ca,sa,.0,    -sa,ca,.0,  .0,.0,1.);}

float t = iGlobalTime - 4.0;

float df_back(vec3 p)
{
	return (16.0-length(p));
}

mat3 rot = rotate_x(t*.5)*rotate_y(t*.5)*rotate_z(t*.5);
vec3 trans = vec3(sin(t),cos(t),sin(t))*.1;

//2D texture based 3 component 1D, 2D, 3D noise
vec3 noise(float p){return texture2D(iChannel0,vec2(p/iChannelResolution[0].x,.0)).xyz;}
vec3 noise(vec2 p){return texture2D(iChannel0,p/iChannelResolution[0].xy).xyz;}
vec3 noise(vec3 p){float m = mod(p.z,1.0);float s = p.z-m; float sprev = s-1.0;if (mod(s,2.0)==1.0) { s--; sprev++; m = 1.0-m; };return mix(texture2D(iChannel0,p.xy/iChannelResolution[0].xy+noise(sprev).yz).xyz,texture2D(iChannel0,p.xy/iChannelResolution[0].xy+noise(s).yz).xyz,m);}

vec3 noise(float p, float lod){return texture2D(iChannel0,vec2(p/iChannelResolution[0].x,.0),lod).xyz;}
vec3 noise(vec2 p, float lod){return texture2D(iChannel0,p/iChannelResolution[0].xy,lod).xyz;}
vec3 noise(vec3 p, float lod){float m = mod(p.z,1.0);float s = p.z-m; float sprev = s-1.0;if (mod(s,2.0)==1.0) { s--; sprev++; m = 1.0-m; };return mix(texture2D(iChannel0,p.xy/iChannelResolution[0].xy+noise(sprev,lod).yz,lod).xyz,texture2D(iChannel0,p.xy/iChannelResolution[0].xy+noise(s,lod).yz,lod).xyz,m);}


float df_obj(vec3 p)
{
	p += trans;
	p *= rot;
	
	//p = mod(p+vec3(2.0),4.0)-vec3(2.0);
	float s0 = dot(abs(p),vec3(1.0))-1.5;
	s0*=.5;
	
	//p*=rot;
	
	float s1 = length(p+vec3(1.,.0,.0))-.5;
	float s2 = length(p+vec3(.0,1.,.0))-.5;
	float s3 = length(p+vec3(.0,.0,1.))-.5;
	float s4 = length(p-vec3(1.,.0,.0))-.5;
	float s5 = length(p-vec3(.0,1.,.0))-.5;
	float s6 = length(p-vec3(.0,.0,1.))-.5;
	s0 = min(s0,s1);
	s0 = min(s0,s2);
	s0 = min(s0,s3);
	s0 = max(s0,-s4);
	s0 = max(s0,-s5);
	s0 = max(s0,-s6);
	
	p*=rot;
	
	s0 = min(s0,max(max(abs(p.x+2.0),abs(p.y)),abs(p.z))-.25);
	s0 = min(s0,max(max(abs(p.x-2.0),abs(p.y)),abs(p.z))-.25);
	s0 = min(s0,max(max(abs(p.y+2.0),abs(p.z)),abs(p.x))-.25);
	s0 = min(s0,max(max(abs(p.y-2.0),abs(p.z)),abs(p.x))-.25);
	s0 = min(s0,max(max(abs(p.z+2.0),abs(p.x)),abs(p.y))-.25);
	s0 = min(s0,max(max(abs(p.z-2.0),abs(p.x)),abs(p.y))-.25);
	
	p*=rot;
	
	s0 = min(s0,max(max(abs(p.x+4.0),abs(p.y)),abs(p.z))-.25);
	s0 = min(s0,max(max(abs(p.x-4.0),abs(p.y)),abs(p.z))-.25);
	s0 = min(s0,max(max(abs(p.y+4.0),abs(p.z)),abs(p.x))-.25);
	s0 = min(s0,max(max(abs(p.y-4.0),abs(p.z)),abs(p.x))-.25);
	s0 = min(s0,max(max(abs(p.z+4.0),abs(p.x)),abs(p.y))-.25);
	s0 = min(s0,max(max(abs(p.z-4.0),abs(p.x)),abs(p.y))-.25);
	
	return s0;
}


float df(vec3 p)
{
	return min(df_obj(p),df_back(p));
}


vec3 nf(vec3 p)
{
	float e = .01;
	float dfp = df(p);
	return vec3(
		(dfp+df(p+vec3(e,.0,.0)))/e,
		(dfp+df(p+vec3(.0,e,.0)))/e,
		(dfp+df(p+vec3(.0,.0,e)))/e);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
	uv.x *= iResolution.x/iResolution.y;
	
	vec2 mouse = iMouse.xy/ iResolution.xy*2.0-1.0;
	mouse.x *= iResolution.x/iResolution.y*4.0;
	
	mat3 rotmat = rotate_y(mouse.x) * rotate_x(mouse.y);
	
	vec3 pos = vec3(.0,.0,-3.0)*rotmat ;
	vec3 dir = normalize(vec3(uv*.5,1.0-length(uv)*.25))*rotmat;
	
	vec3 light_dir = normalize(vec3(.4,.5,.6));
	vec3 light_color = vec3(.6,.5,.4);
	
	float dist;
	
	for (int i=0; i<80; i++)
	{
		dist = df(pos);
		pos+=dir*dist;
		if (dist<.00001) break;
	}

	vec3 color = vec3(1.0);
	vec3 n = nf(pos);
	
	vec3 dfdxn = dFdx(n);
	vec3 dfdyn = dFdy(n);
	
	float lines = length((abs(dfdxn)+abs(dfdyn))*3.0);
	lines = lines*3.75;
	lines = lines-1.0;
	lines = clamp(lines,.0,1.0);
	if (lines>1.0)lines = 1.0;
	
	if (length(pos)>5.0)
	{
		color = vec3(1.0);
	}
	else
	{
		float oa = 0.5;//df(pos+n)*.5+.5;
		float od = 1.0;
		
		for (int i=0; i<30; i++)
		{
			float fi = float(i);
			oa += df_obj(pos+noise(fi)-vec3(.5))*.15;
		}
		
		oa = min(1.0,oa);
		
		vec3 ocdir = light_dir;
		vec3 ocpos = pos+ocdir*.1;
		for (int i=0; i<60; i++)
		{
			float dist = df_obj(ocpos);
			od = min(od,dist*10.);
			ocpos += ocdir*dist*.3;
			if (dist<.0||dist>10.0) break;
		}
		

		od = max(.0,od);
		
		//oa -= mod(oa,.33);
		
		float diffuse = max(.0,dot(n,light_dir)*.8+.2)*od*oa*1.5;
	

		
		color = vec3(.1,.2,.3)*oa + diffuse*light_color;
		
	
	}
	
	vec3 color0 = mix(color,vec3(.0),lines);
	vec3 color1 = n*.4+.4;
	vec3 color2 = dfdxn+dfdyn;
	vec3 color3 = vec3(lines);
	
	float mt = mod(t,32.0);
	float mti = mod(t,1.0);
	
	if (mt<7.0){color = color0;}
	else if (mt<8.0){color = mix(color0,color1,mti);}
	else if (mt<11.0){color = color1;}
	else if (mt<12.0){color = mix(color1,color2,mti);}
	else if (mt<13.0){color = color2;}
	else if (mt<14.0){color = mix(color2,color3,mti);}
	else if (mt<18.0){color = color3;}
	else if (mt<19.0){color = mix(color2,color1-color3,mti);}
	else if (mt<24.0){color = color1-color3;}
	else if (mt<25.0){color = mix(color1-color3,color,mti);}
	else if (mt<29.0){;}
	else if (mt<30.0){color = mix(color,color0,mti);}
	else if (mt<32.0){color = color0;}
	
	color += noise(vec3(fragCoord.xy,t*60.0))*0.01;
	
	
	
	fragColor = vec4(pow(color,vec3(.5)),1.0);
}