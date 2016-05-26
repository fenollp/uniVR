// Shader downloaded from https://www.shadertoy.com/view/XlsGRN
// written by shadertoy user dr2
//
// Name: Fractal Bridge
// Description: A bridge appears in a tranquil valley; follow the bird as it flies through it.
// "Fractal Bridge" by dr2 - 2014
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

vec4 Hashv4f (float p)
{
  return fract (sin (p + cHashA4) * cHashM);
}

float Hashfv2 (vec2 p)
{
  return fract (sin (dot (p, cHashA3.xy)) * cHashM);
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

float Fbm2 (vec2 p)
{
  float s = 0.;
  float a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * Noisefv2 (p);
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

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec3 WoodCol (vec3 p, vec3 n)
{
  p *= 4.;
  float f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.zx * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return 0.5 * mix (vec3 (0.8, 0.4, 0.2), vec3 (0.45, 0.25, 0.1), f);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  float s = length (max (d, 0.));
  d = min (d, 0.);
  return max (d.x, max (d.y, d.z)) + s;
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

float PrFlatCylDf (vec3 p, float rhi, float rlo, float h)
{
  return max (length (p.xy - vec2 (rhi *
     clamp (p.x / rhi, -1., 1.), 0.)) - rlo, abs (p.z) - h);
}

float PrArchDf (vec3 p, float ht, float wd)
{
  return max (length (p.yx - vec2 (ht * clamp (p.y / ht, -1., 1.), 0.)) - wd, - p.y);
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  return length (vec2 (length (p.xy) - rc, p.z)) - ri;
}

struct RBridge {
  float bLen, bHt, lvHt, aWd, aHt, aTk, aRp, rFac;
};
RBridge rb;

int idObj;
mat3 bdMat, birdMat;
vec3 bdPos, birdPos, fltBox, qHit, ltDir;
float tCur, tBldCyc, tBldSeq, birdLen, birdVel, scnRad, scnLen;
bool isShad, brBuild, brShow;
const float dstFar = 50.;
const int idBrg1 = 1, idBrg2 = 2, idSlope = 3, idRocks = 4, idCase = 5,
   idWat = 6, idWing = 11, idBdy = 12, idEye = 13, idBk = 14;

vec3 SkyBg (vec3 rd)
{
  const vec3 sbCol = vec3 (0.2, 0.3, 0.55);
  return sbCol + 0.2 * pow (1. - max (rd.y, 0.), 5.);
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  const float skyHt = 150.;
  vec3 col;
  float cloudFac;
  if (rd.y > 0.) {
    ro.x += 10. * tCur;
    vec2 p = 0.02 * (rd.xz * (skyHt - ro.y) / rd.y + ro.xz);
    float w = 0.8;
    float f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.;
    }
    cloudFac = clamp (5. * f * rd.y - 1., 0., 1.);
  } else cloudFac = 0.;
  float s = max (dot (rd, ltDir), 0.);
  col = SkyBg (rd) + (0.35 * pow (s, 6.) +
     0.65 * min (pow (s, 256.), 0.3));
  col = mix (col, vec3 (0.85), cloudFac);
  return col;
}

float WaterHt (vec3 p)
{
  p *= 0.05;
  p += 0.005 * tCur * vec3 (0., 0., 1.);
  float ht = 0.;
  const float wb = 1.414;
  float w = wb;
  for (int j = 0; j < 7; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x) +
       0.003 * tCur * vec3 (0., 0., 1.);
    ht += w * abs (Noisefv3 (p) - 0.5);
  }
  return 0.12 * ht;
}

vec3 WaterNf (vec3 p)
{
  float ht = WaterHt (p);
  vec2 e = vec2 (0.01, 0.);
  return normalize (vec3 (ht - WaterHt (p + e.xyy), e.x, ht - WaterHt (p + e.yyx)));
}

float BdWingDf (vec3 p, float dHit)
{
  vec3 q, qh;
  float d, dd, a, wr;
  float wngFreq = 6.;
  float wSegLen = 0.15 * birdLen;
  float wChord = 0.3 * birdLen;
  float wSpar = 0.02 * birdLen;
  float fTap = 8.;
  float tFac = (1. - 1. / fTap);
  q = p - vec3 (0., 0., 0.3 * birdLen);
  q.x = abs (q.x) - 0.1 * birdLen;
  float wf = 1.;
  a = -0.1 + 0.2 * sin (wngFreq * tCur);
  d = dHit;
  qh = q;
  for (int k = 0; k < 5; k ++) {
    q.xy = Rot2D (q.xy, a);
    q.x -= wSegLen;
    wr = wf * (1. - 0.5 * q.x / (fTap * wSegLen));
    dd = PrFlatCylDf (q.zyx, wr * wChord, wr * wSpar, wSegLen);
    if (k < 4) {
      q.x -= wSegLen;
      dd = min (dd, PrCapsDf (q, wr * wSpar, wr * wChord));
    } else {
      q.x += wSegLen;
      dd = max (dd, PrCylDf (q.xzy, wr * wChord, wSpar));
      dd = min (dd, max (PrTorusDf (q.xzy, 0.98 * wr * wSpar, wr * wChord), - q.x));
    }
    if (dd < d) {
      d = dd;  qh = q;
    }
    a *= 1.03;
    wf *= tFac;
  }
  if (d < dHit) { dHit = min (dHit, d);  idObj = idWing;  qHit = qh; }
  return dHit;
}

float BdBodyDf (vec3 p, float dHit)
{
  vec3 q;
  float d, a, wr;
  float bkLen = 0.15 * birdLen;
  q = p;
  wr = q.z / birdLen;
  float tr, u;
  if (wr > 0.5) {
    u = (wr - 0.5) / 0.5;
    tr = 0.17 - 0.11 * u * u;
  } else {
    u = clamp ((wr - 0.5) / 1.5, -1., 1.);
    u *= u;
    tr = 0.17 - u * (0.34 - 0.18 * u); 
  }
  d = PrCapsDf (q, tr * birdLen, birdLen);
  if (d < dHit) { dHit = d;  idObj = idBdy;  qHit = q; }
  q = p;
  q.x = abs (q.x);
  wr = (wr + 1.) * (wr + 1.);
  q -= birdLen * vec3 (0.3 * wr, 0.1 * wr, -1.2);
  d = PrCylDf (q, 0.009 * birdLen, 0.2 * birdLen);
  if (d < dHit) { dHit = min (dHit, d);  idObj = idBdy;  qHit = q; }
  q = p;
  q.x = abs (q.x);
  q -= birdLen * vec3 (0.08, 0.05, 0.9);
  d = PrSphDf (q, 0.04 * birdLen);
  if (d < dHit) { dHit = d;  idObj = idEye;  qHit = q; }
  q = p;  q -= birdLen * vec3 (0., -0.015, 1.15);
  wr = clamp (0.5 - 0.3 * q.z / bkLen, 0., 1.);
  d = PrFlatCylDf (q, 0.25 * wr * bkLen, 0.25 * wr * bkLen, bkLen);
  if (d < dHit) { dHit = d;  idObj = idBk;  qHit = q; }
  return dHit;
}

float BirdDf (vec3 p, float dHit)
{
  dHit = BdWingDf (p, dHit);
  dHit = BdBodyDf (p, dHit);
  return 0.9 * dHit;
}

vec4 BirdCol (vec3 n)
{
  vec3 col;
  float spec = 1.;
  if (idObj == idWing) {
    float gw = 0.15 * birdLen;
    float w = mod (qHit.x, gw);
    w = SmoothBump (0.15 * gw, 0.65 * gw, 0.1 * gw, w);
    col = mix (vec3 (0., 0., 1.), vec3 (1., 0., 0.), w);
  } else if (idObj == idEye) {
    col = vec3 (0., 0.6, 0.);
    spec = 5.;
  } else if (idObj == idBdy) {
    vec3 nn = birdMat * n;
    col = mix (mix (vec3 (1., 0., 0.), vec3 (0., 0., 1.),
       smoothstep (0.5, 1., nn.y)), vec3 (1.),
       1. - smoothstep (-1., -0.7, nn.y));
  } else if (idObj == idBk) {
    col = vec3 (1., 1., 0.);
  }
  return vec4 (col, spec);
}

vec3 BirdTrack (float t)
{
  vec3 bp;
  float rdTurn = 0.3 * min (fltBox.x, fltBox.z);
  float tC = 0.5 * pi * rdTurn / birdVel;
  vec3 tt = vec3 (fltBox.x - rdTurn, length (fltBox.xy), fltBox.z - rdTurn) *
     2. / birdVel;
  float tFlyCyc = 2. * (2. * tt.z + tt.x  + 4. * tC + tt.y);
  float tFlySeq = mod (t + 0.2 * tt.z, tFlyCyc);
  float ti[9];  ti[0] = 0.;  ti[1] = ti[0] + tt.z;  ti[2] = ti[1] + tC;
  ti[3] = ti[2] + tt.x;  ti[4] = ti[3] + tC;  ti[5] = ti[4] + tt.z;
  ti[6] = ti[5] + tC;  ti[7] = ti[6] + tt.y;  ti[8] = ti[7] + tC;
  float a, h, hd, tf;
  h = - fltBox.y;
  hd = 1.;
  if (tFlySeq > 0.5 * tFlyCyc) {
    tFlySeq -= 0.5 * tFlyCyc;
    h = - h;  hd = - hd;
  }
  float rSeg = -1.;
  vec3 fbR = vec3 (1.);
  fbR.xz -= vec2 (rdTurn) / fltBox.xz;
  bp.xz = fltBox.xz;
  bp.y = h;
  if (tFlySeq < ti[4]) {
    if (tFlySeq < ti[1]) {
      tf = (tFlySeq - ti[0]) / (ti[1] - ti[0]);
      bp.xz *= vec2 (1., fbR.z * (2. * tf - 1.));
    } else if (tFlySeq < ti[2]) {
      tf = (tFlySeq - ti[1]) / (ti[2] - ti[1]);  rSeg = 0.;
      bp.xz *= fbR.xz;
    } else if (tFlySeq < ti[3]) {
      tf = (tFlySeq - ti[2]) / (ti[3] - ti[2]);
      bp.xz *= vec2 (fbR.x * (1. - 2. * tf), 1.);
    } else {
      tf = (tFlySeq - ti[3]) / (ti[4] - ti[3]);  rSeg = 1.;
      bp.xz *= fbR.xz * vec2 (-1., 1.);
    }
  } else {
    if (tFlySeq < ti[5]) {
      tf = (tFlySeq - ti[4]) / (ti[5] - ti[4]);
      bp.xz *= vec2 (- 1., fbR.z * (1. - 2. * tf));
    } else if (tFlySeq < ti[6]) {
      tf = (tFlySeq - ti[5]) / (ti[6] - ti[5]);  rSeg = 2.;
      bp.xz *= - fbR.xz;
    } else if (tFlySeq < ti[7]) {
      tf = (tFlySeq - ti[6]) / (ti[7] - ti[6]);
      bp.xz *= vec2 (fbR.x * (2. * tf - 1.), - 1.);
      bp.y = h + 2. * fltBox.y * hd * tf;
    } else {
      tf = (tFlySeq - ti[7]) / (ti[8] - ti[7]);  rSeg = 3.;
      bp.xz *= fbR.xz * vec2 (1., -1.);
      bp.y = - h;
    }
  }
  if (rSeg >= 0.) {
    a = 0.5 * pi * (rSeg + tf);
    bp += rdTurn * vec3 (cos (a), 0., sin (a));
  }
  bp.y -= 0.85 * rb.bHt - fltBox.y;
  return bp;
}

float BridgeDf (vec3 p, float dHit)
{
  vec3 q;
  float d, ds, yb, yh, sRed, aw, ah;
  float zCut = 0.3 * rb.bHt;
  q = p;
  yh = 0.02 * q.z;
  q = p;  q.y -= 0.01 * rb.bHt;
  d = PrBoxDf (q, vec3 (rb.bLen, rb.bHt, 0.0875 * rb.bHt * (1. - 0.444 * q.y / rb.bHt)));
  sRed = 1.;
  yb = - rb.bHt;
  for (int k = 0; k < 4; k ++) {
    float kf = float (k);
    aw = rb.aWd * sRed;
    ah = rb.aHt * sRed;
    q = p;
    q.x = mod (q.x + kf * rb.aRp * aw, 2. * rb.aRp * aw) - rb.aRp * aw;
    q.y -= yb;
    d = max (max (d, - PrArchDf (q, ah, aw)), - PrArchDf (q.zyx, 0.6 * ah, 0.3 * aw));
    yb += rb.lvHt * sRed;
    sRed *= rb.rFac;
  }
  q = p;  q.y -= rb.bHt;  q.y -= yh;
  float dc = PrCylDf (q, scnRad, zCut);
  d = max (d, dc);
  float varHt, varHtP, varLen;
  if (brBuild) {
    varHt = 0.;
    varLen = rb.bLen * min (mod (5. * tBldSeq / tBldCyc, 1.) + 0.01, 1.);
    int iq = int (floor (5. * tBldSeq / tBldCyc));
    sRed = 1.;
    for (int k = 0; k <= 4; k ++) {
      varHtP = varHt;
      varHt += rb.lvHt * sRed;
      sRed *= rb.rFac;
      if (k == iq) break;
    }
    q = p;  q.y -= - rb.bHt;
    ds = min (PrBoxDf (q, vec3 (varLen, varHt, zCut)),
       PrBoxDf (q, vec3 (rb.bLen, varHtP, zCut)));
    d = max (d, ds);
  }
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBrg1; }
  yb = - rb.bHt;
  q = p;  q.y -= yb;
  d = min (d, PrBoxDf (q, vec3 (rb.bLen, rb.aTk, 10. * rb.aTk)));
  q.x = mod (q.x, 2. * rb.aRp * rb.aWd) - rb.aRp * rb.aWd;
  d = max (d, - PrBoxDf (q, vec3 (5.5 * rb.aTk, 2. * rb.aTk, zCut)));
  sRed = 1.;
  for (int k = 0; k <= 3; k ++) {
    yb += rb.lvHt * sRed;
    sRed *= rb.rFac;
    q = p;  q.y -= yb;
    d = min (d, PrBoxDf (q, vec3 (rb.bLen, rb.aTk * sRed, 10. * rb.aTk * sRed)));
  }
  d = max (d, dc);
  if (brBuild) {
    q = p;  q.y -= - rb.bHt + 0.125 * rb.lvHt - 3. * rb.aTk;
    d = max (d, ds);
  }
  d = max (d, dc);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBrg2; }
  return dHit;
}

