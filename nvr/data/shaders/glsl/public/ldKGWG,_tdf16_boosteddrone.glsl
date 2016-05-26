// Shader downloaded from https://www.shadertoy.com/view/ldKGWG
// written by shadertoy user yasuo
//
// Name: [TDF16]BoostedDrone
// Description: Tokyodemofest GLSL compo 4th
#define NEAR 0.01
#define FAR 84.
#define ITER 84
float time = iGlobalTime;
float tt;
float atime;
const float PI = 3.14159265359;
const float DEG_TO_RAD = PI / 180.0;

float c_0 = 31599.0;
float c_1 = 9362.0;
float c_2 = 29671.0;
float c_3 = 29391.0;
float c_4 = 23497.0;
float c_5 = 31183.0;
float c_6 = 31215.0;
float c_7 = 29257.0;
float c_8 = 31727.0;
float c_9 = 31695.0;
float c_colon = 1040.0;

mat4 matRotateX(float rad)
{
	return mat4(1,       0,        0,0,
				0,cos(rad),-sin(rad),0,
				0,sin(rad), cos(rad),0,
				0,       0,        0,1);
}

mat4 matRotateY(float rad)
{
	return mat4( cos(rad),0,-sin(rad),0,
				 0,       1,        0,0,
				 sin(rad),0, cos(rad),0,
				 0,       0,        0,1);
}

mat4 matRotateZ(float rad)
{
	return mat4(cos(rad),-sin(rad),0,0,
				sin(rad), cos(rad),0,0,
				       0,        0,1,0,
					   0,        0,0,1);
}

mat3 mat3RotateX(float rad)
{
	return mat3(1,       0,        0,
				0,cos(rad),-sin(rad),
				0,sin(rad), cos(rad));
}

vec4 combine(vec4 val1, vec4 val2 )
{
	if ( val1.w < val2.w ) return val1;
	return val2;
}

