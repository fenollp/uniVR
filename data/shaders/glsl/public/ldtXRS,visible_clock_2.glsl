// Shader downloaded from https://www.shadertoy.com/view/ldtXRS
// written by shadertoy user dr2
//
// Name: Visible Clock 2
// Description: An update...
// "Visible Clock 2" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  The mechanics of timekeeping; when the clock is open time speeds up
  to show all the gears rotating. This is an improved version that is
  much faster (and less likely to browser-crash) than the original;
  the second hand is now shown by default and the mouse is active. 
*/

const float pi = 3.14159;
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
  vec4 t;
  vec2 ip, fp;
  ip = floor (p);
  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  t = Hashv4f (dot (ip, cHashA3.xy));
  return mix (mix (t.x, t.y, fp.x), mix (t.z, t.w, fp.x), fp.y);
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

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrOBoxDf (vec3 p, vec3 b)
{
  return length (max (abs (p) - b, 0.));
}

float PrRoundBoxDf (vec3 p, vec3 b, float r)
{
  return length (max (abs (p) - b, 0.)) - r;
}

float PrOBox2Df (vec2 p, vec2 b)
{
  return length (max (abs (p) - b, 0.));
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
  vec2 q;
  q = vec2 (length (p.xy) - rc, p.z);
  return length (q) - ri;
}

vec3 ltDir, szCase;
float ntt[12], gRot[6], dstFar, tCur, todCur, tCyc, tSeq, aVelFac, axDist, axRad,
   wlGap, ttWid, hFac1, hFac2, fadeCase, openMech;
int idObj, showCase;
bool visCase;
const int idBody = 10, idGearS = 11, idGearB = 12, idAxH = 13, idAxM = 14,
   idAxS = 15, idAxF = 16, idAxB = 17, idBar = 18, idCase = 19, idRing = 20,
   idFoot = 21;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec2 u;
  float a;
  rd.z *= -1.;
  ro.z *= -1.;
  a = 0.5 * atan (length (rd.xy), rd.z);
  rd = normalize (vec3 (rd.xy * tan (a), 1.));
  u = vec2 (ro.xy + 2. * tCur + rd.xy * (100. - ro.z) /rd.z);
  return mix (mix (vec3 (0.2, 0.2, 0.6), vec3 (1.), 0.7 * Fbm2 (0.1 * u)),
     vec3 (0.3, 0.3, 0.6), smoothstep (0.35 * pi, 0.4 * pi, a));
}

float GearWlDf (vec3 p, float rtFac, float nth, float aRot, float tWid,
   float wlThk, float dMin, int idGear)
{
  vec3 q, qq;
  float nspi, rad, d, a, g, r;
  q = p;
  nspi = 1./8.;
  rad = rtFac * nth;
  r = rad - 1.5 * tWid;
  d = PrOBox2Df (vec2 (length (q.xz) - r, q.y), vec2 (2. * tWid, wlThk));
  q.zx = Rot2D (q.zx, aRot);
  g = atan (q.z, - q.x);
  if (d < dMin) {
    qq = q;
    a = 2. * pi / nth;
    qq.xz = Rot2D (qq.xz, a * floor (g / a + 0.5));
    d = 0.4 * max (d, - (r + clamp (2. * (abs (qq.z) - tWid) - abs (qq.x),
       qq.x - tWid, qq.x + tWid)));
  }
  d = min (d, PrCylDf (q.xzy, 5.2 * wlThk, 2. * wlThk));
  a = 2. * pi * nspi;
  q.xz = Rot2D (q.xz, a * floor (g / a + 0.5));
  q.x += 0.5 * (rad - tWid);
  d = min (d, PrOBoxDf (q, vec3 (0.5 * rad - 2. * tWid, wlThk, 0.03 * rad)));
  if (d < dMin) { dMin = d;  idObj = idGear; }
  return dMin;
}

