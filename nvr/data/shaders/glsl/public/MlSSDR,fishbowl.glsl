// Shader downloaded from https://www.shadertoy.com/view/MlSSDR
// written by shadertoy user dr2
//
// Name: Fishbowl
// Description: Lots of optical effects - refraction, total internal reflection and Fresnel
//    reflection (proof of correctness left as exercise for reader); use mouse to explore.
// "Fishbowl" by dr2 - 2015
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

float Length4 (vec2 p)
{
  p *= p;
  p *= p;
  return pow (p.x + p.y, 1. / 4.);
}

int idObj;
mat3 fishMat, vuMat;
vec3 fishPos, qHit, sunDir, waterDisp, cloudDisp;
float tCur, bowlRad, bowlHt, fishLen, angTail, angFin, posMth;
bool inBowl, chkBowl;
const float dstFar = 100.;
const int idBrWall = 1, idTbl = 2, idBowl = 3,
   idFBdy = 11, idTail = 12, idFin = 13, idEye = 14;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col;
  vec2 p;
  float cloudFac, w, f;
  if (rd.y > 0.) {
    ro.xz += cloudDisp.xz;
    p = 0.05 * (rd.xz * (70. - ro.y) / rd.y + ro.xz);
    w = 0.8;  f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);  w *= 0.5;  p *= 2.;
    }
    cloudFac = clamp (3. * f * rd.y - 0.3, 0., 1.);
    f = max (dot (rd, sunDir), 0.);
    col =  mix (vec3 (0.2, 0.3, 0.55) + 0.2 * pow (1. - rd.y, 5.) +
       (0.35 * pow (f, 6.) + 0.65 * min (pow (f, 256.), 0.3)),
       vec3 (0.85), cloudFac);
  } else {
    p = -0.05 * (rd.xz * ro.y / rd.y + ro.xz);
    w = 1.;  f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);  w *= 0.5;  p *= 2.;
    }
    col = mix ((1. + min (f, 1.)) * vec3 (0.15, 0.2, 0.15),
       vec3 (0.2, 0.3, 0.55) + 0.2, pow (1. + rd.y, 5.));
  }
  return col;
}

vec3 BrickSurfCol (vec2 p) {
  vec2 q = p * vec2 (1./40., 1./20.);
  vec2 i = floor (q);
  if (2. * floor (i.y / 2.) != i.y) {
    q.x += 0.5;
    i = floor (q);
  }
  q = smoothstep (0.02, 0.04, abs (fract (q + 0.5) - 0.5));
  return (1. + Noisefv2 (5. * p)) * (0.2 + 0.8 * q.x * q.y) *
     vec3 (0.7, 0.4, 0.3);
}

vec3 BrickCol (vec3 p, vec3 n)
{
  n = abs (n);
  p *= 150.;
  return BrickSurfCol (p.zy) * n.x + BrickSurfCol (p.xz) * n.y +
     BrickSurfCol (p.xy) * n.z;
}

vec3 WoodCol (vec3 p, vec3 n)
{
  p *= 4.;
  float f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.zx * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return mix (vec3 (0.8, 0.4, 0.2), vec3 (0.45, 0.25, 0.1), f);
}

float WaterHt (vec3 p)
{
  float ht, w;
  const float wb = 1.414;
  p *= 0.05;
  ht = 0.;
  w = wb;
  for (int j = 0; j < 4; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x);
    p += waterDisp;
    ht += w * abs (Noisefv3 (p) - 0.5);
  }
  return 0.1 * ht;
}

vec3 WaterNf (vec3 p)
{
  float h = WaterHt (p);
  vec2 e = vec2 (0.001, 0.);
  return normalize (vec3 (h - WaterHt (p + e.xyy), e.x, h - WaterHt (p + e.yyx)));
}

float TableDf (vec3 p, float dMin)
{
  vec3 q;
  float d, d1, d2, br, bl, sFac;
  sFac = 2.5;  br = 1.6 * sFac;  bl = 1.1 * sFac;
  p -= vec3 (0., - 2.2 * sFac - 0.01 * br, 0.);
  q = p;
  q.y -= - 0.55 * br;
  d = PrCylDf (q.xzy, 0.5 * br, 0.03 * br);
  p.xz += 0.05 * br * vec2 (1., 1.5);
  q = p;  q.y -= - 1.4 * bl;
  d1 = PrCylDf (q.xzy, 0.07 * br, 0.6 * bl);
  q = p;  q.y -= - 2. * bl;
  d2 = max (PrCylDf (q.xzy, 0.5 * br, 0.15 * br * (1. -
     0.7 * smoothstep (0.2 * br, 0.35 * br, length (p.xz)))), -0.05 * br - q.y);
  d = min (d, min (d1, d2));
  if (d < dMin) { dMin = d;  idObj = idTbl;  qHit = q; }
  return dMin;
}

