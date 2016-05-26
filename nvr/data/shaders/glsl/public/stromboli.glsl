// Shader downloaded from https://www.shadertoy.com/view/4l2GDG
// written by shadertoy user dr2
//
// Name: Stromboli
// Description: A 3-D volcano.
// "Stromboli" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

float Hashff (float p)
{
  return fract (sin (p) * cHashM);
}

vec2 Hashv2f (float p)
{
  return fract (sin (p + cHashA4.xy) * cHashM);
}

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

float Noiseff (float p)
{
  float i, f;
  i = floor (p);  f = fract (p);
  f = f * f * (3. - 2. * f);
  vec2 t = Hashv2f (i);
  return mix (t.x, t.y, f);
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

float Fbm1 (float p)
{
  float s = 0.;
  float a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * Noiseff (p);
    a *= 0.5;
    p *= 2.;
  }
  return s;
}

float Fbm2 (vec2 p)
{
  float s = 0.;
  float a = 1.;
  for (int i = 0; i < 6; i ++) {
    s += a * Noisefv2 (p);
    a *= 0.5;
    p *= 2.;
  }
  return s;
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
  vec3 s = vec3 (0.);
  float a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * vec3 (Noisefv2 (p.yz), Noisefv2 (p.zx), Noisefv2 (p.xy));
    a *= 0.5;
    p *= 2.;
  }
  return dot (s, abs (n));
}

vec3 VaryNf (vec3 p, vec3 n, float f)
{
  vec3 e = vec3 (0.2, 0., 0.);
  float s = Fbmn (p, n);
  vec3 g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  return length (vec2 (length (p.xy) - rc, p.z)) - ri;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

#define NROCK 16
vec4 rkPos[NROCK];
vec3 moonDir, moonCol, waterDisp, cloudDisp, flmCylPos;
float tCur, qRad, flmCylRad, flmCylLen;
int idObj;
const float dstFar = 100.;
const int nRock = NROCK;

float WaterHt (vec3 p)
{
  float ht, w;
  const float wb = 1.414;
  p *= 0.03;
  w = wb;
  p += waterDisp;
  ht = 0.;
  for (int j = 0; j < 7; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x);
    p += waterDisp;
    ht += w * abs (Noisefv3a (p) - 0.5);
  }
  return 0.2 * ht;
}

vec3 WaterNf (vec3 p, float d)
{
  float ht = WaterHt (p);
  vec2 e = vec2 (max (0.01, 0.001 * d * d), 0.);
  return normalize (vec3 (ht - WaterHt (p + e.xyy), e.x, ht - WaterHt (p + e.yyx)));
}

vec3 SkyGrndCol (vec3 ro, vec3 rd)
{
  const vec3 sbCol = vec3 (0.02, 0.02, 0.04),
     sCol1 = vec3 (0.06, 0.04, 0.02), sCol2 = vec3 (0.1, 0.1, 0.15),
     mBrite = vec3 (0.5, 0.4, -0.77), gCol = vec3 (0.005, 0.01, 0.005);
  const float moonRad = 0.02;
  vec3 col, bgCol, vn, rds;
  vec2 p;
  float cloudFac, bs, cs, ts, dDotS, w, f;
  bool mHit;
  if (rd.y > 0.) {
    ro.xz += cloudDisp.xz;
    p = 0.02 * (rd.xz * (150. - ro.y) / rd.y + ro.xz);
    w = 0.8;
    f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.;
    }
    cloudFac = clamp (3. * f * rd.y - 0.3, 0., 1.);
  } else cloudFac = 0.;
  bgCol = 0.3 * clamp (sbCol - 0.12 * rd.y * rd.y, 0., 1.) +
     sCol1 * pow (clamp (dot (rd, moonDir), 0., 1.), 30.);
  col = bgCol;
  mHit = false;
  bs = - dot (rd, moonDir);
  cs = dot (moonDir, moonDir) - moonRad * moonRad;
  ts = bs * bs - cs;
  if (ts > 0.) {
    ts = - bs - sqrt (ts);
    if (ts > 0.) {
      vn = normalize ((ts * rd - moonDir) / moonRad);
      mHit = true;
    }
  }
  if (mHit) col += 1.4 * moonCol * clamp (dot (mBrite, vn) *
       (0.3 + Noisefv3a (5. * vn)), 0., 1.);
  else {
    rds = rd;
    rds = (rds + vec3 (1.));
    for (int j = 0; j < 14; j ++)
       rds = 11. * abs (rds) / dot (rds, rds) - 3.;
    col += min (1., 1.5e-6 * pow (min (16., length (rds)), 4.5)) *
       vec3 (1., 1., 0.6);
  }
  col = mix (col, sCol2, cloudFac) + bgCol;
  if (rd.y > 0. && rd.y < 0.005 + 0.01 * Fbm1 (20. * rd.x - 0.05 * tCur))
     col = gCol;
  return col;
}

