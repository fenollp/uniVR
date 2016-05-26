// Shader downloaded from https://www.shadertoy.com/view/XlsSz4
// written by shadertoy user codywatts
//
// Name: A Magnifying Lens
// Description: It's a lens which magnifies and removes blurriness. Click and drag the mouse to move the lens around.
float normalDistribution(in float mean, in float deviation, in float x)
{
    // 2.50662827463 = sqrt(2 * pi)
    return (1.0 / (2.50662827463 * deviation)) * exp((-1.0 * pow(x - mean, 2.0))/(2.0 * pow(deviation, 2.0)));
}

vec4 sampleTexture(in sampler2D sampler, in vec2 fragCoord, in vec2 uvOffsets)
{
	const float textureEdgeOffset = 0.005;
	
	vec2 textureCoordinates = (fragCoord + uvOffsets) / iResolution.xy;
	textureCoordinates.y = 1.0 - textureCoordinates.y;
	textureCoordinates = clamp(textureCoordinates, 0.0 + textureEdgeOffset, 1.0 - textureEdgeOffset);
	return texture2D(iChannel0, textureCoordinates);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    const float textureSamplesCount = 8.0;
    const float mean = 0.0;
    
	vec2 mouseCoords = iMouse.xy;
    // This causes the lens to animate in a figure-eight pattern if the user hasn't clicked anything.
    if (mouseCoords == vec2(0.0))
	{
        mouseCoords = (vec2(sin(iGlobalTime), sin(iGlobalTime) * cos(iGlobalTime)) * 0.35 + vec2(0.5)) * iResolution.xy;
	}
    
    float distanceFromLensCenter = distance(fragCoord, mouseCoords);
    float distanceFactor = -1.0 * pow(0.04 * 640.0 / iResolution.x * distanceFromLensCenter, 5.0) + iResolution.x;
    distanceFactor = max(1.0, distanceFactor);
    
    vec2 textureDisplacement = vec2(0.0, 0.0);
    if (distanceFactor > 1.0)
    {
        float displacementFactor = distanceFromLensCenter / 2.0;
        textureDisplacement = normalize(mouseCoords - fragCoord) * displacementFactor;
    }
    
	float standardDeviation = 40.0/distanceFactor;    

    float divisor = (normalDistribution(mean, standardDeviation, 0.0) + 1.0) * distanceFactor;
	vec4 accumulator = sampleTexture(iChannel0, fragCoord, textureDisplacement) * divisor;
    
    vec2 polarityArray[4];
    polarityArray[0] = vec2(1.0, 1.0);
    polarityArray[1] = vec2(-1.0, 1.0);
    polarityArray[2] = vec2(1.0, -1.0);
    polarityArray[3] = vec2(-1.0, -1.0);

	for (float y = 1.0; y < textureSamplesCount; ++y)
	{
        for (float x = 1.0; x < textureSamplesCount; ++x)
        {
            float multiplier = normalDistribution(mean, standardDeviation, distance(vec2(0.0), vec2(x, y))) + 1.0;

            for (int p = 0; p < 4; ++p)
            {
                vec2 offset = vec2(x, y) * polarityArray[p];
                accumulator += sampleTexture(iChannel0, fragCoord, offset) * multiplier;
                divisor += (multiplier);
            }
        }
	}
    
    fragColor = accumulator / divisor;
}