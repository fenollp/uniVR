// Shader downloaded from https://www.shadertoy.com/view/4lsSz2
// written by shadertoy user athlete
//
// Name: Psychodelic Circles
// Description: playing around with concentric circles - pro tip: listen to deep progressive house while watching ;)
const bool mixWithTexture = true;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    //screen centre
	vec2 centre = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
	float l = length(centre); //distance from centre

    //change ring amplitude and phase
    float phase = 15.0*abs(sin(iGlobalTime*0.25));
    float amp = 3.0*sin(iGlobalTime*0.1)+0.2;
    
    //concentric rings
	vec2 p = (centre/l)*sin(l*phase-iGlobalTime*3.0)*amp;

    //blue color shift
    float b = 0.3*abs(sin(iGlobalTime*0.06));
    
    vec3 col;
    if(mixWithTexture)
    {    
    	//mix with texture
    	vec2 uv = fragCoord.xy/iResolution.xy+p;
    	vec3 col1 = texture2D(iChannel0, uv).xyz;
        //vec3 col2 = texture2D(iChannel1, uv).xyz;        
        //vec3 col1 *= col2;

		col.r = min(col1.r*2.0, p.x);
    	col.g = min(col1.g*2.0, p.y);
    	col.b = min((col1.r + col1.g + col1.b)*0.2, b);
    }
    else
        col = vec3(p, b);
    
	fragColor = vec4(col, 1.0);
}