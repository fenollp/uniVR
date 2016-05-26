// Shader downloaded from https://www.shadertoy.com/view/4syGzw
// written by shadertoy user Flyguy
//
// Name: SSTV Encoder WIP (Loud)
// Description:  A WIP Martin M2 Slow Scan Television (SSTV) encoder. 
//    The image can be decoded using software such as MMSSTV and should look something like this : http://i.imgur.com/bY4sMMI.png (Quality may vary).
float tau = atan(1.0)*8.0;

vec3 Image(vec2 uv)
{
    vec3 color = vec3(0);
    
    float split = 0.5 + sin(uv.y * tau * 2.0) * 0.25;
    
    if(uv.x > split)
    {
    	color = mix(vec3(1,0,0), vec3(0,1,0), uv.y);	   
    }
    else
    {
    	color = mix(vec3(1,1,0), vec3(0,0,1), uv.y);   
    }
    
    color = mix(color, vec3(1.0), 1.0-step(0.1, length(uv - 0.5)));
    
    if(uv.y < 0.1)
    {
    	color = vec3(step(0.5,fract(uv.x*uv.x*32.0)));   
    }
    
	return color;   
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 res = iResolution.xy / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.y;
    uv.x += (1.0-res.x)/2.0;
    
    vec3 color = Image(uv);
    
    color *= step(0.0, uv.x) - step(1.0, uv.x);
	fragColor = vec4(color, 1.0);
}