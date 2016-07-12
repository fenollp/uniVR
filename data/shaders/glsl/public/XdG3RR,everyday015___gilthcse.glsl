// Shader downloaded from https://www.shadertoy.com/view/XdG3RR
// written by shadertoy user Makio64
//
// Name: Everyday015 - gilthcse
// Description: Everyday015 - gilthcse
//    Its friday night!!!!!!!!!!!!!!!!!!!! Have fun everyone!!!!!! :D
// Everyday015 - gilthcse
// by David Ronai - @Makio64
// heavy base on : https://www.shadertoy.com/view/lstGW2#
float rand1(in float a, in float b) { return fract((cos(dot(vec2(a,b) ,vec2(12.9898,78.233))) * 43758.5453));}
float rand2(float frag_x, float frag_y) { return fract(sin(frag_y+frag_x)*iGlobalTime+sin(frag_y-frag_x)*iGlobalTime);}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	float zoom = 0.; //abs(sin(iGlobalTime*3.))*.15;
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv.x = abs(uv.x-.5)+.5;
	uv += zoom/2.;
	uv = uv/(1.+zoom);
	vec2 p = uv;
	p.x = uv.y;
	p.y = 1.;
	vec4 t1 = texture2D(iChannel1, p);
	p.x /= 4.0;
	vec4 t2 = texture2D(iChannel1, p);
	t1.y -= (t1.y-0.5) * 0.5;
	t1.x += (t2.y-0.5) * 1.2;
	float shake = sin(rand2(t2.x, t1.x) * 0.5) * .001 * fract(t1.y * iResolution.y/(1.-zoom) / rand1(iGlobalTime, t2.x));
	shake += sin(shake - t1.r * t1.g) * t2.g * 0.14 * fract(uv.y * iResolution.y/(1.-zoom) / 2.0);
	shake *= .8;
	uv.x += shake / t1.g * 2.41;
	uv = mod(uv,1.);
	fragColor = texture2D(iChannel0, uv);
	float grey = (fragColor.r + fragColor.g + fragColor.b) / 2.1;
	fragColor.rgb += grey;
	fragColor.rgb *= .57;
	fragColor *= mix(fragColor, texture2D(iChannel2, 0.9 * uv * -150.0), shake * .09 * iGlobalTime / grey * 0.08) + t1;
	fragColor = mix(fragColor, texture2D(iChannel2, 0.9 * uv * -150.0), -shake * .09 * iGlobalTime / grey * 0.008);
}