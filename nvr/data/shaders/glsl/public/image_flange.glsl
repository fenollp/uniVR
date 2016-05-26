// Shader downloaded from https://www.shadertoy.com/view/4tfSWX
// written by shadertoy user demofox
//
// Name: Image Flange
// Description: applying the audio flange effect to an image to see what it looks like.  Use mouse dragging to enable interactivity on the X axis.  Mouse X = frequency.  Mouse Y = Depth (max offset)
#define CHROMATIC 1

float c_depthX = 3.0;  // in pixels, how far on the x axis the flange moves
float c_depthY = 2.0;  // in pixels, how far on the y axis the flange moves
float c_frequencyX = 4.3; // in Hz, the frequency of the sine wave controling the x axis flange
float c_frequencyY = 7.14; // in Hz, the frequency of the sine wave controling the x axis flange
float c_textureSize = 512.0;

float c_pixelSize = (1.0 / c_textureSize);

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // interactive mode settings
    if (iMouse.z > 0.0)
    {
        c_frequencyX = 100.0 * iMouse.x / iResolution.x;
        c_depthX = 25.0 * iMouse.y / iResolution.y;
        c_frequencyY = 0.0;
        c_depthY = 0.0;
    }
    
    // calculate the uv and offset for our uv
	vec2 uv = fragCoord.xy / iResolution.xy * vec2(1,-1);
    
    vec2 offset = vec2(
        (sin(iGlobalTime*c_frequencyX) * 0.5 + 0.5) * c_pixelSize*c_depthX,
        (sin(iGlobalTime*c_frequencyY) * 0.5 + 0.5) * c_pixelSize*c_depthY
	);
    
    // get our value and our offset value 
    #if CHROMATIC
    	vec3 a = texture2D(iChannel0, uv).rgb;
    	vec3 b = vec3(
            texture2D(iChannel0, uv + offset.xy).r,
            texture2D(iChannel0, uv + offset.yx).g,
            texture2D(iChannel0, uv + vec2(offset.y, -offset.x)).b            
		);
    #else
    	vec3 a = texture2D(iChannel0, uv).rgb;
    	vec3 b = texture2D(iChannel0, uv + offset).rgb;
    #endif
    
    // convert from 0-1 space to -1 to 1 space so we can have cancelation when doing addition
    a = a * 2.0 - 1.0;
    b = b * 2.0 - 1.0;
    
    // add (mix)
    vec3 color = a + b;
    
    // convert from -1 to 1 space to 0 to 1 space again
    color = color * 0.5 + 0.5;
    
    // set the color
	fragColor = vec4(clamp(color, 0.0, 1.0), 1.0);
}
