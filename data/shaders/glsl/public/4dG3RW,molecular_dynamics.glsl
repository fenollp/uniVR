// Shader downloaded from https://www.shadertoy.com/view/4dG3RW
// written by shadertoy user dr2
//
// Name: Molecular Dynamics
// Description: Molecular dynamics simulation of soft disks
// "Molecular Dynamics" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
Simple but inefficient MD program for 2D soft disks. The algorithm
parallelizes but is useless for large systems.

Storing non-pixel data in textures follows iq's approach.

Since the refresh rate is limited to 60 fps, doing multiple compute steps 
between display updates improves performance. Pixel-based rendering of 
large numbers of disks is also time consuming. 

Mouse click restarts run.
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

const float txRow = 32.;

vec4 Loadv4 (int idVar)
{
  float fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

const int nMolEdge = 20;
const int nMol = nMolEdge * nMolEdge;

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec3 col;
  vec2 uv, ut, q;
  float bFac, dMin, b;
  uv = 2. * fragCoord / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  ut = abs (uv) - vec2 (1.);
  b = max (ut.x, ut.y);
  ut = abs (ut);
  if (b > 0.003) col = vec3 (0.82);
  else if (b < 0. && min (ut.x, ut.y) < 0.01) col = vec3 (0.3, 0.3, 1.);
  else {
    bFac = Loadv4 (nMol).y;
    q = 0.5 * (bFac * float (nMolEdge) + 0.5) * uv;
    dMin = 1000.;
    for (int n = 0; n < nMol; n ++)
       dMin = min (dMin, length (q - Loadv4 (n).xy));
    col = mix (vec3 (0.2),  vec3 (0., 1., 0.), 1. - smoothstep (0.4, 0.5, dMin));
  }
  fragColor = vec4 (col, 1.);
}
