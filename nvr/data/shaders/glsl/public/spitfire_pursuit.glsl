// Shader downloaded from https://www.shadertoy.com/view/4dSSWV
// written by shadertoy user dr2
//
// Name: Spitfire Pursuit
// Description: More fun in the air.
// "Spitfire Pursuit" by dr2 - 2014
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

float PrCapsDf (vec3 p, vec2 b) {
  return length (p - vec3 (0., 0., b.x * clamp (p.z / b.x, -1., 1.))) - b.y;
}

float PrCylDf (vec3 p, vec2 b) {
  return max (length (p.xy) - b.x, abs (p.z) - b.y);
}

float PrConeDf (vec3 p, vec3 b) {
  return max (dot (vec2 (length (p.xy), p.z), b.xy), abs (p.z) - b.z);
}

int idObj, idObjGrp;
mat3 flyerMat[2], flMat;
vec3 flyerPos[2], flPos, qHit, qHitTransObj, sunDir, sunCol;
vec2 trkOffset;
float szFac, wSpan, fusLen, tCur;
const float dstFar = 200.;
const float pi = 3.14159;

vec3 TrackPath (float t)
{
  return vec3 (24. * sin (0.035 * t) * sin (0.012 * t) * cos (0.01 * t) +
     19. * sin (0.0032 * t) + 100. * trkOffset.x,
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
  float g = smoothstep (1., 3.5, sqrt (abs (p.x - pt.x) + 1.) - 1.);
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
  const vec3 gCol1 = vec3 (0.6, 0.7, 0.7), gCol2 = vec3 (0.2, 0.1, 0.1),
     gCol3 = vec3 (0.4, 0.3, 0.3), gCol4 = vec3 (0.1, 0.2, 0.1),
     gCol5 = vec3 (0.7, 0.7, 0.8), gCol6 = vec3 (0.05, 0.3, 0.03),
     gCol7 = vec3 (0.02, 0.1, 0.02), gCol8 = vec3 (0.1, 0.08, 0.);
  vec2 q = p.xz;
  float f, d;
  float cSpec = 0.;
  f = 0.5 * (clamp (Noisefv2 (0.1 * q), 0., 1.) +
      0.8 * Noisefv2 (0.2 * q + 2.1 * n.xy + 2.2 * n.yz));
  vec3 col = f * mix (f * gCol1 + gCol2, f * gCol3 + gCol4, 0.65 * f);
  if (n.y < 0.5) {
    f = 0.4 * (Noisefv2 (0.4 * q + vec2 (0., 0.57 * p.y)) +
       0.5 * Noisefv2 (6. * q));
    d = 4. * (0.5 - n.y);
    col = mix (col, vec3 (f), clamp (d * d, 0.1, 1.));
    cSpec += 0.1;
  }
  if (p.y > 22.) {
    if (n.y > 0.25) {
      f = clamp (0.07 * (p.y - 22. - Noisefv2 (0.2 * q) * 15.), 0., 1.);
      col = mix (col, gCol5, f);
      cSpec += f;
    }
  } else {
    if (n.y > 0.45) {
      vec3 c = (n.y - 0.3) * (gCol6 * vec3 (Noisefv2 (0.4 * q),
         Noisefv2 (0.34 * q), Noisefv2 (0.38 * q)) + gCol7);
      col = mix (col, c, smoothstep (0.45, 0.65, n.y) *
         (1. - smoothstep (15., 22., p.y - 1.5 + 1.5 * Noisefv2 (0.2 * q))));
    }
    if (p.y < 0.65 && n.y > 0.4) {
      d = n.y - 0.4;
      col = mix (col, d * d + gCol8, 2. * clamp ((0.65 - p.y -
         0.35 * (Noisefv2 (0.4 * q) + 0.5 * Noisefv2 (0.8 * q) +
         0.25 * Noisefv2 (1.6 * q))), 0., 0.3));
      cSpec += 0.1;
    }
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
    s += max (0.15, 0.4 * h) + 0.005 * s;
    if (s > dstFar) break;
  }
  if (h < 0.) {
    sHi = s;
    for (int j = 0; j < 10; j ++) {
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

float WaterHt (vec3 p)
{
  p *= 0.2;
  float ht = 0.;
  const float wb = 1.414;
  float w = 0.1 * wb;
  for (int j = 0; j < 7; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x);
    ht += w * abs (Noisefv3 (p) - 0.5);
  }
  return ht;
}

vec3 WaterNf (vec3 p, float d)
{
  float ht = WaterHt (p);
  vec2 e = vec2 (max (0.01, 0.001 * d * d), 0.);
  return normalize (vec3 (ht - WaterHt (p + e.xyy), e.x, ht - WaterHt (p + e.yyx)));
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
    cloudFac = clamp (5. * (f - 0.4) * rd.y - 0.1, 0., 1.);
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
  float d = 0.01;
  for (int i = 0; i < 80; i++) {
    vec3 p = ro + rd * d;
    float h = p.y - GrndHt (p.xz, 0);
    sh = min (sh, 20. * h / d);
    d += 0.5;
    if (h < 0.001) break;
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

float PropelDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  dHit /= szFac;
  p /= szFac;
  q = p;
  d = PrCylDf (q - vec3 (0., 0., fusLen - 1.), vec2 (2.3, 0.05));
  if (d < dHit) {
    dHit = d;
    qHitTransObj = q;
  }
  return dHit * szFac;
}

float TransObjDf (vec3 p)
{
  float dHit = dstFar;
  dHit = PropelDf (flyerMat[0] * (p - flyerPos[0]), dHit);
  dHit = PropelDf (flyerMat[1] * (p - flyerPos[1]), dHit);
  return dHit;
}

float TransObjRay (vec3 ro, vec3 rd)
{
  const float dTol = 0.001;
  float d;
  float dHit = 0.;
  for (int j = 0; j < 150; j ++) {
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
  float d, wr, ws;
  float cLen;
  float wSweep = 0.1;
  float taPos = 0.92 * fusLen;
  dHit /= szFac;
  p /= szFac;
  q = p;
  wr = q.z / fusLen;
  d = PrCapsDf (q - fusLen * vec3 (0., 0.065 + 0.13 * wr, -0.1),
     fusLen * vec2 (0.4, 0.08));
  if (d < dHit) {
    dHit = d;  idObj = idObjGrp + 1;  qHit = q;
  }
  d = PrCapsDf (q - fusLen * vec3 (0., 0., -0.12),
     fusLen * vec2 (1., 0.14 - 0.1 * wr * wr));
  d = max (d, q.z - 0.91 * fusLen);
  if (d < dHit + 0.1) {
    dHit = SmoothMin (dHit, d, 0.1);  idObj = idObjGrp + 2;  qHit = q;
  }
  ws = wSweep * abs (p.x) / wSpan;
  q = p + vec3 (0., 0.07 * fusLen - 12. * ws, -1. + 2. * ws);
  wg = WingParm (wSpan, 13.7, 0., 14.05, 0.37);
  d = WingDf (q, wg);
  if (d < dHit + 0.3) {
    dHit = SmoothMin (dHit, d, 0.3);  idObj = idObjGrp + 3;  qHit = q;
   }
  q = p + vec3 (0., -0.1 - 6. * ws, taPos + 4. * ws);
  wg = WingParm (0.45 * wSpan, 6.8, 0., 7.05, 0.37);
  d = WingDf (q, wg);
  if (d < dHit + 0.2) {
    dHit = SmoothMin (dHit, d, 0.2);  idObj = idObjGrp + 4;  qHit = q;
  }
  ws = wSweep * abs (p.y) / wSpan;
  q = p.yxz + vec3 (-0.2, 0., taPos + 20. * ws);
  wg = WingParm (0.2 * wSpan, 7., 1.5, 7.2, 0.2);
  d = max (WingDf (q, wg), - q.x);
  if (d < dHit + 0.4) {
    dHit = SmoothMin (dHit, d, 0.4);  idObj = idObjGrp + 5;  qHit = q;
  }
  q = p + vec3 (0., 0., -0.98 * fusLen);
  d = PrConeDf (q, vec3 (0.8, 0.6, 0.9));
  if (d < dHit) {
    dHit = d;  idObj = idObjGrp + 6;  qHit = q;
  }
  q = p + vec3 (0., 0.5, -4.);
  q.x = abs (q.x) - 3.5;
  d = PrCylDf (q, vec2 (0.1, 0.5));
  if (d < dHit) {
    dHit = d;  idObj = idObjGrp + 7;  qHit = q;
  }
  return 0.8 * szFac * dHit;
}

float ObjDf (vec3 p)
{
  float dHit = dstFar;
  idObjGrp = 1 * 256;
  dHit = FlyerDf (flyerMat[0] * (p - flyerPos[0]), dHit);
  idObjGrp = 2 * 256;
  dHit = FlyerDf (flyerMat[1] * (p - flyerPos[1]), dHit);
  return dHit;
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
  float v0 = ObjDf (p + e.xxx);
  float v1 = ObjDf (p + e.xyy);
  float v2 = ObjDf (p + e.yxy);
  float v3 = ObjDf (p + e.yyx);
  return normalize (vec3 (v0 - v1 - v2 - v3) + 2. * vec3 (v1, v2, v3));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh = 1.;
  float d = 0.07 * szFac;
  for (int i = 0; i < 50; i++) {
    float h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.07 * szFac;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 ObjCol (vec3 p, vec3 n)
{
  vec3 bCol = vec3 (0.9, 0.9, 0.95), tCol = vec3 (0.9, 0.7, 0.), 
     wCol1 = vec3 (0.3, 0.9, 0.3), wCol2 = vec3 (0.9, 0.3, 0.3),
     uCol1 = vec3 (0.9, 0.2, 0.), uCol2 = vec3 (0.2, 0.9, 0.),
     gCol = vec3 (0.05, 0.1, 0.05);
  float cFac = 1.;
  int ig = idObj / 256;
  int id = idObj - 256 * ig;
  vec3 uCol, wCol;
  if (ig == 1) {
    uCol = uCol1;  wCol = wCol1;
  } else {
    uCol = uCol2;  wCol = wCol2;
  }
  if (id >= 3 && id <= 5) {
    float s1, s2, s3;
    if (id == 3) {
      s1 = 1.9;  s2 = 5.; s3 = 10.;
    } else if (id == 4) {
      s1 = 1.;  s2 = 1.2; s3 = 3.8;
    } else if (id == 5) {
      s1 = 1.1;  s2 = 1.; s3 = 3.3;
    }
    if (abs (qHit.x) > s2 - 0.03 && abs (qHit.x) < s3 + 0.03)
       cFac = 1. - 0.9 * SmoothBump (- 0.08, 0.08, 0.02, qHit.z + s1);
    if (qHit.z < - s1)
       cFac = 1. - 0.9 * (SmoothBump (- 0.05, 0.05, 0.02, abs (qHit.x) - s2)
       + SmoothBump (- 0.05, 0.05, 0.02, abs (qHit.x) - s3));
  }
  vec3 col;
  if (id == 1 || id == 2) {
    vec3 nn;
    if (ig == 1) nn = flyerMat[0] * n;
    else nn = flyerMat[1] * n;
    col = mix (uCol, bCol, 1. - smoothstep (-0.9, -0.5, nn.y));
    col = mix (col, tCol, SmoothBump (-5., -4.5, 0.1, qHit.z) +
       SmoothBump (-6., -5.5, 0.1, qHit.z));
  } else if (id == 3) {
    col = mix (bCol, wCol, SmoothBump (10.5, 11.5, 0.1, abs (qHit.x)));
    col = mix (col, uCol, SmoothBump (1., 2., 0.3, abs (qHit.x)));
  } else if (id == 4) {
    col = mix (bCol, wCol, SmoothBump (4., 4.5, 0.1, abs (qHit.x)));
    col = mix (col, uCol, SmoothBump (0.1, 1.15, 0.2, abs (qHit.x)));
  } else if (id == 5) {
    col = mix (bCol, tCol, SmoothBump (3.5, 4., 0.1, qHit.x));
    col = mix (col, uCol, SmoothBump (-1., 1., 0.1, qHit.x));
  } else if (id == 6) {
    col = tCol;
  } else if (id == 7) {
    col = gCol;
  }
  if (id == 1) {
    if (abs (qHit.x) > 0.07 && qHit.z > 1.5 && 
       abs (abs (abs (qHit.z) - 3.2) - 0.6) > 0.07) idObj += 99;
  }
  return col * cFac;
}

void PlanePM (float t, float vu)
{
  float tInterp = 20.;
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
  if (vu == 0.) {
    m1 = 1.5;  m2 = 25.;
  } else {
    m1 = 0.2;  m2 = 10.;
  }
  vel.y = vy;
  vec3 ort = vec3 (m1 * asin (vel.y / length (vel)),
     atan (vel.z, vel.x) - 0.5 * pi, m2 * length (va) * sign (va.y));
  if (vu > 0.) {
    ort.xz *= -1.;  ort.y += pi;
  }
  vec3 cr = cos (ort);
  vec3 sr = sin (ort);
  flMat = mat3 (cr.z, - sr.z, 0., sr.z, cr.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., cr.x, - sr.x, 0., sr.x, cr.x) *
     mat3 (cr.y, 0., - sr.y, 0., 1., 0., sr.y, 0., cr.y);
  float tDisc = floor ((t) / tInterp) * tInterp;
  float s = (t - tDisc) / tInterp;
  flPos.y = (1. - s) * GrndHt (TrackPath (tDisc).xz, 0) +
     s * GrndHt (TrackPath (tDisc + tInterp).xz, 0) + 5.5;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  const float eps = 0.01;
  vec3 objCol, col, vn;
  float dstHit, dstGrnd, dstObj, dstPropel, f;
  int idObjT;
  vec3 roo = ro;
  dstHit = dstFar;
  dstGrnd = GrndRay (ro, rd);
  wSpan = 13.;
  fusLen = 12.;
  dstPropel = TransObjRay (ro, rd);
  idObj = 0;
  dstObj = ObjRay (ro, rd);
  idObjT = idObj;
  dstPropel = TransObjRay (ro, rd);
  if (dstObj < dstPropel) dstPropel = dstFar;
  float refFac = 1.;
  if (dstGrnd < dstObj && ro.y + dstGrnd * rd.y < 0.) {
    float dw = - ro.y / rd.y;
    ro += dw * rd;
    rd = reflect (rd, WaterNf (ro, dw));
    ro += eps * rd;
    dstGrnd = GrndRay (ro, rd);
    idObj = 0;
    dstObj = ObjRay (ro, rd);
    idObjT = idObj;
    refFac *= 0.4;
  }
  bool isGrnd = false;
  if (dstObj < dstGrnd) {
    ro += dstObj * rd;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = ObjCol (ro, vn);
    if (idObj == 256 + 100 || idObj == 512 + 100)
       objCol = vec3 (0.2) + 0.5 * SkyCol (ro, reflect (rd, vn));
    float dif = max (dot (vn, sunDir), 0.);
    col = sunCol * objCol * (0.2 * (1. +
       max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.)) +
       max (0., dif) * ObjSShadow (ro, sunDir) *
       (dif + 5. * pow (max (0., dot (sunDir, reflect (rd, vn))), 256.)));
    dstHit = dstObj;
  } else {
    vec3 rp = ro + dstGrnd * rd;
    if (refFac < 1.) dstHit = length (rp - roo);
    else dstHit = dstGrnd;
    if (dstHit < dstFar) {
      ro = rp;
      isGrnd = true;
    } else {
      col = refFac * SkyCol (ro, rd);
    }
  }
  if (isGrnd) {
    vn = GrndNf (ro, dstHit);
    vec4 col4 = GrndCol (ro, vn);
    col = col4.xyz * refFac;
    float dif = max (dot (vn, sunDir), 0.);
    col *= sunCol * (0.2 * (1. +
       max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.)) +
       max (0., dif) * GrndSShadow (ro, sunDir) *
       (dif + col4.w * pow (max (0., dot (sunDir, reflect (rd, vn))), 100.)));
  }
  if (dstPropel < dstFar) col = 0.7 * col + 0.1 -
     0.04 * SmoothBump (1.6, 1.8, 0.02, length (qHitTransObj.xy));
  if (dstHit < dstFar) {
    f = dstHit / dstFar;
    col = mix (col, refFac * SkyBg (rd), clamp (1.03 * f * f, 0., 1.));
  }
  col = sqrt (clamp (col, 0., 1.));
  return clamp (col, 0., 1.);
}

vec3 GlareCol (vec3 rd, vec3 sd, vec2 uv)
{
  vec3 col;
  if (sd.z > 0.) {
    vec3 e = vec3 (1., 0., 0.);
    col = 0.5 * pow (sd.z, 8.) *
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
  vec2 uvs = uv;
  uv.x *= iResolution.x / iResolution.y;
  trkOffset = vec2 (0.);
  float zmFac = 2.7;
  tCur = 15. * iGlobalTime + 100. * trkOffset.y;
  sunDir = normalize (vec3 (-0.9, 1., 1.));
  sunCol = vec3 (1., 0.9, 0.8);
  szFac = 0.3;
  float tGap = 16.;
  tCur += tGap;
  PlanePM (tCur, 0.);
  flyerPos[0] = flPos;
  flyerMat[0] = flMat;
  PlanePM (tCur + tGap, 0.);
  flyerPos[1] = flPos;
  flyerMat[1] = flMat;
  float vuPeriod = 800.;
  float lookDir = 2. * mod (floor (tCur / vuPeriod), 2.) - 1.;
  PlanePM (tCur + (0.5 + 1.5 * lookDir) * tGap, lookDir);
  vec3 ro = flPos;
  vec3 rd = normalize (vec3 (uv, zmFac)) * flMat;
  ro.y += 1.;
  vec3 col = ShowScene (ro, rd);
  col += GlareCol (rd, flMat * sunDir, uv);
  uvs *= uvs * uvs;
  col = mix (vec3 (0.7), col, pow (max (0., 0.95 - length (uvs * uvs * uvs)), 0.3));
  fragColor = vec4 (col, 1.);
}
