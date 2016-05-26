// Shader downloaded from https://www.shadertoy.com/view/lt2GDy
// written by shadertoy user ManuManu
//
// Name: Funky tentacles
// Description: Ok, I must confess it : it was totally out of control
//    I made this from testing something from this demo http://glslsandbox.com/e#25403.2 and its parent here http://glslsandbox.com/e#25400.0
//    
//    original : http://glslsandbox.com/e#25442.7
#ifdef GL_ES
precision mediump float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;


// Ok, I must confess it : it was totally out of control
// I made this from testing something from this demo http://glslsandbox.com/e#25403.2 and it's parent here http://glslsandbox.com/e#25400.0

// I didn't expect that, but it's really gorgious ( IMHO )


// Note : I can't save with such a value :(
//#define MAX_STEP 100
//#define PRECISION .001
#define MAX_STEP 200
#define PRECISION .1


vec3 pin(vec3 v)
{
	vec3 q = vec3(0.0);
	
	q.x = sin(v.x)*0.5+0.5;
	q.y = sin(v.y+1.0471975511965977461542144610932)*0.5+0.5;
	q.z = sin(v.z+4.1887902047863909846168473723972)*0.5+0.5;
	
	return normalize(q);
}

vec3 spin(vec3 v)
{
	for(int i = 0; i <3; i++)
	{
		v=pin(v.yzx*6.283185307179586476925286766559);
	}
	return v.zxy;

}
float map(vec3 p) {
	vec3 val = spin(p);
	float k = val.x + val.y + val.z;
	return (cos(p.x) + cos(p.y*0.75) + sin(p.z)*0.25)+k*1.2;
}

vec2 rot(vec2 r, float a) {
	return vec2(
		cos(a) * r.x - sin(a) * r.y,
		sin(a) * r.x + cos(a) * r.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv  = ( gl_FragCoord.xy / iResolution.xy ) * 2.0 - 1.0;
	uv.x *= iResolution.x / iResolution.y ;
	vec3 dir = normalize(vec3(uv, 1.0));
	dir.zy = rot(dir.zy, iGlobalTime * 0.2);
	dir.xz = rot(dir.xz, iGlobalTime * 0.1); dir = dir.yzx;

	vec3 pos = vec3(0, 0, iGlobalTime * 2.0);
	float t = 0.0;
	for(int i = 0 ; i < MAX_STEP; i++) {
		float temp = map(pos + dir * t) * 0.55;
		if(temp < PRECISION) break;
		t += temp;
		dir.xy=rot(dir.xy,temp*0.05);
		dir.yz=rot(dir.yz,temp*0.05);
		dir.zx=rot(dir.zx,temp*0.05);
	}
	vec3 ip = pos + dir * t;
	fragColor = vec4(vec3(max(0.01, map(ip + 0.2)) + t * 0.02) + (dir*spin(ip)), 1.0);

}