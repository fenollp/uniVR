// Shader downloaded from https://www.shadertoy.com/view/Msd3zn
// written by shadertoy user iq
//
// Name: Texture - LOD II
// Description: Testing the LOD feature on textures.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec3 col = texture2DLodEXT( iChannel0, uv, 3.0 ).xyz;
	fragColor = vec4(col,1.0);
}