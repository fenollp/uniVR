// Shader downloaded from https://www.shadertoy.com/view/4sV3zR
// written by shadertoy user dr2
//
// Name: Ocean Crossing
// Description: Choppy seas.
// "Ocean Crossing" by dr2 - 2016
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

vec2 Noisev2v4 (vec4 p)
{
  vec4 i, f, t1, t2;
  i = floor (p);  f = fract (p);
  f = f * f * (3. - 2. * f);
  t1 = Hashv4f (dot (i.xy, cHashA3.xy));
  t2 = Hashv4f (dot (i.zw, cHashA3.xy));
  return vec2 (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
               mix (mix (t2.x, t2.y, f.z), mix (t2.z, t2.w, f.z), f.w));
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

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrRoundBoxDf (vec3 p, vec3 b, float r)
{
  return length (max (abs (p) - b, 0.)) - r;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCylAnDf (vec3 p, float r, float w, float h)
{
  return max (abs (length (p.xy) - r) - w, abs (p.z) - h);
}

float PrRCylDf (vec3 p, float r, float rt, float h)
{
  vec2 dc;
  float dxy, dz;
  dxy = length (p.xy) - r;
  dz = abs (p.z) - h;
  dc = vec2 (dxy, dz) + rt;
  return min (min (max (dc.x, dz), max (dc.y, dxy)), length (dc) - rt);
}

int idObj, idObjGrp;
mat3 bMat, boatMat[2];
vec3 bPos, boatPos[2], qHit, sunDir, waterDisp;
float tCur, bAng, boatAng[2], dstFar;

vec3 SkyCol (vec3 ro, vec3 rd)
{
  vec3 col, bgCol;
  float cloudFac;
  bgCol = vec3 (0.2, 0.4, 1.);
  if (rd.y > 0.) {
    ro.xz += 0.5 * tCur;
    vec2 p = 0.01 * (rd.xz * (100. - ro.y) / rd.y + ro.xz);
    float w = 0.65;
    float f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.3;
    }
    cloudFac = clamp (3. * (f - 0.1) * rd.y + 0.1, 0., 1.);
    col = bgCol + 0.2 * pow (1. - max (rd.y, 0.), 5.);
    col = mix (col, vec3 (0.85), cloudFac);
  } else col = 0.9 * bgCol + 0.25;
  return col;
}

float WaveHt (vec3 p)
{
  const mat2 qRot = mat2 (1.6, -1.2, 1.2, 1.6);
  vec4 t4, t4o, ta4, v4;
  vec2 q2, t2, v2;
  float wFreq, wAmp, pRough, ht;
  wFreq = 0.2;  wAmp = 0.35;  pRough = 8.;
  t4o.xz = tCur * vec2 (1., -1.);
  q2 = p.xz + waterDisp.xz;
  ht = 0.;
  for (int j = 0; j < 4; j ++) {
    t4 = (t4o.xxzz + vec4 (q2, q2)) * wFreq;
    t2 = Noisev2v4 (t4);
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
  vec2 e = vec2 (max (0.1, 1e-4 * d * d), 0.);
  float h = WaveHt (p);
  return normalize (vec3 (h - WaveHt (p + e.xyy), e.x, h - WaveHt (p + e.yyx)));
}

float BoatDf (vec3 p, float dMin)
{
  vec3 q;
  float d;
  p.y -= 0.7;
  q = p;
  d = max (max (PrRCylDf (q, 1.2, 2., 3.5),
     - max (PrRCylDf (q - vec3 (0., 0.1, 0.), 1.15, 2., 3.5),
     max (q.y - 0.1, - q.y - 0.1))), max (q.y - 0., - q.y - 0.2));
  q.y -= -0.2;
  d = max (SmoothMin (d, max (PrRCylDf (q, 1., 2., 3.3), q.y), 0.1), q.z - 2.);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 1;  qHit = q; }
  q = p;
  q.yz -= vec2 (-0.5, -0.2);
  d = max (PrRCylDf (q, 1., 1.1, 2.3), max (0.4 - q.y, q.z - 1.2));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 2;  qHit = q; }
  q = p;
  q.yz -= vec2 (1.3, -0.6);
  d = PrCylDf (q.xzy, 0.04, 0.8);
  q.y -= 0.2;
  d = min (d, PrCylDf (q.yzx, 0.02, 0.2));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 3; }
  q.y -= 0.6;
  d = PrCylDf (q.xzy, 0.15, 0.02);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 4; }
  q = p;
  q.x = abs (q.x);
  q -= vec3 (0.3, -0.9, 2.);
  d = PrRoundBoxDf (q, vec3 (0.02, 0.2, 0.1), 0.03);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 5; }
  q.y -= -0.4;
  d = PrCylAnDf (q, 0.1, 0.02, 0.2);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 6; }
  q = p;
  q.yz -= vec2 (-1., 2.);
  d = PrCylDf (q, 0.1, 0.2);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 6; }
  q = p;
  q.yz -= vec2 (0.3, 1.9);
  d = PrCylDf (q.xzy, 0.015, 0.5);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 7; }
  q.yz -= vec2 (0.38, 0.15);
  d = PrBoxDf (q, vec3 (0.01, 0.1, 0.15));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 8; }
  return dMin;
}

