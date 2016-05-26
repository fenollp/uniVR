// Shader downloaded from https://www.shadertoy.com/view/4l2SDc
// written by shadertoy user summer
//
// Name: Moonwalkin2
// Description: walking on the moon...
#define RES 4
#define GAIN 0.8
#define LAC 1.3
#define HEIGHT 0.3
#define PREC 0.003
#define EPS 0.03
#define SIZE 4.
const vec2 add = vec2(1., 0.);
float Noise(vec2 xy){
	return texture2D(iChannel0, xy).x*2.-1.;   
}

float ridge(float n){
	return 2.*pow(1.-abs(n), 3.0)-1.;   
}


float stars(vec2 uv){
	if(Noise(uv*0.7)>0.9)
		return 1.0;
	return 0.0;
}

float ridged(vec2 pos){
	float r = 0.0, f = 1.0, a = 1.0, p = 1.0;
	for(int i=0; i<10; i++){
        if(i>=RES)
            break;
        float n = a*ridge(Noise(f*pos));
        r += (p/2.+.5)*n;
		f *= LAC;
		a *= GAIN;
        p = n;
	}
	return r/1.5;
}

float holes(vec2 pos){
        vec2 tile = floor(pos/SIZE);    
    vec2 offset = abs(vec2(fract(Noise(tile))*SIZE, fract(Noise(tile*11.123))*SIZE));
    offset = vec2(.5, .5)*SIZE+Noise(tile)*2.;
       vec2 uv = fract(abs(pos)/SIZE)*SIZE-offset;
     if(length(uv)<1.)
        return pow(length(uv*0.2), 1.3);
    return 20.;
}
float grid(vec2 pos){
    vec2 tile = floor(pos/SIZE);    
    vec2 offset = abs(vec2(fract(Noise(tile))*SIZE, fract(Noise(tile*11.123))*SIZE));
    offset = vec2(.5, .5)*SIZE+Noise(tile)*2.;
    vec2 uv = fract(abs(pos)/SIZE)*SIZE-offset;
    float size = Noise(tile*4.234);
    return min(1./(pow(length(uv), 6.)+0.1), 0.6);
}

float map(vec2 pos){

    return min(max(ridged(pos/350.)*HEIGHT, grid(pos)/1.4-.3),holes(pos));
    
}


bool trace(vec3 ro, vec3 rd, out vec3 hit){
    vec3 last = ro;
    hit = ro;
    for(int i=0; i<1000; i++){
        float dist = length(ro-hit);
        if(dist>30.0)
            return false;
        float h = map(hit.xy);
        hit = last+rd*max(0.01, (hit.z-h)*0.1);       
        if(h>hit.z){
            //hit = bs(last,hit);
           
            return true;
        }
        last = hit;
    }
    return false;
}

void camera(vec2 uv, out vec3 cp, out vec3 cd){
	cp = iGlobalTime * vec3(0., 1., 0.)+vec3(0., 0., 1.4);
    cd = vec3(mix(-1., 1., uv.x)*iResolution.x/iResolution.y,
              1.,
              mix(-1., .5, uv.y)
        );
}

vec3 normal(vec2 pos){
     float dfx = map(pos+add.xy*EPS)-map(pos-add.xy*EPS);
     float dfy = map(pos+add.yx*EPS)-map(pos-add.yx*EPS);
     return normalize(cross(vec3(add.xy*EPS, dfx), vec3(add.yx*EPS, dfy)));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 cp;
    vec3 cd;
    vec2 uv = fragCoord.xy / iResolution.xy;
    camera(uv, cp, cd);
    vec3 hit;
    float t;
    if(trace(cp, cd, hit))
        //t = length(hit-cp)/15.;
        t = dot(normal(hit.xy), normalize(vec3(1.0, 0.0, 0.1)));
    else
        t = stars(uv);
    //t = ridged(uv/10.)/2.+0.5;
	fragColor = vec4(t, t, t, 0.0);
}