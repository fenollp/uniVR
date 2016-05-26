// Shader downloaded from https://www.shadertoy.com/view/llSXzK
// written by shadertoy user dr2
//
// Name: Stromboli2
// Description: A 3-D volcano - daytime view (mouse enabled).
// "Stromboli2" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// A 3-D volcano - daytime view.

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
  vec2 t;
  float ip, fp;
  ip = floor (p);  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  t = Hashv2f (ip);
  return mix (t.x, t.y, fp);
}

float Noisefv2 (vec2 p)
{
  vec4 t;
  vec2 ip, fp;
  ip = floor (p);  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  t = Hashv4f (dot (ip, cHashA3.xy));
  return mix (mix (t.x, t.y, fp.x), mix (t.z, t.w, fp.x), fp.y);
}

float Noisefv3 (vec3 p)
{
  vec4 t1, t2;
  vec3 ip, fp;
  float q;
  ip = floor (p);  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  q = dot (ip, cHashA3);
  t1 = Hashv4f (q);
  t2 = Hashv4f (q + cHashA3.z);
  return mix (mix (mix (t1.x, t1.y, fp.x), mix (t1.z, t1.w, fp.x), fp.y),
              mix (mix (t2.x, t2.y, fp.x), mix (t2.z, t2.w, fp.x), fp.y), fp.z);
}

vec2 Noisev2v4 (vec4 p)
{
  vec4 ip, fp, t1, t2;
  ip = floor (p);  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  t1 = Hashv4f (dot (ip.xy, cHashA3.xy));
  t2 = Hashv4f (dot (ip.zw, cHashA3.xy));
  return vec2 (mix (mix (t1.x, t1.y, fp.x), mix (t1.z, t1.w, fp.x), fp.y),
               mix (mix (t2.x, t2.y, fp.z), mix (t2.z, t2.w, fp.z), fp.w));
}

float Fbm2 (vec2 p)
{
  float s, a;
  s = 0.;  a = 1.;
  for (int i = 0; i < 6; i ++) {
    s += a * Noisefv2 (p);
    a *= 0.5;  p *= 2.;
  }
  return s;
}

float Fbm3 (vec3 p)
{
  const mat3 mr = mat3 (0., 0.8, 0.6, -0.8, 0.36, -0.48, -0.6, -0.48, 0.64);
  float s, a;
  s = 0.;  a = 0.5;
  p *= 0.5;
  for (int i = 0; i < 6; i ++) {
    s += a * Noisefv3 (p);
    a *= 0.5;  p *= 4. * mr;
  }
  return s;
}

float Fbmn (vec3 p, vec3 n)
{
  vec3 s;
  float a;
  s = vec3 (0.);  a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * vec3 (Noisefv2 (p.yz), Noisefv2 (p.zx), Noisefv2 (p.xy));
    a *= 0.5;  p *= 2.;
  }
  return dot (s, abs (n));
}

vec3 VaryNf (vec3 p, vec3 n, float f)
{
  const vec3 e = vec3 (0.1, 0., 0.);
  vec3 g;
  float s;
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  return length (vec2 (length (p.xy) - rc, p.z)) - ri;
}

#define NROCK 16
vec4 rkPos[NROCK];
vec3 sunDir, waterDisp, cloudDisp, flmCylPos;
float tCur, lavHt, qRad, waterHt, flmCylRad, flmCylLen;
int idObj;
const float dstFar = 100.;
const int nRock = NROCK;
const int idMnt = 1, idRock = 2, idLav = 3;

vec3 SkyCol (vec3 ro, vec3 rd)
{
  const float skyHt = 150.;
  vec3 col, bgCol;
  float cloudFac;
  bgCol = vec3 (0.1, 0.2, 0.5);
  if (rd.y > 0.) {
    ro.xz += 0.5 * tCur;
    vec2 p = 0.01 * (rd.xz * (skyHt - ro.y) / rd.y + ro.xz);
    float w = 0.65;
    float f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.3;
    }
    cloudFac = clamp (3. * (f - 0.5) * rd.y + 0.1, 0., 1.);
    col = bgCol + 0.2 * pow (1. - max (rd.y, 0.), 5.);
    col = mix (col, vec3 (0.75), cloudFac);
  } else col = 0.9 * bgCol + 0.25;
  return col;
}

