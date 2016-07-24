// Shader downloaded from https://www.shadertoy.com/view/Xll3Rr
// written by shadertoy user dr2
//
// Name: Alpine Jets
// Description: Flight over snowy landscape.
// "Alpine Jets" by dr2 - 2014
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

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

vec3 Noisev3v2 (vec2 p)
{
  vec2 i = floor (p);
  vec2 f = fract (p);
  vec2 ff = f * f;
  vec2 u = ff * (3. - 2. * f);
  vec2 uu = 30. * ff * (ff - 2. * f + 1.);
  vec4 h = Hashv4f (dot (i, cHashA3.xy));
  return vec3 (h.x + (h.y - h.x) * u.x + (h.z - h.x) * u.y +
     (h.x - h.y - h.z + h.w) * u.x * u.y, uu * (vec2 (h.y - h.x, h.z - h.x) +
     (h.x - h.y - h.z + h.w) * u.yx));
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

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  vec2 q = vec2 (length (p.xy) - rc, p.z);
  return length (q) - ri;
}

float PrConeDf (vec3 p, vec3 b)
{
  return max (dot (vec2 (length (p.xy), p.z), b.xy), abs (p.z) - b.z);
}

int idObj, idObjGrp;
mat3 flyerMat[3], flMat;
vec3 flyerPos[3], flPos, qHit, qHitTransObj, sunDir, sunCol;
vec2 trkOffset;
float szFac, wSpan, fusLen, flameLen, tCur;
const float dstFar = 200.;
const float pi = 3.14159;

vec3 TrackPath (float t)
{
  return vec3 (30. * sin (0.035 * t) * sin (0.012 * t) * cos (0.01 * t) +
     26. * sin (0.0032 * t) + 100. * trkOffset.x,
     1. + 3. * sin (0.021 * t) * sin (1. + 0.023 * t), t);
}

float GrndHt (vec2 p, int hiRes)
{
  const vec2 vRot = vec2 (1.4624, 1.6721);
  vec2 q = 0.06 * p;
  float w = 0.75 * Noisefv2 (0.25 * q) + 0.15;
  w *= 36. * w;
  vec2 vyz = vec2 (0.);
  float ht = 0.;
  for (int j = 0; j < 10; j ++) {
    vec3 v = Noisev3v2 (q);
    vyz += v.yz;
    ht += w * v.x / (1. + dot (vyz, vyz));
    if (j == 4 && hiRes == 0) break;
    w *= -0.37;      
    q *= mat2 (vRot.x, vRot.y, - vRot.y, vRot.x);
  }
  vec3 pt = TrackPath (p.y);
  pt.y += (sqrt (abs (ht) + 1.) - 1.) * sign (ht) + 0.3 * Noisefv2 (0.1 * p);
  float g = smoothstep (0.7 * (0.6 + 0.4 * Noisefv2 (0.31 * p)), 3.5 *
     (0.7 + 0.4 * Noisefv2 (0.11 * p)), sqrt (abs (p.x - pt.x) + 1.) - 1.);
  return SmoothMin (ht, pt.y * (1. - g) + ht * g, 0.5);
}

vec3 GrndNf (vec3 p, float d)
{
  float ht = GrndHt (p.xz, 1);
  vec2 e = vec2 (max (0.01, 0.00001 * d * d), 0.);
  return normalize (vec3 (ht - GrndHt (p.xz + e.xy, 1), e.x,
     ht - GrndHt (p.xz + e.yx, 1)));
}

