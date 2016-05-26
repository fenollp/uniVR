// Shader downloaded from https://www.shadertoy.com/view/4sBGD3
// written by shadertoy user FabriceNeyret2
//
// Name: cylinder perception
// Description: a classical experiment to study how eye perceive shape and motion
vec2 FragCoord;

vec2 offset(vec2 uv,float sgn)
{
	float ang = acos(1.*2.*(FragCoord.x/iResolution.x-.5));
	return vec2(ang,uv.y+sgn*sin(ang));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.y;
    FragCoord=fragCoord;
	float ZOOM = iResolution.y/256.;
	vec3 col;
	vec2 pos = .2*iGlobalTime*vec2(1.,0.);
	col = smoothstep(.5,1.,texture2D(iChannel0,ZOOM*(offset(uv,1.)+pos)).rgb);
	col += .5*smoothstep(.5,1.,texture2D(iChannel0,ZOOM*(offset(uv,-1.)-pos)).rgb);
	fragColor = vec4(2.*col,1.0);
}
