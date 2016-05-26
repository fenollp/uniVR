// Shader downloaded from https://www.shadertoy.com/view/XllGRn
// written by shadertoy user dr2
//
// Name: Visible Clock
// Description: The mechanics of timekeeping; when the clock is open time speeds up to show all the gears rotating (there is an optional second hand - see the source).
//    
// "Visible Clock" by dr2 - 2014
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

//#define SHOW_SEC   // uncomment to show second hand (may crash some browsers)

const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

float Hashfv2 (vec2 p)
{
  return fract (sin (dot (p, cHashA3.xy)) * cHashM);
}

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
  for (int i = 0; i < 5; i ++) {
    s += a * Noisefv2 (p);
    a *= 0.5;
    p *= 2.;
  }
  return s;
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

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

int idObj;
vec3 qHit, ltDir;
float tCur, todCur, tCyc, tSeq, aVelFac, axDist, wlGap, fadeCase, openMech;
bool visCase;
const float ntM1 = 36., ntM2 = 12., ntM3 = 48., ntM4 = 12.;
#ifdef SHOW_SEC
const float ntS1 = 32., ntS2 = 16., ntS3 = 36., ntS4 = 12.,
   ntS5 = 60., ntS6 = 12., ntS7 = 32., ntS8 = 16.;
#endif
const float rtFacB = (7./32.), ttWid = 0.35;
const int idBody = 10, idGearS = 11, idGearB = 12, idHandH = 13,
   idHandM = 14, idHandS = 15, idAxH = 16, idAxM = 17, idAxS = 18,
   idAxF = 19, idAxB = 20, idCase = 21, idDial = 22, idRing = 23, idFoot = 24;
const float dstFar = 100.;
const float pi = 3.14159;

float GearDf (vec3 p, float rtFac, float nth, float aRot, float tWid, float wlThk,
   float dHit, int idGear)
{
  float nsp = 8.;
  float rad = rtFac * nth;
  float d, a;
  vec3 q = p;
  vec2 s = vec2 (abs (length (q.xz) - (rad - 1.5 * tWid)) - 2. * tWid,
     abs (q.y) - wlThk);
  d = min (max (s.x, s.y), 0.) + length (max (s, 0.));
  d = min (d, max (length (q.xz) - 5. * wlThk, abs (q.y) - wlThk));
  q.zx = Rot2D (q.zx, aRot);
  vec3 qq = q;
  float g = atan (q.z, - q.x);
  a = 2. * pi / nth;
  q.xz = Rot2D (q.xz, a * floor (g / a + 0.5));
  d = max (d, - (rad - 1.5 * tWid - tWid + clamp (2. * abs (q.z) - abs (q.x) - tWid,
     q.x, q.x + 2. * tWid)));
  q = qq;
  a = 2. * pi / nsp;
  q.xz = Rot2D (q.xz, a * floor (g / a + 0.5));
  q.x += 0.5 * rad - 0.5 * tWid;
  d = min (d, PrBoxDf (q, vec3 (0.5 * rad - 2. * tWid, wlThk, 0.03 * rad)));
  if (d < dHit) { dHit = d;  idObj = idGear;  qHit = q; }
  return dHit;
}

