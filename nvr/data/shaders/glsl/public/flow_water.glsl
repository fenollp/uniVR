// Shader downloaded from https://www.shadertoy.com/view/XdtGR2
// written by shadertoy user DeMaCia
//
// Name: flow water
// Description: press down Numeric Keys ('1') 

#define KEY_1 49
#define KEY_2 50

bool keyToggle(int ascii)
{
    return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.1);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    if (keyToggle(KEY_1))
    {
    	vec2 t = texture2D(iChannel1, uv).gb;
    	//uv.y += ((t.x/t.y)+iGlobalTime*1.2)*.04;
        uv.xy += ((t.xy-.5)*.04);
        uv.y += iGlobalTime*.08 + .01*sin(iGlobalTime*.4);
        
    }
    else
    {
        
        vec2 t = texture2D(iChannel1, uv).gb;
        float noise = (t.x/t.y)+
            			iGlobalTime*-.025+
            			.01*sin(iGlobalTime);
        uv += vec2(noise*.4);
    }
    
    fragColor = vec4(texture2D(iChannel0, uv));
}