float BowlWlDf (vec3 p, float dMin)
{
  float d, db;
  db = Length4 (vec2 (length (p.xz), p.y));
  d = inBowl ? max (max (db - 1.03 * bowlRad, p.y - bowlHt),
     - max (db - bowlRad, p.y - bowlHt)) : max (db - bowlRad, p.y - bowlHt);
  if (d < dMin) { dMin = d;  qHit = p;  idObj = idBowl; }
  return dMin;
}

float FishDf (vec3 p, float dMin)
{
  vec3 q;
  float d, wr, tr, u;
  q = p;  q.x = abs (q.x);  q -= fishLen * vec3 (0.12, 0.1, 0.9);
  d = PrSphDf (q, 0.05 * fishLen);
  if (d < dMin) { dMin = d;  idObj = idEye;  qHit = q; }
  q = p;
  wr = q.z / fishLen;
  if (wr > 0.5) {
    u = (wr - 0.5) / 0.5;  tr = 0.17 - 0.11 * u * u;
  } else {
    u = clamp ((wr - 0.5) / 1.5, -1., 1.);  u *= u;  tr = 0.17 - u * (0.33 - 0.13 * u); 
  }
  q.y *= 0.5;
  d = PrCapsDf (q, 1.1 * tr * fishLen, fishLen);
  q.y *= 2.;  q.z -= posMth * fishLen;
  d = max (d, - PrCylDf (q.yzx, 0.03 * fishLen, 0.1 * fishLen));
  if (d < dMin + 0.01 * fishLen) {
    dMin = SmoothMin (dMin, d, 0.01 * fishLen);  idObj = idFBdy;  qHit = q;
  }
  q = p;  q.z -= -0.9 * fishLen;  q.y *= 0.1;
  wr = q.z / (0.4 * fishLen);
  if (wr > 0.5) {
    u = (wr - 0.5) / 0.5;  tr = 0.17 - 0.05 * u * u;
  } else {
    u = clamp ((wr - 0.5) / 1.5, -1., 1.);  u *= u;  tr = 0.17 - u * 0.34; 
  }
  float dTail = PrCylDf (q, 0.13 * tr * fishLen, 0.6 * fishLen);
  d = max (dTail, 0.15 * fishLen - q.z);
  if (d < dMin + 0.01 * fishLen) {
    dMin = SmoothMin (dMin, d, 0.01 * fishLen);  idObj = idTail;  qHit = q;
  }
  q.z -= 0.15 * fishLen;
  q.xz = Rot2D (q.xz, angTail);
  d = max (PrCylDf (q, 0.13 * tr * fishLen, 0.6 * fishLen), q.z);
  if (d < dMin) { dMin = d;  idObj = idTail;  qHit = q; }
  q = p;  q.y *= 0.5;  q.z -= -0.75 * fishLen;
  q = q.xzy;
  d = max (PrCylDf (q, 0.022 * fishLen, 0.11 * fishLen), dTail);
  if (d < dMin) { dMin = d;  idObj = idTail;  qHit = 0.2 * q.xzy; }
  q = p;  q.x = abs (q.x) - 0.18 * fishLen;  q.y *= 0.1;  q.z -= 0.4 * fishLen;
  q.xz = Rot2D (q.xz, angFin);
  wr = q.z / (0.2 * fishLen);
  if (wr > 0.5) {
    u = (wr - 0.5) / 0.5;  tr = 0.17 - 0.01 * u * u;
  } else {
    u = clamp ((wr - 0.5) / 1.5, -1., 1.);  u *= u;  tr = 0.17 - u * 0.34; 
  }
  q.z -= 0.3 * fishLen;
  d = PrCylDf (q, 0.12 * tr * fishLen, 0.5 * fishLen);
  if (d < dMin + 0.005 * fishLen) {
    dMin = SmoothMin (dMin, d, 0.005 * fishLen);  idObj = idFin;  qHit = q;
  }
  return 0.75 * dMin;
}

