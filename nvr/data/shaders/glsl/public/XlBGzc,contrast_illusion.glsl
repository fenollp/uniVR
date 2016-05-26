// Shader downloaded from https://www.shadertoy.com/view/XlBGzc
// written by shadertoy user FabriceNeyret2
//
// Name: Contrast illusion
// Description: all the diamonds are identical.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv0 = fragCoord.xy / iResolution.y, uv = -.1+1.2*uv0;
    vec2 m = iMouse.xy / iResolution.xy;
    float v = 6.,c=.5;

    uv *= mat2(-1.,.5,1.,.5);
    
    if (uv0.x>  (1.-cos(iGlobalTime/4.))*.5*iResolution.x/iResolution.y)
        c = (1.+floor(uv.x*v)+floor(uv.y*v))/(v);

    if ((c>0.) && (c<1.)) {
	    c = .5*(fract(uv.x*v)+fract(uv.y*v));
    	//c = .5 + .2*(2.*c-1.);
    }
    
	fragColor = vec4(c);
}