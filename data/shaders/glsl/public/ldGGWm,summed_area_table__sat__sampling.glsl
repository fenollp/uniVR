// Shader downloaded from https://www.shadertoy.com/view/ldGGWm
// written by shadertoy user tsone
//
// Name: Summed Area Table (SAT) Sampling
// Description: SAT building &amp; minification. Left: SAT, right: mipmap. The SAT minification uses 9 tex samples. SAT can be built on CPU in 1 pass, O(N) but here it's built in 4 passes. For shadertoy preview to work, this SAT is dynamically rescaled to fit iResolution.y.
/*

Copyright 2016 Valtteri "tsone" Heikkilä

This work is licensed under the Creative Commons Attribution 4.0 International License.
To view a copy of this license, visit http://creativecommons.org/licenses/by/4.0/

*/


// NOTE: The shader is not optimized.


// Texture size multiplier. See main(). (Also see 'Buf A' pass.)
float M;
// SAT size in texels (as stored in FB in iChannel0). See main().
vec2 TS;
vec2 INVTS;

float length2(in vec2 v) { return dot(v, v); }


vec3 SATSample(in vec2 p, in vec2 s, in vec2 fbres)
{
    vec2 sc = TS / fbres;
    vec2 mx = (TS - .5) / TS;    
    
    float area = (4. * TS.x*TS.y) * s.x*s.y;
    
    p -= INVTS;
    p -= floor(p - s);

    vec2 it = floor(p + s);
    
    vec2 at = INVTS + p - s;
    vec2 bt = INVTS + fract(p + vec2(s.x, -s.y));
    vec2 ct = INVTS + fract(p + vec2(-s.x, s.y));
    vec2 dt = INVTS + fract(p + s);
    vec2 b2t = vec2(mx.x, bt.y);
    vec2 c2t = vec2(ct.x, mx.y);
    vec2 d2t = vec2(mx);
    vec2 d3t = vec2(mx.x, dt.y);
    vec2 d4t = vec2(dt.x, mx.y);

	vec3 a  = texture2D(iChannel0, sc*at ).rgb;
	vec3 b  = texture2D(iChannel0, sc*bt ).rgb;
	vec3 c  = texture2D(iChannel0, sc*ct ).rgb;
	vec3 d  = texture2D(iChannel0, sc*dt ).rgb;
    vec3 b2 = texture2D(iChannel0, sc*b2t).rgb;
    vec3 c2 = texture2D(iChannel0, sc*c2t).rgb;
    vec3 d2 = texture2D(iChannel0, sc*d2t).rgb;
    vec3 d3 = texture2D(iChannel0, sc*d3t).rgb;
    vec3 d4 = texture2D(iChannel0, sc*d4t).rgb;
    
    return (a - (it.x*b2 + b) - (it.y*c2 + c)
            + (it.x*it.y*d2 + it.x*d3 + it.y*d4 + d)) / area;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    M = max(ceil(iChannelResolution[1].y / iResolution.y), 1.);
    TS = iChannelResolution[1].xy / M;
    INVTS = 1. / TS;
    
    float ti = .2 * cos(.92*iGlobalTime);

    // Intersect plane and rotate texture coordinates.
    vec3 c = fragCoord.xyy - vec3(.5*iResolution.x, iResolution.yy);
    c.y += 1. * iResolution.y;
    c.xy /= .02*c.z * iResolution.xy;
    float sc = 6. - 2.*sin(iGlobalTime);
    mat2 mat = sc * mat2(cos(ti), -sin(ti), sin(ti), cos(ti));
    vec2 tc = mat * c.xy;
    
    // SAT sample using derivates.
    vec2 dtc = fwidth(tc);
    vec3 s = SATSample(tc, dtc, iChannelResolution[0].xy);
    
    // Mipmap sampling.
    // TODO: Make sure mipmap uses anisotropic sampling.
    float borderx = (iMouse.z > 0.) ? iMouse.x : .5*iResolution.x;
    if (length2(dtc) < .25/length(TS) || fragCoord.x > borderx) {
        s = texture2D(iChannel1, tc).rgb;
        s = pow(s, vec3(2.2)); // Gamma decode.
    }
    
    // Border.
    s.gb *= clamp(abs(fragCoord.x - borderx) / 2.5, .375, 1.);

    // Gamma encode.
    s = pow(s, vec3(1./2.2));
    fragColor = vec4(s, 1.);    
}
