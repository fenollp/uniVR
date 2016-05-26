// Shader downloaded from https://www.shadertoy.com/view/4dy3Dc
// written by shadertoy user psychicteeth
//
// Name: Spiral optical illusion
// Description: An optical illusion reproduced from an image I saw on facebook. Two arms of a magenta/orange spiral interact with a second spiral, turning green when they hit opposite arms of the second spiral. The result appears to show two different shades of green.

float spiral(vec2 m) {
	float r = length(m)*6.;
	float a = atan(m.y, m.x);
	float v = 50.*sin(60.*(pow(r,1.)-1.*a));
	return clamp(v,0.,1.);

}

float spiral2(vec2 m) {
	float r = pow(length(m)*40.,0.8);
	float a = atan(-m.y, m.x);
	float v = sin(r-a)*2.*0.707;
	float rv = clamp(v,-1.,1.);
    return rv;

}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

	vec2 uv = fragCoord.xy / iResolution.y;
	
	vec2 m = vec2(.9,.5);

	float s2 = float(int(spiral2(m-uv)));
    float s1 = spiral(m-uv);
    //float abss2 = abs(s2);
    //vec3 spiral2col = vec3(0,(0.5+s2)*abss2,(0.5-s2)*abss2);

	uv = fragCoord.xy / iResolution.xy;
    vec3 green = vec3(0.,1.,0.);
    float s2_1 = clamp(s2,0.,1.);
    float s2_2 = abs(clamp(s2,-1.,0.));
    vec3 magenta = vec3(1.,0.,1.) * (1.-s2_1) + green * s2_1;
    vec3 orange = vec3(1.,0.5,0.) * (1.-s2_2) + green * s2_2;
	vec3 col = magenta * (1.-s1) + orange * s1;
	
	fragColor = vec4(col,1.);
}