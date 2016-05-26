// Shader downloaded from https://www.shadertoy.com/view/MdKGzV
// written by shadertoy user jherico
//
// Name: shadertoyVR test
// Description: testbed for testing shadertoy vr's access to the REST API and the vr rendering mechanism
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
}


void mainVR( out vec4 fragColor, in vec2 fragCoord, in vec3 rayOrigin, in vec3 rayDirection ) {
    vec2 uv = fragCoord.xy / iResolution.xy;
    fragColor = vec4(abs(rayDirection), 1.0);
}
