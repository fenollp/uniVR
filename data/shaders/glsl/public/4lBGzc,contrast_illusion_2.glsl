// Shader downloaded from https://www.shadertoy.com/view/4lBGzc
// written by shadertoy user FabriceNeyret2
//
// Name: Contrast illusion 2
// Description: Constrast disappear if boundary disappears.
//    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    //vec2 m = iMouse.xy /  iResolution.xy;
    vec2 m = vec2(fract(floor(.6+iGlobalTime/2.)/5.));
    float c = floor(uv.x*5.)/5.; c = .3+.4*c;
    if (abs(m.x-uv.x)<.03) 
        fragColor = vec4(1.,0.,0.,0.);
    else	
		fragColor = c*vec4(.8,.9,1.1,1.);
}