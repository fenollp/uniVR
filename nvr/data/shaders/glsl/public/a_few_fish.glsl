// Shader downloaded from https://www.shadertoy.com/view/4dtSDs
// written by shadertoy user dr2
//
// Name: A Few Fish
// Description: A few fish and lots of optical effects (mouse enabled)
// "A Few Fish" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

float Fbm2 (vec2 p);
float Noisefv2 (vec2 p);
float Noisefv3 (vec3 p);
float SmoothMin (float a, float b, float r);
float SmoothBump (float lo, float hi, float w, float x);
float Length4 (vec2 p);
vec2 Rot2D (vec2 q, float a);

const float pi = 3.14159;

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d;
  d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
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

vec3 fishP, qHit, sunDir, waterDisp;
float dstFar, tCur, bowlRad, bowlHt, fishLen, angTail, angFin, posMth;
bool inBowl, chkBowl;
int idObj;
const int idVWall = 1, idHWall = 2, idTbl = 3, idBowl = 4, idFBdy = 11,
  idTail = 12, idFin = 13, idEye = 14;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col;
  vec2 p;
  if (rd.y >= 0.) {
    col = vec3 (0.1, 0.2, 0.4) + 0.2 * pow (1. - rd.y, 8.) +
       0.35 * pow (max (dot (rd, sunDir), 0.), 6.);
    col = mix (col, vec3 (1.), clamp (0.1 +
       0.8 * Fbm2 (0.01 * tCur + 3. * rd.xz / max (rd.y, 0.001)) * rd.y, 0., 1.));
  } else {
    p = ro.xz - (ro.y + 2. * bowlRad - 1.) * rd.xz / rd.y;
    col = 0.6 * mix (vec3 (0.4, 0.5, 0.1), vec3 (0.5, 0.6, 0.2),
       Fbm2 (0.11 * p)) * (1. - 0.05 * Noisefv2 (5. * p));
    col = mix (col, vec3 (0.35, 0.45, 0.65), pow (1. + rd.y, 5.));
  }
  return col;
}

vec4 HexGrdCol (vec2 p)
{
  p *= 0.85;
  p.y /= sqrt (0.75);
  p.x += 0.5 * mod (floor (p.y), 2.);
  p = abs ((fract (p) - 0.5));
  return mix (vec4 (0.8, 0.8, 0.6, 0.1), vec4 (0.5, 0.5, 0.4, 0.4),
     smoothstep (0.05, 0.1, abs (p.x + max (p.x, 1.5 * p.y) - 1.)));
}

vec3 WoodCol (vec3 p, vec3 n)
{
  float f;
  p *= 4.;
  f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.zx * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return mix (vec3 (0.7, 0.4, 0.3), vec3 (0.4, 0.25, 0.2), f);
}

float WaterHt (vec3 p)
{
  float ht, w, wb;
  wb = 1.414;
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
  float h;
  const vec2 e = vec2 (0.001, 0.);
  h = WaterHt (p);
  return normalize (vec3 (h - WaterHt (p + e.xyy), e.x, h - WaterHt (p + e.yyx)));
}

