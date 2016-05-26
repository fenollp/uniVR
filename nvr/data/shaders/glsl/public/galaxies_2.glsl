// Shader downloaded from https://www.shadertoy.com/view/4syXRR
// written by shadertoy user vox
//
// Name: Galaxies 2
// Description: Galaxies 2
//-----------------SETTINGS-----------------
//#define TIMES_DETAILED (sin(time*32.0)+1.0)
#define TIMES_DETAILED (1.0+.1*sin(time*PI*1.0))
#define SPIRAL_BLUR_SCALAR 2.0
//-----------------USEFUL-----------------

#define MOUSE_X (iMouse.x/iResolution.x)
#define MOUSE_Y (iMouse.y/iResolution.y)

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS 1.0E-20

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
	vec2 a = sin(seedling+vec2(time, time*GR/E))*.1+.75;
	vec2 b = sin(seedling+vec2(time, time*GR/E))*.1+.3;
	vec2 c = sin(seedling+vec2(time, time*GR/E))*.1-.5;
	vec2 d = sin(seedling+vec2(time, time*GR/E))*.1-.5;
	return cdiv(cmul(uv, a) + b, cmul(uv, c) + d);
}

vec2 map(vec2 uv)
{
    return saw(mobius(zoom*(uv*2.0-1.0))*2.0*PI);
}

vec2 spiral(vec2 uv)
{
    return (1.0-saw(PI*(uv*.5+.5)));
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
    
    
   	const int max_i = 32;
    float ifs = 1.0;
    float depth = 0.0;
    float magnification;
    
    float shift = time*PI*10.0;

    float stripes;
    float black = 1.0;
        
    
    vec3 final = vec3(0.0);
    for(int i = 0; i < max_i; i++)
    {
        seedling += fract(float(i)*123456.123456);
        
        vec2 next = iterate(uv, .5/iResolution.xy, magnification);
        
        //omg so platform dependent... pls help fix:
        float weight = smoothstep(0.0, 0.75, ifs);
        
        ifs *= smoothstep(0.0, 1.0/TIMES_DETAILED, sqrt(1.0/(1.0+magnification)));
        
        uv = next*weight+uv*(1.0-weight);
        
        float delta = sphereN(uv*2.0-1.0).z*ifs;
        depth += (1.0-delta)*ifs;
        
    	stripes = depth*PI*iResolution.x;
    	black *= smoothstep(0.0, .75, saw(stripes));
        final += (
        				vec3(saw(depth*PI*2.0),
                	  		saw(4.0*PI/3.0+depth*PI*2.0),
                	  		saw(2.0*PI/3.0+depth*PI*2.0)
                 		)
        		 );
        
    }
    
    
    //fragColor = vec4(ifs);
    
    //depth /float(max_i);
    
    fragColor = vec4(vec3(ifs), 1.0);
    
    if(pow(ifs, 1.0/float(max_i))*depth*black > EPS)
    {
        ifs = 1.0;
        depth = 0.0;
        uv = fragCoord.xy/iResolution.xy;
        black = 1.0;
        final = vec3(0.0);
        discard;
    }
    black = smoothstep(0.0, .75, saw(stripes));
    float white = smoothstep(0.75, 1.0, saw(stripes))*black;
    fragColor = vec4(final*black/float(max_i)+white, 1.0);
}
