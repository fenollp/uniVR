// Shader downloaded from https://www.shadertoy.com/view/XsfXDr
// written by shadertoy user Zavie
//
// Name: Sphere normal map
// Description: Just the normals of a sphere, to use as a reference when debugging normal mapping.
/*

This shader just shows the typical colors as seen in a normal map,
in this case, with a sphere.

TODO: typical other normal buffer formats.

--
Zavie

*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float ratio = iResolution.x / iResolution.y;
	vec2 uv = vec2(ratio, 1.) * (2. * fragCoord.xy / iResolution.xy - 1.);
	
    vec3 n = vec3(uv, sqrt(1. - clamp(dot(uv, uv), 0., 1.)));

    vec3 color = 0.5 + 0.5 * n;
    color = mix(vec3(0.5), color, smoothstep(1.01, 1., dot(uv, uv)));
	fragColor = vec4(color, 1.0);
}
