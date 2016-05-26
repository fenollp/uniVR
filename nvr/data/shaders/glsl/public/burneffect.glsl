// Shader downloaded from https://www.shadertoy.com/view/4dtSzH
// written by shadertoy user Lawliet
//
// Name: BurnEffect
// Description: This is a burn effects
/**
 * 2016/3/15
 * Because I am a novice, so the effect and the code quality are not perfect.
 * Welcome to improve.
 *
 * 
 */


vec4 grid(vec2 fragCoord)
{
    vec2 index = ceil(fragCoord * 0.1);
   	
    return vec4(0.7 + 0.5*mod(index.x + index.y, 2.0));
}

vec4 alphaBlend( vec4 tc, vec4 bc)
{
	vec4 o;
	o.rgb = bc.rgb * (1.0 - tc.a) + tc.rgb * tc.a;
	o.a = 1.0 - (1.0 - tc.a) * (1.0 - bc.a);
	return o; 
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec4 mainColor = texture2D(iChannel0,uv);
    
    //I don't konw how to draw PerlinNoise,so user this.
    vec4 noiseColor = texture2D(iChannel1,uv);
    
    float percent = noiseColor.r + mod(iGlobalTime,20.0) * 0.1 - 0.8;
    
    percent = clamp(percent, 0.0, 1.0);
    
    vec4 gradientColor = texture2D(iChannel2,vec2(1.0 - percent,0));
    
    //0.7255-0.8745 1.0-0.0
    float alpha = clamp((percent - 0.8745) /(0.7255 - 0.8745), 0.0, 1.0);
    
   	fragColor = alphaBlend(gradientColor,mainColor);
    
    fragColor.rgb *= alpha;
    
    fragColor.a = alpha;
    
    fragColor = alphaBlend(fragColor,grid(fragCoord));
    
    //fragColor = alphaBlend(texture2D(iChannel2,uv),grid(fragCoord));
    
    //fragColor = alphaBlend(fragColor,vec4(0.0));
}