// Shader downloaded from https://www.shadertoy.com/view/XdKXRh
// written by shadertoy user jackdavenport
//
// Name: Greenscreen Drop Shadow
// Description: A green screen effect, with edge smoothing and a drop shadow.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel1, uv);
    
    vec4 jcvd = texture2D(iChannel0,uv-vec2(.01,-.02));
    fragColor.xyz *= 1. - (.5 * jcvd.a);
    
   	jcvd = texture2D(iChannel0, uv);
    fragColor.xyz = mix(fragColor.xyz, jcvd.xyz, jcvd.a);

}