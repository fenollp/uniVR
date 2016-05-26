// Shader downloaded from https://www.shadertoy.com/view/4dd3Ds
// written by shadertoy user aiekick
//
// Name: Crumble Spiral (211c)
// Description: Based on my shader [url=https://www.shadertoy.com/view/Xdc3R8#]Easy RM (287c =&gt; 172c)[/url]
//    with another texture its very cool also :) (211c without inverse code )
// Created by Stephane Cuillerdier - @Aiekick/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
based on my shader https://www.shadertoy.com/view/Xdc3R8# 
*/

//#define INVERSE

void mainImage( out vec4 f, vec2 v )
{
    f.xyz = iResolution;
	
	for (int i = 0; i < 60; i++) 
        f.z += length((v-f.xy*.5)*f.z/f.y + sin(f.z - 4.*iDate.w + vec2(1.6,0))) - 2. 
        - texture2D(iChannel0,(v-f.xy)/f.y * 2.).x 
#ifdef INVERSE
		* f.z*0.2
#endif
		;
    f = vec4(1,2,3,1) / (2. + .2*f*f).z;
}