vec4 GrndCol (vec3 p, vec3 n)
{
  const vec3 gCol1 = vec3 (0.7, 0.8, 0.8), gCol2 = vec3 (0.3, 0.2, 0.2),
     gCol3 = vec3 (0.5, 0.4, 0.4), gCol4 = vec3 (0.2, 0.3, 0.2);
  vec3 col = vec3 (0.9, 0.9, 1.);
  float cSpec = 1.;
  float f, d;
  vec2 q = p.xz;
  if (n.y < 0.5) {
    f = 0.5 * (clamp (Noisefv2 (0.1 * q), 0., 1.) +
        0.8 * Noisefv2 (0.2 * q + 2.1 * n.xy + 2.2 * n.yz));
    col = f * mix (f * gCol1 + gCol2, f * gCol3 + gCol4, 0.65 * f);
    f = 0.4 * (Noisefv2 (0.4 * q + vec2 (0., 0.57 * p.y)) +
       0.5 * Noisefv2 (6. * q));
    d = 4. * (0.5 - n.y);
    col = mix (col, vec3 (f), clamp (d * d, 0.1, 1.));
    cSpec = 0.5;
  }
  return vec4 (col, cSpec);
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
    h = p.y - GrndHt (p.xz, 0);
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
      h = step (0., p.y - GrndHt (p.xz, 0));
      sLo += h * (s - sLo);
      sHi += (1. - h) * (s - sHi);
    }
    dHit = sHi;
  }
  return dHit;
}

vec3 SkyBg (vec3 rd)
{
  const vec3 sbCol = vec3 (0.2, 0.3, 0.55);
  vec3 col;
  col = sbCol + 0.2 * sunCol * pow (1. - max (rd.y, 0.), 5.);
  return col;
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  const float skyHt = 150.;
  vec3 col;
  float cloudFac;
  if (rd.y > 0.) {
    ro.x += 0.5 * tCur;
    vec2 p = 0.02 * (rd.xz * (skyHt - ro.y) / rd.y + ro.xz);
    float w = 0.8;
    float f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.;
    }
    cloudFac = clamp (5. * f * rd.y - 0.1, 0., 1.);
  } else cloudFac = 0.;
  float s = max (dot (rd, sunDir), 0.);
  col = SkyBg (rd) + sunCol * (0.35 * pow (s, 6.) +
     0.65 * min (pow (s, 256.), 0.3));
  col = mix (col, vec3 (0.85), cloudFac);
  return col;
}

float GrndSShadow (vec3 ro, vec3 rd)
{
  float sh = 1.;
  float d = 2.;
  for (int i = 0; i < 10; i++) {
    vec3 p = ro + rd * d;
    float h = p.y - GrndHt (p.xz, 0);
    sh = min (sh, 20. * h / d);
    d += 4.;
    if (h < 0.01) break;
  }
  return clamp (sh, 0., 1.);
}

struct WingParm
{
  float span, sRad, trans, thck, tapr;
};

float WingDf (vec3 p, WingParm wg)
{
  vec2 q = p.yz;
  float s = abs (p.x - wg.trans);
  float dz = s / wg.span;
  return max (length (abs (q) + vec2 (wg.sRad + wg.tapr * dz * dz * dz, 0.)) -
     wg.thck, s - wg.span);
}

float FlameDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  q = p;
  q.z -= - (fusLen + 0.5 * flameLen);
  float wr = 0.5 * (q.z / flameLen - 1.);
  d = PrCylDf (q, 0.045 * (1. + 0.6 * wr) * fusLen, flameLen);
  if (d < dHit) {
    dHit = d;
    qHitTransObj = q;
  }
  return dHit;
}

float TransObjDf (vec3 p)
{
  float dHit = dstFar / szFac;
  dHit = FlameDf (flyerMat[0] * (p - flyerPos[0]) / szFac, dHit);
  dHit = FlameDf (flyerMat[1] * (p - flyerPos[1]) / szFac, dHit);
  dHit = FlameDf (flyerMat[2] * (p - flyerPos[2]) / szFac, dHit);
  return dHit * szFac;
}

float TransObjRay (vec3 ro, vec3 rd)
{
  const float dTol = 0.01;
  float d;
  float dHit = 0.;
  for (int j = 0; j < 100; j ++) {
    d = TransObjDf (ro + dHit * rd);
    dHit += d;
    if (d < dTol || dHit > dstFar) break;
  }
  return dHit;
}