float GearTrainDf (vec3 p, float dHit)
{
  vec3 q;
  float d, angRot, rtFac;
  float wlThk = 0.15;
  angRot = - todCur * aVelFac;
  rtFac = rtFacB;
  p.y -= 4. * wlGap;
  q = p;  q.x -= axDist;
  dHit = GearDf (q, rtFac, ntM1, angRot, ttWid, wlThk, dHit, idGearB);
  angRot *= - ntM1 / ntM2;
  q = p;  q.x += axDist;
  dHit = GearDf (q, rtFac, ntM2, angRot + pi / ntM2, ttWid, wlThk, dHit, idGearS);
  wlThk *= 0.9;
  rtFac = (4./5.) * rtFacB;
  p.y += 2. * wlGap;
  q = p;  q.x += axDist;
  dHit = GearDf (q, rtFac, ntM3, angRot, ttWid, wlThk, dHit, idGearB);
  angRot *= - ntM3 / ntM4;
  q = p;  q.x -= axDist;
  dHit = GearDf (q, rtFac, ntM4, angRot + pi / ntM4, ttWid, wlThk, dHit, idGearS);
#ifdef SHOW_SEC
  wlThk *= 0.9;
  rtFac = rtFacB;
  p.y += 2. * wlGap;
  q = p;  q.x -= axDist;
  dHit = GearDf (q, rtFac, ntS1, angRot, ttWid, wlThk, dHit, idGearB);
  angRot *= - ntS1 / ntS2;
  q = p;  q.x += axDist;
  dHit = GearDf (q, rtFac, ntS2, angRot + pi / ntS2, ttWid, wlThk, dHit, idGearS);
  rtFac = rtFacB;
  p.y += 2. * wlGap;
  q = p;  q.x += axDist;
  dHit = GearDf (q, rtFac, ntS3, angRot, ttWid, wlThk, dHit, idGearB);
  angRot *= - ntS3 / ntS4;
  q = p;  q.x -= axDist;
  dHit = GearDf (q, rtFac, ntS4, angRot + pi / ntS4, ttWid, wlThk, dHit, idGearS);
  wlThk *= 0.9;
  rtFac = (2./3.) * rtFacB;
  p.y += 2. * wlGap;
  q = p;  q.x -= axDist;
  dHit = GearDf (q, rtFac, ntS5, angRot, ttWid, wlThk, dHit, idGearB);
  q = p;  q.x += axDist;
  angRot *= - ntS5 / ntS6;
  dHit = GearDf (q, rtFac, ntS6, angRot + pi / ntS6, 0.65 * ttWid, wlThk, dHit, idGearS);
  wlThk *= 0.9;
  rtFac = rtFacB;
  p.y += 2. * wlGap;
  q = p;  q.x += axDist;
  dHit = GearDf (q, rtFac, ntS7, angRot, ttWid, wlThk, dHit, idGearB);
  angRot *= - ntS7 / ntS8;
  q = p;  q.x -= axDist;
  dHit = GearDf (q, rtFac, ntS8, angRot + pi / ntS8, ttWid, wlThk, dHit, idGearS);
#endif
  return 0.5 * dHit;
}

float AxleDf (vec3 p, float rad, float len, float dHit, int idAx)
{
  vec3 q = p.xzy;
  float d;
  d = PrCylDf (q, rad, len);
  if (d < dHit) { dHit = d;  idObj = idAx;  qHit = q; }  
  return dHit;
}

float FrameDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  float axRad = 0.3;
  p.y -= 4. * wlGap;
  q = p;  q.xy -= vec2 (axDist, 0.5 * wlGap);
  dHit = AxleDf (q, 1.5 * axRad, 1.4 * wlGap, dHit, idAxH);
  p.y += wlGap;
  q = p;  q.x += axDist;
  dHit = AxleDf (q, axRad, 1.8 * wlGap, dHit, idAxB);
  p.y += wlGap;
  q = p;  q.x += axDist;
  dHit = AxleDf (q, axRad, 0.6 * wlGap, dHit, idAxB);
  p.y += 2. * wlGap;
  q = p;  q.xy -= vec2 (axDist, 3. * wlGap);
  dHit = AxleDf (q, axRad, 4. * wlGap, dHit, idAxM);
#ifdef SHOW_SEC
  p.y += wlGap;
  q = p;  q.x += axDist;
  dHit = AxleDf (q, axRad, 1.8 * wlGap, dHit, idAxB);
  p.y += wlGap;
  q = p;  q.x -= axDist;
  dHit = AxleDf (q, axRad, 0.8 * wlGap, dHit, idAxB);
  p.y += wlGap;
  q = p;  q.x -= axDist;
  dHit = AxleDf (q, axRad, 1.8 * wlGap, dHit, idAxB);
  p.y += wlGap;
  q = p;  q.x -= axDist;
  dHit = AxleDf (q, axRad, 0.8 * wlGap, dHit, idAxB);
  p.y += wlGap;
  q = p;  q.x += axDist;
  dHit = AxleDf (q, axRad, 1.8 * wlGap, dHit, idAxB);
#else
  p.y += 5. * wlGap;
