// Shader downloaded from https://www.shadertoy.com/view/MdVXRW
// written by shadertoy user aiekick
//
// Name: Cook-Torrance Light Model
// Description: shader based for 90% of the code on shane shader  : [url=https://www.shadertoy.com/view/MscSDB]Cellular Tiled Tunnel[/url]
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/*
antialiased code from shane simpleAA : https://www.shadertoy.com/view/4d3SWf
shader in bufA based for 90% of the code on shane shader 
Cellular Tiled Tunnel https://www.shadertoy.com/view/MscSDB 
*/

void mainImage( out vec4 f, vec2 g )
{
    vec2 si = iResolution.xy;
   
    const float AA = 2.;
    
    vec2 uv = g/si;
    
    vec2 pix = 2./si/AA;

    vec3 col = vec3(0);

    for (float i=0.; i<AA; i++)
    { 
        vec2 uvOffs = uv + vec2(floor(i/AA), mod(i, AA))*pix;
        col += clamp(texture2D(iChannel0,uvOffs).rgb, 0., 1.);
    }
    
    col /= AA;

    f = vec4(col, 1.);   
}