float BowlExtDf (vec3 p, float dMin)
{
  vec3 q;
  float d;
  q = p;  q.y -= -2.72 * bowlRad + 11.;  q.z -= 1.2 * bowlRad;
  d = PrBoxDf (q, vec3 (2.38, 1.33, 0.05) * bowlRad);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idBrWall; }
  q = p;  q -= vec3 (0., -2. * bowlRad + 1., 1.2 * bowlRad);
  d = max (PrCylDf (q.xzy, 2.38 * bowlRad, 0.05 * bowlRad), q.z);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idBrWall; }
  q = p;  q.y -= - bowlHt + 5.1;
  dMin = TableDf (q, dMin);
  return dMin;
}

float ObjDf (vec3 p)
{
  float dMin = dstFar;
  if (chkBowl) dMin = BowlWlDf (p, dMin);
  else if (inBowl) dMin = FishDf (fishMat * (p - fishPos), dMin);
  else dMin = BowlExtDf (p, dMin);
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
  float sh, d, h;
  sh = 1.;
  d = 0.1;
  for (int j = 0; j < 60; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.2;
    if (h < 0.001) break;
  }
  return clamp (0.5 + 0.5 * sh, 0., 1.);
}

vec3 FishCol (vec3 n)
{
  vec3 col;
  const vec3 col1 = vec3 (1., 1., 0.1), col2 = vec3 (0.1, 0.1, 1.);
  qHit *= 20. / fishLen;
  if (idObj == idEye) {
    col = vec3 (0.1, 1., 0.1);
    if (qHit.z > 0.5) col = vec3 (0.5, 0., 0.);
  } else if (idObj == idFBdy) {
    col = mix (col2, col1, 0.5 * (1. + sin (4. * qHit.y)));
    vec3 nn = fishMat * n;
    col = mix (col1,  mix (col, col2, smoothstep (0.7, 1., nn.y)),
       smoothstep (-1., -0.7, nn.y)) *
       (1. - 0.2 * SmoothBump (-0.2, 0.2, 0.1, qHit.x));
  } else if (idObj == idTail) {
    col = mix (col2, col1, 0.5 * (1. + sin (40. * qHit.y)));
  } else if (idObj == idFin) {
    col = mix (col2, col1, 0.5 * (1. + sin (40. * qHit.y)));
  }
  return col;
}

vec4 ObjCol (vec3 n)
{
  vec4 col;
  if (idObj == idBrWall) col = vec4 (BrickCol (0.1 * qHit, n), 0.);
  else if (idObj == idTbl) col = vec4 (WoodCol (qHit, n), 0.2);
  else col = vec4 (FishCol (n), 1.);
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 roW, rdW, rdd, vn, vnW, colD, colR, qHitBowl, reflCol;
  float dstHit, dstBowl, dstBowlW, yLim, dif, sh, frnlFac;
  int idObjT, hitBowl;
  bool bWallHit;
  const float eta = 1.33;
  yLim = 0.999 * bowlHt;
  idObj = -1;
  inBowl = false;
  chkBowl = true;
  dstBowl = ObjRay (ro, rd);
  if (idObj < 0) dstBowl = dstFar;
  hitBowl = -1;
  if (dstBowl < dstFar) {
    hitBowl = idObj;
    qHitBowl = qHit;
  }
  idObj = -1;
  chkBowl = false;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  idObjT = idObj;
  roW = ro;  rdW = rd;
  dstBowlW = dstBowl;
  reflCol = vec3 (1.);
  frnlFac = 0.;
  bWallHit = (dstBowl < dstHit && hitBowl > 0);
  if (bWallHit) {
    ro += dstBowl * rd;
    chkBowl = true;
    vn = (qHitBowl.y < yLim) ? ObjNf (ro) : WaterNf (qHitBowl);
    vnW = vn;
    frnlFac = (qHitBowl.y > - yLim) ? abs (dot (rd, vn)) : 0.;
    rd = refract (rd, vn, 1. / eta);
    ro += 0.01 * rd;
    idObj = -1;
    inBowl = true;
    dstBowl = ObjRay (ro, rd);
    if (idObj < 0) dstBowl = dstFar;
    hitBowl = -1;
    if (dstBowl < dstFar) {
      hitBowl = idObj;
      qHitBowl = qHit;
    }
    idObj = -1;
    chkBowl = false;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
    idObjT = idObj;
    if (dstBowl < dstHit && hitBowl > 0) {
      ro += dstBowl * rd;
      chkBowl = true;
      vn = (qHitBowl.y < yLim) ? ObjNf (ro) : - WaterNf (qHitBowl);
      rdd = refract (rd, vn, eta);
      if (length (rdd) > 0.) {
        rd = rdd;
        reflCol *= vec3 (0.9, 1., 0.9);
        inBowl = false;
      } else rd = reflect (rd, vn);
      ro += 0.01 * rd;
      idObj = -1;
      chkBowl = false;
      dstHit = ObjRay (ro, rd);
      if (idObj < 0) dstHit = dstFar;
      idObjT = idObj;
    }
  }
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    chkBowl = false;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = ObjCol (vn);
    dif = max (dot (vn, sunDir), 0.);
    sh = (idObjT < idFBdy) ? ObjSShadow (ro, sunDir) : 1.;
    colD = reflCol * (objCol.rgb * (0.2 + 0.8 * dif * sh +
       objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.)));
    idObj = idObjT;
  } else colD = reflCol * BgCol (ro, rd);
  colR = vec3 (0.);
  reflCol = vec3 (1.);
  if (bWallHit) {
    ro = roW + dstBowlW * rdW;
    rd = (frnlFac > 0.) ? reflect (rdW, vnW) : rdW;
    ro += 0.01 * rd;
    inBowl = false;
    idObj = -1;
    chkBowl = false;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
    idObjT = idObj;
    if (dstHit < dstFar) {
      ro += rd * dstHit;
      vn = ObjNf (ro);
      idObj = idObjT;
      objCol = ObjCol (vn);
      dif = max (dot (vn, sunDir), 0.);
      sh = ObjSShadow (ro, sunDir);
      colR = reflCol * (objCol.rgb * (0.2 + 0.8 * dif * sh +
         objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.)));
    } else colR = reflCol * BgCol (ro, rd);
  }
  frnlFac = (eta != 1. && frnlFac > 0.) ? 1. - pow (frnlFac, 4.) : 0.;
  return clamp (mix (colD, colR, smoothstep (0.98, 1., frnlFac)), 0., 1.);
}

