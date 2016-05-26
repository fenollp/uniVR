// Shader downloaded from https://www.shadertoy.com/view/XsKSRR
// written by shadertoy user vox
//
// Name: Galaxies 7
// Description: Galaxies 7
//-----------------SETTINGS-----------------
#define TIMES_DETAILED (3.0)
//#define TIMES_DETAILED (5.0+sin(time*PI*1.0)*.1)

//-----------------USEFUL-----------------

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS (0.5/max(iResolution.x, iResolution.y))

#define time ((saw(float(__LINE__))+.5)*(iGlobalTime+12345.12345))
#define saw(x) (acos(cos(x))/PI)
#define sphereN(uv) (normalize(vec3((uv).xy, sqrt(clamp(1.0-length((uv)), 0.0, 1.0)))))
#define rotatePoint(p,n,theta) (p*cos(theta)+cross(n,p)*sin(theta)+n*dot(p,n) *(1.0-cos(theta)))
//-----------------IMAGINARY-----------------

vec2 cmul(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x - v1.y * v2.y, v1.y * v2.x + v1.x * v2.y);
}

vec2 cdiv(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x + v1.y * v2.y, v1.y * v2.x - v1.x * v2.y) / dot(v2, v2);
}

//-----------------SIMPLEX-----------------

vec3 random3(vec3 c) {
    float j = 4096.0*sin(dot(c,vec3(17.0, 59.4, 15.0)));
    vec3 r;
    r.z = fract(512.0*j);
    j *= .125;
    r.x = fract(512.0*j);
    j *= .125;
    r.y = fract(512.0*j);
    return r-0.5;
}

float simplex3d(vec3 p) {
    const float F3 =  0.3333333;
    const float G3 =  0.1666667;
    
    vec3 s = floor(p + dot(p, vec3(F3)));
    vec3 x = p - s + dot(s, vec3(G3));
    
    vec3 e = step(vec3(0.0), x - x.yzx);
    vec3 i1 = e*(1.0 - e.zxy);
    vec3 i2 = 1.0 - e.zxy*(1.0 - e);
    
    vec3 x1 = x - i1 + G3;
    vec3 x2 = x - i2 + 2.0*G3;
    vec3 x3 = x - 1.0 + 3.0*G3;
    
    vec4 w, d;
    
    w.x = dot(x, x);
    w.y = dot(x1, x1);
    w.z = dot(x2, x2);
    w.w = dot(x3, x3);
    
    w = max(0.6 - w, 0.0);
    
    d.x = dot(random3(s), x);
    d.y = dot(random3(s + i1), x1);
    d.z = dot(random3(s + i2), x2);
    d.w = dot(random3(s + 1.0), x3);
    
    w *= w;
    w *= w;
    d *= w;
    
    return dot(d, vec4(52.0));
}

//-----------------RENDERING-----------------

float seedling;
float zoom;

vec2 mobius(vec2 uv)
{
	vec2 a = saw(seedling/PI+cos(vec2(time, time*GR/E)))+.5;
	vec2 b = saw(seedling/PI+cos(vec2(time, time*GR/E)))+.5;
	vec2 c = saw(seedling/PI+cos(vec2(time, time*GR/E)))+.5;
	vec2 d = saw(seedling/PI+cos(vec2(time, time*GR/E)));
	return cdiv(cmul(uv, a) + b, cmul(uv, c) + d);
}


vec2 map(vec2 uv)
{
    return saw(mobius(zoom*(uv*2.0-1.0))*2.0*PI);
}

vec2 iterate(vec2 uv, vec2 dxdy, out float magnification)
{
    vec2 a = uv+vec2(0.0, 		0.0);
    vec2 b = uv+vec2(dxdy.x, 	0.0);
    vec2 c = uv+vec2(dxdy.x, 	dxdy.y);
    vec2 d = uv+vec2(0.0, 		dxdy.y);//((fragCoord.xy + vec2(0.0, 1.0)) / iResolution.xy * 2.0 - 1.0) * aspect;

    vec2 ma = map(a);
    vec2 mb = map(b);
    vec2 mc = map(c);
    vec2 md = map(d);
    
    float da = length(mb-ma);
    float db = length(mc-mb);
    float dc = length(md-mc);
    float dd = length(ma-md);
    
	float stretch = max(max(max(da/dxdy.x,db/dxdy.y),dc/dxdy.x),dd/dxdy.y);
    
    magnification = stretch;
    
    return map(uv);
}

