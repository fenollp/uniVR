// Shader downloaded from https://www.shadertoy.com/view/XsySRz
// written by shadertoy user florent_baudon
//
// Name: FB_Algua
// Description: algua
//effet algue
float amp = 0.1; //amplitude
float speed = 1.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv.y = 1.0-uv.y;
    
	float xpos = uv.x+(1.0-uv.y)*amp*sin(uv.y+iGlobalTime*speed);
	
    vec4 t = texture2D(iChannel0, vec2(xpos, uv.y));
    
    
    fragColor = t;
}