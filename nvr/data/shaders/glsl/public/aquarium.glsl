// Shader downloaded from https://www.shadertoy.com/view/Mtf3zM
// written by shadertoy user dr2
//
// Name: Aquarium
// Description: How many robofish can you see?
// "Aquarium" by dr2 - 2014
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Includes refraction, total internal reflection and Fresnel reflection
// (correctness not guaranteed, proof left as exercise for reader).

// Pseudo-caustics based on Dave_H's "Tileable Water Caustic".

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
  float s = length (max (d, 0.));
  d = min (d, 0.);
  return max (d.x, max (d.y, d.z)) + s;
}

float PrOBoxDf (vec3 p, vec3 b)
{
  return length (max (abs (p) - b, 0.));
}

float PrIBoxDf (vec3 p, vec3 b)
{
  vec3 d = min (abs (p) - b, 0.);
  return max (d.x, max (d.y, d.z));
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

vec3 RgbToHsv (vec3 c)
{
  vec4 p = mix (vec4 (c.bg, vec2 (-1., 2./3.)), vec4 (c.gb, vec2 (0., -1./3.)),
     step (c.b, c.g));
  vec4 q = mix (vec4 (p.xyw, c.r), vec4 (c.r, p.yzx), step (p.x, c.r));
  float d = q.x - min (q.w, q.y);
  const float e = 1.e-10;
  return vec3 (abs (q.z + (q.w - q.y) / (6. * d + e)), d / (q.x + e), q.x);
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

int idObj;
mat3 fishMat, vuMat;
vec3 fishPos, qHit, sunDir, tankSize, waterDisp, cloudDisp;
float tCur, fishLen, angTail, angFin, posMth;
bool inTank, chkTank;
const float dstFar = 100.;
const int idStn = 1, idTkFlr = 2, idTkFrm = 3, idBrWall = 4, idTbl = 5,
   idFBdy = 21, idTail = 22, idFin = 23, idEye = 24;

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
    p = -0.02 * (rd.xz * ro.y / rd.y + ro.xz);
    w = 1.;  f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);  w *= 0.7;  p *= 2.5;
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
  return (1. + Noisefv2 (10. * p)) * (0.2 + 0.8 * q.x * q.y) *
     vec3 (0.5, 0.4, 0.3);
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
  float ht = WaterHt (p);
  vec2 e = vec2 (0.01, 0.);
  return normalize (vec3 (ht - WaterHt (p + e.xyy), e.x, ht - WaterHt (p + e.yyx)));
}

float TableDf (vec3 p, float dHit)
{
  vec3 q;
  float d, d1, d2, br, bl, sFac;
  sFac = 2.5;  br = 1.6 * sFac;  bl = 1.1 * sFac;
  p -= vec3 (0., - 2.2 * sFac - 0.01 * br, 0.);
  q = p;
  d = PrBoxDf (q, br * vec3 (1., 0.042, 0.6));
  p.xz += 0.05 * br * vec2 (1., 1.5);
  q = p;  q.y += bl;
  d1 = PrCylDf (q.xzy, 0.07 * br, bl);
  q = p;  q.y += 2. * bl;
  d2 = max (PrCylDf (q.xzy, 0.5 * br, 0.15 * br * (1. -
     0.7 * smoothstep (0.2 * br, 0.35 * br, length (p.xz)))), -0.05 * br - q.y);
  d = min (d, min (d1, d2));
  if (d < dHit) { dHit = d;  idObj = idTbl;  qHit = q; }
  return dHit;
}

float TankWlDf (vec3 p, float dHit)
{
  float d;
  d = (inTank)? max (PrIBoxDf (p, tankSize + 0.025 * tankSize.x),
     - PrIBoxDf (p, tankSize + 0.015 * tankSize.x)) : PrOBoxDf (p, tankSize);
  if (d < dHit) { dHit = d;  qHit = p;  idObj = 10; }
  return dHit;
}