float TableDf (vec3 p, float dMin)
{
  vec3 q;
  float d, d1, d2, br, bl, sFac;
  sFac = 2.5;  br = 1.6 * sFac;  bl = 1.1 * sFac;
  p.y -= - 2.2 * sFac - 0.01 * br;
  q = p;  q.y -= - 0.55 * br;
  d = PrCylDf (q.xzy, 0.5 * br, 0.03 * br);
  q = p;  q.y -= - 1.4 * bl;
  d1 = PrCylDf (q.xzy, 0.07 * br, 0.6 * bl);
  q.y -= - 0.6 * bl;
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
  float d, wr, tr, u, dTail;
  q = p;  q.x = abs (q.x);  q -= fishLen * vec3 (0.12, 0.1, 0.9);
  d = PrSphDf (q, 0.05 * fishLen);
  if (d < dMin) { dMin = d;  idObj = idEye;  qHit = q; }
  q = p;
  wr = q.z / fishLen;
  if (wr > 0.5) {
    u = (wr - 0.5) / 0.5;  tr = 0.17 - 0.11 * u * u;
  } else {
    u = clamp ((wr - 0.5) / 1.5, -1., 1.);  u *= u;
    tr = 0.17 - u * (0.33 - 0.13 * u); 
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
  dTail = PrCylDf (q, 0.13 * tr * fishLen, 0.6 * fishLen);
  d = max (dTail, 0.15 * fishLen - q.z);
  if (d < dMin + 0.01 * fishLen) {
    dMin = SmoothMin (dMin, d, 0.01 * fishLen);  idObj = idTail;  qHit = q;
  }
  q.z -= 0.15 * fishLen;
  q.xz = Rot2D (q.xz, angTail);
  d = max (PrCylDf (q, 0.13 * tr * fishLen, 0.6 * fishLen), q.z);
  if (d < dMin) { dMin = d;  idObj = idTail;  qHit = q; }
  q = p;  q.y *= 0.5;  q.z -= -0.75 * fishLen;
  d = max (PrCylDf (q.xzy, 0.022 * fishLen, 0.11 * fishLen), dTail);
  if (d < dMin) { dMin = d;  idObj = idTail;  qHit = 0.2 * q; }
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
  q = p;  q.y -= -2.72 * bowlRad + 11.2;  q.z -= 1.15 * bowlRad;
  d = PrBoxDf (q, vec3 (2.4, 1.33, 0.01) * bowlRad);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idVWall; }
  q = p;  q -= vec3 (0., -2. * bowlRad + 1., 1.2 * bowlRad);
  d = max (PrCylDf (q.xzy, 2.4 * bowlRad, 0.01 * bowlRad), q.z + 0.2);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idHWall; }
  q = p;  q.y -= - bowlHt + 5.1;
  dMin = TableDf (q, dMin);
  return dMin;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, s;
  dMin = dstFar;
  if (chkBowl) dMin = BowlWlDf (p, dMin);
  else if (inBowl) {
    q = p;
    s = 2. * step (fishP.y, q.y) - 1.;
    q.xz = Rot2D (q.xz, s * fishP.z);
    q.xz = Rot2D (q.xz, 2. * pi *
       (floor (5. * atan (q.z, - q.x) / (2. * pi)) + 0.5) / 5.);
    q.x -= fishP.x;
    q.y = abs (q.y - fishP.y) - 0.4 * bowlHt;
    q.yz *= s;
    dMin = FishDf (q, dMin);
  } else dMin = BowlExtDf (p, dMin);
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
  vec4 v;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.1;
  for (int j = 0; j < 30; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 0.05 * d, h));
    d += max (0.2, 0.1 * d);
    if (sh < 0.05) break;
  }
  return 0.5 + 0.5 * sh;
}

vec3 FishCol ()
{
  vec3 col, c1, c2;
  c1 = vec3 (0.1, 0.1, 1.);
  c2 = vec3 (1., 0.2, 0.2);
  qHit *= 20. / fishLen;
  if (idObj == idEye) {
    col = mix (vec3 (0.1, 1., 0.1), vec3 (1., 1., 0.), step (0.5, qHit.z));
  } else if (idObj == idFBdy) {
    col = mix (c2, c1, 0.5 * (1. + sin (4. * qHit.y)));
    if (qHit.y > 2.) col = mix (col, c2,
       SmoothBump (-0.5, 0.5, 0.2, abs (qHit.x)));
    else if (qHit.y < -2.) col = mix (col, c1,
       SmoothBump (-0.5, 0.5, 0.2, abs (qHit.x)));
  } else if (idObj == idTail || idObj == idFin) {
    col = mix (c2, c1, 0.5 * (1. + sin (40. * qHit.y)));
  }
  return col;
}

