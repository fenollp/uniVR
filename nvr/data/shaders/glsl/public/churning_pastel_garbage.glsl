// Shader downloaded from https://www.shadertoy.com/view/MdcSW8
// written by shadertoy user victor_shepardson
//
// Name: churning pastel garbage
// Description: guh
vec3 sigmoid(vec3 x){
 	return x/(1.+abs(x));   
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
	vec4 s = texture2D(iChannel0, uv)*2.-1.;
    vec3 c = .5+.5*sigmoid(2.*(s.rgb - .25*s.bar));
    c = c + .05 + .15*normalize(c-dot(c,vec3(.3333)));
	fragColor = vec4(c.rgb,1.);
}