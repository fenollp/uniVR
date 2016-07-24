// Shader downloaded from https://www.shadertoy.com/view/XsXGRS
// written by shadertoy user 4rknova
//
// Name: The Blob
// Description: Balls are touching.
// by nikos papadopoulos, 4rknova / 2013
// Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#ifdef GL_ES
precision highp float;
#endif

#define AA 4.

#define CI vec3(.3,.5,.6)
#define CO vec3(.2)
#define CM vec3(.0)
#define CE vec3(.8,.7,.5)

float metaball(vec2 p, float r)
{
	return r / dot(p, p);
}

vec3 sample(in vec2 uv)
{
	float t0 = sin(iGlobalTime * 1.9) * .46;
	float t1 = sin(iGlobalTime * 2.4) * .49;
	float t2 = cos(iGlobalTime * 1.4) * .57;

	float r = metaball(uv + vec2(t0, t2), .33) *
			  metaball(uv - vec2(t0, t1), .27) *
			  metaball(uv + vec2(t1, t2), .59);

	vec3 c = (r > .4 && r < .7)
			  ? (vec3(step(.1, r*r*r)) * CE)
			  : (r < .9 ? (r < .7 ? CO: CM) : CI);

	return c;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy * 2. - 1.)
			* vec2(iResolution.x / iResolution.y, 1) * 1.25;

    vec3 col = vec3(0);

#ifdef AA
    // Antialiasing via supersampling
    float e = 1. / min(iResolution.y , iResolution.x);    
    for (float i = -AA; i < AA; ++i) {
        for (float j = -AA; j < AA; ++j) {
    		col += sample(uv + vec2(i, j) * (e/AA)) / (4.*AA*AA);
        }
    }
#else
    col += sample(uv);
#endif /* AA */
    
    fragColor = vec4(clamp(col, 0., 1.), 1);
}