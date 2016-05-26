// Shader downloaded from https://www.shadertoy.com/view/XdBGzw
// written by shadertoy user denilsonsa
//
// Name: Mouse position fog
// Description: My first shader, written in 2011-10-23. I tried porting it to Shadertoy, but at the time it did not support extra buffers. On 2016-04-26, I've updated this shader to make it work in Shadertoy. This would look much cooler if there was mouse-over support.
// Written by Denilson Sá <denilsonsa@gmail.com>
// http://denilson.sa.nom.br/
//
// GLSL Sandbox version at:
// http://glslsandbox.com/e#12315.2
//
// The source is also available at:
// https://bitbucket.org/denilsonsa/atmega8-magnetometer-usb-mouse/src/tip/html_javascript/
// https://github.com/denilsonsa/atmega8-magnetometer-usb-mouse/tree/master/html_javascript
//
// The original code (above) was restructured to work with Shadertoy.

// Code originally from draw_to_main().
void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 uv = fragCoord.xy / iResolution.xy;
	fragColor = texture2D(iChannel0, uv);
}
