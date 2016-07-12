// Shader downloaded from https://www.shadertoy.com/view/MsySWz
// written by shadertoy user aiekick
//
// Name: Wax Tunnel
// Description: trying to do one approch of Sub Surface Scattering.
//    the wax is better without texture lol. do you prefer with or without ?
// Created by Stephane Cuillerdier - Aiekick/2015 (twitter:@aiekick)
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Tuned via XShade (http://www.funparadigm.com/xshade/)

/*
trying to do one approch of Sub Surface Scattering.
the wax is better without texture lol. do you prefer with or without displaced texture ?
*/

const float AA = 4.;
   
// shane code
void mainImage( out vec4 f, vec2 g )
{
    vec2 si = iResolution.xy;
    vec2 uv = g/si;
    vec3 col = vec3(0);
    for (float i=0.; i<AA; i++)
    {
        vec2 uvOffs = uv + vec2(floor(i/AA), mod(i, AA))*(2./si/AA);
        col += clamp(texture2D(iChannel0,uvOffs).rgb, 0., 1.);
    }
    f = vec4(col/AA, 1.);   
}
