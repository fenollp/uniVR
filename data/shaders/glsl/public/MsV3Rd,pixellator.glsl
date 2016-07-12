// Shader downloaded from https://www.shadertoy.com/view/MsV3Rd
// written by shadertoy user Metalavocado
//
// Name: Pixellator
// Description: Makes a view pixellated. Currently has some image positioning issues as it runs from top-left, the fix for this may be introduced shortly.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 diffFragCoordXY = fragCoord.xy;
    
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 uv2 = uv;
    
    float numPixelGrouping = 16.0;
    
    vec4 fragColorAtCoord = texture2D(iChannel0, uv);
    
    vec4 currentColor = vec4(0.0, 0.0, 0.0, 1.0);
    
    if (numPixelGrouping <= 0.0)
    {
        numPixelGrouping = 1.0;
    }
    
    int posX = int(ceil(mod(floor(fragCoord.x), numPixelGrouping)));
    int posY = int(ceil(mod(floor(fragCoord.y), numPixelGrouping)));

    
    if ((posX == 0) && (posY == 0))
    {
        currentColor = fragColorAtCoord;
    }
    else
    {
        diffFragCoordXY = vec2(fragCoord.x - float(posX), fragCoord.y - float(posY));
        
        uv2 = diffFragCoordXY / iResolution.xy;

        currentColor = texture2D(iChannel0, uv2);
    }
    fragColor = currentColor;
}