float ObjDf (vec3 p)
{
  vec3 q;
  const float szFac = 1.5;
  float dMin, d, dLim;
  dLim = 0.5;
  dMin = dstFar;
  dMin *= szFac;
  q = p - boatPos[0];
  idObjGrp = 1 * 256;
  d = PrCylDf (q.xzy, 2., 2.);
  dMin = (d < dLim) ? BoatDf (szFac * boatMat[0] * q, dMin) : min (dMin, d);
  q = p - boatPos[1];
  idObjGrp = 2 * 256;
  d = PrCylDf (q.xzy, 2., 2.);
  dMin = (d < dLim) ? BoatDf (szFac * boatMat[1] * q, dMin) : min (dMin, d);
  return dMin / szFac;
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
  d = 0.02;
  for (int j = 0; j < 25; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 20. * h / d));
    d += min (0.05, 3. * h);
    if (h < 0.001) break;
  }
  return 0.3 + 0.7 * sh;
}

vec4 BoatCol (vec3 n)
{
  vec3 col, nn;
  float spec;
  int ig, id;
  ig = idObj / 256;
  id = idObj - 256 * ig;
  if (ig == 1) nn = boatMat[0] * n;
  else nn = boatMat[1] * n;
  spec = 0.3;
  if (id == 1) {
    if (qHit.y < 0.1 && nn.y > 0.99) {
      col = vec3 (0.8, 0.5, 0.3) *
         (1. - 0.4 * SmoothBump (0.42, 0.58, 0.05, mod (7. * qHit.x, 1.)));
      spec = 0.1;
    } else if (qHit.x * nn.x > 0. && nn.y < 0. && qHit.z < 1.99 &&
       abs (qHit.y - 0.1) < 0.095) col = (ig == 1) ? vec3 (0.3, 0.9, 0.3) :
       vec3 (0.9, 0.3, 0.3);
    else col = (qHit.y > -0.3) ? vec3 (1., 1., 0.2) : vec3 (0.7, 0.7, 0.8);
  } else if (id == 2) {
    if (abs (abs (qHit.x) - 0.24) < 0.22 && abs (qHit.y - 0.7) < 0.15 ||
       abs (abs (qHit.z + 0.2) - 0.5) < 0.4 && abs (qHit.y - 0.7) < 0.15) {
       col = vec3 (0., 0., 0.1);
       spec = 1.;
     } else col = vec3 (1.);
  } else if (id == 3) col = vec3 (1., 1., 1.);
  else if (id == 4) col = vec3 (1., 1., 0.4);
  else if (id == 5) col = vec3 (0.4, 1., 0.4);
  else if (id == 6) col = vec3 (1., 0.2, 0.);
  else if (id == 7) col = vec3 (1., 1., 1.);
  else if (id == 8) col = (ig == 1) ? vec3 (1., 0.4, 0.4) : vec3 (0.4, 1., 0.4);
  return vec4 (col, spec);
}

float WaveAO (vec3 ro, vec3 rd)
{
  float ao, d;
  ao = 0.;
  for (int j = 1; j <= 4; j ++) {
    d = 0.1 * float (j);
    ao += max (0., d - 3. * ObjDf (ro + rd * d));
  }
  return clamp (1. - 0.1 * ao, 0., 1.);
}

