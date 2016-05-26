// Shader downloaded from https://www.shadertoy.com/view/ll2SRz
// written by shadertoy user dr2
//
// Name: Wobbly Blob
// Description: The ancient Temple of the Wobbly Blob; use the mouse for a closer look.
// "Wobbly Blob" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

vec4 Hashv4f (float p)
{
  return fract (sin (p + cHashA4) * cHashM);
}

vec4 Hashv4v3 (vec3 p)
{
  const vec3 cHashVA3 = vec3 (37.1, 61.7, 12.4);
  const vec3 e = vec3 (1., 0., 0.);
  return fract (sin (vec4 (dot (p + e.yyy, cHashVA3), dot (p + e.xyy, cHashVA3),
     dot (p + e.yxy, cHashVA3), dot (p + e.xxy, cHashVA3))) * cHashM);
}

float Noisefv2 (vec2 p)
{
  vec2 i = floor (p);
  vec2 f = fract (p);
  f = f * f * (3. - 2. * f);
  vec4 t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

float Noisefv3a (vec3 p)
{
  vec3 i, f;
  i = floor (p);  f = fract (p);
  f *= f * (3. - 2. * f);
  vec4 t1 = Hashv4v3 (i);
  vec4 t2 = Hashv4v3 (i + vec3 (0., 0., 1.));
  return mix (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
              mix (mix (t2.x, t2.y, f.x), mix (t2.z, t2.w, f.x), f.y), f.z);
}

float Fbm3 (vec3 p)
{
  const mat3 mr = mat3 (0., 0.8, 0.6, -0.8, 0.36, -0.48, -0.6, -0.48, 0.64);
  float f, a, am, ap;
  f = 0.;  a = 0.5;
  am = 0.5;  ap = 4.;
  p *= 0.5;
  for (int i = 0; i < 6; i ++) {
    f += a * Noisefv3a (p);
    p *= mr * ap;  a *= am;
  }
  return f;
}

float Fbmn (vec3 p, vec3 n)
{
  vec3 s;
  float a;
  s = vec3 (0.);
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * vec3 (Noisefv2 (p.yz), Noisefv2 (p.zx), Noisefv2 (p.xy));
    a *= 0.5;
    p *= 2.;
  }
  return dot (s, abs (n));
}

