// Shader downloaded from https://www.shadertoy.com/view/4sjGRD
// written by shadertoy user RavenWorks
//
// Name: Classic Mac floyd-steinberg-ish
// Description: Fake floyd-steinberg dithering; each pixel's error should flow into the next, but I'm getting close enough by looking up the previous few for each pixel. Not having a consistent (or square) history introduces some artifacts, but still looks pretty cool!
const int lookupSize = 64;
const float errorCarry = 0.3;

float getGrayscale(vec2 coords){
	vec2 uv = coords / iResolution.xy;
	uv.y = 1.0-uv.y;
	vec3 sourcePixel = texture2D(iChannel0, uv).rgb;
	return length(sourcePixel*vec3(0.2126,0.7152,0.0722));
}

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
		
		float xError = 0.0;
		for(int xLook=0; xLook<lookupSize; xLook++){
			float grayscale = getGrayscale(fragCoord.xy + vec2(-lookupSize+xLook,0));
			grayscale += xError;
			float bit = grayscale >= 0.5 ? 1.0 : 0.0;
			xError = (grayscale - bit)*errorCarry;
		}
		
		float yError = 0.0;
		for(int yLook=0; yLook<lookupSize; yLook++){
			float grayscale = getGrayscale(fragCoord.xy + vec2(0,-lookupSize+yLook));
			grayscale += yError;
			float bit = grayscale >= 0.5 ? 1.0 : 0.0;
			yError = (grayscale - bit)*errorCarry;
		}
		
		float finalGrayscale = getGrayscale(fragCoord.xy);
		finalGrayscale += xError*0.5 + yError*0.5;
		float finalBit = finalGrayscale >= 0.5 ? 1.0 : 0.0;
		
		fragColor = vec4(finalBit,finalBit,finalBit,1);
			
	}
	
}