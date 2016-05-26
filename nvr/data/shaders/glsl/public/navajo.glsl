// Shader downloaded from https://www.shadertoy.com/view/4scXz8
// written by shadertoy user eiffie
//
// Name: Navajo
// Description: Fairly simple pattern generator using overlaid checkers/diagonal checkers.
// Simple 2d noise algorithm contributed by Trisomie21 (Thanks!)
float noise2D( vec2 p ) {
	vec2 f = fract(p);
	p = floor(p);
	float v = p.x+p.y*1000.0;
	vec4 r = vec4(v, v+1.0, v+1000.0, v+1001.0);
	r = fract(100000.0*sin(r*.001));
	f = f*f*(3.0-2.0*f);
	return 2.0*(mix(mix(r.x, r.y, f.x), mix(r.z, r.w, f.x), f.y))-1.0;
}

float Pattern(vec2 p, vec4 s, float b){//s=scale and b=offset
	p=abs(p);//typical rug reflection
	p.y+=floor(2.0*fract(p.x))*b; //brick offset
	vec2 c=fract(vec2(p.x+p.y,p.x-p.y)*s.zw)-0.5; //diamond repeat
	p=fract(p*s.xy)-0.5; //square repeat
	return step(p.x*p.y,0.0)+step(c.x*c.y,0.0); //overlaid checkers
}

float rnd=0.0;
float rand(){return fract(sin(rnd+=2.0)*324.234);}
float irnd(int i){return floor(rand()*float(i));}
void mainImage(out vec4 O, in vec2 U) {
	vec2 uv=U/iResolution.xy-0.5;
	uv*=3.0;
	rnd=floor(iGlobalTime);
	vec4 s=vec4(irnd(3),irnd(3),irnd(3),irnd(3))/(vec4(irnd(4),irnd(4),irnd(4),irnd(4))+1.0);
	float b=irnd(3)/(1.0+irnd(4));
	float d=(Pattern(uv,s,b)+Pattern(uv*3.0,s,b))*0.4;
	vec2 g=vec2(370.0,8.8);
	float n=noise2D(uv*g)+noise2D(uv*g.yx);
	vec3 col=max(cos(vec3(d,d+1.0,d+2.0)),0.1)*(1.0+0.3*n);
	O=vec4(col,1.0);
}
