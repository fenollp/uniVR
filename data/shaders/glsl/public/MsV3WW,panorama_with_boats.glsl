// Shader downloaded from https://www.shadertoy.com/view/MsV3WW
// written by shadertoy user dr2
//
// Name: Panorama with Boats
// Description: Tracking camera switches between normal and 360 panorama modes
// "Panorama with Boats" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

vec4 Hashv4f (float p)
{
  return fract (sin (p + cHashA4) * cHashM);
}

float Noisefv2 (vec2 p)
{
  vec4 t;
  vec2 i, f;
  i = floor (p);  f = fract (p);  f = f * f * (3. - 2. * f);
  t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

float Noisefv3 (vec3 p)
{
  vec4 t1, t2;
  vec3 i, f;
  float q;
  i = floor (p);  f = fract (p);  f = f * f * (3. - 2. * f);
  q = dot (i, cHashA3);
  t1 = Hashv4f (q);  t2 = Hashv4f (q + cHashA3.z);
  return mix (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
     mix (mix (t2.x, t2.y, f.x), mix (t2.z, t2.w, f.x), f.y), f.z);
}

vec2 Noisev2v4 (vec4 p)
{
  vec4 i, f, t1, t2;
  i = floor (p);  f = fract (p);  f = f * f * (3. - 2. * f);
  t1 = Hashv4f (dot (i.xy, cHashA3.xy));  t2 = Hashv4f (dot (i.zw, cHashA3.xy));
  return vec2 (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
               mix (mix (t2.x, t2.y, f.z), mix (t2.z, t2.w, f.z), f.w));
}

float Fbm2 (vec2 p)
{
  float f, a;
  f = 0.;
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    f += a * Noisefv2 (p);
    a *= 0.5;
    p *= 2.;
  }
  return f;
}

float Fbm3 (vec3 p)
{
  float f, a;
  f = 0.;
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    f += a * Noisefv3 (p);
    a *= 0.5;
    p *= 2.;
  }
  return f;
}

float Fbmn (vec3 p, vec3 n)
{
  vec3 s;
  float a;
  s = vec3 (0.);
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * vec3 (Noisefv2 (p.yz), Noisefv2 (p.zx), Noisefv2 (p.xy));
    a *= 0.5;
    p *= 2.;
  }
  return dot (s, abs (n));
}

vec3 VaryNf (vec3 p, vec3 n, float f)
{
  vec3 g, e;
  float s;
  e = vec3 (0.1, 0., 0.);
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s, Fbmn (p + e.yxy, n) - s,
     Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d;
  d = abs (p) - b;
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

float SmoothMin (float a, float b, float r)
{
  float h;
  h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
  return mix (b, a, h) - r * h * (1. - h);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

int idObj, idObjGrp;
mat3 bMat, boatMat[2];
vec3 bPos, boatPos[2], qHit, sunDir, waterDisp, cloudDisp;
float tCur, bAng, boatAng[2], dstFar;

vec3 SkyBg (vec3 rd)
{
  return vec3 (0.15, 0.2, 0.65) + vec3 (0.2) * pow (1. - max (rd.y, 0.), 5.);
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  vec3 col;
  vec2 p;
  float cloudFac, skyHt, w, f, s;
  skyHt = 200.;
  if (rd.y > 0.) {
    ro.x += cloudDisp.x;
    p = 0.01 * (rd.xz * (skyHt - ro.y) / rd.y + ro.xz);
    w = 0.65;
    f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.3;
    }
    cloudFac = clamp (5. * (f - 0.3) * rd.y - 0.1, 0., 1.);
  } else cloudFac = 0.;
  s = max (dot (rd, sunDir), 0.);
  col = SkyBg (rd) + (0.35 * pow (s, 6.) + 0.65 * min (pow (s, 256.), 0.3));
  return mix (col, vec3 (0.85), cloudFac);
}

vec3 TrackPath (float t)
{
  return vec3 (1.3 * sin (0.2 * t) + 1.7 * sin (0.09 * t) +
     3.5 * sin (0.022 * t), 0., t);
}

float GrndHt (vec2 p)
{
  vec3 q;
  float h, g;
  h = 7. * Fbm2 (0.08 * p);
  q = TrackPath (p.y);
  return min (h, mix (q.y - 2., h, smoothstep (1.5, 4.5, sqrt (abs (p.x - q.x)))));
}

vec3 GrndNf (vec3 p, float d)
{
  float ht = GrndHt (p.xz);
  vec2 e = vec2 (max (0.01, 0.00001 * d * d), 0.);
  return normalize (vec3 (ht - GrndHt (p.xz + e.xy), e.x,
     ht - GrndHt (p.xz + e.yx)));
}

float GrndRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, h, s, sLo, sHi;
  s = 0.;
  sLo = 0.;
  dHit = dstFar;
  for (int j = 0; j < 200; j ++) {
    p = ro + s * rd;
    h = p.y - GrndHt (p.xz);
    if (h < 0.) break;
    sLo = s;
    s += max (0.1, 0.4 * h) + 0.005 * s;
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

float WaveHt (vec2 p)
{
  const mat2 qRot = mat2 (1.6, -1.2, 1.2, 1.6);
  vec4 t4, t4o, ta4, v4;
  vec2 q2, t2, v2;
  float wFreq, wAmp, pRough, ht;
  wFreq = 0.3;  wAmp = 0.2;  pRough = 6.;
  t4o.xz = tCur * vec2 (1., -1.);
  q2 = p + waterDisp.xz;
  ht = 0.;
  for (int j = 0; j < 4; j ++) {
    t4 = (t4o.xxzz + vec4 (q2, q2)) * wFreq;
    t2 = Noisev2v4 (t4);
    t4 += 2. * vec4 (t2.xx, t2.yy) - 1.;
    ta4 = abs (sin (t4));
    v4 = (1. - ta4) * (ta4 + sqrt (1. - ta4 * ta4));
    v2 = pow (1. - pow (clamp (v4.xz * v4.yw, 0., 1.), vec2 (0.65)), vec2 (pRough));
    ht += (v2.x + v2.y) * wAmp;
    q2 *= qRot;  wFreq *= 2.;  wAmp *= 0.2;
    pRough = 0.8 * pRough + 0.2;
  }
  return 0.4 * ht;
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
    h = p.y - WaveHt (p.xz);
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
      h = step (0., p.y - WaveHt (p.xz));
      sLo += h * (s - sLo);
      sHi += (1. - h) * (s - sHi);
    }
    dHit = sHi;
  }
  return dHit;
}

