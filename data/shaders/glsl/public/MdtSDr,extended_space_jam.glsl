// Shader downloaded from https://www.shadertoy.com/view/MdtSDr
// written by shadertoy user jhfredriksen
//
// Name: Extended Space Jam
// Description: Plasma.
//    Originally inspired by https://www.shadertoy.com/view/lsdXWr, but changed from 1-bit output to smooth results.

//
// This uses the same basic function as https://www.shadertoy.com/view/lsdXWr,
// only with an added fudge-factor to hide the high-frequency components when
// dividing by (close to) zero.
//
// Visualization part rewritten to give smooth results instead of 1-bit :)

float plasma(vec2 uv, float scale, float time)
{
    float v = cos(uv.x*uv.y * scale) - cos(uv.x/(0.4+uv.y) + time);
    float f = floor(v);
    float c = ceil(v);
    float e = min(c-v, v-f);
 	float r = min(pow(e * 1.8, 0.7), 1.0);

    return r;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = 10.;
    float deform = 0.6;
	vec2 uv = (fragCoord.xy / iResolution.xy) - 0.5;
    uv.y *= deform;

    float r0 = plasma(uv, scale, iGlobalTime);
    float r1 = plasma(uv, scale * 2., iGlobalTime*1.5 + 0.32);

    // combine octaves in various ways
    //float r = max(r0, r1);
    float r = r0*r1;
    //float r = r0*0.75+r1*0.25;

    // attenuate borders
    vec2 centeruv = (fragCoord.xy / iResolution.xy*2.0) - 1.0;
    r *= 1.0 - pow(length(centeruv*centeruv)*0.8,6.0);

    // tint
	fragColor = r*vec4(0.8, 0.7, 0.9, 1.0);
}