const vec4 bitEnc = vec4(1.,255.,65025.,16581375.);
const vec4 bitDec = 1./bitEnc;
vec4 EncodeFloatRGBA (float v) {
    vec4 enc = bitEnc * v;
    enc = fract(enc);
    enc -= enc.yzww * vec2(1./255., 0.).xxxy;
    return enc;
}

float DecodeFloatRGBA (vec4 v) {
    return dot(v, bitDec);
}

float lowAverage()
{
    const int iters = 32;
    float sum = 0.0;
    
    float last = length(texture2D(iChannel0, vec2(0.0)));
    float next;
    for(int i = 1; i < iters; i++)
    {
        next = length(texture2D(iChannel0, vec2(float(i)/float(iters), 0.0)));
        sum += last;//pow(abs(last-next), 1.0);
        last = next;
    }
    return sum/float(iters);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.y/iResolution.x;
   
    vec2 uv = fragCoord.xy/iResolution.xy;
    
    float height = lowAverage();
    
    zoom = (10.25+15.15*(1.0-height));
    
    
   	const int max_i = 16;
    int last_i;
    float stretch = 1.0;
    float ifs = 1.0;
    float total = 0.0;
    float depth = 0.0;
    float magnification;
    
    seedling = 0.0;
    
    for(int i = 0; i < max_i; i++)
    {
        last_i = i;
        seedling += fract(float(i)*123456.123456);
        
        vec2 next = iterate(uv, .5/iResolution.xy, magnification);
        
        //omg so platform dependent... pls help fix:
        float weight = smoothstep(0.0, 1.0/float(i+1), ifs);
        
        ifs *= smoothstep(0.0, 1.0/(TIMES_DETAILED-height), sqrt(1.0/(1.0+magnification)));
        
        uv = next*weight+uv*(1.0-weight);
        float delta = sphereN(uv*2.0-1.0).z*ifs;
        depth += 1.0-delta;
        
        total += weight;
        
		if(ifs == 0.0)
            break;
        
    	float sound = DecodeFloatRGBA(texture2D(iChannel0, uv));
        seedling += sound;
        
        //if(mod(iGlobalTime, float(max_i))-float(i) < 0.0) break;
    }
    
    
    float sound = DecodeFloatRGBA(texture2D(iChannel0, uv));
    //sound *= simplex3d(vec3(fragCoord, time*3.0*PI));

    if (sound < total/float(last_i))
    {
        if(sound*sound < .25*ifs)
        {
            fragColor = fragColor*vec4(sound*sound/.25/ifs);
            return;
        }
        discard;
        return;
    }
    
	    
    fragColor = vec4(uv, 0.0, 1.0);

    float shift = time;
    float stripes = (depth+simplex3d(vec3(fragCoord.xy/iResolution.xy+uv, sound)))*height;
    float black = smoothstep(0.0, .05, saw(stripes))*clamp(sound*2.0, 0.0, 1.0);
    float white = smoothstep(0.95, 1.0, saw(stripes))*black;


    vec3 final = (
        vec3(saw(stripes*PI*2.0),
             saw(4.0*PI/3.0+stripes*PI*2.0),
             saw(2.0*PI/3.0+stripes*PI*2.0)
            )
    )*black
        +white;

    fragColor = vec4(vec3(ifs), 1.0);

    fragColor = vec4(saw((depth)));
    fragColor = vec4(final, 1.0)*height;
    
    //fragColor = vec4(simplex3d(vec3(fragCoord.xy/iResolution.xy, time)));
}
