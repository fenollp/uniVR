// Shader downloaded from https://www.shadertoy.com/view/MdGXRm
// written by shadertoy user dr2
//
// Name: Chaotic Pendulum
// Description: Chaotic motion of a pendulum - see source
// "Chaotic Pendulum" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  The pendulum mass is attracted by several 'magnets' resulting in
  chaotic motion.

  The sliders control the strength and number of magnets. A trace of the
  recent trajectory is shown, and the magnets flash when approached.
*/

float PrSphDf (vec3 p, float s);
float PrCylDf (vec3 p, float r, float h);
float PrCapsDf (vec3 p, float r, float h);
float ShowInt (vec2 q, vec2 cBox, float mxChar, float val);
vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, vec4 slVal);
float SmoothBump (float lo, float hi, float w, float x);
vec2 Rot2D (vec2 q, float a);
vec4 Loadv4 (int idVar);

const float pi = 3.14159;
const float txRow = 32.;

#define MAX_SITE 9

vec3 rSite[MAX_SITE], rb, ltDir, qHit;
float dstFar, nSite, penLen, hDist, vDist;
int idObj;
const int ntPoint = 400;

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, s;
  dMin = dstFar;
  p.y -= - 0.5 * penLen;
  q = p;  q.y -= penLen + vDist;
  s = length (rb.xy);
  if (s > 0.) {
    q.xz = Rot2D (q.xz, atan (rb.y, - rb.x));
    q.xy = Rot2D (q.xy, atan (s, - rb.z));
  }
  q.y -= -0.5 * penLen;
  d = PrCylDf (q.xzy, 0.03, 0.5 * penLen);
  if (d < dMin) { dMin = d;  idObj = 1;  qHit = q; }
  q = p - rb.xzy;
  q.y -= penLen + vDist;
  d = PrSphDf (q, 0.12);
  if (d < dMin) { dMin = d;  idObj = 2; }
  q = p;
  d = PrCylDf (q.xzy, 2., 0.1);
  if (d < dMin) { dMin = d;  idObj = 3; }
  q = p;  q.z -= 2.25;
  d = PrCapsDf (q, 0.1, 0.25);
  q = p;  q.yz -= vec2 (0.5 * (penLen + vDist), 2.5);
  d = min (d, PrCapsDf (q.xzy, 0.1, 0.5 * (penLen + vDist)));
  q.yz -= vec2 (0.5 * (penLen + vDist), -1.25);
  d = min (d, PrCapsDf (q, 0.1, 1.25));
  if (d < dMin) { dMin = d;  idObj = 4; }
  for (int j = 0; j < MAX_SITE; j ++) {
    if (float (j) == nSite) break;
    q = p;  q.xz -= rSite[j].xy;  q.y -= 0.125;
    d = PrCylDf (q.xzy, 0.12, 0.02);
    if (d < dMin) { dMin = d;  idObj = 5 + j; }
  }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 120; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col;
  vec2 p;
  float dstObj, s, h;
  int idObjT;
  bool isNr;
  dstObj = ObjRay (ro, rd);
  if (dstObj < dstFar) {
    ro += rd * dstObj;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == 1) {
      col = vec3 (0.9, 1., 0.9) * (0.3 + 0.7 *
         SmoothBump (0.1, 0.9, 0.05, mod (10. * qHit.y, 1.)));
    } else if (idObj == 2) {
      col = vec3 (1., 0.9, 0.2);
    } else if (idObj == 3) {
      col = vec3 (0.5, 0.5, 0.55);
      if (vn.y > 0.) {
        s = 1.;
        h = 1.;
        for (int j = 0; j < ntPoint; j ++) {
          s = min (s, h * length (Loadv4 (5 + j).xy - ro.xz));
          h += 1. / float (ntPoint);
        }
        col = mix (vec3 (1., 1., 0.), col, smoothstep (0.03, 0.04, s));
      }
    } else if (idObj == 4) {
      col = vec3 (0.6, 0.3, 0.);
    } else if (idObj >= 5) {
      isNr = false;
      for (int j = 0; j < MAX_SITE; j ++) {
        if (j == idObj - 5) {
          if (length (rb.xy - rSite[j].xy) < 0.5) isNr = true;
        }
      }
      col = isNr ? vec3 (1., 0., 0.) : vec3 (0., 1., 0.);
    }
    col = col * (0.2 + 0.8 * max (dot (vn, ltDir), 0.) +
       0.5 * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.));
  } else {
    rd.yz = Rot2D (rd.yz, -0.3 * pi);
    col = (1. - 2.5 * dot (rd.xy, rd.xy)) * vec3 (0.1, 0.1, 0.2);
  }
  col = clamp (col, 0., 1.);
  return col;
}

void SetSites ()
{
  float a, fj;
  for (int j = 0; j < MAX_SITE; j ++) {
    fj = float (j);
    if (fj == nSite) break;
    a = (fj + 0.5) * 2. * pi / nSite;
    rSite[j] = vec3 (hDist * sin (a), hDist * cos (a), - penLen - vDist);
  }
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 stDat, slVal;
  vec3 ro, rd, col;
  vec2 canvas, uv, ori, ca, sa;;
  float az, el, asp, eTot;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  dstFar = 30.;
  penLen = 4.;
  hDist = 1.6;
  vDist = 0.4;
  asp = canvas.x / canvas.y;
  stDat = Loadv4 (0);
  eTot = stDat.y;
  el = stDat.z;
  az = stDat.w;
  stDat = Loadv4 (1);
  rb = stDat.xyz;
  slVal = Loadv4 (3);
  nSite = floor (10. * slVal.y + 0.01);
  SetSites ();
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  rd = vuMat * normalize (vec3 (uv, 6.));
  ro = vuMat * vec3 (0., 0., -20.);
  ltDir = vuMat * normalize (vec3 (1., 2., -1.));
  col = ShowScene (ro, rd);
  col = ShowWg (uv, canvas, col, slVal);
  if (false) col = mix (col, vec3 (1., 1., 0.),
     ShowInt (0.5 * uv - vec2 (0.47 * asp, - 0.45),
     vec2 (0.06 * asp, 0.03), 4., floor (100. * eTot)));
  fragColor = vec4 (col, 1.);
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, vec4 slVal)
{
  vec4 wgBx[2];
  vec2 ut, ust;
  float vW[2], asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (0.38 * asp, -0.1, 0.012 * asp, 0.18);
  wgBx[1] = vec4 (0.45 * asp, -0.1, 0.012 * asp, 0.18);
  vW[0] = slVal.x;
  vW[1] = slVal.y;
  for (int k = 0; k < 2; k ++) {
    ut = 0.5 * uv - wgBx[k].xy;
    ust = abs (ut) - wgBx[k].zw * vec2 (0.7, 1.);
    if (max (ust.x, ust.y) < 0.) {
      if  (min (abs (ust.x), abs (ust.y)) * canvas.y < 2.) col = vec3 (1., 1., 0.);
      else col = (mod (0.5 * ((0.5 * uv.y - wgBx[k].y) / wgBx[k].w - 0.99), 0.1) *
         canvas.y < 6.) ? vec3 (1., 1., 0.) : vec3 (0.4, 0.3, 0.);
    }
    ut.y -= (vW[k] - 0.5) * 2. * wgBx[k].w;
    ut = abs (ut) * vec2 (1., 2.);
    if (abs (max (ut.x, ut.y) - 0.015) < 0.006) col = vec3 (0.1, 0.5, 1.);
  }
  return col;
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

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}
