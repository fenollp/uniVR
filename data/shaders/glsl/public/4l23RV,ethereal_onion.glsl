// Shader downloaded from https://www.shadertoy.com/view/4l23RV
// written by shadertoy user Aj_
//
// Name: Ethereal onion
// Description: An onion I came up with while learning stuff
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	
    
    vec2 res = iResolution.xy/abs(2./sin(iGlobalTime/4.));
	vec2 position = ( (fragCoord.xy - vec2(iResolution.x/2., iResolution.y/2.)) / max(res.y, res.x)  ) ;
	mat2 rot;
	float ang = -45. * 0.0174532925;
	rot[0] = vec2(cos(ang), -sin(ang));
	rot[1] = vec2(sin(ang), cos(ang));	
	position*=rot;
	float x = position.x;
	float y = position.y;
	float u,t;
	
	for(int i=0;i<60;i++) {
		u = x*y*y  - y*y+x +.008 ;
		t = y*x*x  - x*x+y +.008 ;
		
		
		x = u;
		y = t;
		if(dot(vec2(u,t), vec2(u,t))>.08) {
			break;
		}
		
	}
	
	vec3 color =  vec3((x*y))*100.;

	fragColor = vec4(vec3(color.x/8., color.y/4., color.z/4.), 1.);
}