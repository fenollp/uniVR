// Shader downloaded from https://www.shadertoy.com/view/Md23D1
// written by shadertoy user RavenWorks
//
// Name: Wave tester
// Description: Just a quick little tool to glance at the way a squiggly wave function will play out in the long run; edit waveFunc to whatever you want, and click+drag left/right to zoom in/out. (Made it for my own purposes, but figured other people might make use&hellip;)
float waveFunc(float x){
	return sin( x + sin(x*0.8) + sin(x*0.2)*sin(x*2.1) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	const float minMargin = 0.02;
	float zoomAmt = (1.0 +minMargin)/( iMouse.x/iResolution.x +minMargin );
	
	float xAmt = zoomAmt * 2.0 * (fragCoord.x / iResolution.x) + iGlobalTime * 8.0;
	float yAmt = zoomAmt * 2.0 * (fragCoord.y / iResolution.y - 0.5);
	
	if (abs(yAmt) > 1.0) {
		fragColor = vec4(0.6,0.6,0.6,1);
	} else {
		fragColor = yAmt < waveFunc(xAmt) ? vec4(1,0,0,1) : vec4(1,1,1,1);
	}
}