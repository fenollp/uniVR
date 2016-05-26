// Shader downloaded from https://www.shadertoy.com/view/lts3Rf
// written by shadertoy user dzira
//
// Name: gritty sound
// Description: My first sound, don't really know what I'm doing or what's 'correct', mostly messing around. (is there a way to reference sound code in image without copy paste?)
//edit: changed it to be more correct, messing around (real messy) then using x/(1+|x|) to get it in range
float hash( float n )
{
    return fract(sqrt(abs(n))*3734.421891);
}
vec2 mainSound(float time)
{
    float t = mod(time,.6);
    vec2 b = vec2(sin(.125*6.2831*440.0*.8*t));
    b += 0.5+(.4+t)*vec2((t/2.+.5)*sin(.5*6.2831*440.0*.5*t)*1./t*.08/exp(-3.0*t))+.2*(sin(4.*time));;
    vec2 huv = floor(t*40.+80.*vec2(sin(t/2.),cos(t/2.)));
    vec2 x = vec2(hash(fract(hash(.213*huv.x+.5*huv.y)+hash(.73*huv.y+7.))));
    b = b*2.-1.5;
    x = 2.*(x-1.);
    x=b+.4*sin(time)*x;
    x=(sin(time*3.14)+.5)*x+b;
    x=x/(1.+abs(x));
    return x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = vec2(.6,6.)*(fragCoord.xy - iResolution.xy/2.) / iResolution.y;
    uv.x += iGlobalTime;
    vec2 s = mainSound(uv.x);
    float w = clamp(floor(s.x/uv.y), 0.,1.0);
	fragColor = vec4(w,w,w,1.0);
}