vec3 WaveNf (vec3 p, float d)
{
  vec2 e;
  float h;
  e = vec2 (max (0.1, 1e-4 * d * d), 0.);
  h = WaveHt (p.xz);
  return normalize (vec3 (h - WaveHt (p.xz + e.xy), e.x, h - WaveHt (p.xz + e.yx)));
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
  float dMin, d, dLim;
  const float szFac = 4.;
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
    d += min (0.03, 3. * h);
    if (h < 0.001) break;
  }
  return 0.5 + 0.5 * sh;
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
  tw = row.xz - (boatPos[0].xz - Rot2D (vec2 (0., 1.5), boatAng[0]));
  tw1 = row.xz - (boatPos[1].xz - Rot2D (vec2 (0., 1.5), boatAng[1]));
  if (length (tw1) < length (tw)) {
    tw = tw1;
    ba = boatAng[1];
  } else ba = boatAng[0];
  tw *= 1.8;
  tw = Rot2D (tw, - ba);
  wkFac = 0.;
  if (length (tw * vec2 (1., 0.5)) < 1.) wkFac =
     clamp (1. - 1.5 * abs (tw.x), 0., 1.) * clamp (1. + 0.5 * tw.y, 0., 1.);
  return wkFac;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, watCol, vn, vnw, row, rdw;
  float dstObj, dstGrnd, dstWat, wkFac, sh;
  int idObjT;
  bool waterRefl;
  dstWat = WaveRay (ro, rd);
  dstObj = ObjRay (ro, rd);
  dstGrnd = GrndRay (ro, rd);
  if (dstGrnd < dstObj) {
    dstObj = dstGrnd;
    idObj = 1;
  }
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
    dstGrnd = GrndRay (ro, rd);
    if (dstGrnd < dstObj) {
      dstObj = dstGrnd;
      idObj = 1;
    }
  }
  if (dstObj < dstWat) {
    ro += dstObj * rd;
    if (idObj == 1) {
      vn = VaryNf (5. * ro, GrndNf (ro, dstObj), 1.);
      objCol = vec4 (mix (vec3 (0.07, 0.25, 0.02), vec3 (0., 0.3, 0.),
         clamp (0.8 * Noisefv2 (ro.xz) - 0.1, 0., 1.)), 0.1);
      sh = 1.;
    } else {
      idObjT = idObj;
      vn = ObjNf (ro);
      idObj = idObjT;
      objCol = BoatCol (vn);
      sh = ObjSShadow (ro, sunDir);
    }
    col = objCol.rgb * (0.3 + 0.7 * sh * max (dot (vn, sunDir), 0.)) +
       objCol.a * sh * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.);
    col = mix (col, SkyCol (ro, rd), clamp (10. * dstObj / dstFar - 9., 0., 1.));
  } else col = SkyCol (ro, rd);
  if (waterRefl) {
    watCol = (vec3 (0.15, 0.3, 0.3) * (0.5 + 0.5 * (max (vnw.y, 0.) +
       0.1 * pow (max (0., dot (sunDir, reflect (rdw, vnw))), 64.)))) *
       WaveAO (row, vec3 (0., 1., 0.));
    col = mix (watCol, col, 0.8 * pow (1. - abs (dot (rdw, vnw)), 4.));
    col = mix (col, vec3 (0.9),
       pow (clamp (WaveHt (row.xz) + 0.4 * Fbm3 (7. * row), 0., 1.), 8.));
    if (wkFac > 0.) col = mix (col, vec3 (0.9),
       wkFac * clamp (0.1 + 0.5 * Fbm3 (23. * row), 0., 1.));
    col = mix (col, SkyCol (row, rdw), clamp (10. * dstWat / dstFar - 9., 0., 1.));
  }
  return pow (clamp (col, 0., 1.), vec3 (0.7));
}

