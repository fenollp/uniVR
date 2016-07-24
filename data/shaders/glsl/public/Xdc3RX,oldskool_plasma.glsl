// Shader downloaded from https://www.shadertoy.com/view/Xdc3RX
// written by shadertoy user Harha
//
// Name: oldskool plasma
// Description: Some plasma functions combined with 4x4 dithering.
#define time iGlobalTime * 1.0
#define scale 8.0
#define resolution 1.0 / 2.0
#define background 0.25
#define PI 3.14159265359

/*
	Brightness function adapted from: https://github.com/hughsk/glsl-luma
	Dithering functions adapted from: https://github.com/hughsk/glsl-dither
	Edit: Eh, I just realized that the 8x8 R texture is made for this.
*/
float luma(in vec4 color) {
    return dot(color.rgb, vec3(0.299, 0.587, 0.114));
}

float dither4x4(in vec2 position, in float brightness) {
    int x = int(mod(position.x, 4.0));
	int y = int(mod(position.y, 4.0));
	int index = x + y * 4;
	float limit = 0.0;

	if (x < 8) {
		if (index == 0) limit = 0.0625;
		if (index == 1) limit = 0.5625;
    	if (index == 2) limit = 0.1875;
    	if (index == 3) limit = 0.6875;
    	if (index == 4) limit = 0.8125;
    	if (index == 5) limit = 0.3125;
    	if (index == 6) limit = 0.9375;
    	if (index == 7) limit = 0.4375;
    	if (index == 8) limit = 0.25;
    	if (index == 9) limit = 0.75;
    	if (index == 10) limit = 0.125;
    	if (index == 11) limit = 0.625;
    	if (index == 12) limit = 1.0;
    	if (index == 13) limit = 0.5;
    	if (index == 14) limit = 0.875;
    	if (index == 15) limit = 0.375;
        limit *= 0.75;
  }

  return brightness < limit ? 0.0 : 1.0;
}

vec4 dither4x4(in vec2 position, in vec4 color) {
	return vec4(color.rgb * dither4x4(position, luma(color)), 1.0);
}

/*
	Plasma functions adapted from: http://www.bidouille.org/prog/plasma
	At first I tried to make up my own, but as I didn't like the outcome I decided to use the ones in above link.
	It's surprisingly difficult to come up with good looking color combinations.
*/
float v1(in vec2 uv)
{
    return sin(uv.x * scale + time);
}

float v2(in vec2 uv)
{
    return sin(scale * (uv.x * sin(time / 2.0) + uv.y * cos(time / 3.0)) + time);
}

float v3(in vec2 uv)
{
    float cx = uv.x + 0.5 * sin(time / 5.0);
    float cy = uv.y + 0.5 * cos(time / 3.0);
    return sin(sqrt(128.0 * (cx * cx + cy * cy) + 1.0) + time);
}

float v(in vec2 uv)
{
    return v1(uv) + v2(uv) + v3(uv);
}

void mainImage(out vec4 c, in vec2 f)
{
    // Center & scale the uv coordinates
	vec2 uv = (f.xy / iResolution.xy) - vec2(0.5);
    uv.x *= iResolution.x / iResolution.y;
   	c = vec4(0.0);
    
    // Plasma
    c.r += sin(v(uv) * PI * 0.16);
    c.g += sin(v(uv) * PI * 0.33);
    c.b += sin(v(uv) * PI * 0.66);
    
    // Dither + mix with background color
    c = max(dither4x4(f * resolution, c), background);
}