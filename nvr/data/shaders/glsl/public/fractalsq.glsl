// Shader downloaded from https://www.shadertoy.com/view/lt23RK
// written by shadertoy user Aj_
//
// Name: Fractalsq
// Description: Just another fractal
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 resolution = iResolution.xy;
	vec2 res = resolution/4.;
	vec2 position = ( (fragCoord.xy - vec2(resolution.x/2., resolution.y/2.)) / max(res.y, res.x)  ) ;
	
	float x = position.x;
	float y = position.y;
	float u,t;
	float iv = 60.;
	
	for(int i=0;i<80;i++) {
		u =  -y*y*x*x -2.*x*x+.92-.0;
		t =  -x*x*y*y  -2.*y*y+.92 -0.0;
		
		
		x = u;
		y = t;
		if(dot(vec2(u,t), vec2(u,t))>10.08) {
			iv = float(i);
			break;
		}
		
	}
	
	vec3 color =  vec3(iv/60.)*10.;
	fragColor = vec4(vec3(color.x/8., color.y/4., color.z/4.), 1.);
}