float GroundDf (vec3 p, float dHit)
{
  vec3 q;
  float d, db, dc, yh, dw, a, g;
  q = p;  q.y -= rb.bHt;
  yh = 0.02 * q.z;
  dc = PrCylDf (q, scnRad, 1.2 * scnLen);
  db = max (max (PrCylDf (q, 1.01 * scnRad, scnLen), q.y + 0.015 * rb.bHt),
     - q.y - 2.11 * rb.bHt + yh);
  d = max (db, - dc);
  q = p;  q.y -= - 1.05 * rb.bHt + yh;
  dw = PrBoxDf (q, vec3 (0.7 * scnRad, 0.025 * scnRad, 1.005 * scnLen));
  q.y -= 0.025 * scnRad;
  dw = max (dw, - PrBoxDf (q, vec3 (0.6 * scnRad, 0.025 * scnRad, scnLen)));
  d = min (d, max (dw, dc));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idCase; }
  q = p;  q.y -= rb.bHt + yh;
  a = atan (q.x, - q.y) / pi;
  g = Fbm2 (2. * vec2 ((abs (a) < 0.8) ? 12. * a : q.x, q.z));
  d = max (db, - PrCylDf (q, scnRad  * (0.995 - 0.07 * (1. - abs (a)) * g),
     1.2 * scnLen));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idSlope; }
  d = max (db, q.y + 2.12 * rb.bHt * (1. - 0.05 * g));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idRocks; }
  d = max (db, q.y + 2. * rb.bHt);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idWat; }
  return dHit;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dHit = dstFar;
  if (brShow) dHit = BridgeDf (p, dHit);
  if (! isShad) dHit = GroundDf (p, dHit);
  if (! brBuild) {
    q = p;  q -= birdPos;
    if (PrSphDf (q, 0.2) < dHit) dHit = BirdDf (birdMat * q, dHit);
  }
  return 0.9 * dHit;
}