float WaveHt (vec3 p)
{
  const mat2 mr = mat2 (1.6, -1.2, 1.2, 1.6);
  vec4 t4, t4o, ta4, v4;
  vec2 q2, t2, v2;
  float wFreq, wAmp, pRough, ht;
  wFreq = 0.2;  wAmp = 1.;  pRough = 5.;
  t4o.xz = 1.3 * tCur * vec2 (1., -1.);
  q2 = 10. * p.xz + waterDisp.xz;
  ht = 0.;
  for (int j = 0; j < 3; j ++) {
    t4 = (t4o.xxzz + vec4 (q2, q2)) * wFreq;
    t2 = Noisev2v4 (t4);
    t4 += 2. * vec4 (t2.xx, t2.yy) - 1.;
    ta4 = abs (sin (t4));
    v4 = (1. - ta4) * (ta4 + sqrt (1. - ta4 * ta4));
    v2 = pow (1. - pow (v4.xz * v4.yw, vec2 (0.65)), vec2 (pRough));
    ht += (v2.x + v2.y) * wAmp;
    q2 *= mr;  wFreq *= 2.;  wAmp *= 0.2;
    pRough = 0.8 * pRough + 0.2;
  }
  return 0.03 * ht + waterHt;
}

float WaveRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, h, s, sLo, sHi;
  s = 0.;
  sLo = 0.;
  dHit = dstFar;
  for (int j = 0; j < 70; j ++) {
    p = ro + s * rd;
    h = p.y - WaveHt (p);
    if (h < 0.) break;
    sLo = s;
    s += max (0.4, 1.2 * h) + 0.01 * s;
    if (s > dstFar) break;
  }
  if (h < 0.) {
    sHi = s;
    for (int j = 0; j < 10; j ++) {
      s = 0.5 * (sLo + sHi);
      p = ro + s * rd;
      h = step (0., p.y - WaveHt (p));
      sLo += h * (s - sLo);
      sHi += (1. - h) * (s - sHi);
    }
    dHit = sHi;
  }
  return dHit;
}

vec3 WaveNf (vec3 p, float d)
{
  vec2 e = vec2 (max (0.002, 1e-3 * d * d), 0.);
  float h = WaveHt (p);
  return normalize (vec3 (h - WaveHt (p + e.xyy), e.x, h - WaveHt (p + e.yyx)));
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
  float d, a, r, hd, s;
  q = p;
  a = atan (q.z, q.x) / (2. * pi) + 0.5;
  r = length (q.xz);
  s = Fbm2 (vec2 (33. * a, 7. * r)) - 0.5;
  d = PrCylDf (q.xzy, 2., 0.75);
  q.y -= 0.75;
  d = max (d, - (PrSphDf (q, 0.35) - 0.03 * s));
  hd = 0.015 * (1. + sin (64. * pi * a) + 2. * sin (25. * pi * a)) *
     SmoothBump (0.5, 1.8, 0.3, r) + 0.15 * s * SmoothBump (0.1, 2., 0.2, r);
  q.y -= 1.2 + hd;
  d = max (max (d, - PrTorusDf (q.xzy, 2.8, 2.8)), 0.15 - length (q.xz));
  if (d < dMin) { dMin = d;  idObj = idMnt; }
  q = p;
  q.y -= lavHt;
  d = PrCylDf (q.xzy, 0.3, 0.02);
  if (d < dMin) { dMin = d;  idObj = idLav; }
  return 0.8 * dMin;
}

