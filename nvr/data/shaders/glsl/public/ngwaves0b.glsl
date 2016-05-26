// Shader downloaded from https://www.shadertoy.com/view/4tSGRz
// written by shadertoy user netgrind
//
// Name: ngWaves0B
// Description: noisey waves
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xx);
    uv.x -=.5;
    vec4 c = vec4(1.0);
    vec3 a = vec3(atan(uv.y,uv.x));
    vec3 d = vec3(length(uv));
    a.g+=.025;
    a.b+=.05;
    vec3 coord = d*.5-sin(iGlobalTime*.4)*.5+.5+sin(a*50.0*sin(a*3.0+iGlobalTime)*50.0)*d;
    c.rgb = abs(fract(coord-0.5)-0.5)/fwidth(coord*1.0);
    c.rgb = 1.0-min(c.rgb,1.0);
	fragColor = c;
}