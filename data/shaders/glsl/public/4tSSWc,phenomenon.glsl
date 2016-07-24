// Shader downloaded from https://www.shadertoy.com/view/4tSSWc
// written by shadertoy user Sgw32
//
// Name: Phenomenon
// Description: Will be used in my game &quot;The Long Way&quot;. Based on scope shader code.
// Public Domain license

#define SIZE 3.


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float time = iGlobalTime;
    time = mod(time, 5.);
    
    
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	vec3 color = vec3(0.0, 0.0, 0.0);
    
    
	float piikit  = 0.5+asin(sin(SIZE*uv.x*6.28))/5.;
    
    
    if (uv.x<(1./(SIZE)))
    {
            piikit=0.5;
    }  
    
    
    if (uv.x>(1.-1./(SIZE)))
    {
            piikit=0.5;
    }    
    
    float x1 = uv.x*2.;
    //float xt = time/10.;
    float pos = 2.+8.*pow(time,4.);
    float xx = -pow((uv.x*pos-pos/2.),8.);
    //xx=-pow(xx,2.);
    
    //piikit=1.-exp(xx);
    
	float flash = 1.-exp(xx);
                
	float glow = (flash*0.02)/abs(piikit - uv.y);
                
	color = vec3(0.0, glow*0.5, 0);
	color += vec3(sqrt(glow*0.2));
	
	
	fragColor = vec4(color, 1.0);
}