float FishDf (vec3 p, float dHit)
{
  vec3 q;
  float d, wr, tr, u;
  q = p;  q.x = abs (q.x);  q -= fishLen * vec3 (0.12, 0.1, 0.9);
  d = PrSphDf (q, 0.05 * fishLen);
  if (d < dHit) { dHit = d;  idObj = idEye;  qHit = q; }
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
  if (d < dHit + 0.01 * fishLen) {
    dHit = SmoothMin (dHit, d, 0.01 * fishLen);  idObj = idFBdy;  qHit = q;
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
  if (d < dHit + 0.01 * fishLen) {
    dHit = SmoothMin (dHit, d, 0.01 * fishLen);  idObj = idTail;  qHit = q;
  }
  q.z -= 0.15 * fishLen;
  q.xz = Rot2D (q.xz, angTail);
  d = max (PrCylDf (q, 0.13 * tr * fishLen, 0.6 * fishLen), q.z);
  if (d < dHit) { dHit = d;  idObj = idTail;  qHit = q; }
  q = p;  q.y *= 0.5;  q.z -= -0.75 * fishLen;
  q = q.xzy;
  d = max (PrCylDf (q, 0.022 * fishLen, 0.11 * fishLen), dTail);
  if (d < dHit) { dHit = d;  idObj = idTail;  qHit = 0.2 * q.xzy; }
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
  if (d < dHit + 0.005 * fishLen) {
    dHit = SmoothMin (dHit, d, 0.005 * fishLen);  idObj = idFin;  qHit = q;
  }
  return 0.75 * dHit;
}

float TankIntDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  q = p;  q.y -= -0.548 * tankSize.x;
  d = max (max (PrSphDf (q, 0.35 * tankSize.x), q.y - 0.25 * tankSize.x), - q.y);
  q.y -= 0.25 * tankSize.x;
  d = max (d, - min (PrCylDf (q, 0.1 * tankSize.x, 0.4 * tankSize.x),
     PrCylDf (q.zyx, 0.1 * tankSize.x, 0.4 * tankSize.x)));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idStn; }
  return dHit;
}

float TankExtDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  q = p;  q.y -= - 2.7 * tankSize.x + 11.;  q.z -= 1.1 * tankSize.x;
  d = PrBoxDf (q, vec3 (2.4, 1.35, 0.05) * tankSize.x);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBrWall; }
  q = p;  q -= vec3 (0., -2. * tankSize.x + 1., 1.1 * tankSize.x);
  d = max (PrCylDf (q.xzy, 2.4 * tankSize.x, 0.05 * tankSize.x),
     q.z);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBrWall; }
  q = p;  q.y -= - tankSize.y + 5.1;
  dHit = TableDf (q, dHit);
  return dHit;
}

float TankFrameDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  q = p;  q.y -= -0.489 * tankSize.x;
  d = max (q.y, PrBoxDf (q, vec3 (tankSize.x, 0.01 * tankSize.x, tankSize.z)));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idTkFlr; }
  vec3 ts = tankSize - 0.01 * tankSize.x;
  vec3 db = vec3 (0.1 * tankSize.x, 0., 0.);
  q = p;
  d = max (PrBoxDf (q, ts + 0.05 * tankSize.x),
     - min (PrBoxDf (q, ts + 0.025 * tankSize.x),
     min (PrBoxDf (q, ts + db.yzx), min (PrBoxDf (q, ts + db.zxy),
     PrBoxDf (q, ts + db)))));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idTkFrm; }
  return dHit;
}

float ObjDf (vec3 p)
{
  float dHit = dstFar;
  if (chkTank) dHit = TankWlDf (p, dHit);
  else {
    dHit = TankFrameDf (p, dHit);
    if (inTank) {
      dHit = TankIntDf (p, dHit);
      dHit = FishDf (fishMat * (p - fishPos), dHit);
    } else dHit = TankExtDf (p, dHit);
  }
  return dHit;
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
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.1;
  for (int j = 0; j < 60; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 10. * h / d);
    d += 0.1;
    if (h < 0.001) break;
  }
  return clamp (0.6 + sh, 0., 1.);
}

float ObjAO (vec3 ro, vec3 rd)
{
  float ao, d;
  ao = 0.;
  for (int j = 0; j < 8; j ++) {
    d = 0.1 + float (j) / 8.;
    ao += max (0., d - 3. * ObjDf (ro + rd * d));
  }
  return 0.3 + 0.7 * clamp (1. - 0.1 * ao, 0., 1.);
}