float FlyerDf (vec3 p, float dHit)
{
  vec3 q;
  WingParm wg;
  float d, wt;
  float wSweep = 0.1;
  float taPos = 0.75 * fusLen;
  q = p;
  wt = q.z / fusLen;
  d = PrCapsDf (q - fusLen * vec3 (0., 0.07 + 0.11 * wt, -0.05),
      0.08 * fusLen, 0.4 * fusLen);
  if (d < dHit) { dHit = d;  idObj = idObjGrp + 1;  qHit = q; }
  q = p;
  q -= fusLen * vec3 (0., 0., -0.12);
  d = max (PrCylDf (q, (0.14 - 0.1 * wt * wt) * fusLen, fusLen),
     - min (PrCylDf (q - fusLen * vec3 (0., 0., 1.07), 0.06 * fusLen, 0.1 * fusLen),
     PrCylDf (q - fusLen * vec3 (0., 0., -0.99), 0.04 * fusLen, 0.15 * fusLen)));
  d = min (d, PrTorusDf (q - fusLen * vec3 (0., 0., 0.99),
     0.01 * fusLen, 0.055 * fusLen));
  if (d < dHit + 0.1) { dHit = SmoothMin (dHit, d, 0.1);  idObj = idObjGrp + 2;  qHit = q; }
  q = p;
  q -= fusLen * vec3 (0., 0., 0.9);
  d = PrConeDf (q, fusLen * vec3 (0.04, 0.02, 0.05));
  if (d < dHit) { dHit = d;  idObj = idObjGrp + 6;  qHit = q; }
  q = p;
  q -= fusLen * vec3 (0., 0.15, -0.1);
  d = PrCylDf (q.xzy, 0.005 * fusLen, 0.05 * fusLen);
  if (d < dHit) { dHit = d;  idObj = idObjGrp + 1;  qHit = q; }
  wt = wSweep * abs (p.x) / wSpan;
  q = p - vec3 (0., - 0.05 * fusLen + 12. * wt, 1. - 2. * wt);
  wg = WingParm (wSpan, 13.7, 0., 14.05, 0.37);
  d = WingDf (q, wg);
  if (d < dHit + 0.2) { dHit = SmoothMin (dHit, d, 0.2);  idObj = 3;  qHit = q; }
  q = p - vec3 (0., -0.01 * fusLen + 6. * wt, - taPos - 4. * wt);
  wg = WingParm (0.45 * wSpan, 6.8, 0., 7.05, 0.37);
  d = WingDf (q, wg);
  if (d < dHit + 0.1) { dHit = SmoothMin (dHit, d, 0.1);  idObj = idObjGrp + 4;  qHit = q; }
  wt = wSweep * abs (p.y) / wSpan;
  q = p.yxz + vec3 (-0.2, 0., taPos + 40. * wt);
  wg = WingParm (0.2 * wSpan, 7., 1.5, 7.2, 0.2);
  d = max (WingDf (q, wg), - q.x);
  if (d < dHit + 0.1) { dHit = SmoothMin (dHit, d, 0.1);  idObj = idObjGrp + 5;  qHit = q; }
  return dHit;
}

