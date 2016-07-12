// Shader downloaded from https://www.shadertoy.com/view/4slXR4
// written by shadertoy user FabriceNeyret2
//
// Name: the aliasing side
// Description: Mouse.x to tune the power
//    C toggles colors
bool keyToggle(int ascii) 
{ return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.); }


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = 2.* (fragCoord.xy / iResolution.y - vec2(.85,.5));
	vec2 mouse = iMouse.xy / iResolution.xy;
	if (iMouse.z<=0.) mouse.x = .5;
	
	float r = length(uv); 
	
	float n = 4.*mouse.x;
	//float n = floor(uv.x*3./2.)/3.+floor(uv.y*3./2.);
	
	float k = .1* iResolution.y/1.5;
	float l = k*pow(r,n);
	float c =100.*sin(.1*iGlobalTime)*l;
	
	vec3 col;
	if (keyToggle(67))
		col = vec3(sin(c));
	else
		col = vec3(sin(c),sin(1.002*c),sin(1.004*c));
	
	fragColor = vec4(col,1.);
}