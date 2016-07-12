// Shader downloaded from https://www.shadertoy.com/view/MtfXRN
// written by shadertoy user codywatts
//
// Name: Tile Mosaic
// Description: This is my first shader. It's simple, but I had fun making it.
// "USE_TILE_BORDER" creates a border around each tile.
// "USE_ROUNDED_CORNERS" gives each tile a rounded effect.
// If neither are defined, it is a basic pixelization filter.
#define USE_TILE_BORDER
//#define USE_ROUNDED_CORNERS

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float minTileSize = 1.0;
	const float maxTileSize = 32.0;
	const float textureSamplesCount = 3.0;
	const float textureEdgeOffset = 0.005;
	const float borderSize = 1.0;
	const float speed = 1.0;

	float time = pow(sin(iGlobalTime * speed), 2.0);
	float tileSize = minTileSize + floor(time * (maxTileSize - minTileSize));
	tileSize += mod(tileSize, 2.0);
	vec2 tileNumber = floor(fragCoord / tileSize);

	vec4 accumulator = vec4(0.0);
	for (float y = 0.0; y < textureSamplesCount; ++y)
	{
		for (float x = 0.0; x < textureSamplesCount; ++x)
		{
			vec2 textureCoordinates = (tileNumber + vec2((x + 0.5)/textureSamplesCount, (y + 0.5)/textureSamplesCount)) * tileSize / iResolution.xy;
			textureCoordinates.y = 1.0 - textureCoordinates.y;
			textureCoordinates = clamp(textureCoordinates, 0.0 + textureEdgeOffset, 1.0 - textureEdgeOffset);
			accumulator += texture2D(iChannel0, textureCoordinates);
	   }
	}
	
	fragColor = accumulator / vec4(textureSamplesCount * textureSamplesCount);

#if defined(USE_TILE_BORDER) || defined(USE_ROUNDED_CORNERS)
	vec2 pixelNumber = floor(fragCoord - (tileNumber * tileSize));
	pixelNumber = mod(pixelNumber + borderSize, tileSize);
	
#if defined(USE_TILE_BORDER)
	float pixelBorder = step(min(pixelNumber.x, pixelNumber.y), borderSize) * step(borderSize * 2.0 + 1.0, tileSize);
#else
	float pixelBorder = step(pixelNumber.x, borderSize) * step(pixelNumber.y, borderSize) * step(borderSize * 2.0 + 1.0, tileSize);
#endif
	fragColor *= pow(fragColor, vec4(pixelBorder));
#endif
}