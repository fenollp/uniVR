// Shader downloaded from https://www.shadertoy.com/view/Xts3zX
// written by shadertoy user bergi
//
// Name: Obfuskali
// Description: kali fan shader
/* KALI fan shader 

   2015, stefan berke
   License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
*/


#define Iterations 		5
#define Surface 		0.05
#define Time 			(iGlobalTime)

#define TraceSteps		20
#define Fudge			0.7
#define MultiSample		1			// not quadratic, actual number of samples

#define kTime (Time/4.)
#define KaliParam vec3(0.501+.5*sin(kTime/11.1), .9, .3) + 0.1*vec3(sin(kTime), sin(kTime*1.1), sin(kTime*1.2));

float kscale;
float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
    p.x = mod(p.x, 18./kscale);
    p.y = mod(p.y, 13./kscale);
    float koffs = .005;
    a /= kscale;
    b /= kscale;
    r /= kscale;
	// by IQ
    vec3 pa = p - a - koffs, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

// the shape trap
float inDE(in vec3 p)
{
    float d = sdCapsule(p, vec3(0,0,0), vec3(0,4,0), Surface);
    d = min(d, sdCapsule(p, vec3(0,2,0), vec3(2,4,0), Surface));
    d = min(d, sdCapsule(p, vec3(0,2,0), vec3(2,0,0), Surface));
    
    d = min(d, sdCapsule(p, vec3(3,0,0), vec3(4.5,4,0), Surface));
    d = min(d, sdCapsule(p, vec3(6,0,0), vec3(4.5,4,0), Surface));
    d = min(d, sdCapsule(p, vec3(4,2,0), vec3(5,2,0), Surface));
    
    d = min(d, sdCapsule(p, vec3(7,0,0), vec3(7,4,0), Surface));
    d = min(d, sdCapsule(p, vec3(7,0,0), vec3(9,0,0), Surface));
    
    d = min(d, sdCapsule(p, vec3(10,0,0), vec3(10,4,0), Surface));
    
    return d;
}

// the arch structure
// "kali-set" by Kali
float DE(vec3 z)
{
	float d = 100.;
	vec4 p = vec4(z, 1.);
	float s = Surface;
    kscale = 1.;
	for (int i=0; i<Iterations; ++i)
	{
		p = abs(p) / dot(p.xyz, p.xyz);
        if (i!=0)
			d = min(d, inDE(p.xyz/p.w) - s); 
        s = s * .4;
        kscale = pow(kscale,1.03) * 3.5;
		p.xyz -= KaliParam;
	}
	return d;
}

// nimitz https://www.shadertoy.com/view/lslXRS
float hash(in vec2 x) { return fract(sin(dot(x, vec2(12.9898, 4.1414))) * 43758.5453); }

float seed=0.;
float rnd(in vec2 x) { float r = hash(x + seed); seed += 1.; return r; }

mat2 rotate(float r) { float s = sin(r), c = cos(r); return mat2(c, -s, s, c); }

vec3 render(in vec3 ro, in vec3 dir)
{    
	vec3 col = vec3(0.);

    // march
    float d, t = DE(ro) * Fudge * rnd(dir.xy);
    for (int i=0; i<TraceSteps; ++i)
    {
        vec3 p = ro + t * dir;
        
        float d = DE(p);
        
        col += 1./max(1., 1.+10.*d);
       
        t += d * Fudge;
    }
  
	return col / (1. + 100.*t*t*t) / float(TraceSteps);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ti = Time/14.;
    
    vec3 ro = vec3(0.2*sin(ti*4.),0.,-1.5+sin(ti*1.21));
    mat2 r = rotate(-ti);
    ro.yz = r * ro.yz;
    ro.x += 0.;

    vec3 col = vec3(0.);
    for (int i=0; i<MultiSample; ++i)
    {
		vec2 uv = ((fragCoord.xy + rnd(fragCoord.xy)) * 2. - iResolution.xy) / iResolution.y;
    
        vec3 dir = normalize(vec3(uv, 1. - .4*dot(uv,uv)));
        dir.yz = r * dir.yz;
        dir.yz = rotate(.5+sin(ti*2.23)) * dir.yz;
        dir.xy = rotate(2.*sin(ti*2.)) * dir.xy;
        
        col += render(ro, dir);
    }
    col /= float(MultiSample);
    
    fragColor = vec4(clamp(pow(col,vec3(.5)),0.,1.),1.0);
}