vec4 ObjCol (vec3 n)
{
  vec4 col;
  if (idObj == idVWall) col = HexGrdCol (qHit.xy);
  else if (idObj == idHWall) col = HexGrdCol (qHit.xz);
  else if (idObj == idTbl) col = vec4 (WoodCol (qHit, n), 0.2);
  else col = vec4 (FishCol (), 1.);
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 roW, rdW, rdd, vn, vnW, colD, colR, col, qHitBowl, reflCol;
  float dstHit, dstBowl, dstBowlW, yLim, dif, sh, frnlFac, eta;
  int idObjT, hitBowl;
  bool bWallHit;
  eta = 1.33;
  yLim = 0.999 * bowlHt;
  inBowl = false;
  chkBowl = true;
  dstBowl = ObjRay (ro, rd);
  hitBowl = -1;
  if (dstBowl < dstFar) {
    hitBowl = idObj;
    qHitBowl = qHit;
  }
  chkBowl = false;
  dstHit = ObjRay (ro, rd);
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
    inBowl = true;
    dstBowl = ObjRay (ro, rd);
    hitBowl = -1;
    if (dstBowl < dstFar) {
      hitBowl = idObj;
      qHitBowl = qHit;
    }
    chkBowl = false;
    dstHit = ObjRay (ro, rd);
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
      chkBowl = false;
      dstHit = ObjRay (ro, rd);
    }
  }
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    chkBowl = false;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = ObjCol (vn);
    dif = max (dot (vn, sunDir), 0.);
    sh = (idObj < idFBdy) ? ObjSShadow (ro, sunDir) : 1.;
    colD = reflCol * (objCol.rgb * (0.2 + 0.8 * dif * sh +
       objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.)));
  } else colD = reflCol * BgCol (ro, rd);
  colR = vec3 (0.);
  reflCol = vec3 (1.);
  if (bWallHit) {
    ro = roW + dstBowlW * rdW;
    rd = (frnlFac > 0.) ? reflect (rdW, vnW) : rdW;
    ro += 0.01 * rd;
    inBowl = false;
    chkBowl = false;
    dstHit = ObjRay (ro, rd);
    if (dstHit < dstFar) {
      ro += rd * dstHit;
      idObjT = idObj;
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
  col = mix (colD, colR, smoothstep (0.98, 1., frnlFac));
  col = pow (clamp (col, 0., 1.), vec3 (0.8));
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd;
  vec2 canvas, uv, ori, ca, sa;
  float el, az, zmFac;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  dstFar = 80.;
  bowlRad = 5.;
  bowlHt = 2.5;
  fishP = vec3 (-0.6 * bowlRad, bowlHt * (-0.2 + 0.4 * sin (0.077 * 0.5 * tCur)),
     0.5 * tCur);
  fishLen = 0.25 * bowlRad;
  angTail = 0.1 * pi * sin (5. * tCur);
  angFin = pi * (0.8 + 0.1 * sin (2.5 * tCur));
  posMth = 1.04 + 0.01 * sin (5. * tCur);
  waterDisp = 0.1 * tCur * vec3 (1., 0., 1.);
  el = 0.;
  az = 0.;
  if (mPtr.z > 0.) {
    zmFac = 5.5;
    el = clamp (el - 3. * mPtr.y, -1.4, 1.1);
    az = clamp (az - 3. * mPtr.x, -1.5, 1.5);
  } else {
    zmFac = clamp (3. + 0.4 * tCur, 3., 7.);
    el -= pi * (-0.15 + 0.6 * SmoothBump (0.25, 0.75, 0.25,
       mod (0.071 * tCur + 0.4 * pi, 2. * pi) / (2. * pi)));
    az += 0.5 * pi * (1. - 0.5 * abs (el)) * sin (0.21 * tCur);
  }
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  rd = vuMat * normalize (vec3 (uv, zmFac));
  ro = vuMat * vec3 (0., 0., -40.);
  sunDir = vuMat * normalize (vec3 (-0.2, 0.2, -1.));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}

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
  vec2 ip, fp;
  ip = floor (p);
  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  t = Hashv4f (dot (ip, cHashA3.xy));
  return mix (mix (t.x, t.y, fp.x), mix (t.z, t.w, fp.x), fp.y);
}

float Noisefv3 (vec3 p)
{
  vec4 t1, t2;
  vec3 ip, fp;
  float q;
  ip = floor (p);
  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  q = dot (ip, cHashA3);
  t1 = Hashv4f (q);
  t2 = Hashv4f (q + cHashA3.z);
  return mix (mix (mix (t1.x, t1.y, fp.x), mix (t1.z, t1.w, fp.x), fp.y),
              mix (mix (t2.x, t2.y, fp.x), mix (t2.z, t2.w, fp.x), fp.y), fp.z);
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

float Length4 (vec2 p)
{
  p *= p;
  p *= p;
  return pow (p.x + p.y, 1./4.);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}
