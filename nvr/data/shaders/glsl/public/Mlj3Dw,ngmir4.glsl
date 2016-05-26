// Shader downloaded from https://www.shadertoy.com/view/Mlj3Dw
// written by shadertoy user netgrind
//
// Name: ngMir4
// Description: glitchey
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float i = iGlobalTime;
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 c = texture2D(iChannel0,uv)*2.0;
    uv.xy+=c.bg*(iMouse.x/iResolution.x-.5);
    uv-=.5;
    float a = atan(uv.y,uv.x);
    float d = length(uv);
    a+=c.r*(iMouse.y/iResolution.y-.5)*12.0;
    uv.x = cos(a)*d;
    uv.y = sin(a)*d;
    uv+=.5;
    c = texture2D(iChannel0,uv)*2.0;
	fragColor = c;
}