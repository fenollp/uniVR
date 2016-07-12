// Shader downloaded from https://www.shadertoy.com/view/lsXSzn
// written by shadertoy user HLorenzi
//
// Name: Visual dFdx
// Description: Visually showing GLSL's partial derivative functions! Function is in red, derivative is in blue. On my computer, at extreme cases, the blue line displays as 2-pixel-wide dashes, revealing my GPU's fragment shader architecture.
float function(float x)
{
	float index = mod(floor(iGlobalTime / 2.0), 4.0);
	
	if (index < 1.0)
		return pow(x * 0.5, 2.0);
		
	else if (index < 2.0)
		return (pow(x * 0.75,3.0) + 3.0*pow(x * 0.75,2.0) - 6.0*x - 8.0) / 8.0;
	
	else if (index < 3.0)
		return sin(x) * 4.0;
		
	else
		return pow(x * 0.25, x * 0.5);
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	// Viewport: (-16,-16) to (16,16)
	vec2 uv = fragCoord.xy / iResolution.xy;
	uv = uv * 2.0 - vec2(1,1);
	uv *= 16.0;
	
	
	
	
	
	// Function of viewport's X position:
	float fx = function(uv.x);
	
	// Take the function's image difference between neighboring pixels
	// and divide by the viewport distance between the pixels:
	float dfdx = dFdx(fx) / (32.0 / iResolution.x); 
	
	
	
	
	
	
	// Color the function line
	if (fx >= uv.y && fx < uv.y + 32.0 / iResolution.y)
		fragColor = vec4(1,0,0,1);
	
	// Color the derivative line
	else if (dfdx >= uv.y && dfdx < uv.y + 32.0 / iResolution.y)
		fragColor = vec4(0,0,1,1);
		
	// Color vertical grid
	else if (mod(uv.x, 1.0) > 0.5 && mod(uv.x + 32.0 / iResolution.x, 1.0) <= 0.5)
		if (abs(uv.x) < 0.5)
			fragColor = vec4(0,0.5,0,1);
		else
			fragColor = vec4(0,0.2,0.1,1) * (mod(uv.x, 5.0) * 0.25 + 0.25);
		
	// Color horizontal grid
	else if (mod(uv.y, 1.0) > 0.5 && mod(uv.y + 32.0 / iResolution.y, 1.0) <= 0.5)
		if (abs(uv.y) < 0.5)
			fragColor = vec4(0,0.5,0,1);
		else
			fragColor = vec4(0,0.2,0.1,1) * (mod(uv.y, 5.0) * 0.25 + 0.25);
	
	// Color the background
	else
		fragColor = vec4(0,0,0,1);
}