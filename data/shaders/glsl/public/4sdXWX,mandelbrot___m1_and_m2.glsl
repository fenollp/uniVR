// Shader downloaded from https://www.shadertoy.com/view/4sdXWX
// written by shadertoy user iq
//
// Name: Mandelbrot - M1 and M2
// Description: The convergent region of the Mandelbrot set (M1, in yellow) and the period-2 region (M2, in blue) have analytical description and don't need iteration to be identified. More info: [url]http://iquilezles.org/www/articles/mset_1bulb/mset1bulb.htm[/url]
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// The convergent region of the Mandelbrot set (M1, in yellow) and the period-2 region 
// (M2, in blue) have analytical description and don't need of iteration to be identified. 
// Naturally, the Mset cannot overla the exterior of a disk of radious 2 (in green)

// More info: http://iquilezles.org/www/articles/mset_1bulb/mset1bulb.htm
    
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (-iResolution.xy + 2.0*fragCoord) / iResolution.y;

    vec2 c = uv*1.2 - vec2(0.65,0.0);
    
    float c2 = dot(c, c);
    float s1 = 256.0*c2*c2 - 96.0*c2 + 32.0*c.x - 3.0;
    float s2 = 16.0*(c2+2.0*c.x+1.0) - 1.0;
    
    // early skip computation inside M1
    if( s1 < 0.0 ) { fragColor = vec4(1.0,0.6,0.1,1.0); return; }
    // early skip computation inside M2
    if( s2 < 0.0 ) { fragColor = vec4(0.2,0.6,1.0,1.0); return; }
    // early skip computation outside |c|>2
    if( c2 > 4.0 ) { fragColor = vec4(0.2,1.0,0.6,1.0); return; }
    
    vec2 z = vec2(0.0, 0.0);

    float n = 0.0;
    for( int i = 0; i<256; i++ )
    {
        z = vec2( z.x*z.x - z.y*z.y, 2.0*z.x*z.y ) + c;

        if( dot(z,z) > 4.0 )
        {
        	n = float(i);
            break;
        }
    }
    
    float f = n / 64.0;
    fragColor = vec4( f, f, f, 1.0);
}