float ObjRay (vec3 ro, vec3 rd)
{
  const float dTol = 0.001;
  float d;
  float dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < dTol || dHit > dstFar) break;
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

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh = 1.;
  float d = 0.03;
  for (int i = 0; i < 50; i++) {
    float h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.03;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

float ObjAO (vec3 ro, vec3 rd)
{
  float ao = 0.;
  for (int i = 0; i < 8; i ++) {
    float d = 0.01 + float (i) / 8.;
    ao += max (0., d - 3. * ObjDf (ro + rd * d));
  }
  return clamp (1. - 0.1 * ao, 0., 1.);
}

vec4 SceneCol (vec3 n)
{
  vec3 col;
  float spec = 1.;
  if (idObj == idBrg1) col = vec3 (0.55, 0.35, 0.15);
  else if (idObj == idBrg2) col = 0.9 * vec3 (0.55, 0.35, 0.15);
  else if (idObj == idSlope) {
    col = mix (vec3 (0.3, 0.2, 0.1), vec3 (0.2, 0.7, 0.2),
       clamp (qHit.y + 3.5, 0., 1.));
    if (abs (n.z) < 0.99 && n.y < 0.5) col = mix (vec3 (0.25, 0.25, 0.2), col, 
       smoothstep (0.2, 0.5, n.y));
    spec = 0.2;
  } else if (idObj == idRocks) {
    col = mix (vec3 (0.2, 0.4, 0.1), vec3 (0.3, 0.25, 0.1),
       clamp (10. * (qHit.y + 3.5), 0., 1.));
    spec = 0.5;
  } else if (idObj == idCase) col = WoodCol (3. * qHit.zyx, n);
  return vec4 (col, spec);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 vn, col;
  float reflFac;
  int idObjT;
  float dstHit, ao, sh;
  isShad = false;
  reflFac = 1.;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar && idObj == idWat) {
    ro += rd * dstHit;
    rd = reflect (rd, WaterNf (qHit));
    ro += 0.01 * rd;
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    reflFac *= 0.8;
  }
  if (idObj < 0) dstHit = dstFar;
  idObjT = idObj;
  if (dstHit >= dstFar) col = SkyCol (ro, rd);
  else {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == idBrg1 || idObj == idBrg2) vn = VaryNf (50. * qHit, vn, 0.5);
    else if (idObj == idCase) vn = VaryNf (qHit * vec3 (10., 10., 0.5), vn, 1.);
    if (idObj >= idWing) objCol = BirdCol (vn);
    else objCol = SceneCol (vn);
    float dif = max (dot (vn, ltDir), 0.);
    ao = ObjAO (ro, vn);
    isShad = true;
    sh = ObjSShadow (ro, ltDir);
    col = reflFac * objCol.xyz * (0.2 * ao * (1. +
       max (dot (vn, - normalize (vec3 (ltDir.x, 0., ltDir.z))), 0.)) + 
       max (0., dif) * sh *
       (dif + ao * objCol.w * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.)));
  }
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

