// Shader downloaded from https://www.shadertoy.com/view/ldjSzd
// written by shadertoy user aaaidan
//
// Name: Mouse Input Debug Demo
// Description: Shows how to use the iMouse vector to get access to the last click position, the last drag position, as well as whether the mouse is clicked.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    // iMouse's xy values contain the (last) mouse drag position. Simple.
    // iMouse's zw values contain the (last) click position, and are
    // signed negative if the mouse button is up.
    bool iMouseDown = !(iMouse.z < 0.);
    vec2 iMouseClick = iMouse.zw;
    if (iMouseClick.x < 0.) {
        iMouseClick.x *= -1.;
    }
    if (iMouseClick.y < 0.) {
        iMouseClick.y *= -1.;
    }
    
    if (uv.x < 0.5) {
        // Left side of screen shows iMouse.xy (mouse drag location)
        fragColor = vec4(
            iMouse.xy / iResolution.xy,
            0.,0.);
    } else {
        // Right side of screen shows iMouse.zw (as 'normalized' iMouseClick.xy) 
        fragColor = vec4(
            iMouseClick.xy / iResolution.xy,
            0.,0.);
    }
    
    // Draw mouseDown indicator.
    // Empty circle if up, solid if down.
    float distToScreenCenter = distance(fragCoord.xy, vec2(0.5,0.5) * iResolution.xy);
    if ( distToScreenCenter < 20. && distToScreenCenter > (iMouseDown ? 0. : 18.) ) {
    	fragColor = vec4(1.,1.,1.,0.);
    }
    
    // Draw mouseClick and mouse location indicators.
    float distToMouse = distance(fragCoord.xy, iMouse.xy);
    float distToMouseClick = distance(fragCoord.xy, iMouseClick.xy);
    
    // Mouse drag location
    if ( distToMouse < 10. && distToMouse > 8.) {
        fragColor = vec4(1.0,1.0,1.0,0.);
    }
    
    // Mouse click location
    if ( distToMouseClick < 5.) {
        fragColor = vec4(1.0,1.0,1.0,0.);
    }
    
}