// iq's distance functions
float sdBox( vec3 p, vec3 b )
{
	vec3 d = abs(p) - b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float smin(float a, float b, float k) {
	float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
	return mix(b, a, h) - k * h * (1.0 - h);
}


float WEIGHT = 3.0 / iResolution.x;
float line(vec2 p, vec2 p0, vec2 p1, float w) {
    vec2 d = p1 - p0;
	
    float t = clamp(dot(d,p-p0) / dot(d,d), tan(time*1.0)*1.5,1.0+tan(time*1.0)*0.5);
    vec2 proj = p0 + d * t/1.0;
    float dist = length(p - proj);			
    dist = 1.0/dist*WEIGHT*(w);
	
    return min(dist*dist,1.0);
}

float staticline(vec2 p, vec2 p0, vec2 p1, float w) {
    vec2 d = p1 - p0;
	
    float t = clamp(dot(d,p-p0) / dot(d,d), 0.0,1.0);
    vec2 proj = p0 + d * t/1.0;
    float dist = length(p - proj);			
    dist = 1.0/dist*WEIGHT*(w);
	
    return min(dist*dist,1.0);
}

float getBit(float num,float bit)
{
	num = floor(num);
	bit = floor(bit);
	
	return float(mod(floor(num/pow(2.,bit)),2.) == 1.0);
}

float Sprite3x5(float sprite,vec2 p)
{
	float bounds = float(all(lessThan(p,vec2(3,5))) && all(greaterThanEqual(p,vec2(0,0))));
	
	return getBit(sprite,(2.0 - p.x) + 3.0 * p.y) * bounds;
}

float Digit(float num,vec2 p)
{
	num = mod(floor(num),11.0);
	
	if(num == 0.0) return Sprite3x5(c_0,p);
	if(num == 1.0) return Sprite3x5(c_1,p);
	if(num == 2.0) return Sprite3x5(c_2,p);
	if(num == 3.0) return Sprite3x5(c_3,p);
	if(num == 4.0) return Sprite3x5(c_4,p);
	if(num == 5.0) return Sprite3x5(c_5,p);
	if(num == 6.0) return Sprite3x5(c_6,p);
	if(num == 7.0) return Sprite3x5(c_7,p);
	if(num == 8.0) return Sprite3x5(c_8,p);
	if(num == 9.0) return Sprite3x5(c_9,p);
	if(num == 10.0) return Sprite3x5(c_colon,p);
	
	return 0.0;
}

// terrain from https://www.shadertoy.com/view/lt2GRV
void rotate(const float a, inout vec2 v)
{
    float cs = cos(a), ss = sin(a);
    vec2 u = v;
    v.x = u.x*cs + u.y*ss;
    v.y = u.x*-ss+ u.y*cs;
}

float dfTerraHills(vec3 p)
{
    p.y-=1.0;
    vec3 pm = p;
    pm.xz = mod(pm.xz+vec2(8.0),16.0)-vec2(8.0);
    pm = abs(pm);
    return (p.y*.8+3.0+pm.x*.1+pm.z*.1);
}

float dfTerra(vec3 p)
{
    p.y+=.1;
    vec3 p2 = p;
    float height = (sin(p.x*.1)+sin(p.z*.1))*1.5;
    rotate(.6,p2.xz);
    return max(dfTerraHills(p2),dfTerraHills(p))+height;
}

vec4 map( vec3 pos, mat4 m)
{
	float d = 10.0;

	vec4 q = vec4(pos+vec3(0,-3,-50.0),1.0)*m;
	vec4 ql = vec4(pos+vec3(0,-3,-50.0)+vec3( 0, 0, time*50.0 ),1.0);
	vec4 body1 = vec4(vec3(0.35,0.0,0.0),sdBox(q.xyz + vec3( 0, 0, 0 ), vec3(1.0,1.0,13.0) ));
	vec4 body2 = vec4(vec3(0.35,0.0,0.0),sdBox(q.xyz + vec3( 0, 0, 0 ), vec3(13.0,1.0,1.0) ));
	vec4 body3 = vec4(vec3(0.35,0.0,0.0),sdBox(q.xyz + vec3( 0, 0, 0 ), vec3(3.0,2.0,3.0) ));
	d = min(d, smin(body1.w, body2.w, 0.2));
	d = smin(d, body3.w, 0.2);

	ql.z = mod(ql.z, 16.0)-8.0;
	vec4 lineL = vec4(vec3(0.5,0.1,0.1),sdBox(ql.xyz + vec3( 17.0, 2.0, 0 ), vec3(0.5,0.01,3.0) ));
	vec4 lineR = vec4(vec3(0.5,0.1,0.1),sdBox(ql.xyz + vec3( -17.0, 2.0, 0 ), vec3(0.5,0.01,3.0) ));

	vec4 wholeBody = vec4(0.33,0.33,0.32,d);

	vec4 propeller1a = vec4(vec3(0.7,0.7,0.7),sdBox(q.xyz + vec3( 12.0, -1.0, 0 ), vec3(0.5,3.0,0.5) ));
	vec4 prot1 = (q+vec4( 12.0, -3.7, 0, 1.0))*matRotateY(-time*7.0);
	vec4 propeller1b = vec4(vec3(1.0,0.16,0.0),sdBox(prot1.xyz, vec3(0.5,0.1,7.0) ));

	vec4 propeller2a = vec4(vec3(0.7,0.7,0.7),sdBox(q.xyz + vec3( -12.0, -1.0, 0 ), vec3(0.5,3.0,0.5) ));
	vec4 prot2 = (q+vec4( -12.0, -3.7, 0, 1.0))*matRotateY(-time*7.5);
	vec4 propeller2b = vec4(vec3(1.0,0.16,0.0),sdBox(prot2.xyz, vec3(0.5,0.1,7.0) ));

	vec4 propeller3a = vec4(vec3(0.7,0.7,0.7),sdBox(q.xyz + vec3( 0.0, -1.0, 12.0 ), vec3(0.5,3.0,0.5) ));
	vec4 prot3 = (q+vec4(0.0, -3.7, 12.0, 1.0))*matRotateY(time*7.3);
	vec4 propeller3b = vec4(vec3(1.0,0.16,0.0),sdBox(prot3.xyz, vec3(0.5,0.1,7.0) ));

	vec4 propeller4a = vec4(vec3(0.7,0.7,0.7),sdBox(q.xyz + vec3( 0.0, -1.0, -12.0 ), vec3(0.5,3.0,0.5) ));
	vec4 prot4 = (q+vec4(0.0, -3.7, -12.0, 1.0))*matRotateY(time*7.5);
	vec4 propeller4b = vec4(vec3(1.0,0.16,0.0),sdBox(prot4.xyz, vec3(0.5,0.1,7.0) ));

	vec4 terrain = vec4(0.15,0.15,0.15,dfTerra(pos+vec3( 0, 0, time*30.0 )));

	vec4 temp = combine(terrain,wholeBody);
	vec4 temp1 = combine(lineL,lineR);
	vec4 temp2 = combine(propeller1a,propeller1b);
	vec4 temp3 = combine(propeller2a,propeller2b);
	vec4 temp4 = combine(propeller3a,propeller3b);
	vec4 temp5 = combine(propeller4a,propeller4b);

	vec4 temp6 = combine(temp,temp1);
	vec4 temp7 = combine(temp2,temp3);
	vec4 temp8 = combine(temp4,temp5);
	vec4 temp9 = combine(temp6,temp7);
	vec4 temp10 = combine(temp8,temp9);

	return temp10;
}

vec2 rot(vec2 p, float a) {
	return vec2(
		cos(a) * p.x - sin(a) * p.y,
		sin(a) * p.x + cos(a) * p.y);
}

vec3 gradientbg(float p)
{
	float span = 15.0;
	vec3 b0 = vec3(0.15, 0.15, 0.15)   * (step(p,(1.0/span) * 5.0) - (step(p,(1.0/span) * (5.0 - 1.))));
    vec3 b1 = vec3(0.25, 0.25, 0.25)   * (step(p,(1.0/span) * 4.0) - (step(p,(1.0/span) * (4.0 - 1.))));
    vec3 b2 = vec3(0.3, 0.3, 0.3)   * (step(p,(1.0/span) * 3.0) - (step(p,(1.0/span) * (3.0 - 1.))));
    vec3 b3 = vec3(0.32, 0.32, 0.32)   * (step(p,(1.0/span) * 2.0) - (step(p,(1.0/span) * (2.0 - 1.))));
    vec3 b4 = vec3(0.35,0.35, 0.35) * (step(p,(1.0/span) * 1.0) - (step(p,(1.0/span) * (1.0 - 1.))));
    return b0 + b1 + b2 + b3 + b4;
}

vec3 drawRader(vec2 p, vec2 pos, float r){
    float dist =  sqrt(dot(p+pos, p+pos));
	float border = 0.006;
	float circle_radius = 0.15;
	vec3 cl = vec3(0);
	float l = staticline(p+pos,vec2(0),rot(vec2(0.1,0.1),r), 0.5);
	
	if ( (dist > (circle_radius+border)) || (dist < (circle_radius-border)) ){
		cl += vec3(0)+vec3(vec3(l)*vec3(1.0,0.16,0.0));
	}else{ 
		cl += vec3(0.3)+vec3(vec3(l)*vec3(1.0,0.16,0.0));
	}
	return cl;
}

float loopEnd = 20.0;
void drwaScene(out vec4 fragColor, in vec2 fragCoord, vec2 position,vec3 dir) {
	float aspect = iResolution.x / iResolution.y;
 	dir = normalize(vec3(position * vec2(aspect, 1.0), 1.0));
 	vec3 pos;

 	if(mod(time,loopEnd) >= 0.0 && mod(time,loopEnd) < 5.0) {
		dir.yz = rot(dir.yz, 1.2 - mod(time*(1.0/5.0),1.0));
	 	pos = vec3(0.0, 60.0-mod(time*(52.0/5.0), 52.0), 35.0-mod(time*(30.0/5.0),30.0));
 	}

 	if(mod(time,loopEnd) >= 5.0 && mod(time,loopEnd) < 15.0) {
 		dir.yz = rot(dir.yz, 0.2);
 		pos = vec3(0.0, 8.0, 5.0);
 	}

    /*
	if(mod(time,loopEnd) >= 10.0 && mod(time,loopEnd) < 15.0) {
		dir.xz = rot(dir.xz, (DEG_TO_RAD*180.0));
 		pos = vec3(0.0, 3.0, 115.0);
	}
    */

	if(mod(time,loopEnd) >= 15.0) {
 		dir.yz = rot(dir.yz, 0.2);
 		pos = vec3(0.0, 8.0, 5.0);
	}

	mat4 m = matRotateY(DEG_TO_RAD*45.0)*matRotateX(sin(time*2.0)*(DEG_TO_RAD*5.0))*matRotateZ(sin(time*1.5)*(DEG_TO_RAD*7.0));

	vec4 result;
	float e = 0.0001;
	float t = e * 2.0;
	float h = 0.0;
	for (int i = 0; i < ITER; i++)
	{
		if(t < e || t > 20.0) continue;
		result = map(pos, m);
		if (result.w < NEAR || result.w > FAR) break;
		pos += result.w * dir;
		t += h;
	}
 
	vec3 col = map(pos, m).xyz;
	vec4 bgCol;
	if ( pos.z> 100. )
	{
		// bg
		position.y += (sin((position.x + (time * 0.3)) * 2.0) * 0.1) + (sin((position.x + (time * 0.1)) * 10.0) * 0.01);
		float xpos = 0.2;
		float ypos = 0.13;
		float l = line(position,vec2(0.1+xpos,0.1+ypos),vec2(0.22+xpos,0.1+ypos),0.2);
		l += line(position,vec2(0.12+xpos,0.12+ypos),vec2(0.2+xpos,0.12+ypos),0.2);				
		l += staticline(position,vec2(0.1+xpos,0.1+ypos),vec2(0.22+xpos,0.1+ypos),0.2);
		l += staticline(position,vec2(0.1+xpos,0.1+ypos),vec2(0.178+xpos,0.3+ypos),0.2);
		l += staticline(position,vec2(0.22+xpos,0.1+ypos),vec2(0.19+xpos,0.25+ypos),0.2);
		l += staticline(position,vec2(0.12+xpos,0.12+ypos),vec2(0.2+xpos,0.12+ypos),0.2);
		l += staticline(position,vec2(0.12+xpos,0.12+ypos),vec2(0.178+xpos,0.27+ypos),0.2);

		col = gradientbg(position.y+0.1)+(vec3(l)*vec3(1.0,0.16,0.0));
	}
	else
	{
		// shade
		vec3 lightPos = vec3(20.0, 20.0, 20.0 );
		vec3 light2Pos = normalize( lightPos - pos);
		vec3 eps = vec3( .1, .01, .0 );
		vec3 n = vec3( result.w - map( pos - eps.xyy, m ).w,
			       result.w - map( pos - eps.yxy, m ).w,
			       result.w - map( pos - eps.yyx, m ).w );
		n = normalize(n);
				
		float lambert = max(.0, dot( n, light2Pos));
		col *= vec3(lambert);

		col += vec3(result.xyz);
	}

	position = (fragCoord.xy * 2.0 - iResolution.xy) / min(iResolution.x, iResolution.y);
	vec3 cl3 = vec3(0);
	cl3 += drawRader(position,vec2(1.23,-0.80),time*2.0);
	cl3 += drawRader(position,vec2(1.58,-0.80),-time*3.0);

	position = ( fragCoord.xy /iResolution.xy ) * vec2(256,128);
	vec2 cpos = vec2(1.5);
	float dc = Digit(fract(time)*10.0,floor(position-cpos));
	cpos.x += 3.5;
	dc += Digit(fract(time)*20.0,floor(position-cpos));
	cpos.x += 3.5;
	dc += Digit(10.0,floor(position-cpos));
	cpos.x += 3.5;
	dc += Digit(fract(time)*40.0,floor(position-cpos));
	cpos.x += 3.5;
	dc += Digit(fract(time)*50.0,floor(position-cpos));
	cpos.x += 3.5;
	dc += Digit(10.0,floor(position-cpos));
	cpos.x += 3.5;
	dc += Digit(fract(time)*70.0,floor(position-cpos));
	cpos.x += 3.5;
	dc += Digit(fract(time)*80.0,floor(position-cpos));
	cpos.x += 3.5;
	dc += Digit(fract(time)*90.0,floor(position-cpos));

	vec3 cl2 = vec3(dc)*vec3(0.3,0.3,0.3);

	fragColor = vec4( col+cl2+cl3, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
    vec2 position = ( fragCoord.xy / iResolution.xy );
	position -= .5;
	vec3 dir = vec3( position, 1.0 );
	/*
	if(mod(time,20.0) >= 10.0 && mod(time,20.0) < 15.0) {
		position = mod(position, .5);
		position = position * 2.0 - .5;
		position.y /= iResolution.x / iResolution.y;
	}
	*/
    drwaScene(fragColor,fragCoord,position,dir);
}