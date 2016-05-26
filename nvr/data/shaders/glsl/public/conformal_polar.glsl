// Shader downloaded from https://www.shadertoy.com/view/lssSRj
// written by shadertoy user FabriceNeyret2
//
// Name: conformal polar
// Description: Mouse: move   SPACE: switch parametric / texture   T: time
//    A conformal space transform keeps local angles and proportions.
//    Here, polar transform is made conformal to avoid stretching in x at poles and in y at circumference (but sizes are not preserved).
float t = iGlobalTime;
#define Pi 3.1415927

bool keyToggle(int ascii) {
	return (texture2D(iChannel2,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec2 mouse = 2.*(iMouse.xy / iResolution.xy-vec2(.5,.5));
	
	float K = 2.*Pi*iResolution.y/iResolution.x;
	float r = exp(-K*uv.y)/(1.-exp(-K));
	float a = 2.*Pi*uv.x;
	
	vec2 tuv = vec2(.5,.5)+.5*r*vec2(cos(a),r*sin(a));
	vec4 col = vec4(0.);
	
	bool IMG = keyToggle(32);
	if (keyToggle(64+20)) t = 0.;
	
	if (IMG) {
		tuv += .5*mouse + .01*t;
		col = texture2D(iChannel0,tuv/vec2(iChannelResolution[0].x/iChannelResolution[0].y,1.));
	}
	else {
		tuv += .1*mouse + .01*t;;
		uv = pow(abs(sin(2.*Pi*tuv*10.)),vec2(7./r)); 	
		col.g = uv.x+uv.y;
		uv = pow(abs(sin(2.*Pi*tuv*50.)),vec2(7./r)); 
		col.r = (1.-col.g)*(uv.x+uv.y);
	}
	fragColor = col;
}