float GearsDf (vec3 p, float dMin)
{
  vec3 q;
  float d, angRot, rtFac, sx, tw, rtFacB, wlThk, f1, f2;
  int kk;
  wlThk = 0.16;
  rtFacB = (7./32.);
  kk = int (floor (3. - p.y / wlGap));
  if (kk >= 0 && kk < 6) {
    sx = -1.;
    for (int k = 0; k < 6; k ++) {
      sx = - sx;
      wlThk *= 0.92;
      f1 = ntt[2 * k];
      f2 = ntt[2 * k + 1];
      angRot = gRot[k];
      if (k == kk) break;
    }
    rtFac = rtFacB;
    tw = ttWid;
    if (kk == 1) rtFac *= 0.8;
    else if (kk == 4) {
      rtFac *= 0.66667;
      tw *= 0.65;
    }
    q = p;
    q.y = mod (q.y, wlGap) - 0.5 * wlGap;
    q.x -= sx * axDist;
    dMin = GearWlDf (q, rtFac, f1, angRot, ttWid, wlThk, dMin, idGearB);
    angRot = - (f1 / f2) * angRot + pi / f2;
    q.x -= -2. * sx * axDist;
    dMin = GearWlDf (q, rtFac, f2, angRot, tw, wlThk, dMin, idGearS);
  }
  return dMin;
}

float GearsRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float d, dHit, srd, dda;
  srd = - sign (rd.y);
  dda = - srd / (rd.y + 0.00001);
  dHit = PrOBoxDf (ro, vec3 (szCase.x, 3. * wlGap, szCase.z));
  for (int j = 0; j < 200; j ++) {
    p = ro + dHit * rd;
    d = GearsDf (p, dstFar);
    dHit += min (d, wlGap * (0.3 + max (0.,
       fract (dda * fract (srd * p.y / wlGap)))));
    if (d < 0.0001 || dHit > dstFar) break;
  }
  if (d >= 0.0001) dHit = dstFar;
  return dHit;
}

float AxlesDf (vec3 p, float dMin)
{
  vec3 q;
  float d;
  q = p;  q.xy -= vec2 (- axDist, 2. * wlGap);
  d = PrCylDf (q.xzy, axRad, 0.9 * wlGap);
  q = p;  q.xy -= vec2 (- axDist, 1.5 * wlGap);
  d = min (d, PrCylDf (q.xzy, axRad, 0.3 * wlGap));
  q = p;  q.xy -= vec2 (- axDist, 0.);
  d = min (d, PrCylDf (q.xzy, axRad, 0.9 * wlGap));
  q = p;  q.xy -= vec2 (axDist, -0.5 * wlGap);
  d = min (d, PrCylDf (q.xzy, axRad, 0.4 * wlGap));
  q = p;  q.xy -= vec2 (axDist, - wlGap);
  d = min (d, PrCylDf (q.xzy, axRad, 0.9 * wlGap));
  q = p;  q.xy -= vec2 (axDist, -1.5 * wlGap);
  d = min (d, PrCylDf (q.xzy, axRad, 0.4 * wlGap));
  q = p;  q.xy -= vec2 (- axDist, -2. * wlGap);
  d = min (d, PrCylDf (q.xzy, axRad, 0.9 * wlGap));
  if (d < dMin) { dMin = d;  idObj = idAxB; }  
  q = p;  q.y = abs (q.y) - 2.75 * wlGap;
  d = PrOBoxDf (q, vec3 (axDist - 1.8 * axRad, 0.3 * axRad, 0.7 * axRad));
  q.x = abs (q.x) - axDist;
  d = min (d, PrCylDf (q.xzy, 2. * axRad, 0.3 * axRad));
  if (d < dMin) { dMin = d;  idObj = idBar; }
  q = p;  q.xy -= vec2 (- axDist, 0.);
  d = PrCylDf (q.xzy, 0.5 * axRad, 3.05 * wlGap);
  if (d < dMin) { dMin = d;  idObj = idAxF; }  
  return dMin;
}

