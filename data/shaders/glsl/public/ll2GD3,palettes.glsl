// Shader downloaded from https://www.shadertoy.com/view/ll2GD3
// written by shadertoy user iq
//
// Name: Palettes
// Description: Cosine based palettes (faster than linear interpolation or triangle waves). 
//    More info: [url]http://iquilezles.org/www/articles/palettes/palettes.htm[/url]
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


// A simple way to create color variation in a cheap way (yes, trigonometrics ARE cheap
// in the GPU, don't try to be smart and use a triangle wave instead).

// See http://iquilezles.org/www/articles/palettes/palettes.htm for more information


vec3 pal( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d )
{
    return a + b*cos( 6.28318*(c*t+d) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
    
    // animate
    p.x += 0.01*iGlobalTime;
    
    // compute colors
    vec3                col = pal( p.x, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.33,0.67) );
    if( p.y>(1.0/7.0) ) col = pal( p.x, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.0,0.10,0.20) );
    if( p.y>(2.0/7.0) ) col = pal( p.x, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,1.0),vec3(0.3,0.20,0.20) );
    if( p.y>(3.0/7.0) ) col = pal( p.x, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,1.0,0.5),vec3(0.8,0.90,0.30) );
    if( p.y>(4.0/7.0) ) col = pal( p.x, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(1.0,0.7,0.4),vec3(0.0,0.15,0.20) );
    if( p.y>(5.0/7.0) ) col = pal( p.x, vec3(0.5,0.5,0.5),vec3(0.5,0.5,0.5),vec3(2.0,1.0,0.0),vec3(0.5,0.20,0.25) );
    if( p.y>(6.0/7.0) ) col = pal( p.x, vec3(0.8,0.5,0.4),vec3(0.2,0.4,0.2),vec3(2.0,1.0,1.0),vec3(0.0,0.25,0.25) );
    

    // band
    float f = fract(p.y*7.0);
    // borders
    col *= smoothstep( 0.49, 0.47, abs(f-0.5) );
    // shadowing
    col *= 0.5 + 0.5*sqrt(4.0*f*(1.0-f));
    // dithering
    col += (1.0/255.0)*texture2D( iChannel0, fragCoord.xy/iChannelResolution[0].xy ).xyz;

	fragColor = vec4( col, 1.0 );
}