// Shader downloaded from https://www.shadertoy.com/view/4tXGDH
// written by shadertoy user dr2
//
// Name: Atlantis
// Description: Follow the fish and see where it goes.
// "Atlantis" by dr2 - 2015
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

float Fbm2 (vec2 p)
{
  float s = 0.;
  float a = 1.;
  for (int i = 0; i < 6; i ++) {
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

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
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

float PrTorusDf (vec3 p, float ri, float rc)
{
  vec2 q = vec2 (length (p.xy) - rc, p.z);
  return length (q) - ri;
}

int idObj;
mat3 fishMat, swmMat;
vec3 qHit, sunDir, fishPos, swmPos;
float tCur, teRingO, teRingI, swmVel, fishLen, angTail, angFin, posMth;
const float dstFar = 100.;
const int idBase = 1, idPlat = 2, isShel = 3, idFrm = 4, idDway = 5,
  idTwr = 6, idBrg = 7, idBrCab = 8, idRdw = 9, idGem = 10, idFBdy = 21,
  idTail = 22, idFin = 23, idEye = 24;

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float AngQnt (float a, float s1, float s2, float nr)
{
  return (s1 + floor (s2 + a * (nr / (2. * pi)))) * (2. * pi / nr);
}

vec3 TrackPath (float t)
{
  vec3 p;
  vec2 tr;
  float a, d, r, tO, tI, tR, rGap;
  bool rotStep;
  tO = 0.5 * pi * teRingO / swmVel;
  tI = 0.5 * pi * teRingI / swmVel;
  rGap = teRingO - teRingI;
  tR = rGap / swmVel;
  rotStep = false;
  p.y = 3.;
  float ti[9];
  ti[0] = 0.;  ti[1] = ti[0] + tO;  ti[2] = ti[1] + tR;  ti[3] = ti[2] + tI;
  ti[4] = ti[3] + tR;  ti[5] = ti[4] + tO;  ti[6] = ti[5] + tR;
  ti[7] = ti[6] + tI;  ti[8] = ti[7] + tR;
  float tCyc = ti[8];
  float aDir = 2. * mod (floor (t / tCyc), 2.) - 1.;
  t = mod (t, tCyc);
  r = teRingO;
  tr = vec2 (0.);
  if (t < ti[1]) {
    rotStep = true;
    a = (t - ti[0]) / (ti[1] - ti[0]);
  } else if (t < ti[2]) {
    tr.y = teRingO - rGap * (t - ti[1]) / (ti[2] - ti[1]);
  } else if (t < ti[3]) {
    rotStep = true;
    a = 1. + (t - ti[2]) / (ti[3] - ti[2]);
    r = teRingI;
  } else if (t < ti[4]) {
    tr.x = - (teRingI + rGap * (t - ti[3]) / (ti[4] - ti[3]));
  } else if (t < ti[5]) {
    rotStep = true;
    a = 2. + (t - ti[4]) / (ti[5] - ti[4]);
  } else if (t < ti[6]) {
    tr.y = - teRingO + rGap * (t - ti[5]) / (ti[6] - ti[5]);
  } else if (t < ti[7]) {
    rotStep = true;
    a = 3. + (t - ti[6]) / (ti[7] - ti[6]);
    r = teRingI;
  } else if (t < ti[8]) {
    tr.x = teRingI + rGap * (t - ti[7]) / (ti[8] - ti[7]);
  }
  if (rotStep) {
    a *= 0.5 * pi * aDir;
    p.xz = r * vec2 (cos (a), sin (a));
  } else {
    if (aDir < 0.) tr.y *= -1.;
    p.xz = tr;
  }
  return p;
}

void FishPM (float t)
{
  vec3 fpF, fpB, vel;
  float a, ca, sa, dt;
  dt = 0.4;
  fpF = TrackPath (t + dt);
  fpB = TrackPath (t - dt);
  fishPos = 0.5 * (fpF + fpB);
  vel = (fpF - fpB) / (2. * dt);
  a = atan (vel.z, vel.x) - 0.5 * pi;
  ca = cos (a);  sa = sin (a);
  fishMat = mat3 (ca, 0., - sa, 0., 1., 0., sa, 0., ca);
}

float Terrain (vec2 p)
{
  const mat2 qRot = mat2 (1.6, -1.2, 1.2, 1.6);
  vec2 q, t, ta, v;
  float wAmp, pRough, ht;
  wAmp = 4.;  pRough = 5.;
  q = p * 0.05;
  ht = 0.;
  for (int j = 0; j < 5; j ++) {
    t = q + 2. * Noisefv2 (q) - 1.;
    ta = abs (sin (t));
    v = (1. - ta) * (ta + abs (cos (t)));
    v = pow (1. - v, vec2 (pRough));
    ht += (v.x + v.y) * wAmp;
    q *= 2. * qRot;  wAmp *= 0.2;  pRough = 0.8 * pRough + 0.2;
  }
  return ht;
}

float GrndHt (vec2 p)
{
  float hb = 0.;
  float hf = 1.;
  float su = length (p) / 50.;
  if (su < 1.) {
    su *= su;
    hf = 0.3 + 0.7 * su;
    hb = -11. * (1. - su * su * su * su);
  }
  su = abs (max ((SmoothMin (abs (p.x), abs (p.y), 0.5) - 2.) / 6., 0.));
  su = SmoothMin (su, abs (length (p) - teRingO) / 6., 1.);
  if (su < 1.2) {
    su *= su;
    hf = SmoothMin (hf, 0.3 + 0.7 * su, 0.2);
    hb = SmoothMin (hb, - 11. * (1. - su) +
       0.5 * Noisefv2 (0.8 * p) + 2. * Fbm2 (0.2 * p), 0.5);
  }
  return hf * Terrain (p) + hb + 5.;
}

float GrndRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, h, s, sLo, sHi;
  s = 0.;
  sLo = 0.;
  dHit = dstFar;
  for (int j = 0; j < 150; j ++) {
    p = ro + s * rd;
    h = p.y - GrndHt (p.xz);
    if (h < 0.) break;
    sLo = s;
    s += max (0.05, 0.5 * h);
    if (s > dstFar) break;
  }
  if (h < 0.) {
    sHi = s;
    for (int j = 0; j < 6; j ++) {
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

float FishDf (vec3 p, float dHit)
{
  vec3 q;
  float d, wr, tr, u;
  dHit /= 0.75;
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

float BridgeDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  float wRd = 1.;
  q = p;  q.y -= -1.;
  d = PrBoxDf (q, vec3 (wRd, 0.1, 21.));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idRdw; }
  q = p;  q.x = abs (q.x);  q.xy -= vec2 (wRd - 0.1, 2.);
  q.z = mod (q.z + 0.75, 1.5) - 0.75;
  d = PrCylDf (q.xzy, 0.07, 3.);
  q = p;  q.y -= 2.;
  d = max (d, PrBoxDf (q, vec3 (wRd, 3., 9.8)));
  q = p;  q.y -= 13.;
  d = max (d, - PrCylDf (q.yzx, 13., 1.01));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBrCab; }
  q = p;  q.x = abs (q.x);  q.xy -= vec2 (wRd - 0.1, 13.);
  d = max (PrTorusDf (q.yzx, 0.1, 13.), q.y + 8.);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBrCab; }
  q = p;  q.xz = abs (q.xz);  q -= vec3 (wRd - 0.1, 1.5, 13.5);
  q.yz = Rot2D (q.yz, -0.25 * pi);
  d = PrCylDf (q, 0.1, 4.5);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBrCab; }
  q = p;  q.z = abs (q.z);  q.yz -= vec2 (0., 10.2);
  d = PrBoxDf (q, vec3 (wRd + 0.2, 5., 0.2));
  q.y -= -0.3;
  d = max (d, - PrBoxDf (q, vec3 (wRd - 0.1, 4.8, 0.21)));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBrg; }
  return dHit;
}

