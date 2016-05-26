// Shader downloaded from https://www.shadertoy.com/view/4dtXzX
// written by shadertoy user huttarl
//
// Name: Elliptic curve explorer
// Description: Click the mouse to set the a and b parameters for the elliptic curve, to see how they affect the shape of the curve. The red lines show values for a and b that introduce singular points, making the curve non-elliptic.
// This is an exercise in preparation for another shader I'm working on,
// https://www.shadertoy.com/view/lstXRj (not published yet).

// In particular, it lets you explore how changes in a and b affect the curve.
// Click mouse to set a = mouse x coordinate, b = mouse y.

// The red curve shows values for a and b that introduce singular points in
// the curve, such as cusps (a=b=0), self-intersections (certain b > 0), or
// isolated points (certain b < 0), which make the curve non-elliptic.

// For values of a and b left of the red curve, the elliptic includes a separate
// round shape. For values above the red curve, the elliptic has a "horseshoe"
// bend. For values below the red curve, the elliptic looks more like a simple
// hyperbola.

// See https://en.wikipedia.org/wiki/Elliptic_curve about elliptic curves.

// HT to marius at https://www.shadertoy.com/view/Mt2Gzw, who already made a shader
// with elliptic curves. I used his delta idea (adapted).

// TODO: display the values of a and b on-screen, e.g. using digits from
//    https://www.shadertoy.com/view/Xst3zX
// TODO: use a 1:1 aspect ratio?
// TODO: make the distance formulas more accurate for black line
//    See e.g. https://www.shadertoy.com/view/Xd2Xz1
//     or https://www.shadertoy.com/view/4ts3DB ?
//   For the red line, we just get by with vertical distance to the nearest
//   line.
//   For the cubic curve, maybe also look at
//    http://www.gamedev.net/topic/419160-distance-from-point-to-cubic-curve/
//   What I see online talks about distance to a cubic spline, so we may need
//   to approximate the curve as a spline.

const float PI = 3.14159265;

float distRedLine(vec2 p) {
    // The red line is where 4a^3 + 27b^2 = 0.
    if (p.x > 0.) return 999999.;
    // Just return vertical distance -- good enough.
    float y = sqrt(p.x * p.x * p.x * -4./27.);
    return abs(abs(p.y) - y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = (uv * 2. - 1.) * 5.; // center at origin and zoom out.
    
    vec2 m = iMouse.xy / iResolution.xy;
    m = (m * 2. - 1.) * 5.;
    
    float a = m.x, b = m.y;
        
    float delta = -uv.y * uv.y + uv.x * uv.x * uv.x + a * uv.x + b;
    float ad = abs(delta);

    const float hueChange = 1.;
    vec4 curveColor = vec4(
        sin(ad * hueChange + iGlobalTime) * 0.5 + 0.5,
        sin(ad * hueChange + iGlobalTime + PI * 2. / 3.) * 0.5 + 0.5,
        sin(ad * hueChange + iGlobalTime + PI * 4. / 3.) * 0.5 + 0.5,
	    1.0);

    // Thin black line in the middle
    curveColor *= min(ad * 10., 1.);
    
    vec4 background = vec4(1.0);
    
    // Show where values of a,b would make the curve non-singular.
    // When the determinant of a and b is zero, the curve is singular.
    float dist = distRedLine(uv); // distance from red line
    float color = min(dist * 20., 1.0);
    background *= vec4(1., color, color, 1.);

    // JG wanted rainbow colors.
    // Rainbow on black:
    // fragColor = vec4(r1, g1, b1, 1.0) * pow(0.8, ad*5.);
    // Rainbow on white:
    fragColor = mix(curveColor, background, 1. - pow(0.2, ad));

    // a little fancy coloring...
    // fragColor = vec4(ad, pow(abs(delta), 0.16), pow(abs(delta), 0.1), 1.0);
}
