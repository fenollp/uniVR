// Shader downloaded from https://www.shadertoy.com/view/MdKSWz
// written by shadertoy user dr2
//
// Name: Gray-Scott Explorer
// Description: Modeling a simple but complex chemical process - see the source.
// "Gray-Scott Explorer" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  The autocatalytic Gray-Scott system involves two chemical reactions
  U + 2V -> 3V and V -> P.
  In terms of partial differential equations, where U = U(x,y,t), etc,
  with diffusion added (fixed diffusion constants D_u and D_v that
  differ significantly), these correspond to
    dU/dt = D_u del^2 U - UV^2 + f(1 - U)
    dV/dt = D_v del^2 V + UV^2 - (f + k)V
  where f is the feed rate (coupled to reservoirs with U=1 and V=0) and
  k is the rate constant for V->P.

  The equations are numerically integrated using the Euler method (on a
  regular CPU use the stable ADI method that allows a 10x larger time
  step). A small degree of randomness is added to the initial state to
  break symmetry, so each run will be different; boundaries are periodic.

  The left and right sliders set the k and f parameters; the values are
  shown x100. The button cycles through several interesting parameter
  presets; there are many other combinations worth examining. Some
  patterns are slow to evolve; patience.

  Online sources include:
   http://blog.hvidtfeldts.net/index.php/2012/08/
     reaction-diffusion-systems/
   http://mrob.com/pub/comp/xmorphia/pearson-classes.html
   https://www.shadertoy.com/view/MdVGRh
*/

vec4 Loadv4 (int idVar);
vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, vec2 slVal);

float gSize;

float Fval (vec2 g)
{
  return Loadv4 (int (dot (mod (g, gSize), vec2 (1., gSize)))).x;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 hs;
  vec3 col, vn, ltDir;
  vec2 canvas, uv, ut, gv, sv, e;
  float w;
  int gSizeSq;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  ltDir = normalize (vec3 (-1., 3., 1.));
  gSize = (canvas.y > 512.) ? 512. : (canvas.y > 200.) ? 256. : 32.;
  gSizeSq = int (gSize * gSize);
  ut = abs (uv) - vec2 (1.);
  if (max (ut.x, ut.y) > 0.) {
    col = ShowWg (uv, canvas, vec3 (0.82), Loadv4 (3).zw);
  } else {
    gv = gSize * (0.5 * uv + 0.5);
    sv = floor (gv);
    e = vec2 (1., 0.);
    hs = vec4 (Fval (sv), Fval (sv + e), Fval (sv + e.yx), Fval (sv + e.xx));
    vn = normalize (vec3 (hs.x - hs.w - hs.y + hs.z, 0.5,
       hs.x - hs.w + hs.y - hs.z));
    gv -= sv;
    w = mix (mix (hs.x, hs.y, gv.x), mix (hs.z, hs.w, gv.x), gv.y);
    col = mix (vec3 (1., 1., 0.3), vec3 (0., 0., 0.5), smoothstep (0.3, 0.7, w));
    col *= 0.2 + 0.8 * max (dot (vn, ltDir), 0.) +
       0.5 * pow (max (0., dot (ltDir, reflect (vec3 (0., -1., 0.), vn))), 32.);
  }
  fragColor = vec4 (col, 1.);
}

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, gSize), floor (fi / gSize)) + 0.5) /
     txSize);
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

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, vec2 slVal)
{
  vec4 wgBx[3];
  vec3 c1, c2;
  vec2 ut, ust;
  float vW[2], asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (0.36 * asp, 0., 0.012 * asp, 0.25);
  wgBx[1] = vec4 (0.44 * asp, 0., 0.012 * asp, 0.25);
  wgBx[2] = vec4 (0.4 * asp, -0.4, 0.013 * asp, 0.);
  vW[0] = slVal.x;
  vW[1] = slVal.y;
  c1 = vec3 (0., 0.6, 0.);
  c2 = vec3 (1., 1., 0.);
  for (int k = 0; k < 2; k ++) {
    ut = 0.5 * uv - wgBx[k].xy;
    ust = abs (ut) - wgBx[k].zw * vec2 (0.7, 1.);
    if (max (ust.x, ust.y) < 0.) {
      if  (min (abs (ust.x), abs (ust.y)) * canvas.y < 2.) col = c2;
      else col = (mod (0.5 * ((0.5 * uv.y - wgBx[k].y) / wgBx[k].w - 0.99), 0.05) *
         canvas.y < 5.) ? c2 : vec3 (0.7);
    }
    ut.y -= (vW[k] - 0.5) * 2. * wgBx[k].w;
    ut = abs (ut) * vec2 (1., 2.);
    if (abs (max (ut.x, ut.y) - 0.015) < 0.006) col = c1;
    col = mix (col, c1, ShowInt (0.5 * uv - wgBx[k].xy -
       wgBx[k].zw * vec2 (1., -1.) - vec2 (0.0045, -0.06),
       0.028 * vec2 (asp, 1.), 2., clamp (floor (1000. * vW[k] * 0.1 + 1e-4),
       1., 99.)));
  }
  if (length (0.5 * uv - wgBx[2].xy) < wgBx[2].z) {
    col = (length (0.5 * uv - wgBx[2].xy) < 0.7 * wgBx[2].z) ? c1 : c2;
  }
  return col;
}
