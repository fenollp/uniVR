// Shader downloaded from https://www.shadertoy.com/view/ldBGDc
// written by shadertoy user FabriceNeyret2
//
// Name: look me in the eyes
// Description: look at the center for 1 minute, then press SPACE
//    
//    T: toggles rotation direction     S: stop/go
//    2: 2 spirals (mouse location)   R: reverse orientation   T : opposite rotation
//    
float t = iGlobalTime;

bool keyToggle(int ascii) {
	return (texture2D(iChannel1,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

float spiral(vec2 m) {
	float r = length(m);
	float a = atan(m.y, m.x);
	float v = sin(100.*(sqrt(r)-0.02*a-.3*t));
	return clamp(v,0.,1.);

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	if (keyToggle(84)) t=-t; // 'T'
	if (keyToggle(83)) t=0.; // 'S'

	vec2 uv = fragCoord.xy / iResolution.y;
	
	vec2 m = iMouse.xy/ iResolution.y;
	if ((length(m)==0.) || (iMouse.z<0.)) m = vec2(.9,.5);

	float v = spiral(m-uv);
	if (keyToggle(50)) {     // '2'
		m = vec2(.9,.5);
		if (!keyToggle(82)) uv.y = 1.-uv.y;  // 'R'
		if (!keyToggle(84)) t = -t;          // 'T'
		v += (1.-v)*spiral(m-uv);
	}

	uv = fragCoord.xy / iResolution.xy;
	vec3 col = (keyToggle(32)) ? texture2D(iChannel0,1.-uv).rgb : vec3(v);
	
	fragColor = vec4(col,1.);
}