vec3 FishCol (vec3 n)
{
  vec3 col;
  const vec3 col1 = vec3 (1., 0.2, 0.1), col2 = vec3 (0.1, 1., 0.2);
  qHit *= 20. / fishLen;
  if (idObj == idEye) {
    col = vec3 (0., 0.6, 1.);
    if (qHit.z > 0.5) col = vec3 (0., 0., 0.1);
  } else if (idObj == idFBdy) {
    col = mix (col2, col1, 0.5 * (1. + sin (2. * qHit.y)));
    vec3 nn = fishMat * n;
    col = mix (col1,  mix (col, col2, smoothstep (0.7, 1., nn.y)),
       smoothstep (-1., -0.7, nn.y)) *
       (1. - 0.2 * SmoothBump (-0.2, 0.2, 0.1, qHit.x));
  } else if (idObj == idTail) {
    col = mix (col2, col1, 0.5 * (1. + sin (20. * qHit.y)));
  } else if (idObj == idFin) {
    col = mix (col2, col1, 0.5 * (1. + sin (20. * qHit.y)));
  }
  return col;
}

vec4 ObjCol (vec3 n)
{
  vec4 col;
  if (idObj == idStn) col = vec4 (0.16, 0.2, 0.16, 0.2) *
     (0.1 + Fbm2 (5. * qHit.xz));
  else if (idObj == idTkFlr) col = vec4 (0.2, 0.2, 0.05, 0.1) *
     (0.5 + 0.5 * Fbm2 (10. * qHit.xz));
  else if (idObj == idTkFrm) col = vec4 (0.2, 0.3, 0.9, 2.);
  else if (idObj == idBrWall) col = vec4 (BrickCol (0.1 * qHit, n), 0.1);
  else if (idObj == idTbl) col = vec4 (WoodCol (qHit, n), 0.3);
  else col = vec4 (FishCol (n), 1.);
  return col;
}

float TurbLt (vec3 p, vec3 n, float t)
{
  vec2 q, qq, a1, a2;
  float c, tt;
  q = 2. * pi * mod (vec2 (dot (p.yzx, n), dot (p.zxy, n)), 1.) - 256.;
  t += 11.;
  qq = q;  c = 0.;
  for (int k = 1; k <= 6; k ++) {
    tt = t * (1. + 1. / float (k));
    a1 = tt - qq;  a2 = tt + qq;
    qq = q + tt + vec2 (cos (a1.x) + sin (a2.y), sin (a1.y) + cos (a2.x));
    c += 1. / length (q / vec2 (sin (qq.x), cos (qq.y)));
  }
  return clamp (pow (abs (1.1 - 40. * c), 8.), 0., 1.);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 roW, rdW, rdd, vn, vno, vnW, colD, colR, qHitTank;
  float dstHit, dstTank, dstTankW, yLim, dif, ao, sh, reflFac, frnlFac;
  int idObjT, idTank;
  bool tWallHit, isDown;
  const float eta = 1.25;
  yLim = 0.999 * tankSize.y;
  idObj = -1;
  inTank = false;
  chkTank = true;
  dstTank = ObjRay (ro, rd);
  if (idObj < 0) dstTank = dstFar;
  idTank = -1;
  if (dstTank < dstFar) {
    idTank = idObj;
    qHitTank = qHit;
  }
  idObj = -1;
  chkTank = false;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  idObjT = idObj;
  roW = ro;  rdW = rd;
  dstTankW = dstTank;
  reflFac = 1.;
  frnlFac = 0.;
  tWallHit = (dstTank < dstHit && idTank > 0);
  if (tWallHit) {
    ro += dstTank * rd;
    chkTank = true;
    vn = (qHitTank.y < yLim) ? ObjNf (ro) : WaterNf (qHitTank);
    vnW = vn;
    frnlFac = (qHitTank.y > - yLim) ? abs (dot (rd, vn)) : 0.;
    rd = refract (rd, vn, 1. / eta);
    ro += 0.01 * rd;
    idObj = -1;
    inTank = true;
    dstTank = ObjRay (ro, rd);
    if (idObj < 0) dstTank = dstFar;
    idTank = -1;
    if (dstTank < dstFar) {
      idTank = idObj;
      qHitTank = qHit;
    }
    idObj = -1;
    chkTank = false;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
    idObjT = idObj;
    if (dstTank < dstHit && idTank > 0) {
      ro += dstTank * rd;
      chkTank = true;
      vn = (qHitTank.y < yLim) ? ObjNf (ro) : - WaterNf (qHitTank);
      rdd = refract (rd, vn, eta);
      if (length (rdd) > 0.) {
        rd = rdd;
        reflFac *= 0.8;
        inTank = false;
      } else rd = reflect (rd, vn);
      ro += 0.01 * rd;
      idObj = -1;
      chkTank = false;
      dstHit = ObjRay (ro, rd);
      if (idObj < 0) dstHit = dstFar;
      idObjT = idObj;
    }
  }
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    chkTank = false;
    vn = ObjNf (ro);
    vno = vn;
    idObj = idObjT;
    if (idObj == idStn) {
      vn = VaryNf (6. * qHit, vn, 5.);
    } else if (idObj == idTkFlr) {
      vn = (vn.y > 0.) ? VaryNf (10. * qHit, vn, 2.) : vn;
    }
    objCol = ObjCol (vn);
    dif = max (dot (vn, sunDir), 0.);
    ao = ObjAO (ro, vn);
    sh = (idObjT < idFBdy) ? ObjSShadow (ro, sunDir) : 1.;
    colD = reflFac * objCol.rgb * (0.2 * ao + max (0., dif) * sh *
       (dif + ao * objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.)));
    isDown = (vno.y < -0.999);
    vno = normalize (smoothstep (0.1, 0.9, abs (vno)));
    idObj = idObjT;
    if (! isDown && (idObj <= idTkFlr || idObj >= idFBdy)) colD *= 1. +
       ((idObj <= idTkFlr) ? 3. : 0.3) * TurbLt (0.1 * ro, vno, 0.5 * tCur);
  } else colD = reflFac * BgCol (ro, rd);
  colR = vec3 (0.);
  reflFac = 1.;
  if (tWallHit) {
    ro = roW + dstTankW * rdW;
    rd = (frnlFac > 0.) ? reflect (rdW, vnW) : rdW;
    ro += 0.01 * rd;
    inTank = false;
    idObj = -1;
    chkTank = false;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
    idObjT = idObj;
    if (dstHit < dstFar) {
      ro += rd * dstHit;
      vn = ObjNf (ro);
      idObj = idObjT;
      objCol = ObjCol (vn);
      dif = max (dot (vn, sunDir), 0.);
      ao = ObjAO (ro, vn);
      sh = ObjSShadow (ro, sunDir);
      colR = reflFac * objCol.rgb * (0.2 * ao + max (0., dif) * sh *
         (dif + ao * objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.)));
    } else colR = reflFac * BgCol (ro, rd);
    colR = HsvToRgb (RgbToHsv (colR) * vec3 (1., 0.7, 0.5));
  }
  frnlFac = (eta != 1. && frnlFac > 0.) ? 1. - pow (frnlFac, 4.) : 0.;
  return sqrt (clamp (mix (colD, colR, smoothstep (0.98, 1., frnlFac)), 0., 1.));
}

