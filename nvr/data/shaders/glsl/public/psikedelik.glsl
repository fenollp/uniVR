// Shader downloaded from https://www.shadertoy.com/view/XdfGRs
// written by shadertoy user FabriceNeyret2
//
// Name: psikedelik
// Description: cosines are just lovely functions :-D
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float t = iGlobalTime;
	vec2 p = (fragCoord.xy / iResolution.y-vec2(.8,.5))*2.;
	vec2 m = (iMouse.xy/iResolution.y-vec2(.8,.5))*2.;
	vec3 col = vec3(0.);
	vec2 q = 1.*vec2(cos(t),sin(t));

	col += cos(40.*distance(p,q))   *vec3(1.,.5,.2);
	col += cos(37.*distance(p,q*q)) *vec3(.2,.5,1.);
	col += cos(32.*distance(p,m))   *vec3(.5,1,.2);
	col += cos(43.*distance(p,m*m)) *vec3(.2,1,.5);
	col += cos(46.*distance(p,m*q)) *vec3(.1,1.,1.);

	col *= cos(10.*length(col));
	fragColor = vec4(col,1.0);
}