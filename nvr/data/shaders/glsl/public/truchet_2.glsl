// Shader downloaded from https://www.shadertoy.com/view/4dS3Dc
// written by shadertoy user FabriceNeyret2
//
// Name: truchet 2
// Description: truchet variation on https://www.shadertoy.com/view/4d2GzV#
// inspired from https://www.shadertoy.com/view/4d2GzV#

const float s3 = 1.7320508075688772/2.;  // sqrt(3)/2
const float i3 = 0.5773502691896258;     // 1/sqrt(3)
const mat2 tri2cart = mat2(1., 0.,   -.5,    s3);
const mat2 cart2tri = mat2(1., 0.,    i3, 2.*i3);

float t = iGlobalTime;

vec4 pick3(vec4 a, vec4 b, vec4 c, float u) {
	float v = fract(u/3.);
	return mix( mix(a, b, step(.3, v)), c, step(.6, v));
}

vec4 closestHexCenters(vec2 p) {
	vec2 pi = floor(p), pf = fract(p);

	vec4 nn = pick3(vec4(0., 0., 2.,  1.),
					vec4(1., 1., 0., -1.),
					vec4(1., 0., 0.,  1.),
					pi.x + pi.y);
	
	return ( mix(nn, nn.yxwz, step(pf.x, pf.y)) + vec4(pi,pi));	
}

float rnd(vec2 pos) {
	return texture2D(iChannel0, fract(pos/511.)).x;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	
	float scl = .02*(1.3-1.*cos(.31*t)) * 200./iResolution.y;
	
	float cx = 2. * cos(t*.3) + 1.0 * cos(t*0.7+2.);
	float cy = 4. * sin(t*.4) + 0.3 * sin(t*1.2+4.);
	float theta = .05*t;
		
	vec2 pos = (fragCoord.xy - .5*iResolution.xy)*scl + vec2(cx, cy);
	
	float ct = cos(theta), st = sin(theta);
	
	float v=0., q=1.; vec4 col=vec4(0.);
	for (int i=0; i<10; i++)
	{
		vec2 pos2  = mat2(ct, -st, st, ct) * pos;
		vec4 h = closestHexCenters(cart2tri*pos2);
		vec2 q1 = tri2cart * h.xy;
		float s = 2.*step(rnd(h.xy), 0.5) - 1.;
		vec2 d1 = pos2 - q1;
		float l = min(min(distance(d1, vec2(-s  , 0.)), 
						  distance(d1, vec2(s*.5, s3))), 
					      distance(d1, vec2(s*.5,-s3)));
		float r = smoothstep(.1+scl, .1, abs(l-.5));
		col = 1.- (1.-col)*(1.-q*r*texture2D(iChannel1,h.xy/1000.));
		v = 1.- (1.-v)*(1.-q*r);
		pos *= 2.; q /= 1.5;
	}
	
	fragColor = vec4(col);
	
}
