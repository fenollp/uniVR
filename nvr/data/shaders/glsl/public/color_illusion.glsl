// Shader downloaded from https://www.shadertoy.com/view/Xd2GRR
// written by shadertoy user FabriceNeyret2
//
// Name: color illusion
// Description: look fixly the white dot long enough, then toggle SPACE or MouseClic
float t = iGlobalTime;

bool keyToggle(int ascii) 
{
	return (texture2D(iChannel1,vec2((.5+float(ascii))/256.,0.75)).x > 0.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) 
{
	vec2 uv = fragCoord.xy / iResolution.y - vec2(.8,.5);
	float r = length(uv), a = atan(uv.y,uv.x);
	vec3 col;
	float zone = step(.75,1.-abs(uv.x))*step(.9,1.-abs(uv.y));
	float grid = sign(sin(400.*uv.x)*sin(400.*uv.y));

	if (r<.01*(1.+.5*sin(t))) 
		col=vec3(1.);
	else 
		if (keyToggle(32) || (iMouse.z>0.))  {
			// col = vec3(1.);
			col = vec3(texture2D(iChannel0,1.-fragCoord.xy/iResolution.xy).r);
		}
		else {
			if (zone==0.) {
				col = vec3(.5);
				if (min(abs(uv.x),abs(uv.y))<.003) col = vec3(0.);
			}
			else {
				// col = vec3(zone*(.5+.5*sin(60.*t)),0.,0.);
				col = vec3(zone*(.5+.5*grid*sin(60.*t)),0.,0.);
				if (uv.x<0.) col = col.brr;
			}
		}
	

	fragColor = vec4(col,1.0);
}