float ObjDf (vec3 p)
{
  float dHit = dstFar / szFac;
  idObjGrp = 1 * 256;
  dHit = FlyerDf (flyerMat[0] * (p - flyerPos[0]) / szFac, dHit);
  idObjGrp = 2 * 256;
  dHit = FlyerDf (flyerMat[1] * (p - flyerPos[1]) / szFac, dHit);
  idObjGrp = 3 * 256;
  dHit = FlyerDf (flyerMat[2] * (p - flyerPos[2]) / szFac, dHit);
  return dHit * szFac;
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
  float d = 0.07 * szFac;
  for (int i = 0; i < 40; i++) {
    float h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.07 * szFac;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

float ObjAO (vec3 ro, vec3 rd)
{
  float ao = 0.;
  for (int i = 0; i < 8; i ++) {
    float d = 0.1 + float (i) / 8.;
    ao += max (0., d - 3. * ObjDf (ro + rd * d));
  }
  return clamp (1. - 0.1 * ao, 0., 1.);
}

vec3 FlyerCol (vec3 n)
{
  vec3 col = vec3 (1., 0.3, 0.3), pCol = vec3 (0., 1., 0.);
  int ig = idObj / 256;
  int id = idObj - 256 * ig;
  if (id >= 3 && id <= 5) {
    float s1, s2, s3;
    if (id == 3) { s1 = 1.6;  s2 = 6.; s3 = 11.; }
    else if (id == 4) { s1 = 1.;  s2 = 1.2; s3 = 4.1; }
    else if (id == 5) { s1 = 1.;  s2 = 0.9; s3 = 3.4; }
    if (abs (qHit.x) > s2 - 0.03 && abs (qHit.x) < s3 + 0.03)
       col *= 1. - 1. * SmoothBump (-0.08, 0.08, 0.02, qHit.z + s1);
    if (qHit.z < - s1)
       col *= 1. - 1. * (SmoothBump (- 0.05, 0.05, 0.02, abs (qHit.x) - s2) +
       SmoothBump (-0.05, 0.05, 0.02, abs (qHit.x) - s3));
  }
  qHit /= fusLen;
  if (id == 1) {
    if (abs (abs (qHit.z - 0.09) - 0.25) > 0.006) col = vec3 (0.3);
  } else if (id == 2) {
    vec3 nn;
    if (ig == 1) nn = flyerMat[0] * n;
    else if (ig == 2) nn = flyerMat[1] * n;
    else nn = flyerMat[2] * n;
    if (qHit.z > 0.97  || qHit.z < -0.83) col *= 0.1;
    else if (qHit.z > 0. && nn.z > 0.9) col *= 0.1;
    else if (qHit.z < 0. && nn.z < -0.9) col = vec3 (1., 0., 0.);
    else {
      qHit.z -= -0.3;
      col = mix (pCol, col,
         (1. - SmoothBump (0.04, 0.07, 0.01, length (qHit.yz))) *
         (1. - 0.8 * SmoothBump (-0.01, 0.02, 0.01, length (qHit.yz))));
    }
  } else if (id == 3) {
    qHit.x = abs (qHit.x) - 0.4;
    qHit.z -= 0.03;
      col = mix (pCol, col,
        (1. - 0.8 * SmoothBump (0.07, 0.11, 0.01, length (qHit.xz))) *
        (1. - 0.8 * SmoothBump (-0.01, 0.03, 0.01, length (qHit.xz))));
  } else if (id == 6) col = vec3 (1., 0., 0.);
  idObj = 10;
  return col;
}

vec3 FlameCol (vec3 col)
{
  vec3 q = qHitTransObj;
  float fFac = clamp (mod (4. * (q.z / flameLen + 1.) +
     0.5 * Noisefv2 (10. * q.xy + tCur * vec2 (11., 13.)) +
     7.1 * tCur, 1.), 0., 1.);
  float c = clamp (q.z, 0., 1.);
  return fFac * vec3 (c + 0.5, 0.5 * c + 0.1, 0.1 * c + 0.1) + 0.8 * (1. - c) * col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 objCol, col, vn;
  float dstHit, dstGrnd, dstObj, dstFlame, f, ao;
  int idObjT;
  dstHit = dstFar;
  dstGrnd = GrndRay (ro, rd);
  wSpan = 13.;
  fusLen = 12.;
  flameLen = 0.25 * fusLen;
  dstFlame = TransObjRay (ro, rd);
  idObj = -1;
  dstObj = ObjRay (ro, rd);
  idObjT = idObj;
  if (dstObj < dstFlame) dstFlame = dstFar;
  bool isGrnd = false;
  if (dstObj < dstGrnd) {
    ro += dstObj * rd;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = FlyerCol (vn);
    if (idObj == 10) objCol = 0.7 * objCol + 0.5 * SkyCol (ro, reflect (rd, vn));
    float dif = max (dot (vn, sunDir), 0.);
    ao = ObjAO (ro, vn);
    col = objCol * (0.2 * ao * (1. +
       max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.)) +
       max (0., dif) * ObjSShadow (ro, sunDir) *
       (dif + ao * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.)));
    dstHit = dstObj;
  } else {
    dstHit = dstGrnd;
    if (dstHit < dstFar) {
      ro += dstGrnd * rd;
      isGrnd = true;
    } else col = SkyCol (ro, rd);
  }
  if (isGrnd) {
    vn = GrndNf (ro, dstHit);
    vec4 col4 = GrndCol (ro, vn);
    float dif = max (dot (vn, sunDir), 0.);
    col = col4.xyz * sunCol * (0.2 + max (0., dif) * GrndSShadow (ro, sunDir) *
       (dif + col4.w * pow (max (0., dot (sunDir, reflect (rd, vn))), 100.)));
  }
  if (dstFlame < dstFar) col = FlameCol (col);
  if (dstHit < dstFar) {
    f = dstHit / dstFar;
    col = mix (col, SkyBg (rd), clamp (1.03 * f * f, 0., 1.));
  }
  col = sqrt (clamp (col, 0., 1.));
  return clamp (col, 0., 1.);
}

