// Shader downloaded from https://www.shadertoy.com/view/4lfGWs
// written by shadertoy user netgrind
//
// Name: ngSound0
// Description: post shader-wave
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = abs(uv-.5);
    float time = iGlobalTime-uv.x-uv.y;
    time = mod(time,60.0);
    float f = sin(6.2831*50.0*sin(time*2.0+cos(time*16.0)))*exp(-3.0*sin(time*8.0)*.5+.5);
    f *= floor(mod(time*8.0,2.0));
    f = cos(f*3.14)*.5+.5;
    f *= floor(mod(time*(sin(time)*20.0+80.0),2.0));
    f = clamp(1.0,-1.0,f);
	fragColor = vec4(f,0.0,0.5+0.5*sin(iGlobalTime+uv.x*uv.y*20.0),1.0);
}