void BirdPM (float t, int id)
{
  float dt = 1.;
  bdPos = BirdTrack (t);
  vec3 bpF = BirdTrack (t + dt);
  vec3 bpB = BirdTrack (t - dt);
  vec3 vel = (bpF - bpB) / (2. * dt);
  float vy = vel.y;  vel.y = 0.;
  vec3 acc = (bpF - 2. * bdPos + bpB) / (dt * dt);  acc.y = 0.;
  vec3 va = cross (acc, vel) / length (vel);
  vel.y = vy;
  float el = - 0.75 * asin (vel.y / length (vel));
  float rl = 1.5 * length (va) * sign (va.y);
  if (id > 0) {
    el += 0.05 * pi;  rl = 0.5 * rl;
  }
  vec3 ort = vec3 (el, atan (vel.z, vel.x) - 0.5 * pi, rl);
  vec3 cr = cos (ort);
  vec3 sr = sin (ort);
  bdMat = mat3 (cr.z, - sr.z, 0., sr.z, cr.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., cr.x, - sr.x, 0., sr.x, cr.x) *
     mat3 (cr.y, 0., - sr.y, 0., 1., 0., sr.y, 0., cr.y);
}

void SetConf ()
{
  rb.bLen = 5.;
  rb.bHt = 0.343 * rb.bLen;  rb.lvHt = rb.bHt * 0.7314;
  rb.aHt = 0.6 * rb.lvHt;  rb.aWd = 0.0526 * rb.bLen;  rb.aTk = 0.0243 * rb.bHt;
  rb.aRp = 1.2;  rb.rFac = 0.75;
  scnRad = 0.867 * rb.bLen;  scnLen = 1.3 * rb.bLen;
  fltBox = vec3 (3. * rb.aRp * rb.aWd, 0.25 * (1. + rb.rFac) * rb.lvHt, 0.7 * scnLen);
  birdVel = 0.5;
  BirdPM (tCur, 0);
  birdPos = bdPos;  birdMat = bdMat;
  birdLen = 0.08;
}

