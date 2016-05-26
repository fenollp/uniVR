// Shader downloaded from https://www.shadertoy.com/view/Ml23WV
// written by shadertoy user dr2
//
// Name: Sailing Home
// Description: Choppy seas and patchy fog.
// "Sailing Home" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Choppy seas and patchy fog. Based on "Wavescape"; blended fog
// idea from nimitz's "Xyptonjtroz".

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
  vec2 i, f;
  i = floor (p);  f = fract (p);
  f = f * f * (3. - 2. * f);
  vec4 t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

vec2 Noisev2v2 (vec4 p)
{
  vec4 i, f, t1, t2;
  i = floor (p);  f = fract (p);
  f = f * f * (3. - 2. * f);
  t1 = Hashv4f (dot (i.xy, cHashA3.xy));
  t2 = Hashv4f (dot (i.zw, cHashA3.xy));
  return vec2 (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
               mix (mix (t2.x, t2.y, f.z), mix (t2.z, t2.w, f.z), f.w));
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
  float f, a;
  f = 0.;  a = 1.;
  for (int i = 0; i < 5; i ++) {
    f += a * Noiseff (p);
    a *= 0.5;  p *= 2.;
  }
  return f;
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

float FrAbsf (float p)
{
  return abs (fract (p) - 0.5);
}

vec3 FrAbsv3 (vec3 p)
{
  return abs (fract (p) - 0.5);
}

float FrNoise3d (vec3 p, vec3 disp)
{
  vec3 q;
  float a, f;
  a = 2.;
  f = 0.;
  q = p;
  for (int j = 0; j < 4; j ++) {
    p += FrAbsv3 (q + FrAbsv3 (q).yzx) + disp;
    p *= 1.2;
    f += a * (FrAbsf (p.x + FrAbsf (p.y + FrAbsf (p.z))));
    q = 2. * q + 0.2;
    a *= 0.7;
  }
  return f;
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

int idObj;
mat3 ballMat, ballMatX[4];
vec3 qHit, ballPos, ballPosX[4], sunCol, sunDir, cloudDisp, waterDisp,
   fogDisp;
vec2 bGap;
float tCur, fCloud, fogAmp;
const float dstFar = 250.;

vec3 SkyGrndCol (vec3 ro, vec3 rd)
{
  vec3 p, q, cSun, skyBg, clCol, col;
  float colSum, attSum, s, att, a, dDotS, ds;
  const vec3 cCol1 = 0.5 * vec3 (0.15, 0.2, 0.4),
     cCol2 = 0.5 * vec3 (0.25, 0.5, 0.7), gCol = vec3 (0.08, 0.12, 0.08);
  const float cloudLo = 200., cloudRngI = 1./200., atFac = 0.09;
  const int nLay = 20;
  if (rd.y < 0.015 * Fbm1 (16. * rd.x + 0.01 * tCur)- 0.0075) col = gCol *
     (0.7 + 0.3 * Noisefv2 (1000. * vec2 (5. * atan (rd.x, rd.z), rd.y)));
  else {
    fCloud = clamp (fCloud, 0., 1.);
    dDotS = max (dot (rd, sunDir), 0.);
    ro += cloudDisp;
    p = ro;
    p.xz += (cloudLo - p.y) * rd.xz / rd.y;
    p.y = cloudLo;
    ds = 1. / (cloudRngI * rd.y * (2. - rd.y) * float (nLay));
    colSum = 0.;  attSum = 0.;
    s = 0.;  att = 0.;
    for (int j = 0; j < nLay; j ++) {
      q = p + rd * s;
      q.z *= 0.7;
      att += atFac * max (fCloud - Fbm3 (0.01 * q), 0.);
      a = (1. - attSum) * att;
      colSum += a * (q.y - cloudLo) * cloudRngI;
      attSum += a;  s += ds;
      if (attSum >= 1.) break;
    }
    colSum += 0.5 * min ((1. - attSum) * pow (dDotS, 3.), 1.);
    clCol = vec3 (1.) * colSum + 0.05 * sunCol;
    cSun = sunCol * clamp ((min (pow (dDotS, 1500.) * 2., 1.) +
       min (pow (dDotS, 10.) * 0.75, 1.)), 0., 1.);
    skyBg = mix (cCol1, cCol2, 1. - rd.y);
    col = clamp (mix (skyBg + cSun, 1.6 * clCol, attSum), 0., 1.);
  }
  return col;
}

float WaveHt (vec3 p)
{
  const mat2 qRot = mat2 (1.6, -1.2, 1.2, 1.6);
  vec4 t4, t4o, ta4, v4;
  vec2 q2, t2, v2;
  float wFreq, wAmp, pRough, ht;
  wFreq = 0.18;  wAmp = 0.6;  pRough = 8.;
  t4o.xz = tCur * vec2 (1., -1.);
  q2 = p.xz + waterDisp.xz;
  ht = 0.;
  for (int j = 0; j < 3; j ++) {
    t4 = (t4o.xxzz + vec4 (q2, q2)) * wFreq;
    t2 = Noisev2v2 (t4);
    t4 += 2. * vec4 (t2.xx, t2.yy) - 1.;
    ta4 = abs (sin (t4));
    v4 = (1. - ta4) * (ta4 + sqrt (1. - ta4 * ta4));
    v2 = pow (1. - pow (v4.xz * v4.yw, vec2 (0.65)), vec2 (pRough));
    ht += (v2.x + v2.y) * wAmp;
    q2 *= qRot;  wFreq *= 2.;  wAmp *= 0.2;
    pRough = 0.8 * pRough + 0.2;
  }
  return ht;
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
    for (int j = 0; j < 5; j ++) {
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
  vec2 e = vec2 (max (0.1, 5e-5 * d * d), 0.);
  float h = WaveHt (p);
  return normalize (vec3 (h - WaveHt (p + e.xyy), e.x, h - WaveHt (p + e.yyx)));
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, db;
  int ih;
  dMin = dstFar;
  db = max (abs (p.x) - 2. * bGap.x, 0.);
  p.z = mod (p.z + 2. * bGap.y, 4. * bGap.y) - 2. * bGap.y;
  q = p;
  if (p.z > 0.) {
    if (p.x > 0.) {
      q -= ballPosX[0];  q *= ballMatX[0];  ih = 0;
    } else {
      q -= ballPosX[1];  q *= ballMatX[1];  ih = 1;
    }
  } else {
    if (p.x > 0.) {
      q -= ballPosX[2];  q *= ballMatX[2];  ih = 0;
    } else {
      q -= ballPosX[3];  q *= ballMatX[3];  ih = 1;
    }
  }
  d = max (PrSphDf (q, 1.2), db);
  if (d < dMin) { dMin = d;  idObj = 1;  qHit = q; }
  q.y -= 2.2;
  d = max (PrCylDf (q.xzy, 0.05, 1.), db);
  if (d < dMin) { dMin = d;  idObj = 2;  qHit = q; }
  q.y -= 1.3;
  d = max (PrCylDf (q.xzy, 0.15, 0.3), db);
  if (d < dMin) { dMin = d;  idObj = 3 + ih;  qHit = q; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
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
  col = vec3 (0.);
  if (idObj == 1) {
    col = vec3 (1., 0.5, 0.);
    if (abs (qHit.y) < 0.125) col =
       (mod (floor (7. * (atan (qHit.x, qHit.z) / pi + 1.)), 2.) == 0.) ?
       vec3 (1., 0., 0.) : vec3 (0.04);
    else if (qHit.y > 1.16) col = vec3 (0., 0.5, 0.);
    else if (abs (qHit.y) < 0.15) col = vec3 (1., 0., 0.);
    else if (abs (abs (qHit.y) - 0.33) < 0.03) col = vec3 (1.);
    else if (abs (abs (qHit.y) - 0.39) < 0.03) col = vec3 (0.05);
  } else if (idObj == 2) {
    col = vec3 (0.7, 0.4, 0.);
  } else if (idObj == 3) {
    if (abs (qHit.y) < 0.2) 
       col = vec3 (0., 1., 0.) * (3. + 2.5 * cos (10. * tCur));
    else col = vec3 (0.6, 0.4, 0.2);
  } else if (idObj == 4) {
    if (abs (qHit.y) < 0.2) 
       col = vec3 (1., 0., 0.) * (3. + 2.5 * sin (10. * tCur));
    else col = vec3 (0.6, 0.4, 0.2);
  }
  return col;
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.1;
  for (int j = 0; j < 40; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.1;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 ObjRender (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  float sh, cc;
  int idObjT;
  idObjT = idObj;
  vn = ObjNf (ro);
  idObj = idObjT;
  col = ObjCol (rd);
  cc = 1. - smoothstep (0.3, 0.6, fCloud);
  sh = ObjSShadow (ro, sunDir);
  return col * (0.3 + 0.7 * max (0., max (dot (vn, sunDir), 0.)) *
     (0.7 + 0.3 * cc * sh)) + 0.3 * cc * sh * sunCol *
     pow (max (0., dot (sunDir, reflect (rd, vn))), 32.);
}

float FogAmp (vec3 p, float d)
{
  vec3 q;
  float s1, s2;
  q = p + fogDisp;
  q.y *= 2.;
  s1 = sin (tCur * 0.6);
  q.x += 0.3 * s1;
  s2 = sin (0.5 * q.x);
  q.y += 0.1 * s1 + 0.2 * s2;
  q.z += s2;
  return fogAmp * FrNoise3d (q / (d + 30.), fogDisp);
}

vec3 FogCol (vec3 col, vec3 ro, vec3 rd, float dHit)
{
  vec3 q;
  float d, dq, fFac, f, fa;
  d = 3.;
  dq = 0.2;
  fFac = 1.;
  for (int j = 0; j < 5; j ++) {
    q = ro + rd * d;
    f = FogAmp (q, d);
    fa = 1. - clamp (f - FogAmp (q + dq, d), 0., 1.);
    col = mix (col, vec3 (0.8, 0.8, 0.75) * fa,
      clamp (fFac * f * smoothstep (0.9 * d, 2.3 * d, dHit), 0., 1.));
    d *= 1.6;
    dq *= 0.8;
    fFac *= 1.1;
    if (d > dHit) break;
  }
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn, rdd, refCol, roo, rdo;
  float dstHit, dstWat, dstFog, dif, bk, sh, foamFac, tWeathr;
  const float eta = 0.75, att = 0.5;
  int idObjT;
  bool doReflect;
  cloudDisp = 5. * tCur * vec3 (1., 0., 1.);
  waterDisp = 0.25 * tCur * vec3 (-1., 0., 1.);
  fogDisp = 0.05 * tCur * vec3 (1., 0., 0.);
  sunDir = normalize (vec3 (0.2, 0.5, 0.5));
  sunCol = vec3 (1., 0.4, 0.3) + vec3 (0., 0.5, 0.2) * sunDir.y;
  tWeathr = mod (0.05 * tCur, 2. * pi);
  fCloud = 0.5 + 0.15 * sin (tWeathr);
  fogAmp = 0.25 * SmoothBump (0.35 * pi, 0.65 * pi, 0.15 * pi, tWeathr);
  roo = ro;
  rdo = rd;
  ro.y = max (ro.y, WaveHt (ro) + 0.1);
  dstWat = WaveRay (ro, rd);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  dstFog = min (dstHit, dstWat);
  doReflect = (dstWat < dstFar && dstWat < dstHit);
  if (doReflect) {
    ro += rd * dstWat;
    vn = WaveNf (ro, dstWat);
    rdd = rd;
    rd = reflect (rd, vn);
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
    dstFog = min (dstFog + dstHit, dstFar);
  } 
  col = (dstHit < dstFar) ? ObjRender (ro + rd * dstHit, rd) :
     SkyGrndCol (ro, rd);
  if (doReflect) {
    refCol = col;
    rd = refract (rdd, vn, eta);
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
    dstFog = min (dstFog + dstHit, dstFar);
    col = (dstHit < dstFar) ? ObjRender (ro + rd * dstHit, rd) *
       exp (- att * dstHit) : vec3 (0., 0.05, 0.05);
    col = mix (col, 0.8 * refCol, pow (1. - abs (dot (rdd, vn)), 5.));
    foamFac = 0.9 * pow (clamp (WaveHt (ro) +
       0.004 * Fbm3 (256. * ro) - 0.55, 0., 1.), 8.);
    col = mix (col, vec3 (0.9), foamFac);
  }
  col = FogCol (col, roo, rdo, dstFog);
  return col;
}

void BallPM (float bOffset)
{
  const vec3 e = vec3 (1., 0., 0.);
  float h[5], b;
  ballPos.z += bOffset;
  h[0] = WaveHt (ballPos);
  h[1] = WaveHt (ballPos + e.yyx);
  h[2] = WaveHt (ballPos - e.yyx);
  h[3] = WaveHt (ballPos + e);
  h[4] = WaveHt (ballPos - e);
  ballPos.y = 0.1 + (2. * h[0] + h[1] + h[2] + h[3] + h[4]) / 15.;
  ballPos.z -= bOffset;
  b = (h[1] - h[2]) / (6. * e.x);
  ballMat[2] = normalize (vec3 (0., b, 1.));
  b = (h[3] - h[4]) / (6. * e.x);
  ballMat[1] = normalize (cross (ballMat[2], vec3 (1., b, 0.)));
  ballMat[0] = cross (ballMat[1], ballMat[2]);
}

void SetBuoys (vec3 ro)
{
  float bOffset;
  bOffset = mod (ro.z + 2. * bGap.y, 4. * bGap.y) - 2. * bGap.y;
  ballPos = vec3 (bGap.x, 0., bGap.y);
  BallPM (bOffset);
  ballPosX[0] = ballPos;
  ballMatX[0] = ballMat;
  ballPos = vec3 (- bGap.x, 0., bGap.y);
  BallPM (bOffset);
  ballPosX[1] = ballPos;
  ballMatX[1] = ballMat;
  ballPos = vec3 (bGap.x, 0., - bGap.y);
  BallPM (bOffset);
  ballPosX[2] = ballPos;
  ballMatX[2] = ballMat;
  ballPos = vec3 (- bGap.x, 0., - bGap.y);
  BallPM (bOffset);
  ballPosX[3] = ballPos;
  ballMatX[3] = ballMat;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  vec2 uvs = uv;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  vec3 col, ro, rd, ca, sa;
  float el, az, rl;
  az = 0.;
  el = 0.02 * pi + 0.04 * (1. + sin (0.5 * tCur + 0.3)) +
     0.024 * (1. + sin (0.8 * tCur));
  rl = 0.1 * sin (0.5 * tCur) + 0.06 * sin (0.8 * tCur + 0.3);
  ca = cos (vec3 (el, az, rl));
  sa = sin (vec3 (el, az, rl));
  vuMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  rd = normalize (vec3 (uv, 3.1)) * vuMat;
  ro = vec3 (0., 1.5, -20.) * vuMat;
  ro.z += 2. * tCur;
  bGap = vec2 (8., 16.);
  SetBuoys (ro);
  col = pow (clamp (ShowScene (ro, rd), 0., 1.), vec3 (0.45));
  uvs *= uvs * uvs;
  col = mix (vec3 (0.2), col,
     pow (max (0., 0.8 - length (uvs * uvs)), 0.2));
  fragColor = vec4 (col, 1.);
}

