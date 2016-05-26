// Shader downloaded from https://www.shadertoy.com/view/4tXXW4
// written by shadertoy user jackdavenport
//
// Name: Simple Masking
// Description: Blends two textures based on a simple black/white mask. White will display iChannell0, while black displays iChannel1. 
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
	vec3 tex1 = texture2D(iChannel0, uv).rgb;
    vec3 tex2 = texture2D(iChannel1, uv).rgb;
    vec3 map = texture2D(iChannel2, uv - iGlobalTime * .2).rgb;
 
    float dist = (map.x + map.y + map.z) / 3.;
    
    fragColor = vec4(mix(tex1, tex2, dist), 1.);
    
}