// Shader downloaded from https://www.shadertoy.com/view/XddSWl
// written by shadertoy user vox
//
// Name: G-Lectric Sheep 6
// Description: Can anyone find anything similar???
//    
//    I repeat:
//    
//    IS THIS A NEW DISTANCE ESTIMATOR? ANYBODY KNOW?
//-----------------SETTINGS-----------------
//#define TIMES_DETAILED (sin(time*32.0)+1.0)
#define TIMES_DETAILED (1.0+sin(time*PI*1.0)*.1)

//-----------------USEFUL-----------------

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS .001

#define time ((saw(float(__LINE__))+1.0)*(iGlobalTime+12345.12345)/PI/2.0)
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

//-----------------RENDERING-----------------

float seedling;
float zoom;

vec2 mobius(vec2 uv)
{
	vec2 a = sin(seedling+vec2(time, time*GR/E));
	vec2 b = sin(seedling+vec2(time, time*GR/E));
	vec2 c = sin(seedling+vec2(time, time*GR/E));
	vec2 d = sin(seedling+vec2(time, time*GR/E));
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float aspect = iResolution.y/iResolution.x;
   
    vec2 uv = fragCoord.xy/iResolution.xy;
    
    zoom = (2.5+2.0*sin(time));
    
    
   	const int max_i = 16;
    float stretch = 1.0;
    float ifs = 1.0;
    float depth = 0.0;
    float magnification;
    
    for(int i = 0; i < max_i; i++)
    {
        seedling += fract(float(i)*123456.123456);
        
        vec2 next = iterate(uv, .5/iResolution.xy, magnification);
        
        //omg so platform dependent... pls help fix:
        float weight = smoothstep(0.0, 0.25, ifs);
        
        ifs *= smoothstep(0.0, 1.0/TIMES_DETAILED, sqrt(1.0/(1.0+magnification)));
        
        uv = next*weight+uv*(1.0-weight);
        float delta = sphereN(uv*2.0-1.0).z*ifs;
        depth += 1.0-delta;
        
		if(ifs != 0.0)
        {
            fragColor = vec4(uv*clamp(delta*3.0, 0.0, 1.0), 0.0, 1.0);
            return;
        }
        
        //if(mod(iGlobalTime, float(max_i))-float(i) < 0.0) break;
    }
    
    
    fragColor = vec4(uv, 0.0, 1.0);
    
    //depth /= float(max_i);
    float shift = time;

    float stripes = depth*PI*5.0;
    float black = smoothstep(0.0, .75, saw(stripes));
    float white = smoothstep(0.75, 1.0, saw(stripes));
        
    
    vec3 final = (
        				vec3(saw(depth*PI*2.0+shift),
                	  		saw(4.0*PI/3.0+depth*PI*2.0+shift),
                	  		saw(2.0*PI/3.0+depth*PI*2.0+shift)
                 		)
        		 )*black
        		 +white;
    
    fragColor = vec4(vec3(ifs), 1.0);
    
    fragColor = vec4(saw((depth)));
    fragColor = vec4(final, 1.0);
}
