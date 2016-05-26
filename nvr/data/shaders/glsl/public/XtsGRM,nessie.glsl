// Shader downloaded from https://www.shadertoy.com/view/XtsGRM
// written by shadertoy user dr2
//
// Name: Nessie
// Description: Nessie, the Loch Ness Monster.
// "Nessie" by dr2 - 2014
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

vec2 Hashv2f (float p)
{
  return fract (sin (p + cHashA4.xy) * cHashM);
}

vec4 Hashv4f (float p)
{
  return fract (sin (p + cHashA4) * cHashM);
}

float Noisefv2 (vec2 p)
{
  vec2 i = floor (p);
  vec2 f = fract (p);
  f = f * f * (3. - 2. * f);
  vec4 t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

float Noisefv3 (vec3 p)
{
  vec3 i = floor (p);
  vec3 f = fract (p);
  f = f * f * (3. - 2. * f);
  float q = dot (i, cHashA3);
  vec4 t1 = Hashv4f (q);
  vec4 t2 = Hashv4f (q + cHashA3.z);
  return mix (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
     mix (mix (t2.x, t2.y, f.x), mix (t2.z, t2.w, f.x), f.y), f.z);
}

float Noiseff (float p)
{
  float i = floor (p);
  float f = fract (p);
  f = f * f * (3. - 2. * f);
  vec2 t = Hashv2f (i);
  return mix (t.x, t.y, f);
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

float SmoothMin (float a, float b, float r)
{
  float h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
  return mix (b, a, h) - r * h * (1. - h);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  vec2 q = vec2 (length (p.xy) - rc, p.z);
  return length (q) - ri;
}

int idObj;
mat3 serpMat;
vec3 serpPos, ltPos, qHit, qHitTransObj, qHitFlame, qHitFlameR, sunDir, sunCol,
   moonDir, moonCol, waterDisp, cloudDisp;
float tCur, flameLen, flameInt, cvRad, bdRad, flameDir;
bool isNight;
const float dstFar = 200.;

float WaterHt (vec3 p)
{
  float ht, w;
  const float wb = 1.414;
  p *= 0.1;
  w = wb;
  p += waterDisp;
  ht = 0.;
  for (int j = 0; j < 7; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x);
    p += waterDisp;
    ht += w * abs (Noisefv3 (p) - 0.5);
  }
  return 0.5 * ht;
}

vec3 WaterNf (vec3 p, float d)
{
  float ht = WaterHt (p);
  vec2 e = vec2 (max (0.01, 0.001 * d * d), 0.);
  return normalize (vec3 (ht - WaterHt (p + e.xyy), e.x, ht - WaterHt (p + e.yyx)));
}

vec3 SkyGrndCol (vec3 ro, vec3 rd)
{
  const vec3 sbCol1 = vec3 (0.02, 0.02, 0.06), sbCol2 = 0.7 * vec3 (0.2, 0.25, 0.5),
     sCol1 = vec3 (0.06, 0.04, 0.02), sCol2 = vec3 (0.1, 0.1, 0.2),
     mBrite = vec3 (-0.5, -0.4, 0.77), gCol = vec3 (0.05, 0.1, 0.05);
  const float moonRad = 0.04;
  vec3 col, bgCol, vn, rdd, st;
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
  if (isNight) {
    bgCol = 0.3 * clamp (sbCol1 - 0.12 * rd.y * rd.y, 0., 1.) +
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
         (0.3 + Noisefv3 (5. * vn)), 0., 1.);
    else {
      rdd = rd;
      rdd.xz = Rot2D (rdd.xz, 0.002 * tCur);
      st = (rdd + vec3 (1.));
      for (int j = 0; j < 10; j ++)
         st = 11. * abs (st) / dot (st, st) - 3.;
      col += min (1., 1.5e-6 * pow (min (16., length (st)), 4.5));
    }
    col = mix (col, sCol2, cloudFac) + bgCol;
  } else {
    dDotS = max (dot (rd, sunDir), 0.);
    col = sbCol2 + 0.2 * sunCol * pow (1. - max (rd.y, 0.), 5.) +
       0.7 * sunCol * min (1.3 * pow (dDotS, 1024.) +
       0.25 * pow (dDotS, 256.), 1.);
    col = mix (col, vec3 (0.55), cloudFac);
  }
  if (rd.y > 0. && rd.y < 0.005 + 0.01 * Fbm1 (20. * rd.x - 0.05 * tCur)) {
    col = gCol;
    if (isNight) col *= 0.1;
  }
  return col;
}

