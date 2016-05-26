// Shader downloaded from https://www.shadertoy.com/view/MtSXW1
// written by shadertoy user fischel
//
// Name: magic spiral
// Description: This is my first shader :) You can change the size with mousex.
#define M_PI 3.1415926535897932384626433832795

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{   
	vec2 uv = fragCoord.xy / iResolution.y;
    uv -= vec2(0.5 * iResolution.x / iResolution.y, 0.5); 
 
    float width = iMouse.x / iResolution.x + 0.2;
    float t = -iGlobalTime / 8.0 + length(uv) / width;
    
    float red = (atan(uv.y, uv.x) + M_PI) / (2.0 * M_PI);   
    red = red + (t - floor(t));
    if (red > 1.0) {
        red = red - 1.0;
    }
    
    float green = red + 1.0 / 3.0;
    if (green > 1.0) {
        green -= 1.0;
    }
    float blue = red + 2.0 / 3.0;
    if (blue > 1.0) {
        blue -= 1.0;
    }
    
    fragColor = vec4(red, green, blue, 1.0);
}