float DwayDf (vec3 p, float h1, float h2, float h3)
{
  return max (length (p.yz -
     vec2 (h1 * clamp (p.y / h1, -1., 1.), 0.)) - h2, abs (p.x) - h3);
}

float CageDf (vec3 p, float dHit)
{
  const float rad = 6., hLen = 8., wg = 0.5, ww = 0.03, wThk = 0.05,
     doorHt = 2., doorWd = 1.5;
  vec3 q, c1, c2;
  vec2 qo;
  float d, ds, dd, a;
  q = p;
  q.y -= hLen;
  c1 = vec3 (0., hLen * clamp (q.y / hLen, -1., 1.), 0.);
  c2 = vec3 (0., (hLen - wThk) * clamp (q.y / (hLen + wThk), -1., 1.), 0.);
  d = max (max (length (q - c1) - rad,
     - (length (q - c2) - (rad - wg))), - q.y);
  a = atan (q.z, - q.x);
  q = p;  q.y -= hLen + 0.5 * rad;
  q.xz = Rot2D (q.xz, AngQnt (a, 0.5, 0., 8.));
  q.x += 0.5 * rad;
  ds = PrBoxDf (q, vec3 (0.5 * rad, hLen + 0.5 * rad, 2. * ww));
  q = p;  q.y = mod (q.y - 1.5, 3.) - 1.5;
  d = max (d, min (ds, PrBoxDf (q, vec3 (rad, 2. * ww, rad))));
  q = p;
  qo = Rot2D (q.xz, AngQnt (a, 0.5, 0., 4.));
  q.xz = qo;  q.xy -= vec2 (- rad, hLen + 1.2 * doorHt);
  dd = DwayDf (q, doorHt, doorWd, 0.2 * rad);
  d = max (d, - dd);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idFrm; }
  q = p;  q.y -= hLen;
  d = max (max (max (max (length (q - c1) - (rad - 0.4 * wg),
     - (length (q - c2) - (rad - 0.6 * wg))), - q.y), - ds), - dd);
  q = p;  q.y -= 2. * hLen + rad;
  d = max (d, - PrCylDf (q.xzy, 0.5 * rad, 0.2 * rad));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = isShel; }
  q = p;  q.xz = qo;  q.xy -= vec2 (-0.98 * rad, hLen + 1.2 * doorHt);
  d = max (max (max (DwayDf (q, doorHt, doorWd, 0.1 * rad),
     - DwayDf (q, doorHt - ww, doorWd - ww, 0.1 * rad + wThk)),
     - (q.y + 2. * doorHt - ww - wThk)), - (q.y + 1.2 * doorHt));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idDway; }
  return dHit;
}

float CentStrucDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  q = p;  q.xz = abs (q.xz) - vec2 (4.);  q.y -= -5.;
  d = max (max (PrSphDf (q, 5.), - PrSphDf (q, 4.7)), - min (4. - q.y, q.y));
  q.y -= 2.3;
  d = max (d, - min (PrCylDf (q.yzx, 1., 6.), PrCylDf (q, 1., 6.)));
  q.y += 0.5;
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBase; }
  q = p;  q.y -= -1.;
  d = PrTorusDf (q.xzy, 0.4, 8.5);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idPlat; }
  d = PrCylDf (q.xzy, 8.5, 0.1);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idPlat; }
  q = p;  q.y -= -9.;
  q.xz = Rot2D (q.xz, 0.25 * pi);
  dHit = CageDf (q, dHit);
  return dHit;
}

float CornStrucDf (vec3 p, float dHit)
{
  vec3 q;
  float d, a;
  q = p;  q.y -= -5.;
  d = max (max (PrSphDf (q, 5.), - PrSphDf (q, 4.7)), - min (3.9 - q.y, q.y));
  q.y -= 2.3;
  d = max (d, - min (PrCylDf (q.yzx, 1., 6.), PrCylDf (q, 1., 6.)));
  q.y -= 1.5;
  d = min (d, PrCylDf (q.xzy, 3., 0.1));
  q.y += 2.;
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idBase; }
  q = p;  q.y -= 1.;
  d = max (max (PrCapsDf (q.xzy, 2.5, 3.), - PrCapsDf (q.xzy, 2.3, 3.)), -2.2 - q.y);
  q = p;  q.y -= 7.;
  d = min (d, max (PrCapsDf (q.xzy, 0.7, 2.), -1. - q.y));
  q = p;  q.y -= 0.;
  q.xz = Rot2D (q.xz, AngQnt (0.5 + atan (q.z, - q.x), 0., 0., 4.));
  q.x += 2.;
  d = max (d, - DwayDf (q, 2., 1., 2.4));
  q = p;  q.y -= 4.;
  q.xz = Rot2D (q.xz, 0.25 * pi);
  d = max (d, - min (PrCylDf (q.yzx, 1., 3.), PrCylDf (q, 1., 3.)));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idTwr; }
  return dHit;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float d;
  float dHit = dstFar;
  q = p;
  q.xz = Rot2D (q.xz, AngQnt (atan (q.z, - q.x), 0., 0.5, 4.));
  q.x += 20.;
  dHit = BridgeDf (q, dHit);
  q = p;  q.xz = abs (q.xz) - vec2 (10.);  q.y -= -1.;
  d = max (max (PrCylDf (q.xzy, 10.9, 0.1), - PrCylDf (q.xzy, 9.1, 0.5)),
     max (- q.x, - q.z));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idRdw; }
  q = p;
  dHit = CentStrucDf (q, dHit);
  q.y -= 0.1; 
  d = PrSphDf (q, 1.);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idGem; }
  q = p;  q.xz = abs (q.xz) - vec2 (20.);
  dHit = CornStrucDf (q, dHit);
  q.y -= -0.1; 
  d = PrSphDf (q, 0.7);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idGem; }
  dHit = FishDf (fishMat * (p - fishPos), dHit);
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

