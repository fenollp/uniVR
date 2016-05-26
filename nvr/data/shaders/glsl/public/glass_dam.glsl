// Shader downloaded from https://www.shadertoy.com/view/ls3SDf
// written by shadertoy user cyberkm
//
// Name: Glass Dam
// Description: Just got bored and saw https://www.shadertoy.com/view/ld3XWf :)
const vec3 keyColor = vec3(0.051,0.639,0.149);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;     
    vec3 colorDelta = texture2D(iChannel0, uv).rgb - keyColor.rgb;
    
    float factor = length(colorDelta); 
        
    uv += (factor * colorDelta.rb) / 8.0;    
    fragColor = texture2D(iChannel1, uv, factor * 1.5);
        
}

