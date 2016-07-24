// Shader downloaded from https://www.shadertoy.com/view/4sVSzz
// written by shadertoy user vox
//
// Name: Dancing Galaxies 2
// Description: Dancing Galaxies 2
//-----------------SETTINGS-----------------
#define TIMES_DETAILED (1.0)
//#define TIMES_DETAILED (5.0+sin(time*PI*1.0)*.1)

//-----------------USEFUL-----------------

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS (2.0/max(iResolution.x, iResolution.y))

#define time ((saw(float(__LINE__))+.5)*(iGlobalTime/PI+12345.12345))
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
	vec2 a = saw(seedling+vec2(time*1.0*PI, time*GR/E*1.0*PI))*.25+.25;
	vec2 b = sin(seedling+vec2(time*1.0*PI, time*GR/E*1.0*PI));
	vec2 c = saw(seedling+vec2(time*1.0*PI, time*GR/E*1.0*PI))*.25+.25;
	vec2 d = sin(seedling+vec2(time*1.0*PI, time*GR/E*1.0*PI));
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
vec2 spiral(vec2 uv)
{
    float turns = 2.0+saw(seedling*1.1234)*4.0;
    float r = pow(log(length(uv)+1.), 1.175);
    float theta = atan(uv.y, uv.x)*turns-r*PI;
    return vec2(saw(r*PI+seedling*1.12345), saw(theta+seedling*1.123456));
}
    /*
    float scale = 2.0*PI;
    uv *= scale;
    uv -= scale/2.0;
	uv.x *= iResolution.x/iResolution.y;
    uv += vec2(cos(iGlobalTime*.234), sin(iGlobalTime*.345))*1.0;
    uv = spiral(uv);
    */
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.y/iResolution.x;
   
    vec2 uv = fragCoord.xy/iResolution.xy;
    
    float height = lowAverage();
    
    zoom = (4.5+height);
    
    
   	const int max_i =5;
    int last_i;
    float stretch = 1.0;
    float ifs = 1.0;
    float depth = 0.0;
    float magnification;
    
    float total = 0.0;
    
    seedling = height*3.0*PI+time;
    
    for(int i = 0; i < max_i; i++)
    {
        last_i = i;
        seedling += fract(float(i)*123456.123456);
        
        vec2 next = iterate(uv, .5/iResolution.xy, magnification);
        
        //omg so platform dependent... pls help fix:
        float weight = smoothstep(0.0, 0.125, ifs);
        
        ifs *= smoothstep(0.0, 1.0/TIMES_DETAILED, sqrt(1.0/(1.0+magnification)));
        
        total += ifs;
        
        uv = next*weight+uv*(1.0-weight);
        float delta = sphereN(uv*2.0-1.0).z*ifs;
        depth += 1.0-delta;
        
		if(ifs <= 1.0E-3)
            break;
        
        //if(mod(iGlobalTime, float(max_i))-float(i) < 0.0) break;
    }
    
    
    float s = simplex3d(vec3(uv*iResolution.xy, time));
    float sound = texture2D(iChannel0, saw(uv*PI+fragCoord.xy/iResolution.xy*PI+time*PI)).r;
    //fragColor = vec4(vec3(sound), 1.0);return;
    
    if(pow(ifs, 1.0/float(last_i+1)) > 1.0-height/GR)
    {
        if( sound < .25)
            sound = 0.0;
        else
        	discard;
    }
    
    fragColor = vec4(uv, 0.0, 1.0);

    //depth /= float(max_i);
    float shift = time;

    float stripes = depth*1.0+sound;
    float black = smoothstep(0.0, .75, saw(stripes));
    float white = smoothstep(0.75, 1.0, saw(stripes));


    vec3 final = (
        vec3(saw(stripes*PI*2.0+shift),
             saw(4.0*PI/3.0+stripes*PI*2.0+shift),
             saw(2.0*PI/3.0+stripes*PI*2.0+shift)
            )
    )*black
        +white;

    fragColor = vec4(vec3(ifs), 1.0);

    fragColor = vec4(saw((depth)));
    fragColor = vec4(final, 1.0)*smoothstep(0.0, .01, height*sound);
    
    //fragColor = vec4(simplex3d(vec3(fragCoord.xy/iResolution.xy, time)));
}
