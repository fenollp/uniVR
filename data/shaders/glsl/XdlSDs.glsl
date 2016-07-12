// Shader downloaded from https://www.shadertoy.com/view/XdlSDs
// written by shadertoy user dynamite
//
// Name: [SIG2014] - Total Noob
// Description: A circle of color with shape - first shadertoy, this was fun!

uniform vec3      iResolution;           // viewport resolution (in pixels)
uniform float     iGlobalTime;           // shader playback time (in seconds)
uniform float     iChannelTime[4];       // channel playback time (in seconds)
uniform vec3      iChannelResolution[4]; // channel resolution (in pixels)
uniform vec4      iMouse;                // mouse pixel coords. xy: current (if MLB down), zw: click
uniform sampler2D iChannel0;             // input channel. XX = 2D/Cube
uniform sampler2D iChannel1;             // input channel. XX = 2D/Cube
uniform vec4      iDate;                 // (year, month, day, time in secs)
uniform float     iSampleRate;           // sound sample rate (i.e., 44100)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (2.0*fragCoord.xy-iResolution.xy)/iResolution.y;
    float tau = 3.1415926535*2.0;
    float a = atan(p.x,p.y);
    float r = length(p)*0.75;
    vec2 uv = vec2(a/tau,r);
	
	//get the color
	float xCol = (uv.x - (iGlobalTime / 3.0)) * 3.0;
	xCol = mod(xCol, 3.0);
	vec3 horColour = vec3(0.25, 0.25, 0.25);
	
	if (xCol < 1.0) {
		
		horColour.r += 1.0 - xCol;
		horColour.g += xCol;
	}
	else if (xCol < 2.0) {
		
		xCol -= 1.0;
		horColour.g += 1.0 - xCol;
		horColour.b += xCol;
	}
	else {
		
		xCol -= 2.0;
		horColour.b += 1.0 - xCol;
		horColour.r += xCol;
	}

	// draw color beam
	uv = (2.0 * uv) - 1.0;
	float beamWidth = (0.7+0.5*cos(uv.x*10.0*tau*0.15*clamp(floor(5.0 + 10.0*cos(iGlobalTime)), 0.0, 10.0))) * abs(1.0 / (30.0 * uv.y));
	vec3 horBeam = vec3(beamWidth);
	fragColor = vec4((( horBeam) * horColour), 1.0);
}