// Shader downloaded from https://www.shadertoy.com/view/Mdy3RW
// written by shadertoy user dr2
//
// Name: Granular Vibration
// Description: Simulation of a vertically vibrated granular layer
// "Granular Vibration" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
Simulation of a vertically vibrated granular layer. Standing waves are
sometimes observed. There are many parameters that can be changed to explore
the problem (e.g., period doubling).

A standard granular particle model with velocity-dependent damping is used. Side
boundaries are periodic.

(See "Molecular Dynamics" shader for brief technical comments.)

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

const int nMolEdge = 24;
const int nMol = nMolEdge * nMolEdge;

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 stDat;
  vec3 col;
  vec2 uv, ut, q;
  float bFac, dMin, b, yBase, bLen;
  uv = 2. * fragCoord / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  ut = abs (uv) - vec2 (1.);
  b = max (ut.x, ut.y);
  ut = abs (ut);
  if (b > 0.003) col = vec3 (0.82);
  else {
    stDat = Loadv4 (nMol);
    bFac = stDat.y;
    yBase = stDat.z;
    bLen = 0.5 * (bFac * float (nMolEdge) + 0.5);
    q = (bLen - 0.5) * uv;
    q.y -= 1.;
    dMin = 1000.;
    for (int n = 0; n < nMol; n ++)
       dMin = min (dMin, length (q - Loadv4 (n).xy));
    col = mix (vec3 (0.2),  vec3 (1., 1., 0.), 1. - smoothstep (0.35, 0.45, dMin));
    col = mix (col, vec3 (0., 1., 0.),
       1. - smoothstep (0.2, 0.3, abs (q.y + bLen - yBase + 0.2)));
  }
  fragColor = vec4 (col, 1.);
}
