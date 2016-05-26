// Shader downloaded from https://www.shadertoy.com/view/lsG3RW
// written by shadertoy user aiekick
//
// Name: 2D Radial Texture (183c)
// Description: 2D, Radial ,Texture 
// Created by Stephane Cuillerdier - @Aiekick/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/* 183c by GregRostani */
void mainImage(out vec4 f,vec2 g)
{
    vec2 r = iResolution.xy;
    f = iDate;
    g = (g+g-r) / r.y;
	g = vec2(atan(g.x, g.y),length(g))/.1;
	g.x += g.y*sin(f.a*.5);
	f = texture2D(iChannel0,(ceil(g - f.a * 3.)+ f.a)*.01);
}

/* original
void mainImage( out vec4 f, in vec2 g )
{
    float t = iGlobalTime;
	vec2 
        s = iResolution.xy,
        v = (g+g-s)/s.y,
        a = vec2(atan(v.x, v.y),length(v))*10.,
        d;
	a.x += a.y*sin(t*.5);
	d = floor(a-t*3.)+t;
	f = texture2D(iChannel0, d*0.01,-100.);
}*/