// Shader downloaded from https://www.shadertoy.com/view/4dtGWB
// written by shadertoy user vgs
//
// Name: GLSL smallpt (multipass)
// Description: A simple port of Zavie's GLSL smallpt that uses multipass.
//    Original source: https://www.shadertoy.com/view/4sfGDB#
// A simple port of Zavie's GLSL smallpt that uses multipass.
// Original source: https://www.shadertoy.com/view/4sfGDB#

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord.xy / iResolution.xy;
	vec3 color = texture2D(iChannel0, uv).rgb;
    
	fragColor = vec4(pow(clamp(color, 0., 1.), vec3(1./2.2)), 1.);
}