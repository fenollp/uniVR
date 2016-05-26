// Shader downloaded from https://www.shadertoy.com/view/MtXGzs
// written by shadertoy user dr2
//
// Name: Yellow Moth
// Description: Cousin of the famous Tiger Moth.
// "Yellow Moth" by dr2 - 2015
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

int idObj;
mat3 flMat;
vec3 flPos, qHit, qHitTransObj, sunDir;
float fusLen, wSpan, flyVel, tCur;
const float dstFar = 350.;
const int idFus = 11, idPipe = 12, idWing = 13, idStrut = 14,
   idHstab = 15, idFin = 16, idLeg = 17, idAxl = 18, idWhl = 19,
   idNose = 20, idCkpit = 21, idPlt = 22;

vec3 SkyBg (vec3 rd)
{
  return mix (vec3 (0.2, 0.2, 0.9), vec3 (0.4, 0.4, 0.55),
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
    ro.x += 10. * tCur;
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

vec3 TrackPath (float t)
{
  float s = sin (0.005 * t);
  float c = cos (0.005 * t);
  c /= (1. + s * s);
  return vec3 (1. + 40. * c, 13. + 2. * sin (0.0073 * t), -5. + 40. * s * c);
}

float GrndHt (vec2 p)
{
  const mat2 qRot = mat2 (1.6, -1.2, 1.2, 1.6);
  vec2 q, t, ta, v;
  float wAmp, pRough, ht;
  wAmp = 2.;
  pRough = 1.;
  q = p * 0.1;
  ht = 0.0001 * dot (p, p);
  for (int j = 0; j < 3; j ++) {
    t = q + 2. * Noisefv2 (q) - 1.;
    ta = abs (sin (t));
    v = (1. - ta) * (ta + abs (cos (t)));
    v = pow (1. - v, vec2 (pRough));
    ht += (v.x + v.y) * wAmp;
    q *= 1.5 * qRot;
    wAmp *= 0.25;
    pRough = 0.6 * pRough + 0.2;
  }
  return ht;
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
    s += max (0.25, 0.4 * h) + 0.005 * s;
    if (s > dstFar) break;
  }
  if (h < 0.) {
    sHi = s;
    for (int j = 0; j < 8; j ++) {
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
  float ht = GrndHt (p.xz);
  vec2 e = vec2 (max (0.01, 0.00001 * d * d), 0.);
  return normalize (vec3 (ht - GrndHt (p.xz + e.xy), e.x,
     ht - GrndHt (p.xz + e.yx)));
}

float PropelDf (vec3 p, float dMin)
{
  vec3 q;
  float d;
  q = p - fusLen * vec3 (0., 0.02, 1.07);
  d = PrCylDf (q, 0.3 * fusLen, 0.007 * fusLen);
  if (d < dMin) {
    dMin = d;
    qHitTransObj = q;
    idObj = 1;
  }
  return dMin;
}

float TransObjDf (vec3 p)
{
  float dMin;
  dMin = dstFar;
  dMin = PropelDf (flMat * (p - flPos), dMin);
  return dMin;
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

float FlyerDf (vec3 p, float dMin)
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
  if (d < dMin) { dMin = min (dMin, d);  idObj = idFus;  qHit = q; }
  q = p;  q -= vec3 (0., 0.08, 0.3) * fusLen;
  d = PrRoundBoxDf (q, vec3 (0.05, 0.02, 0.15) * fusLen, 0.03 * fusLen); 
  if (d < dMin) { dMin = min (dMin, d);  idObj = idCkpit;  qHit = q; }
  q = p;  q.z = abs (q.z - 0.33 * fusLen) - 0.08 * fusLen;
  q -= vec3 (0., 0.17, 0.) * fusLen;
  d = PrSphDf (q, 0.04 * fusLen); 
  if (d < dMin) { dMin = min (dMin, d);  idObj = idPlt;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.03, 0.8);
  q.x = abs (q.x) - 0.1 * fusLen;
  d = PrCapsDf (q, 0.02 * fusLen, 0.15 * fusLen);
  if (d < dMin) { dMin = min (dMin, d);  idObj = idPipe;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.03, 1.05);
  d = PrCapsDf (q, 0.05 * fusLen, 0.02 * fusLen);
  if (d < dMin) { dMin = d;  idObj = idNose;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.09, 0.2);
  qq = q;  qq.y = abs (qq.y) - 0.21 * fusLen;
  wr = q.x / wSpan;
  d = PrFlatCylDf (qq.zyx, 0.24 * (1. - 0.2 * wr * wr) * fusLen,
     0.01 * (1. - 0.8 * wr * wr) * fusLen, wSpan);
  if (d < dMin) { dMin = min (dMin, d);  idObj = idWing;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.09, 0.25);
  q.xz = abs (q.xz) - fusLen * vec2 (0.5, 0.1);
  d = PrCylDf (q.xzy, 0.01 * fusLen, 0.21 * fusLen);
  if (d < dMin) { dMin = min (dMin, d);  idObj = idStrut;  qHit = q; }
  q = p - fusLen * vec3 (0., 0.15, 0.25);
  q.x = abs (q.x) - 0.1 * fusLen;
  d = PrCylDf (q.xzy, 0.01 * fusLen, 0.15 * fusLen);
  if (d < dMin) { dMin = min (dMin, d);  idObj = idStrut;  qHit = q; }
  float tSpan = 0.35 * wSpan;
  q = p - fusLen * vec3 (0., 0., - 0.9);
  wr = q.x / tSpan;
  d = PrFlatCylDf (q.zyx, 0.15 * (1. - 0.25 * wr * wr) * fusLen,
     0.007 * (1. - 0.2 * wr * wr) * fusLen, tSpan);
  q.x = abs (q.x);
  d = max (d, 0.02 * fusLen - 1.5 * q.x - q.z);
  if (d < dMin) { dMin = min (dMin, d);  idObj = idHstab;  qHit = q; }
  float fSpan = 0.32 * wSpan;
  q = p - fusLen * vec3 (0., 0., - 0.87);
  q.yz = Rot2D (q.yz, 0.15);
  wr = q.y / fSpan;
  d = PrFlatCylDf (q.zxy, 0.15 * (1. - 0.3 * wr * wr) * fusLen,
     0.007 * (1. - 0.3 * wr * wr) * fusLen, fSpan);
  d = max (d, - q.y);
  if (d < dMin) { dMin = min (dMin, d);  idObj = idFin;  qHit = q; }
  q = p - fusLen * vec3 (0., -0.25, 0.5);
  q.x = abs (q.x) - 0.14 * fusLen;
  q.xy = Rot2D (q.xy, -0.55);  q.yz = Rot2D (q.yz, 0.15);
  d = PrCylDf (q.xzy, 0.013 * fusLen, 0.12 * fusLen);
  if (d < dMin) { dMin = d;  idObj = idLeg;  qHit = q; }
  q = p - fusLen * vec3 (0., -0.34, 0.515);
  q.x = abs (q.x) - 0.22 * fusLen;
  d = PrCylDf (q.yzx, 0.01 * fusLen, 0.035 * fusLen);
  if (d < dMin) { dMin = d;  idObj = idAxl;  qHit = q; }
  q.x -= 0.01 * fusLen;
  d = PrCylDf (q.yzx, 0.1 * fusLen, 0.015 * fusLen);
  if (d < dMin) { dMin = d;  idObj = idWhl;  qHit = q; }
  return dMin;
}

float ObjDf (vec3 p)
{
  float dMin = dstFar;
  dMin = FlyerDf (flMat * (p - flPos), dMin);
  dMin *= 0.8;
  return dMin;
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
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh = 1.;
  float d = 0.02;
  for (int i = 0; i < 40; i++) {
    float h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.02;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec4 FlyerCol (vec3 n)
{
  vec3 col, qqHit, nn;
  float spec, b;
  spec = 0.2;
  qqHit = qHit / fusLen;
  col = vec3 (0.9, 0.9, 0.);
  nn = flMat * n;
  if (idObj == idFus) {
    qqHit.yz -= vec2 (-0.1, -0.7);
    col = mix (vec3 (0., 1., 0.), col,
       (1. - 0.5 * SmoothBump (0.06, 0.09, 0.01, length (qqHit.yz))) *
       (1. - 0.5 * SmoothBump (-0.01, 0.03, 0.01, length (qqHit.yz))));
    if (nn.z > 0.9 && qqHit.y < -0.03) col *= 0.3;
  } else if (idObj == idWing) {
    b = wSpan / (8. * fusLen);
    b = mod (qqHit.x + 0.5 * b, b) - 0.5 * b;
    col *= 1. + 0.1 * SmoothBump (-0.01, 0.01, 0.002, b);
    if (abs (qqHit.x) > 0.7)
       col *= 1. - 0.6 * SmoothBump (-0.128, -0.117, 0.002, qqHit.z);
    if (qqHit.z < -0.125)
       col *= 1. - 0.6 * SmoothBump (0.695, 0.705, 0.002, abs (qqHit.x));
    if (qqHit.y * nn.y > 0.) {
      qqHit.x = abs (qqHit.x) - 0.8;
      qqHit.z -= 0.03;
      col = mix (vec3 (0., 1., 0.), col,
         (1. - 0.5 * SmoothBump (0.08, 0.12, 0.01, length (qqHit.xz))) *
         (1. - 0.5 * SmoothBump (-0.01, 0.03, 0.01, length (qqHit.xz))));
    }
  } else if (idObj == idFin || idObj == idHstab) {
    col *= 1. - 0.6 * SmoothBump (-0.062, -0.052, 0.002, qqHit.z);
  } else if (idObj == idPipe || idObj == idNose || idObj == idStrut ||
     idObj == idLeg || idObj == idAxl) {
    col = vec3 (0.9, 0., 0.1);
    spec = 0.4;
  } else if (idObj == idCkpit) {
    col = vec3 (0.2, 0.15, 0.05);
  } else if (idObj == idPlt) {
    col = vec3 (0.1, 0.07, 0.);
    if (nn.z > 0.7) {
      col *= 2.;
      qqHit.x = abs (qqHit.x) - 0.015 * fusLen;
      col *= (1. - 0.9 * SmoothBump (0.003, 0.01, 0.001, length (qqHit.xy)));
    }
  } else if (idObj == idWhl) {
    if (length (qqHit.yz) < 0.07) col = vec3 (0.2, 0.2, 0.7);
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
  vec3 col, vn;
  float dstHit, dstGrnd, dstObj, dstPropel, f, bk, sh;
  int idObjT;
  dstHit = dstFar;
  dstGrnd = GrndRay (ro, rd);
  idObj = -1;
  dstPropel = TransObjRay (ro, rd);
  if (idObj < 0) dstPropel = dstFar;
  idObj = -1;
  dstObj = ObjRay (ro, rd);
  if (idObj < 0) dstObj = dstFar;
  if (min (dstObj, dstGrnd) < dstPropel) dstPropel = dstFar;
  idObjT = idObj;
  if (dstObj < dstGrnd) {
    ro += dstObj * rd;
    vn = ObjNf (ro);
    idObj = idObjT;
    col4 = FlyerCol (vn);
    sh = ObjSShadow (ro, sunDir);
    bk = max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.);
    col = col4.rgb * (0.3 + 0.2 * bk  + 0.7 * sh * max (dot (vn, sunDir), 0.)) +
       sh * col4.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.);
    dstHit = dstObj;
  } else {
    dstHit = dstGrnd;
    if (dstHit < dstFar) {
      ro += dstGrnd * rd;
      vn = VaryNf (1.2 * ro, GrndNf (ro, dstHit), 1.);
      col = (mix (vec3 (0.2, 0.4, 0.1), vec3 (0., 0.5, 0.),
	 clamp (0.7 * Noisefv2 (ro.xz) - 0.3, 0., 1.))) *
	 (0.1 + max (0., max (dot (vn, sunDir), 0.))) +
	 0.1 * pow (max (0., dot (sunDir, reflect (rd, vn))), 100.);
      f = dstGrnd / dstFar;
      f *= f;
      col = mix (col, SkyBg (rd), clamp (f * f, 0., 1.));
    } else col = SkyCol (ro, rd);
  }
  if (dstPropel < dstFar) col = vec3 (0.1) * (1. -
     0.3 * SmoothBump (0.25, 0.27, 0.006,
     length (qHitTransObj.xy) / fusLen)) + 0.7 * col;
  if (dstHit < dstFar) {
    f = dstHit / dstFar;
    col = mix (col, SkyBg (rd), clamp (1.03 * f * f, 0., 1.));
  }
  return clamp (col, 0., 1.);
}

void FlyerPM (float t)
{
  float tInterp = 100.;
  float dt = 0.3 * flyVel;
  flPos = TrackPath (t * flyVel);
  vec3 fpF = TrackPath (t * flyVel + dt);
  vec3 fpB = TrackPath (t * flyVel - dt);
  vec3 vel = (fpF - fpB) / (2. * dt);
  float vy = vel.y;
  vel.y = 0.;
  vec3 acc = (fpF - 2. * flPos + fpB) / (dt * dt);
  acc.y = 0.;
  vec3 va = cross (acc, vel) / length (vel);
  vel.y = vy;
  vec3 ort = vec3 (0., atan (vel.z, vel.x) - 0.5 * pi,
     200. * length (va) * sign (va.y));
  vec3 cr = cos (ort);
  vec3 sr = sin (ort);
  flMat = mat3 (cr.z, - sr.z, 0., sr.z, cr.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., cr.x, - sr.x, 0., sr.x, cr.x) *
     mat3 (cr.y, 0., - sr.y, 0., 1., 0., sr.y, 0., cr.y);
}

vec3 GlareCol (vec3 rd, vec3 sd, vec2 uv)
{
  vec3 col;
  if (sd.z > 0.) {
    vec3 e = vec3 (1., 0., 0.);
    col = 0.2 * pow (sd.z, 8.) *
       (1.5 * e.xyy * max (dot (normalize (rd + vec3 (0., 0.3, 0.)), sunDir), 0.) +
        e.xxy * SmoothBump (0.04, 0.07, 0.07, length (uv - sd.xy)) +
        e.xyx * SmoothBump (0.15, 0.2, 0.07, length (uv - 0.5 * sd.xy)) +
        e.yxx * SmoothBump (1., 1.2, 0.07, length (uv + sd.xy)));
  } else col = vec3 (0.);
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  vec3 ro, rd, vd, u, col;
  float zmFac, pDist, f;
  sunDir = normalize (vec3 (sin (0.2 * tCur), 1., cos (0.2 * tCur)));
  fusLen = 1.;
  wSpan = 1.2 * fusLen;
  flyVel = 25.;
  FlyerPM (tCur);
  ro = vec3 (0., 10., 0.);
  vd = flPos - ro;
  pDist = length (vd);
  vd = normalize (vd);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  zmFac = 3. + 4. * pDist / 50.;
  rd = vuMat * normalize (vec3 (uv, zmFac));
  col = ShowScene (ro, rd);
  col += GlareCol (rd, vuMat * sunDir, uv);
  fragColor = vec4 (col, 1.);
}