#endif
  p.y += wlGap;
  q = p;  q.xy -= vec2 (axDist, 6.4 * wlGap);
  dHit = AxleDf (q, 0.5 * axRad, 7.2 * wlGap, dHit, idAxS);
  q = p;  q.xy -= vec2 (- axDist, 5. * wlGap);
  dHit = AxleDf (q, 0.5 * axRad, 6.1 * wlGap, dHit, idAxF);
  p.y -= 5. * wlGap;
  q = p;  q.y = abs (q.y) - 5.5 * wlGap;
  d = PrBoxDf (q, vec3 (axDist - 1.8 * axRad, 0.3 * axRad, 0.7 * axRad));
  q.x = abs (q.x) - axDist;
  d = min (d, PrCylDf (q.xzy, 2. * axRad, 0.3 * axRad));
  if (d < dHit) { dHit = d;  idObj = idAxB;  qHit = q; }
  return dHit;
}

float HandsDf (vec3 p, float dHit)
{
  vec3 q;
  float d, angRot, angRotS, angRotM, angRotH;
  p.x -= axDist;
  angRot = todCur * aVelFac;
  angRotH = angRot - 0.5 * pi;
  q = p;
  q.xz = q.xz * cos (angRotH) * vec2 (1., 1.) + q.zx * sin (angRotH) * vec2 (-1., 1.);
  q.xy -= vec2 (-2., 5.7 * wlGap);
  d = PrCylDf (q.zyx, 0.5 * ttWid, 2.);
  if (d < dHit) { dHit = d;  idObj = idHandH;  qHit = q; }
  angRot *= (ntM1 / ntM2) * (ntM3 / ntM4);
  angRotM = angRot - 0.5 * pi;
  q = p;
  q.xz = q.xz * cos (angRotM) * vec2 (1., 1.) + q.zx * sin (angRotM) * vec2 (-1., 1.);
  q.xy -= vec2 (-2.5, 6.5 * wlGap);
  d = PrCylDf (q.zyx, 0.5 * ttWid, 2.5);
  if (d < dHit) { dHit = d;  idObj = idHandM;  qHit = q; }
#ifdef SHOW_SEC
  angRot *= (ntS1 / ntS2) * (ntS3 / ntS4) * (ntS5 / ntS6) * (ntS7 / ntS8);
  angRotS = angRot - 0.5 * pi;
  q = p;
  q.xz = q.xz * cos (angRotS) * vec2 (1., 1.) + q.zx * sin (angRotS) * vec2 (-1., 1.);
  q.xy -= vec2 (-2.7, 7.3 * wlGap);
  d = PrCylDf (q.zyx, 0.3 * ttWid, 3.2);
  if (d < dHit) { dHit = d;  idObj = idHandS;  qHit = q; }
#endif
  return dHit;
}

float CaseDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  p.y -= -0.8;
  q = p;
  d = PrBoxDf (q, vec3 (13.5, 4.4, 8.5));
  if (d < dHit) { dHit = d;  idObj = idCase;  qHit = q; }
  q.xy -= vec2 (axDist, 4.3);
  d = max (PrCylDf (q.xzy, 7.4, 0.4), - PrCylDf (q.xzy, 7., 0.41));
  if (d < dHit) { dHit = d;  idObj = idRing;  qHit = q; }
  d = PrCylDf (q.xzy, 7., 0.1);
  if (d < dHit) { dHit = d;  idObj = idDial;  qHit = q; }
  q = p;  q.xy = abs (q.xy) - vec2 (10., 2.4);  q.z -= 8.7;
  d = PrCylDf (q, 1., 0.5);
  if (d < dHit) { dHit = d;  idObj = idFoot;  qHit = q; }
  return dHit;
}

