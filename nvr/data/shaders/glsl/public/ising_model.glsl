// Shader downloaded from https://www.shadertoy.com/view/lsVGDh
// written by shadertoy user dr2
//
// Name: Ising Model
// Description: Monte Carlo simulation of the two-dimensional Ising Model
// "Ising Model" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
Monte Carlo simulation of the two-dimensional Ising Model (see Wikipedia for further
information). The system consists of a grid of spins, and the colors correspond to
spin direction (up or down). The slider controls temperature T; at low T the spins
should align in a ferromagnetic state, while at high T they are in a random
paramagnetic state; somewhere in between there is a phase transition (reduce T
gradually to avoid artifacts). (A very crude random number generator is used here
for convenience; for quantitative work this must be replaced by something better.)
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

const float txRow = 64.;

vec4 Loadv4 (int idVar)
{
  float fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

int gSize;

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 stDat;
  vec3 col;
  vec2 uv, ut, gPos;
  float gSizef, tVal;
  uv = 2. * fragCoord / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  ut = abs (uv) - vec2 (1.);
  gSize = (iResolution.y > 160.) ? 128 : 32;
  stDat = Loadv4 (gSize * gSize);
  tVal = stDat.y;
  if (max (ut.x, ut.y) > 0.) {
    col = vec3 (0.82);
    ut = abs (uv - vec2 (1.15, 0.07 * (tVal - 4.))) / vec2 (0.08, 0.04);
    if (length (ut) < 1. && max (ut.x, ut.y) > 0.2)
       col = (tVal > 4.) ? vec3 (1., 0.1, 0.1) :
       ((tVal > 2.) ? vec3 (0.1, 1., 0.1) : vec3 (0.2, 0.2, 1.));
    else {
      ut = abs (uv - vec2 (1.15, 0.)) - vec2 (0.02, 0.3);
      if (max (ut.x, ut.y) < 0.) col =
         (min (abs (ut.x), abs (ut.y)) < 0.01) ? vec3 (0.2) :
	 ((mod (uv.y + 0.3, 0.075) < 0.01) ? vec3 (1., 0., 0.) : vec3 (0.5));
    }
  } else {
    gSizef = float (gSize);
    gPos = floor (gSizef * (0.5 * uv + 0.5));
    col = (Loadv4 (int (gSizef * gPos.y + gPos.x)).x > 0.) ?
       vec3 (1., 1., 0.) : vec3 (1., 0., 1.);
  }
  fragColor = vec4 (col, 1.);
}
