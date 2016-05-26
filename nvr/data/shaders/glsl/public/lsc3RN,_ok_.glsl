// Shader downloaded from https://www.shadertoy.com/view/lsc3RN
// written by shadertoy user rbrt
//
// Name: +OK_
// Description: ...OK
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec4 video = texture2D(iChannel0, uv);
    
    fragColor = video;
    const float iterationStep = .01;
    for (float i = 0.0; i < 1.0; i += iterationStep){
        
        if (distance(fragColor, vec4(0,0,0,0)) < 1.6 - 
            (sin(iGlobalTime) + 1.0) / 2.0)
        {
	        fragColor += texture2D(iChannel0, uv / i) * i;    
        }
        else{
        	fragColor -= texture2D(iChannel0, uv / i) * i;    
        }
    	
    }
	
}