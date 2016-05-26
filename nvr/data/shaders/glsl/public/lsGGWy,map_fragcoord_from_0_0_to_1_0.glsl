// Shader downloaded from https://www.shadertoy.com/view/lsGGWy
// written by shadertoy user raRaRa
//
// Name: Map fragCoord from 0.0 to 1.0
// Description: Mapping gl_FragCoord from 0.0 to 1.0. Can be useful for various use cases. Any suggestion or comment is more than welcome.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // Subtracting 0.5 from fragCoord.xy, since OpenGL will start from vec2(0.5, 0.5) and end on vec2(iResolution.xy - 0.5).
    // uv will now be a value from 0.0 to 1.0.
	vec2 uv = (fragCoord.xy - 0.5) / (iResolution.xy - 1.0);
    
    // Default to white color
    fragColor = vec4(1.0, 1.0, 1.0, 1.0);
    
    // Color the edge of the window red to see if this is working.
    if (uv.x == 0.0 || uv.x == 1.0 || uv.y == 1.0 || uv.y == 0.0) {
    	fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
}