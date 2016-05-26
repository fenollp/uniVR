// Shader downloaded from https://www.shadertoy.com/view/4ls3D4
// written by shadertoy user Dave_Hoskins
//
// Name: [2TC 15] Dearly departed
// Description: An exaltation into the Spirit Realm!
//    At fullscreen it's quite hypnotic. 
//    Thanks to TekF for his idea with [url]https://www.shadertoy.com/view/4tf3WN[/url]
// [2TC 15] Dearly departed
// by David Hoskins.
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 f, in vec2 w )
{
    // Setup 3D camera vector...
    vec4 p = normalize(vec4(w.xy / iResolution.xy - .5, .07, 0)) * .4, 
    // Use it as a stepper through the cloud, and reset alpha...
		d = p, a = p - p;
    // In time...
    p.z += iGlobalTime * 3.;
    //p.z += iDate.w * 3.; // I can't use this as it's far too grainy!
     
    // Loop through cloud...
    for(int i = 0; i < 99; i++)
    {
        // Get xy value plus the offset in texture at z*(37,17)...
        vec4 v = texture2D(iChannel0, (p.xy + vec2(37, 17) * floor(p.z)) / 256.);
        // Use what's left of alpha to change shade....
        a += (1. - a) * (mix(v.y, v.x, fract(p.z))) * abs(p.x) * .003;
        p += d;
    }
    f = vec4(1. - a*a);
}

