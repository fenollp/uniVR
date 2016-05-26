// Shader downloaded from https://www.shadertoy.com/view/MddXRl
// written by shadertoy user dr2
//
// Name: Generalized Life
// Description: An extension of the well-known Game of Life cellular automata; see the source for details.
// "Generalized Life" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  An extension of the well-known "Game of Life" cellular automata. Here a much
  larger set of neighbor cells (a 13x13 square) are examined to determine
  whether a cell is born, stays alive, or dies.

  The left pair of sliders set the lower and upper limits to the percentage of
  living neighbors for which a cell is born. The right sliders determine the
  living neighbor range for which a cell remains alive.

  The pushbutton restarts the system in a random (50% alive) state (necessary
  if all cells are dead). More interesting behavior generally appears if the sliders
  are altered without restarting.

  The cycling color shows when cells were born.

  Size of cell array depends on display size.
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

float gSize;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, gSize), floor (fi / gSize)) + 0.5) /
     txSize);
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p;
  p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

float DigSeg (vec2 q)
{
  return (1. - smoothstep (0.13, 0.17, abs (q.x))) *
     (1. - smoothstep (0.5, 0.57, abs (q.y)));
}

float ShowDig (vec2 q, int iv)
{
  float d;
  int k, kk;
  const vec2 vp = vec2 (0.5, 0.5), vm = vec2 (-0.5, 0.5), vo = vec2 (1., 0.);
  if (iv < 5) {
    if (iv == -1) k = 8;
    else if (iv == 0) k = 119;
    else if (iv == 1) k = 36;
    else if (iv == 2) k = 93;
    else if (iv == 3) k = 109;
    else k = 46;
  } else {
    if (iv == 5) k = 107;
    else if (iv == 6) k = 122;
    else if (iv == 7) k = 37;
    else if (iv == 8) k = 127;
    else k = 47;
  }
  q = (q - 0.5) * vec2 (1.7, 2.3);
  d = 0.;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.yx - vo);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.xy - vp);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.xy - vm);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.yx);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.xy + vm);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.xy + vp);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.yx + vo);
  return d;
}

float ShowInt (vec2 q, vec2 cBox, float mxChar, float val)
{
  float nDig, idChar, s, sgn, v;
  q = vec2 (- q.x, q.y) / cBox;
  s = 0.;
  if (min (q.x, q.y) >= 0. && max (q.x, q.y) < 1.) {
    q.x *= mxChar;
    sgn = sign (val);
    val = abs (val);
    nDig = (val > 0.) ? floor (max (log (val) / log (10.), 0.) + 0.001) + 1. : 1.;
    idChar = mxChar - 1. - floor (q.x);
    q.x = fract (q.x);
    v = val / pow (10., mxChar - idChar - 1.);
    if (sgn < 0.) {
      if (idChar == mxChar - nDig - 1.) s = ShowDig (q, -1);
      else ++ v;
    }
    if (idChar >= mxChar - nDig) s = ShowDig (q, int (mod (floor (v), 10.)));
  }
  return s;
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, vec4 limVar)
{
  vec4 wgBx[5];
  vec3 cc;
  vec2 ut, ust;
  float vW[4], asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (-0.45 * asp, 0., 0.012 * asp, 0.18);
  wgBx[1] = vec4 (-0.35 * asp, 0., 0.012 * asp, 0.18);
  wgBx[2] = vec4 ( 0.35 * asp, 0., 0.012 * asp, 0.18);
  wgBx[3] = vec4 ( 0.45 * asp, 0., 0.012 * asp, 0.18);
  wgBx[4] = vec4 ( 0.4 * asp, -0.4, 0.015 * asp, 0.);
  vW[0] = limVar.x;
  vW[1] = limVar.y;
  vW[2] = limVar.z;
  vW[3] = limVar.w;
  for (int k = 0; k < 4; k ++) {
    cc = (k < 2) ? vec3 (0.3, 0.3, 1.) : vec3 (1., 0.2, 0.2);
    ut = 0.5 * uv - wgBx[k].xy;
    ust = abs (ut) - wgBx[k].zw * vec2 (0.7, 1.);
    if (max (ust.x, ust.y) < 0.) {
      if  (min (abs (ust.x), abs (ust.y)) * canvas.y < 2.) col = vec3 (0.3);
      else col = (mod (0.5 * ((0.5 * uv.y - wgBx[k].y) / wgBx[k].w - 0.99), 0.1) *
         canvas.y < 6.) ? vec3 (1., 1., 0.) : vec3 (0.6);
    }
    ut.y -= (vW[k] - 0.5) * 2. * wgBx[k].w;
    ut = abs (ut) * vec2 (1., 2.);
    if (length (ut) < 0.03 && max (ut.x, ut.y) > 0.007) col = cc;
    col = mix (col, cc, ShowInt (0.5 * uv - (wgBx[k].xy + wgBx[k].zw) * vec2 (1., -1.) -
        vec2 (0.0045, -0.06), 0.028 * vec2 (asp, 1.), 2.,
        clamp (floor (100. * vW[k]), 1., 99.)));
  }
  if (length (0.5 * uv - wgBx[4].xy) < wgBx[4].z) {
    col = (length (0.5 * uv - wgBx[4].xy) < 0.7 * wgBx[4].z) ?
       vec3 (1., 1., 0.) : vec3 (1., 0.2, 0.2);
  }
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 stDat, limVar;
  vec3 col;
  vec2 canvas, uv, ut, gPos;
  float c;
  int gSizeSq;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  gSize = (canvas.y > 512.) ? 512. : (canvas.y > 200.) ? 256. : 32.;
  gSizeSq = int (gSize * gSize);
  stDat = Loadv4 (0);
  stDat = Loadv4 (1);
  limVar.xy = stDat.zw;
  stDat = Loadv4 (2);
  limVar.zw = stDat.zw;
  ut = abs (uv) - vec2 (1.);
  if (max (ut.x, ut.y) > 0.) {
    col = ShowWg (uv, canvas, vec3 (0.82), limVar);
  } else {
    gPos = floor (gSize * (0.5 * uv + 0.5));
    c = Loadv4 (int (gSize * gPos.y + gPos.x)).x;
    if (c >= 0.) col = HsvToRgb (vec3 (c, 0.8, 1.));
    else col = vec3 (0.1);
  }
  fragColor = vec4 (col, 1.);
}
