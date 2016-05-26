// Shader downloaded from https://www.shadertoy.com/view/MlX3Rf
// written by shadertoy user dr2
//
// Name: Biplanes in the Badlands
// Description: More aviation adventures.
// "Biplanes in the Badlands" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

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

float SmoothStep5 (float xLo, float xHi, float x)
{
  x = clamp ((x - xLo) / (xHi - xLo), 0., 1.);
  return x * x * x * (x * (6. * x - 15.) + 10.);
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

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrFlatCylDf (vec3 p, float rhi, float rlo, float h)
{
  return max (length (p.xy - vec2 (rhi *
     clamp (p.x / rhi, -1., 1.), 0.)) - rlo, abs (p.z) - h);
}

float PrRoundBoxDf (vec3 p, vec3 b, float r) {
  return length (max (abs (p) - b, 0.)) - r;
}

int idObj, idObjGrp;
mat3 flyerMat[3], flMat;
vec3 flyerPos[3], flPos, qHit, qHitTransObj, sunDir;
float tCur, flyVel;
float fusLen, wSpan;
const float dstFar = 150.;
const float pi = 3.14159;
const int idFus = 11, idPipe = 12, idWing = 13, idStrut = 14,
   idHstab = 15, idFin = 16, idLeg = 17, idAxl = 18, idWhl = 19,
   idNose = 20, idCkpit = 21, idPlt = 22;

vec3 SkyBg (vec3 rd)
{
  return mix (vec3 (0.1, 0.1, 0.7), vec3 (0.4, 0.4, 0.7),
     1. - max (rd.y, 0.));
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  vec3 p, q, cSun, clCol, col;
  float fCloud, cloudLo, cloudRngI, atFac, colSum, attSum, s,
     att, a, dDotS, ds;
  const int nLay = 30;
  cloudLo = 100.;  cloudRngI = 1./100.;  atFac = 0.045;
  fCloud = 0.5;
  if (rd.y > 0.) {
    fCloud = clamp (fCloud, 0., 1.);
    dDotS = max (dot (rd, sunDir), 0.);
    ro.x += 2.5 * tCur;
    p = ro;
    p.xz += (cloudLo - p.y) * rd.xz / rd.y;
    p.y = cloudLo;
    ds = 1. / (cloudRngI * rd.y * (2. - rd.y) * float (nLay));
    colSum = 0.;  attSum = 0.;
    s = 0.;  att = 0.;
    for (int j = 0; j < nLay; j ++) {
      q = p + rd * s;
      q.z *= 0.7;
      att += atFac * max (fCloud - Fbm3 (0.02 * q), 0.);
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
  } else col = SkyBg (- rd);
  return col;
}

vec3 TrackPath (float z)
{
  return vec3 (30. * sin (0.035 * z) * sin (0.012 * z) * cos (0.01 * z) +
     26. * sin (0.0032 * z),
     5. + 1.5 * SmoothBump (55., 105., 20., mod (z, 140.)), z);
}

float GrndHt (vec2 p)
{
  const mat2 qRot = mat2 (0.8, -0.6, 0.6, 0.8);
  vec2 q;
  float s, a, w;
  q = 0.1 * p;
  s = 0.;
  for (int i = 0; i < 3; i ++) {
    s += Noisefv2 (q);
    q *= 2. * qRot;
  }
  s = 10. * (clamp (0.33 * s, 0., 1.) - 0.55);
  w = clamp (0.5 * abs (p.x - TrackPath (p.y).x) - 1.2, 0., 1.);
  s = 4. * SmoothStep5 (0., 1., SmoothMin (s, 1.5 * w * w, 0.5));
  q = 0.04 * p * qRot;
  a = 1.;
  for (int i = 0; i < 7; i ++) {
    s += a * Noisefv2 (q);
    a *= 0.7;
    q *= 2. * qRot;
  }
  return s;
}

float GrndRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, h, s, sLo, sHi;
  s = 0.;
  sLo = 0.;
  dHit = dstFar;
  for (int j = 0; j < 180; j ++) {
    p = ro + s * rd;
    h = p.y - GrndHt (p.xz);
    if (h < 0.) break;
    sLo = s;
    s += 0.2 * h + 0.007 * s;
    if (s > dstFar) break;
  }
  if (h < 0.) {
    sHi = s;
    for (int j = 0; j < 7; j ++) {
      s = 0.5 * (sLo + sHi);
      p = ro + s * rd;
      h = step (0., p.y - GrndHt (p.xz));
      sLo += h * (s - sLo);
      sHi += (1. - h) * (s - sHi);
    }
    dHit = sHi;
  }
  return dHit;
}

vec3 GrndNf (vec3 p, float d)
{
  vec2 e;
  float ht;
  ht = GrndHt (p.xz);
  e = vec2 (max (0.01, 0.00001 * d * d), 0.);
  return normalize (vec3 (ht - GrndHt (p.xz + e.xy), e.x,
     ht - GrndHt (p.xz + e.yx)));
}

float GrndSShadow (vec3 ro, vec3 rd)
{
  vec3 p;
  float sh, d, h;
  sh = 1.;
  d = 0.4;
  for (int i = 0; i < 20; i ++) {
    p = ro + rd * d;
    h = p.y - GrndHt (p.xz);
    sh = min (sh, 20. * h / d);
    d += 0.4;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 GrndCol (vec3 p, vec3 n)
{
  vec3 q;
  float f;
  const vec3 wCol1 = vec3 (0.6, 0.3, 0.2), wCol2 = vec3 (0.35, 0.3, 0.4),
     tCol1 = vec3 (0.4, 0.4, 0.2), tCol2 = vec3 (0., 0.6, 0.),
     bCol1 = vec3 (0.5, 0.4, 0.2), bCol2 = vec3 (0.6, 0.3, 0.3);
  vec3 col, vCol, hCol;
  q = 2.2 * p;
  vCol = mix (wCol1, wCol2, clamp (1.4 * (Noisefv2 (q.xy +
     vec2 (0., 0.3 * sin (0.14 * q.z)) *
     vec2 (2., 7.3)) + Noisefv2 (q.zy * vec2 (3., 6.3))) - 1., 0., 1.));
  f = clamp (0.7 * Noisefv2 (q.xz) - 0.3, 0., 1.);
  if (p.y > 3.5) hCol = mix (tCol1, tCol2, f);
  else hCol = mix (bCol1, bCol2, f);
  col = 1.4 * mix (vCol, hCol, smoothstep (0.4, 0.7, n.y));
  return col;
}

float PropelDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  q = p - fusLen * vec3 (0., 0.02, 1.07);
  d = PrCylDf (q, 0.3 * fusLen, 0.007 * fusLen);
  if (d < dHit) {
    dHit = d;
    qHitTransObj = q;
  }
  return dHit;
}

float TransObjDf (vec3 p)
{
  float dHit;
  dHit = dstFar;
  dHit = PropelDf (flyerMat[0] * (p - flyerPos[0]), dHit);
  dHit = PropelDf (flyerMat[1] * (p - flyerPos[1]), dHit);
  dHit = PropelDf (flyerMat[2] * (p - flyerPos[2]), dHit);
  return dHit;
}

float TransObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 120; j ++) {
    d = TransObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

float FlyerDf (vec3 p, float dHit)
{
  vec3 q, qq;
  float d, wr;
  q = p;
  wr = -0.2 + q.z / fusLen;
  d = PrRoundBoxDf (q, vec3 (0.07 * (1. - 0.8 * wr * wr),
     0.11 * (1. - 0.6 * wr * wr), 1.) * fusLen, 0.05 * fusLen);
  q -= vec3 (0., 0.1, 0.3) * fusLen;
  d = max (d, - PrRoundBoxDf (q, vec3 (0.05, 0.1, 0.15) * fusLen,
     0.03 * fusLen)); 
  if (d < dHit) { dHit = min (dHit, d);  idObj = idObjGrp + idFus;  qHit = q; }
  q = p;  q -= vec3 (0., 0.08, 0.3) * fusLen;
  d = PrRoundBoxDf (q, vec3 (0.05, 0.02, 0.15) * fusLen, 0.03 * fusLen); 
  if (d < dHit) { dHit = min (dHit, d);  idObj = idObjGrp + idCkpit;  qHit = q; }
  q = p;  q.z = abs (q.z - 0.33 * fusLen) - 0.08 * fusLen;
  q -= vec3 (0., 0.17, 0.) * fusLen;
  d = PrSphDf (q, 0.04 * fusLen); 
  if (d < dHit) { dHit = min (dHit, d);  idObj = idObjGrp + idPlt;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.03, 0.8);
  q.x = abs (q.x) - 0.1 * fusLen;
  d = PrCapsDf (q, 0.02 * fusLen, 0.15 * fusLen);
  if (d < dHit) { dHit = min (dHit, d);  idObj = idObjGrp + idPipe;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.03, 1.05);
  d = PrCapsDf (q, 0.05 * fusLen, 0.02 * fusLen);
  if (d < dHit) { dHit = d;  idObj = idObjGrp + idNose;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.09, 0.2);
  qq = q;  qq.y = abs (qq.y) - 0.21 * fusLen;
  wr = q.x / wSpan;
  d = PrFlatCylDf (qq.zyx, 0.24 * (1. - 0.2 * wr * wr) * fusLen,
     0.01 * (1. - 0.8 * wr * wr) * fusLen, wSpan);
  if (d < dHit) { dHit = min (dHit, d);  idObj = idObjGrp + idWing;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.09, 0.25);
  q.xz = abs (q.xz) - fusLen * vec2 (0.5, 0.1);
  d = PrCylDf (q.xzy, 0.01 * fusLen, 0.21 * fusLen);
  if (d < dHit) { dHit = min (dHit, d);  idObj = idObjGrp + idStrut;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.15, 0.25);
  q.x = abs (q.x) - 0.1 * fusLen;
  d = PrCylDf (q.xzy, 0.01 * fusLen, 0.15 * fusLen);
  if (d < dHit) { dHit = min (dHit, d);  idObj = idObjGrp + idStrut;  qHit = q; }
  float tSpan = 0.35 * wSpan;
  q = p - fusLen * vec3 (0., 0., - 0.9);
  wr = q.x / tSpan;
  d = PrFlatCylDf (q.zyx, 0.15 * (1. - 0.25 * wr * wr) * fusLen,
     0.007 * (1. - 0.2 * wr * wr) * fusLen, tSpan);
  q.x = abs (q.x);
  d = max (d, 0.02 * fusLen - 1.5 * q.x - q.z);
  if (d < dHit) { dHit = min (dHit, d);  idObj = idObjGrp + idHstab;  qHit = q; }
  float fSpan = 0.32 * wSpan;
  q = p - fusLen * vec3 (0., 0., - 0.87);
  q.yz = Rot2D (q.yz, 0.15);
  wr = q.y / fSpan;
  d = PrFlatCylDf (q.zxy, 0.15 * (1. - 0.3 * wr * wr) * fusLen,
     0.007 * (1. - 0.3 * wr * wr) * fusLen, fSpan);
  d = max (d, - q.y);
  if (d < dHit) { dHit = min (dHit, d);  idObj = idObjGrp + idFin;  qHit = q; }
  q = p - fusLen * vec3 (0., -0.25, 0.5);
  q.x = abs (q.x) - 0.14 * fusLen;
  q.xy = Rot2D (q.xy, -0.55);  q.yz = Rot2D (q.yz, 0.15);
  d = PrCylDf (q.xzy, 0.013 * fusLen, 0.12 * fusLen);
  if (d < dHit) { dHit = d;  idObj = idObjGrp + idLeg;  qHit = q; }
  q = p - fusLen * vec3 (0., -0.34, 0.515);
  q.x = abs (q.x) - 0.22 * fusLen;
  d = PrCylDf (q.yzx, 0.01 * fusLen, 0.035 * fusLen);
  if (d < dHit) { dHit = d;  idObj = idObjGrp + idAxl;  qHit = q; }
  q.x -= 0.01 * fusLen;
  d = PrCylDf (q.yzx, 0.1 * fusLen, 0.015 * fusLen);
  if (d < dHit) { dHit = d;  idObj = idObjGrp + idWhl;  qHit = q; }
  return dHit;
}

float ObjDf (vec3 p)
{
  float dHit;
  dHit = dstFar;
  idObjGrp = 1 * 256;
  dHit = FlyerDf (flyerMat[0] * (p - flyerPos[0]), dHit);
  idObjGrp = 2 * 256;
  dHit = FlyerDf (flyerMat[1] * (p - flyerPos[1]), dHit);
  dHit = FlyerDf (flyerMat[2] * (p - flyerPos[2]), dHit);
  return 0.9 * dHit;
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
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.02 * fusLen;
  for (int i = 0; i < 50; i++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.02 * fusLen;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec4 FlyerCol (vec3 n)
{
  vec3 col, qqHit, nn;
  float spec, b;
  int ig, id;
  spec = 0.2;
  qqHit = qHit / fusLen;
  ig = idObj / 256;  id = idObj - 256 * ig;
  col = (ig == 2) ? vec3 (0., 0.9, 0.1) : vec3 (0.9, 0., 0.1);
  if (ig == 1) nn = flyerMat[0] * n;
  else if (ig == 2) nn = flyerMat[1] * n;
  else nn = flyerMat[2] * n;
  if (id == idFus) {
    qqHit.yz -= vec2 (-0.1, -0.7);
    col *= (1. - 0.5 * SmoothBump (0.06, 0.09, 0.01, length (qqHit.yz))) *
       (1. - 0.5 * SmoothBump (-0.01, 0.03, 0.01, length (qqHit.yz)));
    if (nn.z > 0.9 && qqHit.y < -0.03) col *= 0.3;
  } else if (id == idWing) {
    b = wSpan / (8. * fusLen);
    b = mod (qqHit.x + 0.5 * b, b) - 0.5 * b;
    col *= 1. + 0.1 * SmoothBump (-0.01, 0.01, 0.002, b);
    if (qqHit.y * nn.y > 0.) {
      qqHit.x = abs (qqHit.x) - 0.8;
      qqHit.z -= 0.03;
      col *= (1. - 0.5 * SmoothBump (0.08, 0.12, 0.01, length (qqHit.xz))) *
         (1. - 0.5 * SmoothBump (-0.01, 0.03, 0.01, length (qqHit.xz)));
    }
  } else if (id == idFin || id == idHstab) {
    col *= 1. - 0.6 * SmoothBump (-0.062, -0.052, 0.002, qqHit.z);
  } else if (id == idPipe || id == idNose) {
    col = vec3 (0.8, 0.8, 0.);
    spec = 0.4;
  } else if (id == idStrut || id == idLeg) {
    col = 0.6 * col + vec3 (0.4);
  } else if (id == idAxl) {
    col = vec3 (0.3, 0.2, 0.);
  } else if (id == idCkpit) {
    col = vec3 (0.2, 0.15, 0.05);
  } else if (id == idPlt) {
    col = vec3 (0.1, 0.07, 0.);
    if (nn.z > 0.7) {
      col *= 2.;
      qqHit.x = abs (qqHit.x) - 0.015 * fusLen;
      col *= (1. - 0.9 * SmoothBump (0.003, 0.01, 0.001, length (qqHit.xy)));
    }
  } else if (id == idWhl) {
    if (length (qqHit.yz) < 0.07) col = vec3 (0.4, 0.4, 0.4);
    else {
      col = vec3 (0.02);
      spec = 0.;
    }
  }
  return vec4 (col, spec);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 col4;
  vec3 col, c1, c2, vn;
  float dstObj, dstGrnd, dstPropel, f, dif, sh, bk;
  int idObjT;
  dstGrnd = GrndRay (ro, rd);
  dstPropel = TransObjRay (ro, rd);
  idObj = -1;
  dstObj = ObjRay (ro, rd);
  if (idObj < 0) dstObj = dstFar;
  if (min (dstObj, dstGrnd) < dstPropel) dstPropel = dstFar;
  if (dstObj < dstGrnd) {
    ro += dstObj * rd;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    col4 = FlyerCol (flyerMat[0] * vn); // [0]!
    if (idObj == 256 + idWing || idObj == 256 + idHstab) {
      vn.yz = Rot2D (vn.yz, -0.6 * qHit.z / fusLen);
      vn = VaryNf (100. * ro, vn, 0.05);
    } else if (idObj == 256 + idFin) {
      vn.xz = Rot2D (vn.xz, -0.6 * qHit.z / fusLen);
    }
    dif = max (dot (vn, sunDir), 0.);
    sh = ObjSShadow (ro, sunDir);
    bk = max (dot (vn.xz, - normalize (sunDir.xz)), 0.);
    col = col4.rgb * (0.2 + 0.2 * bk + 0.6 * sh * max (0., dif)) +
       sh * col4.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 128.);
    col = sqrt (clamp (col, 0., 1.));
  } else if (dstGrnd < dstFar) {
    ro += dstGrnd * rd;
    vn = VaryNf (3.2 * ro, GrndNf (ro, dstGrnd), 1.5);
    col = GrndCol (ro, vn);
    sh = GrndSShadow (ro, sunDir);
    bk = max (dot (vn.xz, - normalize (sunDir.xz)), 0.);
    col *= (0.7 + 0.3 * sh) * (0.2 + 0.4 * bk +
       0.7 * max (0., max (dot (vn, sunDir), 0.)));
    f = dstGrnd / dstFar;
    f *= f;
    col = mix (col, SkyBg (rd), clamp (f * f, 0., 1.));
  } else col = SkyCol (ro, rd);
  if (dstPropel < dstFar) col = vec3 (0.1) * (1. -
     0.3 * SmoothBump (0.25, 0.27, 0.006,
     length (qHitTransObj.xy) / fusLen)) + 0.7 * col;
  return clamp (col, 0., 1.);
}

void FlyerPM (float t, float vu)
{
  vec3 fpF, fpB, vel, acc, va, ort, cr, sr;
  float vy, dt, vDir, rlFac;
  dt = 0.2;
  flPos = TrackPath (t * flyVel);
  if (vu >= 0.) vDir = 1.;
  else vDir = -1.;
  fpF = TrackPath ((t + vDir * dt) * flyVel);
  fpB = TrackPath ((t - vDir * dt) * flyVel);
  vel = (fpF - fpB) / (2. * dt);
  vy = vel.y;
  vel.y = 0.;
  acc = (fpF - 2. * flPos + fpB) / (dt * dt);
  acc.y = 0.;
  va = cross (acc, vel) / length (vel);
  vel.y = vy;
  rlFac = (vu == 0.) ? 0.4 : 0.7;
  ort = vec3 (0., atan (vel.z, vel.x) - 0.5 * pi,
     rlFac * length (va) * sign (va.y));
  cr = cos (ort);
  sr = sin (ort);
  flMat = mat3 (cr.z, - sr.z, 0., sr.z, cr.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., cr.x, - sr.x, 0., sr.x, cr.x) *
     mat3 (cr.y, 0., - sr.y, 0., 1., 0., sr.y, 0., cr.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  vec2 uvs = uv;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  vec3 ro, rd, col;
  float tSep, t, fHlx, aHlx;
  sunDir = normalize (vec3 (cos (0.03 * tCur), 1., sin (0.03 * tCur)));
  fusLen = 0.5;
  wSpan = 1.2 * fusLen;
  flyVel = 5.;
  aHlx = 2. * fusLen;
  fHlx = 0.03 * flyVel;
  FlyerPM (tCur, 0.);
  ro = flPos;
  vuMat = flMat;
  ro.xy += 0.6 * aHlx * vec2 (cos (fHlx * tCur), sin (fHlx * tCur));
  tSep = 80. * fusLen / flyVel;
  t = ro.z / flyVel + (0.025 + 0.015 * sin (0.1 * tCur)) * tSep;
  FlyerPM (t, 1.);
  flyerPos[0] = flPos;
  flyerMat[0] = flMat;
  flyerPos[0].xy += aHlx * vec2 (cos (fHlx * t), sin (fHlx * t));
  t = tSep * (1. + floor (ro.z / (tSep * flyVel))) - mod (tCur, tSep);
  FlyerPM (t, -1.);
  flyerPos[1] = flPos;
  flyerMat[1] = flMat;
  flyerPos[1].xy -= aHlx * vec2 (cos (fHlx * t), sin (fHlx * t));
  t += tSep;
  FlyerPM (t, -1.);
  flyerPos[2] = flPos;
  flyerMat[2] = flMat;
  flyerPos[2].xy -= aHlx * vec2 (cos (fHlx * t), sin (fHlx * t));
  rd = normalize (vec3 (uv, 2.2)) * vuMat;
  col = ShowScene (ro, rd);
  uvs *= uvs * uvs;
  col = mix (vec3 (0.4), col,
     pow (max (0., 0.95 - length (uvs * uvs * uvs)), 0.2));
  fragColor = vec4 (col, 1.);
}

