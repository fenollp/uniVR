// Shader downloaded from https://www.shadertoy.com/view/Mdl3z2
// written by shadertoy user FabriceNeyret2
//
// Name: planet ocean
// Description: noise(pseudoAdvectedNoise(pos)) on a shape + cubemap + fog.
//    mouse rotate camera
//    #define MODE = 0,1,2  0 is cheaper than the default 2 :-)
// --- planet ocean ---------------------------
// Fabrice NEYRET 27/07/2013

#define MODE 2 // 0,1,2. wave kind. 2 is the most costly.

#define ANIM true
#define PI 3.1415927

float time = iGlobalTime;

// --- noise functions from https://www.shadertoy.com/view/XslGRr
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

mat3 m = mat3( 0.00,  0.80,  0.60,
              -0.80,  0.36, -0.48,
              -0.60, -0.48,  0.64 );

float hash( float n )
{
    return fract(sin(n)*43758.5453);
}

float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0 + 113.0*p.z;

    float res = mix(mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                        mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    mix(mix( hash(n+113.0), hash(n+114.0),f.x),
                        mix( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

float fbm( vec3 p )
{
    float f;
    f  = 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return f;
}
// --- End of Created by inigo quilez


// 2 noise channels from 2D position
vec2 noise2_2( vec2 p )     
{
	vec3 pos = vec3(p,.5);
	if (ANIM) pos.z += time;
	pos *= m;
    float fx = noise(pos);
    float fy = noise(pos+vec3(1345.67,0,45.67));
    return vec2(fx,fy);
}

#define snoise(p)  (2.*noise(p)-1.)
#define snoise2_2(p)  (2.*noise2_2(p)-1.)
#define fbm2(p)  ((noise(p)+.5*noise(m*(p)))/1.5)

// pseudo-advection noise
vec2 advfbm( vec2 p, float s )
{	
    float l=1.;
	vec2 dp;	
    dp  =   snoise2_2(p+s*dp); l*=.5;
    dp += l*snoise2_2(p+s*dp); l*=.5;
    dp += l*snoise2_2(p+s*dp); l*=.5;
    //dp += l*snoise2_2(p+s*dp); l*=.5;
    //dp += l*snoise2_2(p+s*dp); 

    return s*dp;
}

 // ----------- the scene ------------------------------
float _h; // height(p). 
float scene(vec3 p) 
{
	// main shape
	const float scale = 3.;
	vec2 disp = advfbm(scale*p.xz,.5)/scale;

#if MODE==0
	float h = length(disp);
#elif MODE==1
	vec3 pp = p+vec3(disp,0.)+time*vec3(1.,0.,0.);
	float h = texture2D(iChannel0,.05*pp.xy).x;
#else
	vec3 pp = p+vec3(disp,0.)+time*vec3(1.,0.,0.);
	float h = fbm(pp);
#endif
	
	// planet shape.
	h -= .05*dot(p.xz,p.xz);
	_h = h; 
	
	// distance estimate from ray pos to surface
	return  .2*(p.y-h);
}

vec3 Nscene(vec3 hit) // normal at hit point.
{
	const float E = .05;
	vec2 h = vec2(E,0.); 
	float h0 = _h;
	scene(hit+h.xyy); float hx=_h-h0;
	scene(hit+h.yyx); float hz=_h-h0;
	return normalize(vec3(-hx, E, -hz));
}

vec2 rotate(vec2 k,float t)
{   return vec2(cos(t)*k.x-sin(t)*k.y,sin(t)*k.x+cos(t)*k.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	float speed = 0.;
	vec2 pos=(fragCoord.xy/iResolution.y-vec2(.8,.5))*2.;
	vec2 mouse = vec2(0.,.16);
	if (iMouse.x > 0.) mouse = (iMouse.xy/iResolution.xy-.5)*2.;
    vec3 col;
	vec3 sky = vec3(.6,.8,1.);
	vec3 light = vec3(.2,.8,-.2);

	// camera & ray-marching inspired by rez
	// https://www.shadertoy.com/view/MsXGR2
	
	float fov = .5;
	vec3 dir=normalize(vec3(fov*pos,1.0));	// ray dir
	dir.yz=rotate(dir.yz, PI*mouse.y);		// rotation up/down
	dir.zx=rotate(dir.zx,-PI*mouse.x);		// rotation left/right
	//dir.xy=rotate(dir.xy,0.);	       		// twist
	vec3 ray=vec3(0.,2.+3.*sin(time),-4.);  // pos along ray
	
	float l=0.,dl;
#define eps 1.e-3
	const int ray_n=3*64;
	for(int i=0; i<ray_n; i++) // march the ray up to the surface
	{
		l += dl = scene(ray+dir*l);
		if (dl<=eps) break;
	}
	if (dl<=10.*eps) 
	{
		vec3 hit = ray+dir*l;
		float H=_h;
		
		// shading 
		vec3 N = Nscene(hit);
    	float c;
		c = textureCube(iChannel1,N.xzy).x;
		//c += .1*clamp(1.*dot(N,light),0.,1.);
		
		// fog
		float a = 1.-exp(-.07*l); // optical thickness

		// shading
		col = 1.*c*vec3(0.,.5,.8); 
		//col +=  H*vec3(2.);
		col = a*sky + (1.-a)*col;
	}
	else
		col = sky;
	
	fragColor = vec4(col,1.0);
}