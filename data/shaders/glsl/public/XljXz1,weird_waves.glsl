// Shader downloaded from https://www.shadertoy.com/view/XljXz1
// written by shadertoy user aiekick
//
// Name: Weird Waves
// Description: Weird Waves

const vec4 uSlider = vec4(.15, .75, 1.2, -.14);
const float uSlider1 = 1.6;
float uTime = iGlobalTime;
vec2 uScreenSize = iResolution.xy;
const vec3 uColor = vec3(0,.57,1);

void mainImage( out vec4 f, in vec2 g )
{
	vec2 s = uScreenSize;
	
	float r =  g.y/(s.x*2. - g.x);
	
	vec2 uv = 15.*(2.*g - s)/max(s.x,s.y);
	
	vec3 col = vec3(0.);
	
	uv.y += uSlider.y * sin(uv.x / uSlider.x * r + uTime );
	
	float rep = uSlider.z;
	uv = mod(uv, vec2(rep)) - vec2(rep)/uSlider1;
	
	col += uColor * (uSlider.w / uv.y);

	f = vec4(col, 1.0);
}