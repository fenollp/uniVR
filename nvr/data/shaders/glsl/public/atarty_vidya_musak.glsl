// Shader downloaded from https://www.shadertoy.com/view/lsK3R1
// written by shadertoy user losergenerated
//
// Name: Atarty Vidya Musak
// Description: WIP: Attempt at re-creating Atari Video Music. Click once to start.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


const float color_res = 2.0;

const vec3 color1 = vec3(0.5, 0.5, 0.5);
const vec3 color2 = vec3(0.5, 0.5, 0.5);
const vec3 color3 = vec3(1.0, 1.0, 1.0);
const vec3 color4 = vec3(0.00, 0.33, 0.67);


vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return ceil(color_res * (a + b*cos(6.28318*(c*t+d)))) / color_res;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    float scroll = iMouse.y / iResolution.y * 2.0 + .001;
    float repeats = iMouse.x / iResolution.x * 8.0 + .001;
    // create pixel coordinates
	vec2 uv = (fragCoord.xy / iResolution.xy);
    uv.y -= scroll * iGlobalTime;
    uv.x -= scroll * iGlobalTime;
    float d = texture2D( iChannel1, vec2(uv.x,uv.y)).x * .005;


    uv.x = uv.x * iResolution.z;

    uv = mod(uv,1.0/repeats);
    uv -= 0.5/repeats;

    uv = abs(uv);

    d += (uv.x + uv.y) * repeats;


	
	// first texture row is frequency data
	float fft  = texture2D( iChannel0, vec2(d,0.25) ).x;

    // second texture row is the sound wave
	float wave = texture2D( iChannel0, vec2(d,0.75) ).x;

	// convert frequency to colors
	vec3 col = palette(fft, color1, color2, color3, color4);

    col *= .7 - d*d;



	// output final color
	fragColor = vec4(col,1.0);
}
