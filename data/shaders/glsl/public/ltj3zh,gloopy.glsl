// Shader downloaded from https://www.shadertoy.com/view/ltj3zh
// written by shadertoy user flypig
//
// Name: Gloopy
// Description: Three lumps of lava-lamp style gloop.
/*

Copyright (c) 2015 David Llewellyn-Jones

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

precision mediump float;

#define M_PI 3.1415926535897932384626433832795

// (((((x - xc1)**2) + ((y - yc1)**2) - (r1**2)) * (((x - xc2)**2) + ((y - yc2)**2) - (r2**2)))) < (s / 1000)

const vec3 position = vec3(-0.2, 0.2, 1.3);
const vec3 diffuseColour = vec3(0.25, 0.25, 0.5);
const float diffusePower = 2.0;
const vec3 specularColour = vec3(0.5, 0.1, 0.1);
const float specularPower = 5.0;
const float specularHardness = 5.0;
const vec3 ambientColour = vec3(0.4, 0.5, 0.4);

vec3 BlinnPhongLighting(vec3 pos, vec3 viewDir, vec3 normal) {
	vec3 lightDir = position - pos;
	float distance = length (lightDir);
	lightDir = lightDir / distance;
	distance = distance * distance;

	float NdotL = dot (normal, lightDir);
	float intensity = clamp (NdotL, 0.0, 1.0);
	vec3 diffuse = intensity * diffuseColour * diffusePower / distance;
	vec3 H = normalize (lightDir + viewDir);
	float NdotH = dot (normal, H);
	intensity = pow (clamp (NdotH, 0.0, 1.0), specularHardness);
	vec3 specular = intensity * specularColour * specularPower; 

	return (diffuse + specular + ambientColour);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 vTextureCoord = fragCoord / iResolution.xy;
    float time = (310.0 + iGlobalTime) * 1000.0;
    float width = iResolution.x;
    float height = iResolution.y;
    
	const float stickiness = 0.0050;
	const float r1 = 0.25;
	const float r2 = 0.25;
	const float r3 = 0.25;
	vec2 ratio = vec2(width, height) / min(width, height);
	vec2 pos1 = vec2((1.0 + sin(time / 9000.0)) / 2.0, (1.0 + sin(time / 7100.0)) / 2.0) * ratio;
	vec2 pos2 = vec2((1.0 + sin(time / 8900.0)) / 2.0, (1.0 + sin(time / 10400.0)) / 2.0) * ratio;
	vec2 pos3 = vec2((1.0 + sin(time / 9650.0)) / 2.0, (1.0 + sin(time / 91500.0)) / 2.0) * ratio;
	vec2 pos = vTextureCoord * ratio;

	float d1 = pow((pos.x - pos1.x), 2.0) + pow((pos.y - pos1.y), 2.0) - pow(r1, 2.0);
	float d2 = pow((pos.x - pos2.x), 2.0) + pow((pos.y - pos2.y), 2.0) - pow(r2, 2.0);
	float d3 = pow((pos.x - pos3.x), 2.0) + pow((pos.y - pos3.y), 2.0) - pow(r3, 2.0);

	float dist = (stickiness - d1 * d2 * d3);
	vec3 position = vec3(pos.x, pos.y, dist);

	float d12 = distance(pos1, pos2);
	float d13 = distance(pos1, pos3);
	float d23 = distance(pos2, pos3);
	float weght12 = 1.0 / (1.0 + exp(((distance(pos1, pos) / d12) - 0.5) * 8.0));
	float weght13 = 1.0 / (1.0 + exp(((distance(pos1, pos) / d13) - 0.5) * 8.0));
	float weght23 = 1.0 / (1.0 + exp(((distance(pos2, pos) / d23) - 0.5) * 8.0));

	vec2 centre12 = (weght12 * pos1) + ((1.0 - weght12) * pos2);
	vec2 centre13 = (weght13 * pos1) + ((1.0 - weght13) * pos3);
	vec2 centre = (weght23 * centre12) + ((1.0 - weght23) * centre13);

	highp float up = pow(dist, 0.45);
	vec3 normal = normalize(vec3(pos.x - centre.x, pos.y - centre.y, up));

	vec4 colour = vec4(0.8 * (1.0 - vTextureCoord.y), 0.8 * vTextureCoord.y, 0.8, 1.0);
	if (dist > 0.0) {
		colour.xyz = BlinnPhongLighting (position, vec3(0.0, 0.0, 1.0), normal);
	}

	fragColor = colour;
}