float ObjDf (vec3 p)
{
  float dMin, d;
  dMin = dstFar;
  dMin = MountDf (p, dMin);
  for (int j = 0; j < nRock; j ++) {
    d = PrSphDf (p - rkPos[j].xyz, rkPos[j].w);
    if (d < dMin) { dMin = d;  idObj = idRock;  qRad = rkPos[j].w; }
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
  if (d >= 0.001) dHit = dstFar;
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
    g += 1000. * pow (abs (Noisefv3 (q) - 0.11), 64.);
    if (s > flmCylRad || p.y < flmCylPos.y - 0.99 * flmCylLen || g > 1.) break;
  }
  g = clamp (0.9 * g, 0., 1.);
  if (hs > 0.) g *= 1. - hs * hs;
  return g;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  float dstHit, dstWat, dstFlm, dstFlmR, intFlm, bgFlm, reflFac, s;
  int idObjT;
  waterDisp = 0.002 * tCur * vec3 (-1., 0., 1.);
  waterHt = -0.65;
  lavHt = 0.4 + 0.08 * sin (0.47 * tCur) + 0.05 * cos (0.77 * tCur);
  SetRocks ();
  ro.y = max (ro.y, WaveHt (ro) + 0.3);
  flmCylPos = vec3 (0., 0.9, 0.);
  flmCylRad = 0.35;
  flmCylLen = 1.3;
  reflFac = 1.;
  dstFlm = TransObjRay (ro, rd);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  bgFlm = (0.7 + 0.6 * Noiseff (10. * tCur));
  intFlm = (dstFlm < dstHit) ? FlmAmp (ro, rd, dstFlm) : 0.;
  dstWat = WaveRay (ro, rd);
  if (rd.y < 0. && dstWat >= dstFar) dstWat = - (ro.y - waterHt) / rd.y;
  if (dstWat < dstHit) {
    ro += rd * dstWat;
    rd = reflect (rd, WaveNf (ro, dstWat));
    ro += 0.01 * rd;
    dstFlmR = TransObjRay (ro, rd);
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
    if (dstFlmR < dstFlm) {
      intFlm = (dstFlmR < dstHit) ? FlmAmp (ro, rd, dstFlmR) : 0.;
      dstFlm = dstFlmR;
    }
    reflFac = 0.9;
  }
  if (dstHit >= dstFar) col = reflFac * SkyCol (ro, rd);
  else {
    ro += dstHit * rd;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == idMnt) {
      s = clamp (ro.y / 1.2 + 0.6, 0., 1.);
      vn = VaryNf (11. * ro, vn, 10. - 7. * s);
      col = (0.5 + 0.7 * bgFlm * s) * vec3 (0.2 + 0.1 * (1. - s),
         0.05 + 0.2 * (1. - s), 0.05);
      col = reflFac * col * (0.1 + 0.1 * max (vn.y, 0.) +
         0.8 * max (dot (vn, sunDir), 0.));
    } else if (idObj == idLav) {
      col = mix (vec3 (0.4, 0., 0.), vec3 (0.8, 0.7, 0.),
         step (1.1, Fbm2 (41. * ro.xz * vec2 (1. + 0.2 * sin (1.7 * tCur) *
	 vec2 (1. + 0.13 * sin (4.31 * tCur), 1. + 0.13 * cos (4.61 * tCur))))));
      vn = VaryNf (21. * ro, vn, 10.);
      col *= 0.5  + 1.5 * pow (max (vn.y, 0.), 32.);
    } else if (idObj == idRock) {
      col = mix (vec3 (1., 0., 0.), vec3 (0.1, 0.3, 0.1),
         1. - (qRad - 0.005) / 0.03);
      vn = VaryNf (200. * ro, vn, 10.);
      col = reflFac * col * (0.6 + 0.4 * max (dot (vn, vec3 (0., 0.5, 0.)), 0.));
    }
  }
  if (intFlm > 0.) col = mix (col, bgFlm * mix (vec3 (1., 0.1, 0.1),
     vec3 (1., 1., 0.5), 0.5 * intFlm), 1.2 * intFlm);
  return (clamp (col, 0., 1.));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 mPtr;
  mat3 vuMat;
  vec3 rd, ro;
  vec2 canvas, uv, ori, ca, sa;
  float az, el, dist;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  sunDir = normalize (vec3 (1., 1., -1.));
  dist = 8. + 3. * cos (0.2 * tCur);
  az = - 0.03 * tCur;
  el = 0.15 * (11. - dist);
  if (mPtr.z > 0.) {
    az -= 3. * mPtr.x;
    el = clamp (el - 3. * mPtr.y, 0., 1.3);
  }
  ori = vec2 (el, az);
  ca = cos (ori);  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = - vec3 (0., 0., dist) * vuMat;
  rd = normalize (vec3 (uv, 3.5)) * vuMat;
  sunDir *= vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