void PlanePM (float t, float vu)
{
  float tInterp = 100.;
  float dt = 2.;
  flPos = TrackPath (t);
  vec3 fpF = TrackPath (t + dt);
  vec3 fpB = TrackPath (t - dt);
  vec3 vel = (fpF - fpB) / (2. * dt);
  float vy = vel.y;
  vel.y = 0.;
  vec3 acc = (fpF - 2. * flPos + fpB) / (dt * dt);
  acc.y = 0.;
  vec3 va = cross (acc, vel) / length (vel);
  float m1, m2;
  if (vu == 0.) { m1 = 1.;  m2 = 25.; }
  else { m1 = 0.2;  m2 = 10.; }
  vel.y = vy;
  vec3 ort = vec3 (- m1 * asin (vel.y / length (vel)),
     atan (vel.z, vel.x) - 0.5 * pi, m2 * length (va) * sign (va.y));
  if (vu > 0.) { ort.xz *= -1.;  ort.y += pi; }
  vec3 cr = cos (ort);
  vec3 sr = sin (ort);
  flMat = mat3 (cr.z, - sr.z, 0., sr.z, cr.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., cr.x, - sr.x, 0., sr.x, cr.x) *
     mat3 (cr.y, 0., - sr.y, 0., 1., 0., sr.y, 0., cr.y);
  float tDisc = floor ((t) / tInterp) * tInterp;
  float s = (t - tDisc) / tInterp;
  flPos.y = (1. - s) * GrndHt (TrackPath (tDisc).xz, 0) +
     s * GrndHt (TrackPath (tDisc + tInterp).xz, 0) + 7.;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  trkOffset = vec2 (0.);
  float zmFac = 3.3;
  tCur = 18. * iGlobalTime + 100. * trkOffset.y;
  sunDir = normalize (vec3 (-0.9, 1., 1.));
  sunCol = vec3 (1.);
  szFac = 0.2;
  float tGap = 12.;
  tCur += tGap;
  PlanePM (tCur, 0.);  flyerPos[0] = flPos;  flyerMat[0] = flMat;
  PlanePM (tCur + tGap, 0.);  flyerPos[1] = flPos;  flyerMat[1] = flMat;
  PlanePM (tCur + 2. * tGap, 0.);  flyerPos[2] = flPos;  flyerMat[2] = flMat;
  float vuPeriod = 900.;
  float lookDir = 2. * mod (floor (tCur / vuPeriod), 2.) - 1.;
  float dVu = smoothstep (0.8, 0.97, mod (tCur, vuPeriod) / vuPeriod);
  PlanePM (tCur + tGap * (1. + 1.5 * lookDir * (1. - 1.2 * dVu)), lookDir);
  vec3 ro = flPos;
  ro.y += 2.5 * sqrt (dVu);
  vec3 rd = normalize (vec3 (uv, zmFac)) * flMat;
  ro.y += 0.3;
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
