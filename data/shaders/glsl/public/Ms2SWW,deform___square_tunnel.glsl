// Shader downloaded from https://www.shadertoy.com/view/Ms2SWW
// written by shadertoy user iq
//
// Name: Deform - square tunnel
// Description: A 2D square tunnel
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    // normalized coordinates (-1 to 1 vertically)
    vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;

    // angle of each pixel to the center of the screen
    float a = atan(p.y,p.x);
    
    // modified distance metric. Usually distance = (x² + y²)^(1/2). By replacing all the "2" numbers
    // by 32 in that formula we can create distance metrics other than the euclidean. The higher the
    // exponent, then more square the metric becomes. More information here:
    
    // http://en.wikipedia.org/wiki/Minkowski_distance
    
    float r = pow( pow(p.x*p.x,16.0) + pow(p.y*p.y,16.0), 1.0/32.0 );
    
    // index texture by angle and radious, and animate along radius    
    vec2 uv = vec2( 0.5/r + 0.5*iGlobalTime,
                    a/3.1416 );

    // fecth color and darken in the center
    vec3 col =  texture2D( iChannel0, uv ).xyz * r;

    fragColor = vec4( col, 1.0 );
}
