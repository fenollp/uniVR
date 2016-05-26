// Shader downloaded from https://www.shadertoy.com/view/llSGzW
// written by shadertoy user netgrind
//
// Name: ngWaves0E
// Description: mouse x for cybertek dither
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime;
	vec2 uv = fragCoord.xy / iResolution.xy*2.0-1.0; 
    vec4 c = vec4(1.0);
    float d = length(uv);
    float a = atan(uv.y,uv.x)+sin(i*.2)*.5;
    uv.x = cos(a)*d;
    uv.y = sin(a)*d;

    d-=i;
    uv.x+=sin(uv.y*2.+i)*.1;    
    uv += sin(uv*1234.567+i)*iMouse.x*.0005;
    c.r = abs(mod(uv.y+uv.x*2.*d,uv.x*1.1));
    
	fragColor = c.rrra;
}