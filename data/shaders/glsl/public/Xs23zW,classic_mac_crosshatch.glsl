// Shader downloaded from https://www.shadertoy.com/view/Xs23zW
// written by shadertoy user RavenWorks
//
// Name: Classic Mac crosshatch
// Description: I always loved the 'high-res crosshatch' look that old mac games had!
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	
	int topGapY = int(iResolution.y - fragCoord.y);
	
	int cornerGapX = int((fragCoord.x < 10.0) ? fragCoord.x : iResolution.x - fragCoord.x);
	int cornerGapY = int((fragCoord.y < 10.0) ? fragCoord.y : iResolution.y - fragCoord.y);
	int cornerThreshhold = ((cornerGapX == 0) || (topGapY == 0)) ? 5 : 4;
	
	if (cornerGapX+cornerGapY < cornerThreshhold) {
				
		fragColor = vec4(0,0,0,1);
		
	} else if (topGapY < 20) {
			
			if (topGapY == 19) {
				
				fragColor = vec4(0,0,0,1);
				
			} else {
		
				fragColor = vec4(1,1,1,1);
				
			}
		
	} else {
		
		vec2 uv = fragCoord.xy / iResolution.xy;
		uv.y = 1.0-uv.y;
		
		vec3 sourcePixel = texture2D(iChannel0, uv).rgb;
		float grayscale = length(sourcePixel*vec3(0.2126,0.7152,0.0722));
		
		vec3 ditherPixel = texture2D(iChannel1, vec2(mod(fragCoord.xy/iChannelResolution[1].xy,1.0))).xyz;
		float ditherGrayscale = (ditherPixel.x + ditherPixel.y + ditherPixel.z) / 3.0;
		ditherGrayscale -= 0.5;
		
		float ditheredResult = grayscale + ditherGrayscale;
		
		float bit = ditheredResult >= 0.5 ? 1.0 : 0.0;
		fragColor = vec4(bit,bit,bit,1);
			
	}
	
}