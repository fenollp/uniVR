// Shader downloaded from https://www.shadertoy.com/view/4ls3zs
// written by shadertoy user netgrind
//
// Name: ngMir0
// Description: see yr tru soul
//    mouse does stuff
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float ping = (iMouse.y+1.0)/iResolution.y;
    
    uv.x = 	mod(uv.x,ping*2.0);
    uv.x -=	ping;
    uv.x = 	abs(uv.x);
    uv.x += (iMouse.x+1.0)/iResolution.x*(1.0-ping);    
    
    vec4 c = texture2D(iChannel0,uv);
    
    uv.x *= 	-1.0;
    uv.x +=		ping;
    uv.x = 		abs(uv.x);
    
   	c += texture2D(iChannel0,uv);  
	fragColor = c*0.5;
}