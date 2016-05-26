// Shader downloaded from https://www.shadertoy.com/view/MsfGRn
// written by shadertoy user llorens
//
// Name: Burn
// Description: Progressive burn of some material
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 c = texture2D(iChannel0,uv).xyz;
	vec3 c2 = texture2D(iChannel1,uv).xyz;
	float gray = dot(vec3(0.3,0.59,0.11), c);
	float g2 = dot(vec3(0.3,0.59,0.11), c2);
	
	float fT = mod(iGlobalTime * 0.1,0.8);
	float fMin = 0.0 + fT;
	float fMax = 0.3 + fT;
	float ss = smoothstep(fMin,fMax,gray);
	float fStep = step(fMin,ss);
	
	
	vec3 cBurn = mix(mix(vec3(0,0,0),vec3(1.0,0.7,0),g2 * 2.0),mix(vec3(1,0.7,0),vec3(1,1,1), (g2 - 0.5) * 2.0),step(0.5,g2));

	c = mix(cBurn,c,ss);
	c = c * fStep;
	
	fragColor = vec4(c.xyz,1.0);
}