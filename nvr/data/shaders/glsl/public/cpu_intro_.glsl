// Shader downloaded from https://www.shadertoy.com/view/XslGzn
// written by shadertoy user CPU
//
// Name: CPU intro!
// Description: just a little intro...

// inspired by CRT oscilloscopes... facebook.com/steveoscpu


float Logo(vec2 p) {
	float y = floor((p.y)*16.)+3.;
	if(y < 0. || y > 4.) return 0.;
	float x = floor((1.-p.x)*16.)-8.;
	if(x < 0. || x > 14.) return 0.;
	float v=31698.0;if(y>0.5)v=19026.0;if(y>1.5)v=17362.0;if(y>2.5)v=18962.0;if(y>3.5)v=31262.0;
	return floor(mod(v/pow(2.,x), 2.0));
}

float hash( float n ) { return fract(sin(n)*43758.5453); }

float noise( in vec2 x )
{
	vec2 p = floor(x);
	vec2 f = fract(x);
    	f = f*f*(3.0-2.0*f);
    	float n = p.x + p.y*57.0;
    	return mix(mix(hash(n+0.0), hash(n+1.0),f.x), mix(hash(n+57.0), hash(n+58.0),f.x),f.y);
}

vec3 cloud(vec2 p) {
	p.x *= 1.14;
	p.x -= iGlobalTime*.1;
	p.y *= 3.14;
	vec3 f = vec3(0.0);
    	f += 0.5000*noise(p*10.0)*vec3(0.9, 0.2,0.7);
    	f += 0.2500*noise(p*20.0)*vec3(0.9, 1.6, 0.5);
    	f += 0.1250*noise(p*40.0)*vec3(0.9, 0.7, 0.3);
    	f += 0.0625*noise(p*80.0)*vec3(0.9, 1.2, 0.9);
	return f*f*2.;
}

const float SPEED	= 0.001;
const float SCALE	= 80.0;
const float DENSITY	= 0.8;
const float BRIGHTNESS	= 10.0;
       vec2 ORIGIN	= iResolution.xy*.5;
float rand(vec2 co){ return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453); }

vec3 layer(float i, vec2 pos, float dist, vec2 coord) {
	float t = i*10.0 + iGlobalTime*i*i;
	float r = coord.x - (t*SPEED);
	float c = fract(coord.y + i*.543 + iGlobalTime*i*.01);
	vec2  p = vec2(r, c*.5)*SCALE*(4.0/(i*i));
	vec2 uv = fract(p)*2.0-1.0;
	float a = coord.y*(3.1415926*2.0) - (3.1415926*.5);
	uv = vec2(uv.x*cos(a) - uv.y*sin(a), uv.y*cos(a) + uv.x*sin(a));
	float m = clamp((rand(floor(p))-DENSITY/i)*BRIGHTNESS, 0.0, 1.0);
	return  clamp(vec3(Logo(uv*.5))*m*dist, 0.0, 1.0);
}

float segment(vec2 P, vec2 P0, vec2 P1)
{
	vec2 v = P1 - P0;
	vec2 w = P - P0;
	float b = dot(w,v) / dot(v,v);
	v *= clamp(b, 0.0, 1.0);
	return length(w-v);
}

float StockValue(float x, float s) {
	return fract(sin(x)*10000.0)*.25*s-x*.5;
}

vec3 Chart( vec2 p ) {

	float d = 1e20;
	float s = 20.;
	float t = iGlobalTime*s*.08;

	p = p*s + vec2(t+s*.25,-t*.5);

	float x = floor(p.x);

	vec2 p0 = vec2(x-.5, StockValue(x+0., s));
	vec2 p1 = vec2(x+.5, StockValue(x+1., s));
	d = min(d, segment(p+vec2(0,0), p0, p1));

	p0 = vec2(x+1.5, StockValue(x+2., s));
	d = min(d, segment(p+vec2(0,0), p1, p0));

	p = abs(mod(p, vec2(1.,1.))-vec2(.5,.5))-.01;
	float b =1.0-clamp(min(p.x, p.y)*iResolution.x/s, 0.0, 1.0);

	float a1=clamp(1.0-d,0.0,1.0);
	a1*=a1;
	return vec3(a1*a1,a1*a1*a1,a1+b*0.2);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2   pos = fragCoord.xy - ORIGIN ;
	float dist = length(pos) / iResolution.y;
	vec2 coord = vec2(pow(dist, 0.1), atan(abs(pos.x), pos.y) / (3.1415926*2.0));
	vec3 color = cloud(coord)*3.0*dist;
	color.b=cloud(coord*0.998).x*(3.0*dist);
	coord = vec2(pow(dist, 0.1), atan(pos.x, pos.y) / (3.1415926*2.0));
	color += layer(2.0, pos, dist, coord)*0.3;
	color += layer(3.0, pos, dist, coord)*0.2;
	color += layer(4.0, pos, dist, coord)*0.1;
	pos.y=-pos.y;
        vec3 c=((clamp(3.0*abs(fract(iGlobalTime*0.1+vec3(0,2./3.0,1./3.0))*2.-1.)-1.,0.,1.)-1.)+1.);
        c*=(0.2-dist*0.1)*Logo(pos/iResolution.xy);
	fragColor = vec4( (1.0+(2.0-dist*2.0))*0.4 *Chart(pos/iResolution.x)+c+color*.4 , 1.0);//
}
