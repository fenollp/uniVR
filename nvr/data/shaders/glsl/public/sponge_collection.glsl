// Shader downloaded from https://www.shadertoy.com/view/lddXRM
// written by shadertoy user mgattis
//
// Name: Sponge Collection
// Description: Some Menger Sponges. Space Bar restarts rendering.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 color = texture2D(iChannel0, uv).rgb;
    
    fragColor = vec4(color.rgb, 1.0);
}