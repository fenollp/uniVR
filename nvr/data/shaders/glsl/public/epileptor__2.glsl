// Shader downloaded from https://www.shadertoy.com/view/ldXGDn
// written by shadertoy user WAHa_06x36
//
// Name: Epileptor #2
// Description: I am so very, very sorry.
//    
//    Do not run this in fullscreen. You have been warned.
//    
//    I should never have made this.
//    
//    (Tip: Try changing the music track, or close the browser tab.)
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv=fragCoord.xy/iResolution.xy;
	float s1=texture2D(iChannel0,vec2(uv.x,1.0)).x;
	float s2=texture2D(iChannel0,vec2(uv.y,1.0)).x;
	vec3 col=vec3(
	(texture2D(iChannel0,vec2(0.0,0.1)).x-0.5)*2.0,
	(texture2D(iChannel0,vec2(0.0,0.2)).x-0.5)*2.0,
	1.0);
	if(abs(s1-s2)<0.1) fragColor=vec4(vec3(1.0-abs(s1-s2)/0.1)*col,1.0);
	else fragColor=vec4(vec3(0.0),1.0);
}