vec3 FishTrack (float t)
{
  return 0.6 * bowlRad * vec3 (cos (0.5 * t),
     0., - sin (0.5 * t)) + bowlHt * vec3 (0., -0.2 + 0.8 * sin (0.077 * t), 0.);
}

void FishPM (float t)
{
  float dt = 1.;
  fishPos = FishTrack (t);
  vec3 vel = (FishTrack (t + dt) - FishTrack (t - dt)) / (2. * dt);
  float a = atan (vel.z, vel.x) - 0.5 * pi;
  float ca = cos (a);
  float sa = sin (a);
  fishMat = mat3 (ca, 0., - sa, 0., 1., 0., sa, 0., ca);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 canvas = iResolution.xy;
  vec2 uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  vec4 mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  mPtr.y *= -1.;  // local only
  vec3 ro, rd;
  float el, az, zmFac;
  bowlRad = 5.;
  bowlHt = 2.5;
  FishPM (tCur);
  fishLen = 0.25 * bowlRad;
  angTail = 0.1 * pi * sin (5. * tCur);
  angFin = pi * (0.8 + 0.1 * sin (2.5 * tCur));
  posMth = 1.04 + 0.01 * sin (5. * tCur);
  waterDisp = 0.1 * tCur * vec3 (1., 0., 1.);
  cloudDisp = 4. * tCur * vec3 (1., 0., 1.);
  el = 0.;
  az = 0.;
  zmFac = 5.;
  if (mPtr.z > 0.) {
    el = clamp (el + 3. * mPtr.y, -1.1, 1.4);
    az = clamp (az - 3. * mPtr.x, -1.5, 1.5);
  } else {
    zmFac = clamp (zmFac - 2. + 0.4 * tCur, 3., 7.);
    el += pi * (-0.3 + 0.75 * SmoothBump (0.25, 0.75, 0.25,
       mod (0.071 * tCur + 0.4 * pi, 2. * pi) / (2. * pi)));
    az += 0.6 * pi * (1. - 0.5 * abs (el)) * sin (0.21 * tCur);
  }
  vec2 vf = vec2 (el, az);
  vec2 cf = cos (vf);
  vec2 sf = sin (vf);
  vuMat = mat3 (1., 0., 0., 0., cf.x, - sf.x, 0., sf.x, cf.x) *
     mat3 (cf.y, 0., sf.y, 0., 1., 0., - sf.y, 0., cf.y);
  rd = normalize (vec3 (uv, zmFac)) * vuMat;
  ro = vec3 (0., 0., -40.) * vuMat;
  sunDir = normalize (vec3 (-0.2, 0.2, -1.)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
