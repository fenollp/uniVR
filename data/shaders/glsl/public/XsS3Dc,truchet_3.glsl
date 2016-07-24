// Shader downloaded from https://www.shadertoy.com/view/XsS3Dc
// written by shadertoy user FabriceNeyret2
//
// Name: truchet 3
// Description: variations upon https://www.shadertoy.com/view/4d2GzV
//    B: toggles border vs plain
//    C: toggles colors vs B&amp;W
//    I: toggles inverse colors
//    H: toggles saturation
// inspired from https://www.shadertoy.com/view/4d2GzV#

#define NB 10

const float s3 = 1.7320508075688772/2.;  // sqrt(3)/2
const float i3 = 0.5773502691896258;     // 1/sqrt(3)
const mat2 tri2cart = mat2(1., 0.,   -.5,    s3);
const mat2 cart2tri = mat2(1., 0.,    i3, 2.*i3);

float t = iGlobalTime;

bool keyToggle(int ascii) 
{
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}


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

float pattern(vec2 d,float s)
{ return min(min(distance(d, vec2(-s  , 0.)), 
				 distance(d, vec2(s*.5, s3))), 
			     distance(d, vec2(s*.5,-s3)));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	
	float scl = .02*(1.3-1.*cos(.31*t)) * 200./iResolution.y;
	float cx = 2. * cos(t*.3) + 1.0 * cos(t*0.7+2.);
	float cy = 4. * sin(t*.4) + 0.3 * sin(t*1.2+4.);
	float theta = .05*t;
		
	vec2 pos = (fragCoord.xy - .5*iResolution.xy)*scl + vec2(cx, cy);
	
	float ct = cos(theta), st = sin(theta);
	
	float v=0., a=0.,  q=1.; vec3 col=vec3(0.);
	for (int i=0; i<NB; i++)
	{
		vec2 pos2  = mat2(ct, -st, st, ct) * (pos+vec2(10.,0.));
		vec4 h = closestHexCenters(cart2tri*pos2);
		vec2 q1 = tri2cart * h.xy;
		float s = 2.*step(rnd(h.xy), 0.5) - 1.;
		pos2 -= q1;
		vec2 delta = 0.01*vec2(1.,0.);
		float l  = pattern(pos2          ,s);
		float lx = pattern(pos2+delta.xy ,s);
		float ly = pattern(pos2+delta.yx ,s);
		float r  = smoothstep(.1+2./q*scl, .1, abs(l-.5));
		float rx = smoothstep(.1+2./q*scl, .1, abs(lx-.5));
		float ry = smoothstep(.1+2./q*scl, .1, abs(ly-.5));
		float dr = length(vec2(rx-r,ry-r)*10.);

		float c = q * ((!keyToggle(66)) ? dr : r);
		if (keyToggle(72)) c = clamp(c,0.,1.);

		if (!keyToggle(67)) {
			vec3 t = texture2D(iChannel1,h.xy/1000.).rgb;
			col = mix(col, vec3(1.), (1.-a)*c*t); 
			col = clamp(col,0.,1.);
		}
		else {
			v = mix(v,1., (1.-a)*c); 
			v = clamp(v,0.,1.);
		}
		a = mix(a,1., c);  a = clamp(a,0.,1.);

		pos *= 2.; q /= 1.5;
	}
	
	if (keyToggle(67)) col = vec3(v);
	if (keyToggle(73)) col = 1.-col;
	
	fragColor = vec4(col,1.);
	
}
