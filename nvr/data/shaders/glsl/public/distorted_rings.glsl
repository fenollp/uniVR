// Shader downloaded from https://www.shadertoy.com/view/ll2Gzh
// written by shadertoy user flypig
//
// Name: Distorted rings
// Description: A very 2D pattern: a distorted grid of rings, twisted across the canvas, and with a light shadow effect for some semblance of depth.
//    
//    This is an example shader developed for use with shaderback.js
/*

Copyright (c) 2015 David Llewellyn-Jones

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

precision highp float;

#define M_PI 3.1415926535897932384626433832795

// (((((x - xc1)**2) + ((y - yc1)**2) - (r1**2)) * (((x - xc2)**2) + ((y - yc2)**2) - (r2**2)))) < (s / 1000)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 vTextureCoord = fragCoord / iResolution.xy;
    float width = iResolution.x;
    float height = iResolution.y;
    float time = iGlobalTime * 1000.0;

	vec2 ratio = vec2(width, height) / width;
	vec2 pos = vTextureCoord * ratio;
	float scale = (3.0 + sin(time / 25000.0)) / 5.0;
	pos += vec2(sin(time / 3500.0), sin(time / 3650.0)) * 0.1;
	vec2 centre = vec2(0.1 * scale, 0.1 * scale);

	float radius1 = distance(vec2(mod(sin(sin((0.5 * M_PI * pos.y) + time / 3800.0) + pos.x * M_PI), 0.2 * scale),
		mod(sin(cos((0.5 * M_PI * pos.x) + time / 4100.0) + pos.y * M_PI), 0.2 * scale)), centre);

	float angle1 = atan (pos.x - 0.5, pos.y - 0.5);

	float angle2 = atan (mod(sin(sin((0.5 * M_PI * pos.y) + time / 3800.0) + pos.x * M_PI), 0.2 * scale) - centre.x, 
		mod(sin(cos((0.5 * M_PI * pos.x) + time / 4100.0) + pos.y * M_PI), 0.2 * scale) - centre.y);

	float red = 0.0;
	float green = 0.0;
	float blue = 0.0;
	if ((radius1 < 0.09 * scale) && (radius1 > 0.06 * scale)) {
		red = 1.0 - (sin ((time / 3300.0) + angle2 * 3.0) + 1.0) / 3.0;
		green = (sin ((time / 3200.0) + angle2 * 3.0) + 1.0) / 2.0;
		blue = (sin ((time / 3200.0) + angle1 * 3.0) + 1.0) / 2.0;
	}
	else {
		red = 1.0;
		green = 1.0;
		blue = 0.5;

		vec2 shadow = vec2(+0.005, -0.005);
		float radius1 = distance(vec2(mod(sin(sin((0.5 * M_PI * (pos.y - shadow.y)) + time / 3800.0) + (pos.x - shadow.x) * M_PI), 0.2 * scale),
		mod(sin(cos((0.5 * M_PI * (pos.x - shadow.x)) + time / 4100.0) + (pos.y - shadow.y) * M_PI), 0.2 * scale)), centre);

		if ((radius1 < 0.09 * scale) && (radius1 > 0.06 * scale)) {
			float darkness = cos(M_PI * (((radius1 / scale) - 0.075) / 0.03));
			red = 1.0 - 0.5 * darkness;
			green = 1.0 - 0.5 * darkness;
			blue = 0.5 - 0.5 * darkness;
		}

	}

	vec4 colour = vec4(red, green, blue, 1.0);

	fragColor = colour;
}
