// Shader downloaded from https://www.shadertoy.com/view/Xd3SDn
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 0 (208c)
// Description: // Based on Mandelbrot - smooth from iq shader : https://www.shadertoy.com/view/4df3Rn&amp;amp;amp;amp;lt;br/&amp;amp;amp;amp;gt;seem to be a leather &amp;amp;amp;amp;lt;img src=&amp;amp;amp;amp;quot;/img/emoticonHappy.png&amp;amp;amp;amp;quot;/&amp;amp;amp;amp;gt;
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

// Based on Mandelbrot - smooth from iq shader : https://www.shadertoy.com/view/4df3Rn

/* leather (208c)
void mainImage( out vec4 f, vec2 z )
{
	f.xyz = iResolution;
	z = (z+z-f.xy)/f.y;
    
    for( int i=0; i<2; i++ )
		z.x = z.x / (z.x*z.x + 2.*z.x*z.y - 2.) - 2.,
		z.y = z.y / (-z.y*z.y - 2.) + 1.4 ;

	f += .5 + .5 * cos( log2(log2(dot(z,z))) * .15 + vec4(1,1.6,2,2)) - f;
}/**/

//* leather and tex (256c)
void mainImage( out vec4 f, vec2 z )
{
	f.xyz = iResolution;
	
    f.w = 1.5-texture2D(iChannel0, z/f.xy).x * 1.75;
    
    z = (z+z-f.xy)/f.y;
    
    
	for( int i=0; i<2; i++ )
		z.x = z.x / (z.x*z.x + 2.*z.x*z.y - 2.) - 2.,
		z.y = z.y / (-z.y*z.y - 2.) + 1.4 ;

	f += .5 + .5 * cos( log2(log2(dot(z+f.w,z+f.w))) * .15 + vec4(1,1.6,2,2)) - f;
}/**/

/* leather and tex 2 (249c)
void mainImage( out vec4 f, vec2 z )
{
	f.xyz = iResolution;
	z = (z+z-f.xy)/f.y;
    
    float t = 1.-texture2D(iChannel0, z/2.).x;
    
	for( int i=0; i<2; i++ )
		z.x = z.x / (z.x*z.x + 2.*z.x*z.y - 2.) - 2.,
		z.y = z.y / (-z.y*z.y - 2.) + 1.4 ;

	f += .5 + .5 * cos( log2(log2(dot(z,z))) * t * .15 + vec4(1,1.6,2,2)) - f;
}/**/