// Shader downloaded from https://www.shadertoy.com/view/lsy3Rh
// written by shadertoy user milewski
//
// Name: Test Universe
// Description: Test
// 'Warp Speed' by David Hoskins 2013.
// I tried to find gaps and variation in the star cloud for a feeling of structure.
float time = (iGlobalTime+29.) * 60.0;
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float s = 0.0, v = 0.0;
	vec2 uv = (fragCoord.xy / iResolution.xy) * 2.0 - 1.0;
	float t = time*0.005;
	uv.x = (uv.x * iResolution.x / iResolution.y) + sin(t) * 0.5;
	float si = sin(t + 1.0); // ...Squiffy rotation matrix!
	float co = cos(t);
	uv *= mat2(co, si, -si, co);
	vec3 col = vec3(0.0);
	vec3 init = vec3(0.25, 0.25 + sin(time * 0.001) * 0.4, floor(time) * 0.0008);
	for (int r = 0; r < 50; r++) 
	{
		vec3 p = init + s * vec3(uv, 0.143);
		p.z = mod(p.z, 2.0);
		for (int i=0; i < 10; i++)	p = abs(p * 2.04) / dot(p, p) - 0.75;
		v += length(p * p) * smoothstep(0.0, 0.5, 0.9 - s) * .002;
		// Get a purple and cyan effect by biasing the RGB in different ways...
		col +=  vec3(v * 0.8, 1.1 - s * 0.5, .7 + v * 0.5) * v * 0.013;
		s += .01;
	}
	fragColor = vec4(col, 1.0);
}