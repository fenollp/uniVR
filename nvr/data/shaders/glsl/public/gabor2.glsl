// Shader downloaded from https://www.shadertoy.com/view/XsBGDc
// written by shadertoy user FabriceNeyret2
//
// Name: Gabor2
// Description: mouse.x:  frequency
//    mouse.y: directionality
// inspired from https://www.shadertoy.com/view/MdjGWy#

#define NB 100      // number or gabor blobs
#define SIZE 0.22   // size of gabor blobs
                    // freq tuned by mouse.x

#define M_PI 3.14159265358979
float gauss(float x) {
    return exp(-(x*x)/(SIZE*SIZE)); 
}

float rnd(vec2 uv, int z) 
{
	if      (z==0) return texture2D(iChannel1,uv).r;
	else if (z==1) return texture2D(iChannel1,uv).g;
	else if (z==2) return texture2D(iChannel1,uv).b;
	else           return texture2D(iChannel1,uv).a;
}
float rndi(int i, int j)
{
	vec2 uv = vec2(.5+float(i),.5+float(j))/ iChannelResolution[1].x;
	return texture2D(iChannel1,uv).r;
}

float gabor(vec2 pos, vec2 dir) {
    float g = gauss(pos.x)*gauss(pos.y);
    float s = .5*sin(dot(pos,dir) * 2. * M_PI-10.*iGlobalTime);
	return g*s;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.y;
	float freq = mix(10., iResolution.x/10., iMouse.x/iResolution.x);
	float d = 1.5*iMouse.y/iResolution.y - .5;
	vec3 col= vec3(0.);
	
	for (int i=0; i<NB; i++) {
		vec2 pos = vec2(1.5*rndi(i,0),rndi(i,1));
		vec2 dir = (1.+d)*vec2(rndi(i,2),rndi(i,3))-d;
		col += gabor(uv-pos, freq*dir)*texture2D(iChannel0,pos).rgb;
	}
    fragColor = vec4(col,1.0);
}
                  
