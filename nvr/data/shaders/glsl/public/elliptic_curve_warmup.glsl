// Shader downloaded from https://www.shadertoy.com/view/4dcXzf
// written by shadertoy user huttarl
//
// Name: Elliptic curve warmup
// Description: Rendering an elliptic curve for cycling values of a and b.
//    (OK, once in a great while you'll get a non-elliptic curve: when a = b = 0.)
// This is an exercise in preparation for another shader I'm working on,
// https://www.shadertoy.com/view/lstXRj (not published yet).

// See https://en.wikipedia.org/wiki/Elliptic_curve about elliptic curves.

// HT to marius at https://www.shadertoy.com/view/Mt2Gzw, who already made a shader
// with elliptic curves. I used his delta idea (adapted).

// Idea: add sound. Maybe have two sounds, and the volume of one is
// proportional to a, the other, to b.

// Idea: make this 3D, a hill growing and spawning a blob.
//   Maybe make it stereoscopic, and/or VR.

// Idea from Jo Grace:
//   a water surface spawning a droplet that comes out, then splashes back down.

const float PI = 3.14159;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = (uv * 2. - 1.) * 5.; // center at origin and zoom out.
    
    // By keeping a's and b's cycles out of close sync, the idea is to
    // cover a bigger variety of curve shapes over time.
    float a = -0.5 - 8.5 * cos(iGlobalTime), b = 0.5 + 8.5 * cos(iGlobalTime * 0.71415);
    
	// fragColor = vec4(uv,0.5+0.5*sin(iGlobalTime),1.0);
    float delta = -uv.y * uv.y + uv.x * uv.x * uv.x + a * uv.x + b;
    float ad = abs(delta);

    const float hueChange = 1.;
    float r1 = sin(ad * hueChange + iGlobalTime) * 0.5 + 0.5;
    float g1 = sin(ad * hueChange + iGlobalTime + PI * 2. / 3.) * 0.5 + 0.5;
    float b1 = sin(ad * hueChange + iGlobalTime + PI * 4. / 3.) * 0.5 + 0.5;

    // JG wanted rainbow colors.
    // Rainbow on black:
    // fragColor = vec4(r1, g1, b1, 1.0) * pow(0.8, ad*5.);
    // Rainbow on white:
    fragColor = mix(vec4(r1, g1, b1, 1.0), vec4(1.0), 1. - pow(0.2, ad));

    // a little fancy coloring...
    // fragColor = vec4(ad, pow(abs(delta), 0.16), pow(abs(delta), 0.1), 1.0);
}
