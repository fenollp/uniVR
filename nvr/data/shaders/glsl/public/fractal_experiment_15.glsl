// Shader downloaded from https://www.shadertoy.com/view/MstSD4
// written by shadertoy user aiekick
//
// Name: Fractal Experiment 15
// Description: based on my shader : https://www.shadertoy.com/view/4stXR7
//    
//    uncomment the line 29 for see the differents iteration of the fractal based on julia
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/*
shader based on https://www.shadertoy.com/view/4stXR7
antialiased code from shane simpleAA : https://www.shadertoy.com/view/4d3SWf
*/

void mainImage( out vec4 f, vec2 g )
{
    vec2 si = iResolution.xy;
   
    const float AA = 2.;
    
    vec2 uv = g/si;
    
    vec2 pix = AA/si.yy/2.;

    vec3 col = vec3(0);

    for (float i=0.; i<AA; i++)
    { 
        vec2 uvOffs = uv + vec2(floor(i/AA), mod(i, AA))*pix;
        col += clamp(texture2D(iChannel0,uvOffs).rgb, 0., 1.);
    }
    
    col /= AA;

    f = vec4(col, 1.); 
   
}
