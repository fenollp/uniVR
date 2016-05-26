// Shader downloaded from https://www.shadertoy.com/view/4ddXDX
// written by shadertoy user vox
//
// Name: Cellular Activity
// Description: CAUTION: BIOHAZARDOUS

#define PI 3.14159265359
#define E 2.7182818284
#define GR 1.61803398875

#define time ((saw(float(__LINE__))*.001+1.0)*iGlobalTime+100.0)
#define saw(x) (acos(cos(x))/PI)


vec2 cmul(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x - v1.y * v2.y, v1.y * v2.x + v1.x * v2.y);
}

vec2 cdiv(vec2 v1, vec2 v2) {
	return vec2(v1.x * v2.x + v1.y * v2.y, v1.y * v2.x - v1.x * v2.y) / dot(v2, v2);
}

vec2 tree(vec2 uv, vec2 multa, vec2 offa, vec2 multb, vec2 offb)
{
	return cdiv(cmul(uv, multa) + offa, cmul(uv, multb) + offb);
}

vec3 phase(float map)
{
    return vec3(saw(map),
                saw(4.0*PI/3.0+map),
                saw(2.0*PI/3.0+map));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    float scale = (1.0+0.5*sin(time/PI));
    uv = uv*scale-scale/2.0;
    uv.x *= iResolution.x/iResolution.y;
    
    float r = length(uv);

    
    float map = 0.0;
    float noise = 1.0;
    
	const int max_iterations = 4;
    
    vec2 multa, multb, offa, offb;

    for(int i = 0; i < max_iterations; i++)
    {
        float iteration = float(i)/float(max_iterations);
        
        
        multa = cos(vec2(time*.1, time*.2)+iteration*PI);
        offa = cos(vec2(time*.3, time*.4)+iteration*PI)*0.0;
        multb = cos(vec2(time*.5, time*.6)+iteration*PI)/PI;
        offb = cos(vec2(time*.7, time*.8)+iteration*PI)/PI;
        
        uv = tree(uv, multa, offa, multb, offb);
        float dist = length(uv);
        uv = saw(uv)*2.0-1.0;
        map += pow(clamp(1.0-length(uv), 0.0, 1.0), .5);    
        noise *= clamp(1.0-length(fwidth(uv)), 0.0 ,1.0)*
            	 clamp(1.0-fwidth(map), 0.0 ,1.0);
        
    }
    
    fragColor = vec4(phase(map*2.0*PI+time), 1.0)*clamp(map, 0.0, 1.0);
    
    //fragColor = vec4(uv, 0.0, 1.0);
}