float HandsDf (vec3 p, float dMin)
{
  vec3 q, pp;
  float d, angRot;
  pp = p;
  p.y -= 2.5 * wlGap;
  q = p;  q.xy -= vec2 (axDist, 0.25 * wlGap);
  d = PrCylDf (q.xzy, 1.5 * axRad, 0.7 * wlGap);
  if (d < dMin) { dMin = d;  idObj = idAxH; }  
  p.y += 2. * wlGap;
  q = p;  q.xy -= vec2 (axDist, 1.5 * wlGap);
  d = PrCylDf (q.xzy, axRad, 2. * wlGap);
  if (d < dMin) { dMin = d;  idObj = idAxM; }  
  p.y += 3. * wlGap;
  q = p;  q.xy -= vec2 (axDist, 3.2 * wlGap);
  d = PrCylDf (q.xzy, 0.5 * axRad, 3.6 * wlGap);
  if (d < dMin) { dMin = d;  idObj = idAxS; }  
  p = pp;
  p.xy -= vec2 (axDist, 0.5 * wlGap);
  angRot = - gRot[0];
  q = p;
  q.xz = Rot2D (q.xz, angRot - 0.5 * pi);
  q.xy -= vec2 (-2., 2.85 * wlGap);
  d = PrCapsDf (q.zyx, 0.5 * ttWid, 2.);
  if (d < dMin) { dMin = d;  idObj = idAxH; }
  angRot *= hFac1;
  q = p;
  q.xz = Rot2D (q.xz, angRot - 0.5 * pi);
  q.xy -= vec2 (-2.5, 3.25 * wlGap);
  d = PrCapsDf (q.zyx, 0.5 * ttWid, 2.5);
  if (d < dMin) { dMin = d;  idObj = idAxM; }
  angRot *= hFac2;
  q = p;
  q.xz = Rot2D (q.xz, angRot - 0.5 * pi);
  q.xy -= vec2 (-2.7, 3.65 * wlGap);
  d = PrCapsDf (q.zyx, 0.3 * ttWid, 3.2);
  if (d < dMin) { dMin = d;  idObj = idAxS; }
  return dMin;
}

float CaseDf (vec3 p, float dMin)
{
  vec3 q;
  float d;
  p.y -= -0.8 + 0.5 * wlGap;
  q = p;
  d = PrRoundBoxDf (q, szCase - 0.5, 0.5);
  if (d < dMin) { dMin = d;  idObj = idCase; }
  q.xy -= vec2 (-8., 4.3);
  d = PrTorusDf (q.xzy, 0.22, 3.2);
  q = p;
  q.xy -= vec2 (axDist, 4.3);
  d = min (d, PrTorusDf (q.xzy, 0.22, 7.2));
  if (d < dMin) { dMin = d;  idObj = idRing; }
  q = p;  q.xy = abs (q.xy) - vec2 (10., 2.4);  q.z -= 8.7;
  d = PrCylDf (q, 1., 0.5);
  if (d < dMin) { dMin = d;  idObj = idFoot; }
  return dMin;
}

float ObjDf (vec3 p)
{
  float dMin;
  dMin = dstFar;
  if (visCase) dMin = CaseDf (p, dMin);
  else dMin = AxlesDf (p, dMin);
  dMin = HandsDf (p, dMin);
  return dMin;
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
  if (d >= 0.001) dHit = dstFar;
  return dHit;
}

float ObjNDf (vec3 p)
{
  float dMin;
  dMin = ObjDf (p);
  if (! visCase) dMin = GearsDf (p, dMin);
  return dMin;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjNDf (p + e.xxx), ObjNDf (p + e.xyy),
     ObjNDf (p + e.yxy), ObjNDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

vec4 ObjCol (vec3 ro)
{
  vec4 objCol;
  vec2 s;
  float a;
  if (idObj == idCase) {
    objCol = vec4 (0.9, 0.9, 1., 1.);
    if (ro.y > 0.) {
      s = ro.xz - vec2 (axDist, 0.);
      if (length (s) < 7.) {
        objCol = vec4 (0.8, 0.8, 0.6, 0.5);
        a = 6. * (atan (s.y, - s.x) / pi + 1.);
        if (abs (mod (a + 0.5, 1.) - 0.5) < 0.05 &&
           abs (length (s.xy) - 5.9) < 0.9) objCol *= 0.1;
      } else if (length (ro.xz - vec2 (-8., 0.)) < 3.) objCol =
         vec4 (0.8, 0.75, 0.8, 0.) * (1. - 0.5 * Noisefv2 (50. * ro.xz));
    }
  } else if (idObj == idRing) objCol = vec4 (0.7, 0.7, 0.1, 1.);
  else if (idObj == idGearB) objCol = vec4 (1., 1., 0.5, 1.);
  else if (idObj == idGearS) objCol = vec4 (0.8, 0.8, 0.2, 1.);
  else if (idObj == idAxB) objCol = vec4 (0.6, 0.6, 0.3, 1.);
  else if (idObj == idAxH) objCol = vec4 (1., 0.3, 0.2, 1.);
  else if (idObj == idAxM) objCol = vec4 (0.3, 0.2, 1., 1.);
  else if (idObj == idAxS) objCol = vec4 (0.3, 1., 0.2, 1.);
  else if (idObj == idAxF || idObj == idBar) objCol = vec4 (0.6, 0.3, 0.2, 1.);
  else if (idObj == idFoot) objCol = vec4 (0.4, 0.4, 0.4, 0.1);
  return objCol;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 vn, roo, col, colC, colNC;
  float dstObj, d, f;
  int idObjT, showMode;
  colC = vec3 (0., 0., 0.2);
  colNC = colC;
  showMode = showCase;
  if (fadeCase == 0.) showMode = 0;
  else if (fadeCase == 1.) showMode = 2;
  if (showMode > 0) {
    roo = ro;
    visCase = true;
    dstObj = ObjRay (ro, rd);
    if (dstObj < dstFar) {
      ro += rd * dstObj;
      idObjT = idObj;
      vn = ObjNf (ro);
      idObj = idObjT;
      objCol = ObjCol (ro);
      colC = objCol.rgb * (0.2 + max (dot (vn, ltDir), 0.) +
         objCol.a * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.));
      if (idObj == idCase && objCol.a > 0.5)
         colC = mix (colC, BgCol (ro, reflect (rd, vn)), 0.15);
    }
    ro = roo;
  }
  if (showMode < 2) {
    visCase = false;
    dstObj = GearsRay (ro, rd);
    idObjT = idObj;
    d = ObjRay (ro, rd);
    if (d < dstObj) {
      dstObj = d;
    } else {
      idObj = idObjT;
    }
    if (dstObj < dstFar) {
      ro += rd * dstObj;
      idObjT = idObj;
      vn = ObjNf (ro);
      idObj = idObjT;
      objCol = ObjCol (ro);
      colNC = objCol.rgb * (0.2 + max (dot (vn, ltDir), 0.) +
         objCol.a * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.));
    }
  }
  if (showMode == 1) col = mix (colNC, colC, fadeCase);
  else col = (showMode == 0) ? colNC : colC;
  return pow (clamp (col, 0., 1.), vec3 (0.8));
}