float TransObjRay (vec3 ro, vec3 rd)
{
  vec3 q;
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 100; j ++) {
    q = ro + dHit * rd - flmCylPos;
    d = PrCylDf (q.xzy, flmCylRad, flmCylLen);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

float MountDf (vec3 p, float dMin)
{
  vec3 q;
  float d, a, aa, r, hd;
  q = p;
  a = atan (q.z, q.x) / (2. * pi) + 0.5;
  aa = a;
  if (aa > 0.5) aa = 1. - aa;
  r = length (q.xz);
  d = PrCylDf (q.xzy, 2., 0.75);
  d = max (d, - PrCylDf (q.xzy, 0.15, 0.8));
  q.y -= 0.75;
  hd = PrSphDf (q, 0.35) - 0.03 * (Fbm2 (vec2 (22. * aa, 13. * r)) - 0.5);
  d = max (d, - hd);
  hd = 0.02 * (1. + sin (64. * pi * a) + sin (25. * pi * a)) *
     SmoothBump (0.5, 1.8, 0.3, r);
  hd += 0.15 * (Fbm2 (vec2 (33. * aa, 7. * r)) - 0.5) *
     SmoothBump (0.1, 2., 0.2, r);
  q.y -= 1.2 + hd;
  d = max (d, - PrTorusDf (q.xzy, 2.8, 2.8));
  if (d < dMin) { dMin = d;  idObj = 1; }
  return 0.5 * dMin;
}

float ObjDf (vec3 p)
{
  float dMin, d;
  dMin = dstFar;
  dMin = MountDf (p, dMin);
  for (int j = 0; j < nRock; j ++) {
    d = PrSphDf (p - rkPos[j].xyz, rkPos[j].w);
    if (d < dMin) { dMin = d;  idObj = 2;  qRad = rkPos[j].w; }
  }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 100; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

void SetRocks ()
{
  vec3 bv0, bp0, bp;
  float a, tm, fj;
  for (int j = 0; j < nRock; j ++) {
    fj = float (j);
    a = 2. * pi * Hashff (100.11 * fj);
    bv0.xz = 0.7 * vec2 (cos (a), sin (a));
    bv0.y = 1.4 + 0.3 * Hashff (11.11 * fj);
    bp0.xz = 0.1 * bv0.xz;  bp0.y = 0.5;
    tm = mod (tCur + 0.15 * (fj + 0.6 * Hashff (fj)), 3.);
    bp = bp0 + bv0 * tm;  bp.y -= 0.6 * tm * tm;
    rkPos[j] = vec4 (bp, 0.04 - 0.035 * tm / 3.);
  }
}

float FlmAmp (vec3 ro, vec3 rd, float dHit)
{
  vec3 p, q, dp;
  float g, s, fh, fr, f, hs;
  p = ro + dHit * rd - flmCylPos;
  hs = min (p.y / flmCylLen, 1.);
  dp = (flmCylRad / 20.) * rd;
  g = 0.;
  for (int i = 0; i < 20; i ++) {
    p += dp;
    s = distance (p.xz, flmCylPos.xz);
    q = 4. * p;  q.y -= 6. * tCur;
    fh = 0.5 * max (1. - (p.y - flmCylPos.y) / flmCylLen, 0.);
    fr = max (1. - s / flmCylRad, 0.);
    f = Fbm3 (q);
    q = 7. * p;  q.y -= 8.5 * tCur;
    f += Fbm3 (q);
    g += max (0.5 * fr * fr * fh * (f * f - 0.6), 0.);
    q = 23. * p;  q.y -= 11. * tCur;
    g += 1000. * pow (abs (Noisefv3a (q) - 0.11), 64.);
    if (s > flmCylRad || p.y < flmCylPos.y - 0.99 * flmCylLen || g > 1.) break;
  }
  g = clamp (0.9 * g, 0., 1.);
  if (hs > 0.) g *= 1. - hs * hs;
  return g;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  float dstHit, dw, htWat, dstFlm, dstFlmR, intFlm, bgFlm, reflFac, cy;
  int idObjT;
  moonDir = normalize (vec3 (-0.5, 0.1, 0.2));
  moonCol = vec3 (1., 0.9, 0.5);
  cloudDisp = 10. * tCur * vec3 (1., 0., 1.);
  waterDisp = 0.002 * tCur * vec3 (-1., 0., 1.);
  htWat = -0.65;
  SetRocks ();
  flmCylPos = vec3 (0., 0.9, 0.);
  flmCylRad = 0.4;
  flmCylLen = 1.3;
  reflFac = 1.;
  dstFlm = TransObjRay (ro, rd);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  bgFlm = (0.7 + 0.6 * Noiseff (10. * tCur));
  intFlm = (dstFlm < dstHit) ? FlmAmp (ro, rd, dstFlm) : 0.;
  if (rd.y < 0.) {
    dw = - (ro.y - htWat) / rd.y;
    if (dstHit >= min (dw, dstFar)) {
      ro += dw * rd;
      rd = reflect (rd, WaterNf (ro, dw));
      ro += 0.01 * rd;
      dstFlmR = TransObjRay (ro, rd);
      idObj = -1;
      dstHit = ObjRay (ro, rd);
      if (idObj < 0) dstHit = dstFar;
      if (dstFlmR < dstFlm) {
        intFlm = (dstFlmR < dstHit) ? FlmAmp (ro, rd, dstFlmR) : 0.;
        dstFlm = dstFlmR;
      }
      reflFac = 0.8;
    }
  }
  if (dstHit >= dstFar) col = SkyGrndCol (ro, rd);
  else {
    ro += dstHit * rd;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == 1) {
      cy = clamp (ro.y / 1.2 + 0.6, 0., 1.);
      col = reflFac * (0.5 + 0.7 * bgFlm * cy) * vec3 (0.3 + 0.1 * (1. - cy),
         0.2 + 0.2 * (1. - cy), 0.1);
      col = col * (0.6 + 0.4 * max (dot (vn, moonDir), 0.));
    } else if (idObj == 2) {
      col = mix (vec3 (1., 0., 0.), vec3 (0.1, 0.3, 0.1),
         1. - (qRad - 0.005) / 0.03);
      vn = VaryNf (200. * ro, vn, 10.);
      col = col * (0.6 + 0.4 * max (dot (vn, vec3 (0., 0.5, 0.)), 0.));
    }
  }
  if (intFlm > 0.) col = mix (col, bgFlm * mix (vec3 (1., 0.1, 0.1),
     vec3 (1., 1., 0.5), 0.5 * intFlm), 1.2 * intFlm);
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 uv = 2. * (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  float az, el, dist;
  vec3 rd, ro, ca, sa;
  dist = 8. - 3. * sin (0.1 * tCur);
  az = 0.03 * tCur;
  el = 0.4 * (11. - dist) / 5.;
  ca = cos (vec3 (el, az, 0.));
  sa = sin (vec3 (el, az, 0.));
  vuMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = - vec3 (0., 0., dist) * vuMat;
  rd = normalize (vec3 (uv, 3.5)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