void BoatPM (float t, float ds)
{
  vec2 bDir;
  float h[5], c, s, bAz;
  bPos = TrackPath (t);
  vec3 bp = TrackPath (t + 0.1) - bPos;
  bAz = atan (bp.z, - bp.x);
  bPos.x += ds;
  bDir = vec2 (0., 1.);
  bDir = Rot2D (bDir, bAz);
  h[0] = WaveHt (bPos.xz);
  h[1] = WaveHt (bPos.xz + 0.5 * bDir);
  h[2] = WaveHt (bPos.xz - 0.5 * bDir);
  bDir = Rot2D (bDir, -0.5 * pi);
  h[3] = WaveHt (bPos.xz + 0.5 * bDir);
  h[4] = WaveHt (bPos.xz - 0.5 * bDir);
  bPos.y = 0.05 + 1.1 * (2. * h[0] + h[1] + h[2] + h[3] + h[4]) / 6.;
  bMat[2] = normalize (vec3 (0.5, h[2] - h[1], 0.));
  bMat[0] = normalize (vec3 (0., 0.3 + h[3] - h[4], 2.));
  bMat[1] = cross (bMat[0], bMat[2]);
  c = cos (bAz);
  s = sin (bAz);
  bMat *= mat3 (c, 0., s, 0., 1., 0., - s, 0., c);
  bAng = 0.5 * pi - bAz;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec3 ro, rd, vd, u, col;
  vec2 canvas, uv, uvs;
  float vuPeriod, vel, f, zmFac, sPano;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uvs = uv;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  vuPeriod = 100.;
  sPano = SmoothBump (0.25, 0.75, 0.02, mod (tCur / vuPeriod, 1.));
  if (abs (uvs.y) < 0.85 - 0.25 * sPano) {
    dstFar = 300.;
    sunDir = normalize (vec3 (cos (0.03 * tCur), 1., sin (0.03 * tCur)));
    waterDisp = 0.1 * tCur * vec3 (-1., 0., 1.);
    cloudDisp = 0.5 * tCur * vec3 (1., 0., 0.);
    vel = 2.;
    BoatPM (vel * tCur + 5., 0.2);
    boatPos[0] = bPos;  boatMat[0] = bMat;  boatAng[0] = bAng;
    BoatPM (vel * tCur - 5., -0.2);
    boatPos[1] = bPos;  boatMat[1] = bMat;  boatAng[1] = bAng;
    f = 2. * SmoothBump (0.25, 0.75, 0.2, mod (2. * tCur / vuPeriod, 1.)) - 1.;
    ro = TrackPath (vel * tCur - 12. * f);
    f = abs (f);
    ro.y = 0.5 + WaveHt (ro.xz) + 3. * (1. - f * f);
    ro.x += 1.3 * (1. - f);
    zmFac = 4.5 - 2. * (1. - f * f);
    f = smoothstep (0.1, 0.3, 1. - f);
    vd = normalize (0.5 * ((1. + f) * boatPos[0] + (1. - f) * boatPos[1]) - ro);
    u = - vd.y * vd;
    f = 1. / sqrt (1. - vd.y * vd.y);
    vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
    rd = vuMat * normalize (mix (vec3 (uv, zmFac), 
       vec3 (sin (0.56 * pi * uv.x) , uv.y, cos (0.56 * pi * uv.x)), sPano));
    col = ShowScene (ro, rd);
  } else col = vec3 (0.);
  fragColor = vec4 (col, 1.);
}
