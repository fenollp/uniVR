// Shader downloaded from https://www.shadertoy.com/view/4sG3Dc
// written by shadertoy user raRaRa
//
// Name: Texture - exclude edge texels
// Description: Drawing a texture without the edges (excluding one texel from the edges). This will be used for sampling normal maps on a QuadTree terrain, because the height map has one extra texel for neighbor sampling.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float textureWidth = 8.0;
    float texelSize = 1.0 / textureWidth;
    vec2 uvNormal = fragCoord.xy / iResolution.xy;
    vec2 uvSkipEdges = uvNormal * (textureWidth - 2.0) / textureWidth + texelSize;
    
	fragColor = texture2D(iChannel0, uvSkipEdges);
}