float WakeFac (vec3 row)
{
  vec2 tw, tw1;
  float wkFac, ba;
  tw = row.xz - (boatPos[0].xz - Rot2D (vec2 (0., 3.), boatAng[0]));
  tw1 = row.xz - (boatPos[1].xz - Rot2D (vec2 (0., 3.), boatAng[1]));
  if (length (tw1) < length (tw)) {
    tw = tw1;
    ba = boatAng[1];
  } else ba = boatAng[0];
  tw = Rot2D (tw, - ba);
  wkFac = 0.;
  if (length (tw * vec2 (1., 0.5)) < 1.)
     wkFac = clamp (1. - 1.5 * abs (tw.x), 0., 1.) * clamp (1. + 0.5 * tw.y, 0., 1.);
  return wkFac;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, watCol, vn, vnw, row, rdw;
  float dstObj, dstWat, wkFac, sh;
  int idObjT;
  bool waterRefl;
  dstWat = WaveRay (ro, rd);
  dstObj = ObjRay (ro, rd);
  waterRefl = (dstWat < min (dstFar, dstObj));
  if (waterRefl) {
    ro += rd * dstWat;
    row = ro;
    rdw = rd;
    wkFac = WakeFac (row);
    vnw = WaveNf (ro, dstWat);
    if (wkFac > 0.) vnw = VaryNf (10. * row, vnw, 5. * wkFac);
    rd = reflect (rd, vnw);
    ro += 0.1 * rd;
    idObj = -1;
    dstObj = ObjRay (ro, rd);
  }
  if (idObj < 0) dstObj = dstFar;
  if (dstObj < dstWat) {
    ro += dstObj * rd;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = BoatCol (vn);
    sh = ObjSShadow (ro, sunDir);
    col = objCol.rgb * (0.2 + 0.2 * (max (vn.y, 0.) + 
       max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.)) +
       0.8 * sh * max (dot (vn, sunDir), 0.)) +
       objCol.a * sh * pow (max (0., dot (sunDir, reflect (rd, vn))), 128.);
    col = clamp (col, 0., 1.);
  } else col = SkyCol (ro, rd);
  if (waterRefl) {
    watCol = (vec3 (0.2, 0.35, 0.4) * (0.5 + 0.5 * (max (vnw.y, 0.) +
       0.1 * pow (max (0., dot (sunDir, reflect (rdw, vnw))), 128.)))) *
       WaveAO (row, vec3 (0., 1., 0.));
    col = mix (watCol, col, 0.8 * pow (1. - abs (dot (rdw, vnw)), 4.));
    col = mix (col, vec3 (0.9),
       pow (clamp (WaveHt (row) + 0.1 * Fbm3 (32. * row), 0., 1.), 8.));
    if (wkFac > 0.) col = mix (col, vec3 (0.9),
       wkFac * clamp (0.1 + Fbm3 (9.1 * row), 0., 1.));
    col = mix (col, SkyCol (row, rdw), clamp (2. * dstWat / dstFar - 1.2, 0., 1.));
  }
  return clamp (col, 0., 1.);
}

vec3 TrackPath (float t)
{
  return vec3 (5. * sin (0.2 * t), 0., 1.5 * t);
}

void BoatPM (float t, float ds)
{
  vec3 bDir;
  float h[5], c, s, bAz;
  bPos = TrackPath (t);
  vec3 bp = TrackPath (t + 0.1) - bPos;
  bAz = atan (bp.z, - bp.x);
  bPos.x += ds;
  bDir = vec3 (0., 0., 1.);
  bDir.xz = Rot2D (bDir.xz, bAz);
  h[0] = WaveHt (bPos);
  h[1] = WaveHt (bPos + 0.5 * bDir);
  h[2] = WaveHt (bPos - 0.5 * bDir);
  bDir.xz = Rot2D (bDir.xz, -0.5 * pi);
  h[3] = WaveHt (bPos + 1.8 * bDir);
  h[4] = WaveHt (bPos - 1.8 * bDir);
  bPos.y = 0.1 + 1.1 * (2. * h[0] + h[1] + h[2] + h[3] + h[4]) / 6.;
  bMat[2] = normalize (vec3 (4., h[2] - h[1], 0.));
  bMat[0] = normalize (vec3 (0., 0.3 + h[3] - h[4], 4.));
  bMat[1] = cross (bMat[0], bMat[2]);
  c = cos (bAz);
  s = sin (bAz);
  bMat *= mat3 (c, 0., s, 0., 1., 0., - s, 0., c);
  bAng = 0.5 * pi - bAz;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec3 ro, rd, vd, u, bm;
  vec2 canvas, uv, ori, ca, sa;
  float f, az, el;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  sunDir = normalize (vec3 (0.5, 0.5, -1.));
  waterDisp = 0.25 * tCur * vec3 (-1., 0., 1.);
  BoatPM (tCur, -3.);
  boatPos[0] = bPos;
  boatMat[0] = bMat;
  boatAng[0] = bAng;
  BoatPM (tCur, 3.);
  boatPos[1] = bPos;
  boatMat[1] = bMat;
  boatAng[1] = bAng;
  dstFar = 150.;
  az = 2. * pi * 0.03 * tCur;
  el = 0.02 * pi * (1. + sin (0.11 * pi * tCur));
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  ro = vec3 (0., 0., -9.) * mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  bm = 0.5 * (boatPos[0] + boatPos[1]);
  ro += bm;
  ro.y = max (ro.y + 2., 0.3 + WaveHt (ro));
  bm.y += 0.5;
  vd = normalize (bm - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (uv, 2.5));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