void SetConfig ()
{
  tCyc = 40.;
  tSeq = mod (tCur, tCyc);
  if (showCase == 1) {
    fadeCase = 1. - SmoothBump (0.15, 0.85, 0.05, tSeq / tCyc);
    openMech = SmoothBump (0.25, 0.75, 0.05, tSeq / tCyc);
  } else if (showCase == 0) {
    fadeCase = 0.;
    openMech = 1.;
  } else {
    fadeCase = 1.;
    openMech = 0.;
  }
  aVelFac = 2. * pi / (12. * 3600.);
  if (showCase < 2) aVelFac *=
     (1. + 69. * SmoothBump (0.4, 0.6, 0.002, tSeq / tCyc));
  wlGap = 1.4 * (1. + 1.3 * openMech);
  szCase = vec3 (13.5, 4.4, 8.5);
  axDist = 4.83;
  axRad = 0.3;
  ttWid = 0.35;
  ntt[0] = 36.; ntt[1] = 12.; ntt[2] = 48.;  ntt[3] = 12.;
  ntt[4] = 32.; ntt[5] = 16.; ntt[6] = 36.;  ntt[7] = 12.;
  ntt[8] = 60.; ntt[9] = 12.; ntt[10] = 32.; ntt[11] = 16.;
  hFac1 = (ntt[0] / ntt[1]) * (ntt[2] / ntt[3]);
  hFac2 = (ntt[4] / ntt[5]) * (ntt[6] / ntt[7]) * (ntt[8] / ntt[9]) *
     (ntt[10] / ntt[11]);
  gRot[0] = - todCur * aVelFac;
  for (int k = 0; k < 5; k ++)
     gRot[k + 1] = - gRot[k] * ntt[2 * k] / ntt[2 * k + 1];
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd, col;
  vec2 canvas, uv, ori, ca, sa;
  float el, az;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  todCur = iDate.w;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  showCase = 1;
  dstFar = 80.;
  az = pi;
  el = 0.5 * pi;
  if (mPtr.z > 0.) {
    az += 3. * pi * mPtr.x;
    el -= pi * mPtr.y;
  }
  el = clamp (el, 0.4 * pi, 0.9 * pi);
  SetConfig ();
  if (showCase == 1) az +=
     (1. - 2. * floor (mod (tCur / (3. * tCyc), 2.))) * 2. * pi * tSeq / tCyc;
  el -= 0.04 * pi * openMech;
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
          mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  rd = vuMat * normalize (vec3 (uv, 4.));
  ro = vuMat * vec3 (0., 0., -50.);
  ltDir = vuMat * normalize (vec3 (1., 0.5, -1.));
  col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