vec3 FishTrack (float t)
{
  return 0.75 * tankSize * vec3 (cos (0.2 * t),
     0.1 + 0.9 * sin (0.037 * t), sin (0.2 * t));
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

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  vec3 ro, rd;
  float el, az, zmFac;
  tankSize = vec3 (5., 2.5, 3.);
  FishPM (tCur);
  fishLen = 0.2 * tankSize.x;
  angTail = 0.1 * pi * sin (5. * tCur);
  angFin = pi * (0.8 + 0.1 * sin (2.5 * tCur));
  posMth = 1.04 + 0.01 * sin (5. * tCur);
  zmFac = clamp (3. + 0.4 * tCur, 3., 7.);
  waterDisp = 0.1 * tCur * vec3 (1., 0., 1.);
  cloudDisp = 4. * tCur * vec3 (1., 0., 1.);
  el = pi * (-0.25 + 0.7 * SmoothBump (0.25, 0.75, 0.25,
     mod (0.071 * tCur + 0.4 * pi, 2. * pi) / (2. * pi)));
  az = 0.6 * pi * (1. - 0.5 * abs (el)) * sin (0.21 * tCur);
  vec2 vf = vec2 (el, az);
  vec2 cf = cos (vf);
  vec2 sf = sin (vf);
  vuMat = mat3 (1., 0., 0., 0., cf.x, - sf.x, 0., sf.x, cf.x) *
     mat3 (cf.y, 0., sf.y, 0., 1., 0., - sf.y, 0., cf.y);
  rd = normalize (vec3 (uv, zmFac)) * vuMat;
  ro = vec3 (0., 0., -40.) * vuMat;
  sunDir = normalize (vec3 (-0.2, 0.2, -1.)) * vuMat;
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
