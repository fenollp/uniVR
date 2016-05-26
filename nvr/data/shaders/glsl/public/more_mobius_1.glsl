// Shader downloaded from https://www.shadertoy.com/view/lddSWl
// written by shadertoy user vox
//
// Name: More Mobius 1
// Description: More Mobius 1
//-----------------SETTINGS-----------------
//#define TIMES_DETAILED (sin(time*32.0)+1.0)
#define TIMES_DETAILED (1.0+.1*sin(time*PI*1.0))
#define SPIRAL_BLUR_SCALAR (1.0+.1*sin(time*PI*1.0))
//-----------------USEFUL-----------------

#define MOUSE_X (iMouse.x/iResolution.x)
#define MOUSE_Y (iMouse.y/iResolution.y)

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
	vec2 a = sin(seedling+vec2(time, time*GR/E))*10.0;
	vec2 b = sin(seedling+vec2(time, time*GR/E))*10.0;
	vec2 c = sin(seedling+vec2(time, time*GR/E))*10.0;
	vec2 d = sin(seedling+vec2(time, time*GR/E))*10.0;
	return cdiv(cmul(uv, a) + b, cmul(uv, c) + d);
}

vec2 map(vec2 uv)
{
    vec2 mob = mobius(zoom*(uv*2.0-1.0));
    
    return saw(mob*2.0*PI);
}

vec2 spiral(vec2 uv)
{
    float turns = 4.0;
    float r = length(uv);
    float theta = atan(uv.y, uv.x)*turns-r*PI*2.0;
    return vec2(saw(r*PI),
                saw(theta));
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
    
    
   	const int max_i =16;
    float stretch = 1.0;
    float ifs = 1.0;
    float ifsSqrt = 1.0;
    float depth = 0.0;
    float magnification;
    int last_i;
    seedling = 0.0;
    vec3 final;
    
    for(int i = 0; i < max_i; i++)
    {
        last_i = i;
        
        float iteration = saw(time*4.0)*float(max_i);
        
        float fade = i == max_i-1 ? 1.0-fract(iteration) : 1.0;
        
        seedling += fract(float(i)*123456.123456);
        
        vec2 next = iterate(uv, .5/iResolution.xy, magnification);
        
        float weight = ifs;
        
        ifs *= smoothstep(0.0, 1.0/TIMES_DETAILED, sqrt(1.0/(1.0+magnification)));
        
        ifsSqrt = sqrt(ifs);
        
        uv = next*weight+uv*(1.0-weight);
        
        float delta = sphereN(uv*2.0-1.0).z*ifsSqrt;
        depth += fade*(1.0-delta)*ifs;
        
		if(ifs != 0.0)
        {
            uv = spiral(uv*2.0-1.0);//*clamp(pow(delta, SPIRAL_BLUR_SCALAR)*2.0, 0.0, 1.0);
        }
        
        ifs = ifsSqrt;
        
        seedling += saw(atan(uv.y*2.0-1.0, uv.x*2.0-1.0));
        seedling += depth;
        
        float shift = time;

        float stripes = depth*PI*5.0*ifs*(sin(time)+2.0);
        float black = smoothstep(0.0, .25, saw(stripes))*ifs/float(i+1);
        float white = smoothstep(0.75, 1.0, saw(stripes))*ifs/float(i+1);


        final += (
            vec3(saw(depth*PI*2.0+shift),
                 saw(4.0*PI/3.0+depth*PI*2.0+shift),
                 saw(2.0*PI/3.0+depth*PI*2.0+shift)
                )
        )*black
            +white;
        //if(mod(iGlobalTime, float(max_i))-float(i) < 0.0) break;
    }
    
    
    fragColor = vec4(uv, 0.0, 1.0);
    
    //depth /= float(last_i+1.0);
    
    fragColor = vec4(vec3(ifs), 1.0);
    
    fragColor = vec4(saw((depth)));
    fragColor = vec4(final/2.0, 1.0);
}
