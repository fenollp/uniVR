// Shader downloaded from https://www.shadertoy.com/view/XllGzl
// written by shadertoy user netgrind
//
// Name: ngWaves00
// Description: simple phasing waves
#define PI 3.14159
#define TWO_PI (PI*2.0)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv-=0.5;
    uv*=40.0;
    
    float a = atan(uv.y,uv.x);
    mat2 hyper = mat2(
       -cos(a), sin(a), 
       sin(a), cos(a)
    );
    uv = abs(mod(uv*hyper+iGlobalTime,vec2(2.0))-1.0);
	
	fragColor = vec4(0.5+0.5*cos(iGlobalTime*0.1),uv.x,0.5+0.5*sin(iGlobalTime),1.0);
}