float ObjDf (vec3 p)
{
  float dHit = dstFar;
  if (visCase) dHit = CaseDf (p, dHit);
  else dHit = GearTrainDf (p, dHit);
  dHit = FrameDf (p, dHit);
  dHit = HandsDf (p, dHit);
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
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
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

vec3 WoodCol (vec3 p, vec3 n)
{
  p *= 5.;
  float f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.zx * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return mix (vec3 (0.4, 0.2, 0.1), vec3 (0.3, 0.1, 0.), f);
}

vec4 ObjCol (vec3 n)
{
  vec4 col4;
  if (idObj == idCase) {
    if (n.y < 0.99 || length (qHit.xz - vec2 (-8., -3.)) > 3.)
       col4 = vec4 (WoodCol (qHit, n), 1.);
    else col4 = vec4 (0.1, 0.07, 0., 0.1) *
       (0.5 + 0.5 * Noisefv2 (50. * qHit.xz));
  } else if (idObj == idDial) {
    col4 = vec4 (0.7, 1., 1., 1.);
    float a = 6. * (atan (qHit.z, - qHit.x) / pi + 1.);
    if (abs (mod (a + 0.5, 1.) - 0.5) < 0.05 &&
       abs (length (qHit.xz) - 5.9) < 0.9) col4 *= 0.1;
  } else if (idObj == idRing) col4 = vec4 (0.2, 0.7, 1., 1.);
  else if (idObj == idGearB) col4 = vec4 (1., 1., 0.5, 1.);
  else if (idObj == idGearS) col4 = vec4 (0.8, 0.8, 0.2, 1.);
  else if (idObj == idAxB) col4 = vec4 (0.6, 0.6, 0.3, 1.);
  else if (idObj == idAxF) col4 = vec4 (0.4, 0.4, 0.3, 1.);
  else if (idObj == idHandH || idObj == idAxH) col4 = vec4 (1., 0.3, 0.2, 1.);
  else if (idObj == idHandM || idObj == idAxM) col4 = vec4 (0.3, 0.2, 1., 1.);
#ifdef SHOW_SEC
  else if (idObj == idHandS || idObj == idAxS) col4 = vec4 (0.3, 1., 0.2, 1.);
#endif
  else if (idObj == idFoot) col4 = vec4 (0.3, 0.2, 0.1, 0.1);
  else col4 = vec4 (0.);
  return col4;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 vn, roo;
  int idObjT;
  float dstHit, dif, ao;
  vec3 colC = vec3 (0., 0., 0.04), colNC = vec3 (0., 0., 0.04);
  roo = ro;
  visCase = true;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  idObjT = idObj;
  if (idObj < 0) dstHit = dstFar;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = ObjCol (vn);
    dif = max (dot (vn, ltDir), 0.);
    ao = ObjAO (ro, vn);
    colC = objCol.xyz * (0.2 * ao * (1. +
       max (dot (vn, - normalize (vec3 (ltDir.x, 0., ltDir.z))), 0.)) +
       max (0., dif) * (dif + ao * objCol.w *
       pow (max (0., dot (ltDir, reflect (rd, vn))), 64.)));
  }
  ro = roo;
  visCase = false;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  idObjT = idObj;
  if (idObj < 0) dstHit = dstFar;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = ObjCol (vn);
    dif = max (dot (vn, ltDir), 0.);
    ao = ObjAO (ro, vn);
    colNC = objCol.xyz * (0.2 * ao * (1. +
       max (dot (vn, - normalize (vec3 (ltDir.x, 0., ltDir.z))), 0.)) +
       max (0., dif) * (dif + ao * objCol.w *
       pow (max (0., dot (ltDir, reflect (rd, vn))), 64.)));
  }
  return sqrt (clamp (mix (colC, colNC, fadeCase), 0., 1.));
}

void SetConfig ()
{
  tCyc = 30.;
  tSeq = mod (tCur, tCyc);
  fadeCase = SmoothBump (5., 25., 2., tSeq);
  openMech = SmoothBump (10., 20., 1., tSeq);
#ifdef SHOW_SEC
  aVelFac = (2. * pi / (12. * 3600.)) * (1. + 99. * step (0.2, openMech));
#else
  aVelFac = (2. * pi / (12. * 3600.)) * (1. + 1999. * step (0.2, openMech));
#endif
  wlGap = 0.7 * (1. + 1.3 * openMech);
  axDist = 4.83;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  todCur = iDate.w;
  float dist = 60.;
  float zmFac = 5.;
  float az = pi;
  float el = 0.5 * pi;
  SetConfig ();
  float dir = (1. - 2. * floor (mod (tCur / (3. * tCyc), 2.)));
  az += dir * 2. * pi * tSeq / tCyc;
  el -= 0.04 * pi * openMech;
  vec2 ca = cos (vec2 (el, az));
  vec2 sa = sin (vec2 (el, az));
  mat3 vuMat = mat3 (1., 0., 0., 0., 1., 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  vec3 rd = vuMat * normalize (vec3 (uv, zmFac));
  vec3 ro = - vuMat * vec3 (0., 0., dist);
  ltDir = vuMat * normalize (vec3 (1., 1., -1.));
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
