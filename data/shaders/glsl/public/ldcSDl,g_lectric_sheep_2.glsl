// Shader downloaded from https://www.shadertoy.com/view/ldcSDl
// written by shadertoy user vox
//
// Name: G-Lectric Sheep 2
// Description: G-Lectric Sheep 2
//-----------------USEFUL-----------------

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875
#define EPS .001

#define time ((saw(float(__LINE__))+1.0)*(iGlobalTime+12345.12345)/PI/2.0)
#define saw(x) (acos(cos(x))/PI)

//-----------------IMAGINARY-----------------

vec2 cmul(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x - v1.y * v2.y, v1.y * v2.x + v1.x * v2.y);
}

vec2 cdiv(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x + v1.y * v2.y, v1.y * v2.x - v1.x * v2.y) / dot(v2, v2);
}

//-----------------RENDERING-----------------

float seedling;

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
    return saw(mobius(uv*2.0-1.0)*1.0*PI);
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
    //vec2 fbdim = vec2(851.0, 315.0); //Facebook cover photo dimensions.
    vec2 fbdim = iResolution.xy;
    float fbaspect = fbdim.y/fbdim.x;
   
    vec2 uv = fragCoord.xy-iResolution.xy/2.0;
    
    if(abs(uv.x) > fbdim.x/2.0 || abs(uv.y) > fbdim.y/2.0)
        discard;
    
    float zoom = (3.0+2.0*sin(time))*PI;
    
    uv = uv.xy / (iResolution.xy/2.0-fbdim.xy);
    uv.x *= fbaspect;
    uv *= zoom;
    uv = uv*.5+.5;
    
   	const int max_i = 16;
    float stretch = 1.0;
    float ifs = 1.0;
    float sum = 0.0;
    float magnification;
    float noise = 1.0;
    
    for(int i = 0; i < max_i; i++)
    {
        seedling = fract(float(i)*123456.123456);
        vec2 next = iterate(uv, .5/fbdim, magnification);
        
        //omg so platform dependent... pls help fix:
        float weight = smoothstep(0.0, 1.0, ifs);
        
        ifs *= sqrt(1.0/(1.0+magnification));
        
        noise = min(noise, ifs);
        
        uv = next*weight+uv*(1.0-weight);
        
        sum += (pow(clamp(1.0-length(uv*2.0-1.0), 0.0, 1.0), .5))*noise;
        
		if(ifs == 0.0)
            break;
        
        //if(mod(iGlobalTime, float(max_i))-float(i) < 0.0) break;
    }
    
    fragColor = vec4(uv, 0.0, 1.0);
    
    //sum /= float(max_i);
    float shift = time;

    vec3 final = (
        				vec3(saw(sum*PI*2.0+shift),
                	  		saw(4.0*PI/3.0+sum*PI*2.0+shift),
                	  		saw(2.0*PI/3.0+sum*PI*2.0+shift)
                 		)
        		 )*smoothstep(0.0, .25, saw(sum*PI*3.0+time*5.0))+ifs;
    
    fragColor = vec4(vec3(ifs), 1.0);
    
    fragColor = vec4(final, 1.0);
}