float FlameDf (vec3 p, float dHit)
{
  vec3 q;
  float d, wr, tr, u;
  q = p;
  q.z = - q.z + flameLen;
  wr = 0.5 * (1. + q.z / flameLen);
  tr = 0.3 * clamp (1. - 0.7 * wr, 0., 1.);
  d = max (PrCapsDf (q, tr * flameLen, flameLen), -1.2 * flameLen - q.z);
  if (d < dHit) { dHit = d; qHitTransObj = q; }
  return dHit;
}

float TransObjDf (vec3 p)
{
  vec3 q;
  float dHit;
  dHit = dstFar;
  p = serpMat * (p - serpPos);
  q = p;
  q.z -= 8. * cvRad;
  q.xz = Rot2D (q.xz, flameDir);
  q.x = abs (q.x);
  q -= vec3 (0.6 * bdRad, cvRad, 2. * cvRad);
  q.xz = Rot2D (q.xz,  0.1 + 0.4 * (1. + sin (3. * tCur)));
  q.yz = Rot2D (q.yz, -0.1 + 0.2 * sin (tCur));
  dHit = FlameDf (q, dHit);
  return dHit;
}

float TransObjRay (vec3 ro, vec3 rd)
{
  float d, dHit;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = TransObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dHit, d, sz, wr, u;
  dHit = dstFar;
  p = serpMat * (p - serpPos);
  q = p;
  sz = abs (q.z + 3. * cvRad);
  q.z = mod (q.z + 2. * cvRad, 4. * cvRad) - 2. * cvRad;
  d = max (PrTorusDf (q.yzx, bdRad, cvRad), - q.y);
  q.z = mod (q.z, 4. * cvRad) - 2. * cvRad;
  d = min (d, max (PrTorusDf (q.yzx, bdRad, cvRad), q.y));
  d = max (d, sz - 11. * cvRad);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = 1; }
  p.z -= 8. * cvRad;
  p.xz = Rot2D (p.xz, flameDir);
  q = p;  q -= vec3 (0., cvRad, 0.5 * cvRad);
  u = q.z + bdRad;  wr = 1. - 0.2 * u * u / (3. * bdRad);
  d = PrCapsDf (q, 1.5 * wr * bdRad, 3. * bdRad);
  if (d < dHit + 0.3 * bdRad) {
    dHit = SmoothMin (d, dHit, 0.3 * bdRad);  qHit = q;  idObj = 1;
  }
  q = p;  q -= vec3 (0., cvRad + 1.7 * bdRad, 0.5 * cvRad - bdRad);
  u = q.z - 2. * bdRad;  wr = 1. - 0.5 * u * u / (2. * bdRad);
  d = PrCapsDf (q, 0.8 * wr * bdRad, 2. * bdRad);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = 1; }
  q.z -= 2. * bdRad;
  d = PrCylDf (q.yzx, 0.5 * bdRad, 0.8 * bdRad);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = 2; }
  q = p;  q.x = abs (q.x);  q -= vec3 (0.5 * bdRad, cvRad, 1.7 * cvRad);
  d = PrCylDf (q, 0.3 * bdRad, 0.4 * bdRad);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = 3; }
  return dHit;
}

float ObjRay (in vec3 ro, in vec3 rd)
{
  float d, dHit;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.002 || dHit > dstFar) break;
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

vec3 ObjCol (vec3 n)
{
  vec3 col;
  if (idObj == 1) {
    col = vec3 (0.5, 0.3, 0.2);
    if (isNight) col *= 0.2;
  } else if (idObj == 2) col = vec3 (0.2, 5., 0.2) * (1. + 0.8 * cos (3. * tCur));
  else if (idObj == 3) col = vec3 (5., 0.3, 0.2);
  return col;
}

