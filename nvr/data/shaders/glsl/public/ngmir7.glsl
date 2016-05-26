// Shader downloaded from https://www.shadertoy.com/view/MtXXRf
// written by shadertoy user netgrind
//
// Name: ngMir7
// Description: shitty lil dither
//    mouse x to fuck with the number
//    play with the steps define perhaps?
#define steps 2.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 c = texture2D(iChannel0,uv);
    float g = max(c.r,max(c.g,c.b))*steps;
    float fuck = 345.678+iMouse.x;
    float f = mod((uv.x+uv.y+500.)*fuck,1.);
    if(mod(g,1.0)>f)
        c.r = ceil(g);
    else
        c.r = floor(g);
    c.r/=steps;
	fragColor = c.rrra;
}