//#define TRACK_MODE

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  int vuMode;
  mat3 vuMat;
  vec3 ro, rd, vd;
  float tDel, zmFac;
  SetConf ();
  tBldCyc = 10.;
  tBldSeq = mod (tCur, tBldCyc);
  brShow = true;  brBuild = false;
  ltDir = normalize (vec3 (-0.4, 0.2, -0.3));
  if (tCur < tBldCyc) {
    vuMode = 1;  brShow = false;
  } else if (tCur < 2. * tBldCyc) {
    vuMode = 1;  brBuild = true;
#ifdef TRACK_MODE
  } else if (tCur < 10. * tBldCyc) {
    vuMode = 2;
#endif
  } else vuMode = 3;
  if (vuMode == 1) {
    zmFac = 3.6;
    float az = 0.05 * 2. * pi * tCur;
    float el = 0.6 - 0.5 * cos (2. * az);
    float cEl = cos (el), sEl = sin (el);
    float cAz = cos (az), sAz = sin (az);

    vuMat = mat3 (cAz, 0., - sAz, 0., 1., 0., sAz, 0., cAz) *
       mat3 (1., 0., 0., 0., cEl, sEl, 0., - sEl, cEl);
    float dist = max (25. - 10. * tCur / tBldCyc, 15.);
    ro = dist * vuMat * vec3 (0., 0., -1.);
    ltDir = ltDir * vuMat;
    rd = vuMat * normalize (vec3 (uv, zmFac));
  } else if (vuMode == 2) {
    ro = vec3 (-0.45 * fltBox.x, 2. * fltBox.y, - 4. * fltBox.z);
    vd = normalize (birdPos - ro);
    vec3 u = - vd.y * vd;
    float f = 1. / sqrt (1. - vd.y * vd.y);
    vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
    zmFac = 30. * (birdPos.z - ro.z) / (scnLen - ro.z);
    rd = vuMat * normalize (vec3 (uv, zmFac));
  } else if (vuMode == 3) {
    tDel = 1.2;
    BirdPM (tCur - tDel, 1);
    ro = bdPos;  ro.y += 2.5 * birdLen;
    vuMat = bdMat;
    zmFac = 1.3;
    rd = normalize (vec3 (uv, zmFac)) * vuMat;
  }
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
