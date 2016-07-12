// Shader downloaded from https://www.shadertoy.com/view/lll3zH
// written by shadertoy user poljere
//
// Name: HSV Explorer
// Description: Simple pixelization with HSV to RGB color transformation. 
//    Mouse click to pick a color!
#define GRIDRES 20.0

// Thanks IQ for this one
// https://www.shadertoy.com/view/MsS3Wc
vec3 hsv2rgb( in vec3 c )
{
    vec3 rgb = clamp( abs(mod(c.x*6.0+vec3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0 );
	return c.z * mix( vec3(1.0), rgb, c.y);
}

// Returns 1.0 when the uv is inside the quad
// Parameter pos indicates the center of the rect
float rect(vec2 uv, vec2 pos, vec2 size) 
{
	return 1.0 - clamp(length(max(abs(uv - pos)-size, 0.0))*150.0, 0.0, 1.0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Calculate UV coordinates and fix the aspect ratio
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv.x *= iResolution.x / iResolution.y;
    vec2 q = uv;
    
    // Pixelize texture coordinates
    vec2 res = vec2(GRIDRES);
    uv = floor(uv * res ) / res;
    
    // Rescale the mouse coordinates to match the screen coordinates
	vec2 m  = iMouse.xy / iResolution.xy;
	m.x *= iResolution.x / iResolution.y;
    
    // Pixelize mouse coordinates
    m = floor(m * res ) / res;
    
    // Hue will be defined by the X
    // Saturation will be defined by the Y
    // Value will be fixed
	vec3 col = hsv2rgb( vec3(uv.x, uv.y, 1.0) );
    
    // Draw the color selected
    vec3 colFocus = hsv2rgb( vec3(m.x, m.y, 1.0) );
    col = mix(col, colFocus, rect(q, vec2(1.65, 0.13), vec2(0.1)) );
    
	fragColor = vec4(col, 1.0);
}