vec3 FlameCol (vec3 col)
{
  vec3 q;
  float fFac, c;
  q = qHitTransObj;
  fFac = clamp (mod (2. * (q.z / flameLen + 1.) + 3. * Noisefv2 (q.xy *
     vec2 (7., 7.3) + tCur * vec2 (11., 14.)) + 4.1 * tCur, 1.), 0., 1.);
  c = clamp (q.z, 0., 1.);
  if (flameInt > 0.1) col = 2. * flameInt * fFac *
     vec3 (c + 0.5, 0.7 * c + 0.1, 0.2 * c + 0.1) + 0.8 * (1. - c) * col;
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col, objCol, vLight;
  int idObjT;
  float dstHit, dstWat, dstFlame, dstFlameR, dstLightI, reflFac, dif;
  bool doRefD, doRefR;
  reflFac = 1.;
  dstFlame = TransObjRay (ro, rd);
  qHitFlame = qHitTransObj;
  dstFlameR = dstFar;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit < dstFlame) dstFlame = dstFar;
  doRefD = (dstFlame < min (dstHit, dstFar));
  dstWat = - ro.y / rd.y;
  if (rd.y < 0. && dstHit >= min (dstWat, dstFar)) {
    ro += dstWat * rd;
    rd = reflect (rd, WaterNf (ro, dstWat));
    ro += 0.01 * rd;
    dstFlameR = TransObjRay (ro, rd);
    qHitFlameR = qHitTransObj;
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
    if (dstHit < dstFlameR) dstFlameR = dstFar;
    doRefR = (dstFlameR < min (dstHit, dstFar));
    reflFac *= 0.7;
  }
  idObjT = idObj;
  if (dstHit >= dstFar) col = reflFac * SkyGrndCol (ro, rd);
  else {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == 1) vn = VaryNf (8. * qHit.yzx, vn, 10.);
    objCol = ObjCol (vn);
    dif = max (dot (vn, sunDir), 0.);
    col = reflFac * objCol * (0.2 * (1. +
       max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.)) +
       max (0., dif) *  (dif + pow (max (0., dot (sunDir, reflect (rd, vn))), 64.)));
    if (isNight && idObj == 1) {
      vLight = ro - ltPos;
      dstLightI = 1. / length (vLight);
      if (dstLightI < 10. && flameInt > 0.1) col +=
         15. * flameInt * col * (0.2 + max (0., - dot (vn, normalize (vLight)))) *
	 min (1., 200. * dstLightI * dstLightI);
    }
  }
  if (doRefD) {
    qHitTransObj = qHitFlame;
    col = FlameCol (col);
  }
  if (doRefR) {
    qHitTransObj = qHitFlameR;
    col = FlameCol (col);
  }
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  sunDir = normalize (vec3 (0.2, 0.1, 0.5));
  moonDir = normalize (vec3 (0.2, 0.1, 0.5));
  sunCol = vec3 (1., 0.9, 0.8);
  moonCol = vec3 (1., 0.9, 0.5);
  cloudDisp = 10. * tCur * vec3 (1., 0., 1.);
  waterDisp = 0.05 * tCur * vec3 (-1., 0., 1.);
  vec3 rd, ro;
  float az, el;

  az = pi * (0.6 + 0.2 * sin (0.03 * tCur));
  el = 0.005 * pi * sin (0.022 * tCur);
  vec3 ca = cos (vec3 (el, az, 0.));
  vec3 sa = sin (vec3 (el, az, 0.));
  serpMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  serpPos = vec3 (0., 0.4 + 0.35 * cos (1.5 * tCur), 25.);
  cvRad = 1.;
  bdRad = 0.35;
  isNight = true;//mod (floor (tCur / 4.), 2.) != 0.;
  flameDir = 0.2 * pi * sin (2. * tCur);
  flameLen = 0.6 + 1.4 * max (0.2, Fbm1 (5.1 * tCur));
  flameInt = 2. * max (Fbm1 (2.3 * tCur) - 0.7, 0.);
  ltPos = serpPos + vec3 (0., 1.5 * cvRad, 13. * cvRad) * serpMat;
  rd = normalize (vec3 (uv, 3.6));
  ro = vec3 (0., 3., -20.);
  vec3 col;
  col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