vec4 ObjCol (vec3 n)
{
  vec3 col;
  float spec;
  spec = 1.;
  if (idObj == idBase) {
    if (qHit.y < -1.) col = vec3 (0.2, 0.3, 0.2);
    else if (qHit.y > -0.6 || n.y < 0.) col = vec3 (0.1, 0.5, 0.1);
    else col = mix (vec3 (0.5, 0.5, 0.), vec3 (0., 0.5, 0.5),
       floor (mod (32. * atan (qHit.z, - qHit.x) / (2. * pi), 2.)));
  } else if (idObj == idPlat) col = vec3 (0.9, 0.9, 0.1);
  else if (idObj == isShel) col = vec3 (1., 1., 1.);
  else if (idObj == idFrm) col = vec3 (0.8, 0.8, 0.);
  else if (idObj == idDway) col = vec3 (0.8, 0.3, 0.);
  else if (idObj == idTwr) col = vec3 (0.9, 0.7, 0.6);
  else if (idObj == idBrg) col = vec3 (1., 1., 0.2);
  else if (idObj == idBrCab) col = vec3 (1., 0.7, 0.);
  else if (idObj == idRdw) col = vec3 (0.2, 0.15, 0.15);
  else if (idObj == idGem) {
    col = vec3 (1., 0.1, 0.1) * (0.6 + 0.4 * cos (5. * tCur));
    spec = 5.;
  }
  return vec4 (col, spec);
}

vec4 FishCol (vec3 n)
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
  return vec4 (col, 1.);
}

float TurbLt (vec3 p, vec3 n, float t)
{
  vec2 q = vec2 (dot (p.yzx, n), dot (p.zxy, n));
  q = 2. * pi * mod (q, 1.) - 256.;
  t += 11.;
  float c = 0.;
  vec2 qq = q;
  for (int k = 1; k <= 7; k ++) {
    float tt = t * (1. + 1. / float (k));
    vec2 a1 = tt - qq;
    vec2 a2 = tt + qq;
    qq = q + tt + vec2 (cos (a1.x) + sin (a2.y), sin (a1.y) + cos (a2.x));
    c += 1. / length (q / vec2 (sin (qq.x), cos (qq.y)));
  }
  return clamp (pow (abs (1.25 - abs ((1./6.) + 40. * c)), 8.), 0., 1.);
}

