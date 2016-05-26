// Shader downloaded from https://www.shadertoy.com/view/XlsGDS
// written by shadertoy user netgrind
//
// Name: ngWaves04
// Description: see line 9/10 for some mouse control
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float j = 10.0;
    float i = iGlobalTime*0.5;
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv-=0.5;
    float a = atan(uv.y/uv.x);
    
    //vec2 p = iMouse.xy/ iResolution.xy;
    vec2 p = vec2(sin(i),cos(i))*0.3+0.5;
    
    float d = distance(uv,p-.5)*j;
    float d2 = distance(uv,1.0-p-.5)*j;
    
    vec4 c = vec4(0.0);
    c.b = sin((a+d)*j+i);
    c.g = sin((a+d2)*j+i);
    c.r = cos((a+d+d2)*j+i);
    
    c = vec4(sin(c.r+i)*0.5+0.5,sin(c.b-i*0.5)*0.5+0.5,cos(c.g+i*0.66)*0.5+0.5,1.0);
    
	fragColor = c;
}