vec3 VaryNf (vec3 p, vec3 n, float f)
{
  vec3 g;
  float s;
  vec3 e = vec3 (0.1, 0., 0.);
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float SmoothMin (float a, float b, float r)
{
  float h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
  return mix (b, a, h) - r * h * (1. - h);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

vec3 qHit, sunDir;
float tCur;
int idObj;
const float dstFar = 100.;
const int idBase = 1, idCol = 2, idColEnd = 3, idTop = 4, idReflObj = 5;

vec3 SkyBg (vec3 rd)
{
  return mix (vec3 (0.1, 0.1, 0.5), vec3 (0.2, 0.2, 0.5),
     1. - max (rd.y, 0.));
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  vec3 p, q, cSun, clCol, col;
  float fCloud, cloudLo, cloudRngI, atFac, colSum, attSum, s,
     att, a, dDotS, ds;
  const int nLay = 60;
  cloudLo = 300.;  cloudRngI = 1./200.;  atFac = 0.035;
  fCloud = 0.45;
  if (rd.y > 0.) {
    fCloud = clamp (fCloud, 0., 1.);
    dDotS = max (dot (rd, sunDir), 0.);
    ro.xz += 2. * tCur;
    p = ro;
    p.xz += (cloudLo - p.y) * rd.xz / rd.y;
    p.y = cloudLo;
    ds = 1. / (cloudRngI * rd.y * (2. - rd.y) * float (nLay));
    colSum = 0.;  attSum = 0.;
    s = 0.;  att = 0.;
    for (int j = 0; j < nLay; j ++) {
      q = p + rd * s;
      att += atFac * max (fCloud - Fbm3 (0.007 * q), 0.);
      a = (1. - attSum) * att;
      colSum += a * (q.y - cloudLo) * cloudRngI;
      attSum += a;  s += ds;
      if (attSum >= 1.) break;
    }
    colSum += 0.5 * min ((1. - attSum) * pow (dDotS, 3.), 1.);
    clCol = vec3 (1.) * 2.8 * (colSum + 0.05);
    cSun = vec3 (1.) * clamp ((min (pow (dDotS, 1500.) * 2., 1.) +
       min (pow (dDotS, 10.) * 0.75, 1.)), 0., 1.);
    col = clamp (mix (SkyBg (rd) + cSun, clCol, attSum), 0., 1.);
    col = mix (col, SkyBg (rd), pow (1. - rd.y, 16.));
  } else col = SkyBg (rd);
  return col;
}

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col;
  vec2 p;
  float w, f;
  if (rd.y > 0.) col = SkyCol (ro, rd);
  else {
    p = ro.xz - ro.y * rd.xz / rd.y;
    w = 1.;
    f = 0.;
    for (int j = 0; j < 3; j ++) {
      f += w * Noisefv2 (0.1 * p);  w *= 0.5;  p *= 2.;
    }
    col = mix ((1. + min (f, 1.)) * 0.5 * vec3 (0.2, 0.15, 0.1),
       0.4 * vec3 (0.3, 0.4, 0.6), pow (1. + rd.y, 5.));
  }
  return col;
}

vec3 SMap (vec3 p, float t)
{
  float f;
  f = 2.;
  for (int k = 0; k < 5; k ++) {
    p += 0.4 * sin (1.7 * p.yzx / f + f * t);
    f *= 0.8;
  }
  return p;
}

float BlobDf (vec3 p)
{
  float d;
  p.xz = Rot2D (p.xz, 0.2 * tCur);
  d = 0.2 * SmoothMin (PrSphDf (SMap (p - vec3 (0.7, 0., 0.), tCur + 2.),
     1.1 + 0.31 * sin (tCur)),
     PrSphDf (SMap (p + vec3 (0.7, 0., 0.), 1.3 * tCur),
     1. + 0.41 * sin (1.7 * tCur)), 0.5);
  return max (d, - p.y - 2.3);
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, da, db, wr;
  dMin = dstFar;
  q = p;
  d = PrBoxDf (q, vec3 (6.8, 0.101, 8.8));
  q.y -= 0.15;
  d = min (d, PrBoxDf (q, vec3 (6.5, 0.101, 8.5)));
  q.y -= 0.15;
  d = min (d, PrBoxDf (q, vec3 (6.2, 0.101, 8.2)));
  d = max (d, - PrCylDf (q.xzy, 3.5, 0.5));
  if (d < dMin) { dMin = d;  idObj = idBase;  qHit = q; }
  q.y -= 5.52;
  d = max (PrBoxDf (q, vec3 (5.8, 0.05, 7.8)),
     - PrBoxDf (q, vec3 (4.2, 0.4, 6.2)));
  if (d < dMin) { dMin = d;  idObj = idTop;  qHit = q; }
  q = p;  q.y -= 3.1;
  db = max (PrBoxDf (q, vec3 (6., 5., 8.)),
     - PrBoxDf (q, vec3 (4., 5., 6.)));
  q = p;  q.xz = mod (q.xz, 2.) - 1.;  q.y -= 3.1;
  wr = q.y / 2.5;
  d = max (PrCylDf (q.xzy, 0.27 * (1.05 - 0.05 * wr * wr), 2.55), db);
  if (d < dMin) { dMin = d;  idObj = idCol;  qHit = q; }
  q = p;  q.xz = mod (q.xz, 2.) - 1.;  q.y = abs (q.y - 3.1) - 2.5;
  d = PrCylDf (q.xzy, 0.4, 0.07);
  q.y -= 0.14;
  d = max (min (d, PrBoxDf (q, vec3 (0.5, 0.07, 0.5))), db);
  if (d < dMin) { dMin = d;  idObj = idColEnd;  qHit = q; }
  q = p;  q.y -= 2.2;  
  d = BlobDf (q);
  if (d < dMin) { dMin = d;  idObj = idReflObj;  qHit = q; }
  q.y -= -1.9;
  d = PrCylDf (q.xzy, 3.5, 0.02);
  if (d < dMin) { dMin = d;  idObj = idReflObj;  qHit = q; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
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

#define SHADOW 1

float ObjSShadow (vec3 ro, vec3 rd)
{
#if SHADOW
  float sh, d, h;
  sh = 1.;
  d = 0.05;
  for (int i = 0; i < 50; i ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 30. * h / d);
    d += 0.1 + 0.011 * d;
    if (h < 0.001) break;
  }
  return max (sh, 0.);
#else
  return 1.;
#endif
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 objCol, col, rdd, vn, vnw;
  vec2 vnC;
  float dstHit, refl, dif, bk, sh, a, t1, t2;
  int idObjT, showBg;
  const int nRefl = 3;
  refl = 1.;
  showBg = 0;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar && idObj == idReflObj) {
    for (int k = 0; k < nRefl; k ++) {
      ro += rd * dstHit;
      rd = reflect (rd, ObjNf (ro));
      ro += 0.01 * rd;
      refl *= 0.8;
      idObj = -1;
      dstHit = ObjRay (ro, rd);
      if (dstHit >= dstFar || idObj != idReflObj) break;
    }
    if (dstHit >= dstFar) showBg = 1;
  } else if (dstHit >= dstFar) showBg = 1;
  if (showBg > 0) col = refl * BgCol (ro, rd);
  else {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == idCol || idObj == idColEnd) {
      a = 0.5 - mod (20. * (atan (qHit.x, qHit.z) / (2. * pi) + 0.5), 1.);
      vn.xz = Rot2D (vn.xz, -0.15 * pi * sin (pi * a));
    }
    if (idObj == idBase) {
      objCol = vec3 (0.3, 0.3, 0.25);
      vnC = vec2 (10., 3.);
    } else if (idObj == idTop) {
      objCol = vec3 (0.8, 0.6, 0.2);
      vnC = vec2 (40., 0.5);
    } else if (idObj == idCol || idObj == idColEnd) {
      objCol = vec3 (0.4, 0.35, 0.3);
      vnC = vec2 (20., 1.);
    } else {
      objCol = vec3 (0.7);
      vnC = vec2 (0.);
    }
    if (vnC.x != 0.) vn = VaryNf (vnC.x * qHit, vn, vnC.y);
    sh = ObjSShadow (ro, sunDir);
    bk = max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.);
    dif = max (dot (vn, sunDir), 0.);
    col = refl * objCol * (0.2 * (1. + bk) +  dif * (0.2 + 0.8 * sh) +
       0.3 * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.));
  }
  return sqrt (clamp (col, 0., 1.));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 canvas = iResolution.xy;
  vec2 uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  vec4 mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  mat3 vuMat;
  vec3 ro, rd, vd, u;
  float dist, az, f, t;
  t = 0.02 * tCur + 0.3 * pi;
  sunDir = normalize (vec3 (sin (t), 1.5, cos (t)));
  if (mPtr.z <= 0.) {
    dist = 30.;
    az = 0.75 * pi - 0.05 * tCur;
  } else {
    dist = max (3.5, 30. - 60. * mPtr.y);
    az =  0.75 * pi + 2.5 * pi * mPtr.x;
  }
  ro = dist * vec3 (sin (az), 0., cos (az));
  ro.y = 5.;
  vd = normalize (vec3 (0., 3., 0.) - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (uv, 5.));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