vec3 GrndCol (vec3 p, vec3 n)
{
  const vec3 gCol1 = vec3 (0.3, 0.25, 0.25), gCol2 = vec3 (0.1, 0.1, 0.1),
     gCol3 = vec3 (0.3, 0.3, 0.1), gCol4 = vec3 (0., 0.5, 0.);
  vec3 col, wCol, bCol;
  float a = 1. + atan (p.x, p.z) / pi;
  vec2 s = sin (0.35 * p.xz);
  float f = Noisefv2 (vec2 (12. * a, 7. * (p.y + 2.3 * sin (14. * a)))) +
     Noisefv2 (p.zy * vec2 (1., 4.3 + 1.4 * s.y)) +
     Noisefv2 (p.xy * vec2 (1.7, 4.4 + 1.7 * s.x));
  wCol = mix (gCol1, gCol2, clamp (0.3 * f, 0., 1.));
  bCol = mix (gCol3, gCol4, clamp (0.7 * Noisefv2 (p.xz) - 0.3, 0., 1.));
  col = mix (wCol, bCol, smoothstep (0.4, 0.7, n.y));
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, colg, vn;
  float dstHit, dstGrnd, bBri, da;
  int idObjT;
  vec3 uwatCol = vec3 (0., 0.09, 0.06);
  bool hitGrnd;
  dstGrnd = GrndRay (ro, rd);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit < dstGrnd) {
    hitGrnd = false;
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj < idGem) vn = VaryNf (3. * ro , vn, 5.);
    objCol = (idObj >= idFBdy) ? FishCol (vn) : ObjCol (vn);
    bBri = 0.2 * (1. +
       max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.)) +
       0.5 * max (0., max (dot (vn, sunDir), 0.));
    col = objCol.rgb * (bBri + 0.2 * objCol.a *
       pow (max (0., dot (sunDir, reflect (rd, vn))), 32.));
  } else {
    hitGrnd = true;
    dstHit = dstGrnd;
    if (dstGrnd < dstFar) {
      ro += dstGrnd * rd;
      vn = VaryNf (1.2 * ro, GrndNf (ro, dstGrnd), 2.);
      col = GrndCol (ro, vn) * (0.5 + 0.5 * max (0., max (dot (vn, sunDir), 0.)));
    } else col = uwatCol;
  }
  da = min (dstHit, dstFar) / dstFar;
  da =  exp (- 7. * da * da);
  colg = col;
  colg.g += 0.5 * max (colg.r, colg.b);
  colg.rgb *= vec3 (0.2, 0.5, 0.2);
  if (hitGrnd || idObj != idGem && idObj != idEye) col = colg;
  else if (idObj == idGem) col = mix (colg, col, da);
  col *= 1. + 2. * TurbLt (0.01 * ro, normalize (smoothstep (0.1, 0.9, abs (vn))),
     0.2 * tCur);
  return sqrt (clamp (mix (uwatCol, col, da), 0., 1.));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  vec3 ro, rd, vd;
  float az, el, dist, zmFac;
  sunDir = normalize (vec3 (cos (0.1 * tCur), 1.2, sin (0.1 * tCur)));
  teRingO = 80.;
  teRingI = 27.;
  swmVel = 5.;
  fishLen = 1.;
  angTail = 0.15 * pi * sin (6. * tCur);
  angFin = pi * (0.8 + 0.1 * sin (3. * tCur));
  posMth = 1.04 + 0.01 * sin (5. * tCur);
  FishPM (tCur);
  swmPos = fishPos;
  swmMat = fishMat;
  FishPM (tCur + 1.2);
  fishPos.y -= 2.;
  ro = swmPos;
  ro.y -= 1.;
  zmFac = 1.5;
  rd = normalize (vec3 (uv, zmFac)) * swmMat;
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
