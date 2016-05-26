// Shader downloaded from https://www.shadertoy.com/view/ls3XDn
// written by shadertoy user dr2
//
// Name: Lost Egg
// Description: Recently discovered in Dnipropetrovsk. Perhaps a missing Imperial Egg?
// "Lost Egg" by dr2 - 2016
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
  const vec3 e = vec3 (0.1, 0., 0.);
  vec3 g;
  float s;
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d;
  d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrRnd2BoxDf (vec3 p, vec3 b, float r)
{
  vec3 d = abs (p) - b;
  return max (length (max (d.xz, 0.)) - r, d.y);
}

float PrSphDf (vec3 p, float r)
{
  return length (p) - r;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrEllips2ShDf (vec3 p, vec2 r, float w)
{
  vec3 ra;
  float s;
  s = min (r.x, r.y);
  ra = r.xyx;
  return max ((s + w) * (length (p / (ra + w)) - 1.), -
     (s - w) * (length (p / (ra - w)) - 1.));
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

mat3 trainMat[3], trMat;
vec3 trainPos[3], trPos, qHit, ltDir;
vec2 sOpen;
float tCur, dstFar, egRad, egLen, egOpen, wThk, szFac, tRun, tCyc, trVel,
   trkRad, trkLin, trkWid;
int idObj;
bool sigStop;

const int idEng = 1, idCar = 2, idWheel = 3, idLamp = 4, idRail = 5,
   idPlat = 6, idSig = 7, idBase = 8, idEg = 9, idCap = 10, idArm = 11,
   idInt = 12;

float BgShd (vec3 ro, vec3 rd)
{
  float c, f;
  if (rd.y >= 0.) {
    ro.xz += 2. * tCur;
    c = 0.6 + 0.3 * pow (1. - rd.y, 8.);
    f = Fbm2 (0.1 * (ro.xz + rd.xz * (100. - ro.y) / max (rd.y, 0.001)));
    c = mix (c, 1., clamp (0.1 + 0.8 * f * rd.y, 0., 1.));
  } else {
    c = 0.1;
  }
  return c;
}

float EngDf (vec3 p, float dMin)
{
  vec3 q;
  float wRad, d, aw, a, sx;
  wRad = 0.8;
  q = p;  q -= vec3 (0., -0.2, 0.5);
  d = PrCapsDf (q, 1., 2.);
  d = max (d, - (q.z + 1.7));
  q = p;  q.z = abs (q.z - 0.85);  q -= vec3 (0., -0.2, 1.8);
  d = min (d, PrCylDf (q, 1.05, 0.05));
  q = p;  q -= vec3 (0., -1.3, -0.25);
  d = min (d, PrBoxDf (q, vec3 (1., 0.1, 3.2)));
  q = p;  q -= vec3 (0., -1.4, 3.);
  d = min (d, PrBoxDf (q, vec3 (1.1, 0.2, 0.07)));
  q.x = abs (q.x);  q -= vec3 (0.6, 0., 0.1);
  d = min (d, PrCylDf (q, 0.2, 0.1));
  q = p;  q -= vec3 (0., 0.01, -1.75);
  d = min (d, max (max (PrBoxDf (q, vec3 (1., 1.4, 0.6)),
     - PrBoxDf (q - vec3 (0., 0., -0.2), vec3 (0.95, 1.3, 0.65))),
     - PrBoxDf (q - vec3 (0., 0.7, 0.), vec3 (1.1, 0.4, 0.5))));
  q.x = abs (q.x);  q -= vec3 (0.4, 1., 0.4);
  d = max (d, - PrBoxDf (q, vec3 (0.35, 0.15, 0.3)));
  q = p;  q -= vec3 (0., -2.4, -1.75);
  d = min (d, max (PrCylDf (q, 4., 0.65), - (q.y - 3.75)));
  q = p;  q -= vec3 (0., -0.5, -3.15);
  d = min (d, PrBoxDf (q, vec3 (1., 0.7, 0.3)));
  q = p;  q -= vec3 (0., -1.4, -3.5);
  d = min (d, PrCylDf (q.xzy, 0.4, 0.03));
  q = p;  q -= vec3 (0., 1.1, 2.15);
  d = min (d, PrCylDf (q.xzy, 0.3, 0.5));
  q = p;  q -= vec3 (0., 1.5, 2.15);
  d = min (d, max (PrCylDf (q.xzy, 0.4, 0.15), - PrCylDf (q.xzy, 0.3, 0.2)));
  q = p;  q -= vec3 (0., 0.8, 0.55);
  d = min (d, PrCapsDf (q.xzy, 0.3, 0.2));
  q = p;  q.x = abs (q.x);  q -= vec3 (1., -0.2, 0.85);
  d = min (d, PrBoxDf (q, vec3 (0.05, 0.1, 1.8)));
  q = p;  q.x = abs (q.x);  q -= vec3 (1., -0.2, -1.75);
  d = min (d, min (d, PrBoxDf (q, vec3 (0.05, 0.1, 0.6))));
  q = p;  q.x = abs (q.x);  q -= vec3 (1., -0.2, -3.15);
  d = min (d, PrBoxDf (q, vec3 (0.05, 0.1, 0.3)));
  if (d < dMin) { dMin = d;  idObj = idEng; }
  q = p;  q.xz = abs (q.xz);  q -= vec3 (trkWid - 0.12, -1.4, 1.1);
  d = PrCylDf (q.zyx, wRad, 0.1);
  if (d < dMin) {
    d = min (max (min (d, PrCylDf (q.zyx - vec3 (0.,0., -0.07), wRad + 0.05, 0.03)),
       - PrCylDf (q.zyx, wRad - 0.1, 0.12)), PrCylDf (q.zyx, 0.15, 0.10));
    if (d < dMin) { dMin = d;  idObj = idWheel; }
    q = p;  q.x = abs (q.x);  q -= vec3 (trkWid - 0.17, -1.4, 1.1 * sign (q.z));
    aw = - (trVel / wRad) * tRun;
    q.yz = q.yz * cos (aw) * vec2 (1., 1.) + q.zy * sin (aw) * vec2 (-1., 1.);  
    a = floor ((atan (q.y, q.z) + pi) * 8. / (2. * pi) + 0.5) / 8.;
    q.yz = q.yz * cos (2. * pi * a) * vec2 (1., 1.) +
       q.zy * sin (2. * pi * a) * vec2 (-1., 1.);
    q.z += 0.5 * wRad;
    d = PrCylDf (q, 0.05, 0.5 * wRad);
    q = p;
    sx = sign (q.x);
    q.x = abs (q.x);  q -= vec3 (trkWid + 0.08, -1.4, 0.);
    aw -= 0.5 * pi * sx; 
    q.yz -= 0.3 * vec2 (cos (aw), - sin (aw));
    d = min (d, PrCylDf (q, 0.04, 1.2));
    q.z = abs (q.z);  q -= vec3 (-0.1, 0., 1.1);
    d = min (d, PrCylDf (q.zyx, 0.06, 0.15));
    q = p;  q.z = abs (q.z);  q -= vec3 (0., -1.4, 1.1);
    d = min (d, PrCylDf (q.zyx, 0.1, trkWid - 0.1));
    if (d < dMin) { dMin = d;  idObj = idWheel; }
  }
  q = p;  q -= vec3 (0., -0.2, 3.5);
  d = PrCylDf (q, 0.2, 0.1);
  if (d < dMin) { dMin = d;  idObj = idLamp; }
  return dMin;
}

float CarDf (vec3 p, float dMin)
{
  vec3 q;
  float wRad, d;
  wRad = 0.35;
  q = p;
  d = max (max (PrBoxDf (q, vec3 (1.3, 1.4, 2.8)),
     - PrBoxDf (q, vec3 (1.2, 1.3, 2.7))), - PrBoxDf (q, vec3 (0.5, 1., 2.9)));
  q.z = abs (q.z);  q -= vec3 (0., 0.6, 1.2);
  d = max (d, - PrBoxDf (q, vec3 (1.4, 0.7, 1.1)));
  q = p;  q.y -= -2.35;
  d = min (d, max (PrCylDf (q, 4., 2.8), - (q.y - 3.75)));
  q = p;  q.z = abs (q.z);  q -= vec3 (0., -0.2, 2.75);
  d = min (d, PrCylDf (q.zyx, 0.05, 0.5));
  q = p;  q.y -= -1.6;
  d = min (d, PrBoxDf (q, vec3 (0.8, 0.3, 2.)));
  q = p;  q.z = abs (q.z);  q -= vec3 (0., -1.4, 2.9);
  d = min (d, PrCylDf (q.xzy, 0.4, 0.03));
  q = p;  q.x = abs (q.x);  q -= vec3 (1.3, -0.2, 0.);
  d = min (d, PrBoxDf (q, vec3 (0.05, 0.1, 2.8)));
  if (d < dMin) { dMin = d;  idObj = idCar; }
  q = p;  q.xz = abs (q.xz);  q -= vec3 (trkWid - 0.12, -1.85, 1.1);
  d = min (min (PrCylDf (q.zyx, wRad, 0.1),
     PrCylDf (q.zyx - vec3 (0.,0., -0.07), wRad + 0.05, 0.03)),
     PrCylDf (q.zyx, 0.15, 0.10));
  q.x -= 0.1;
  d = max (d, - (PrCylDf (q.zyx, 0.2, 0.05)));
  q = p;  q.z = abs (q.z);  q -= vec3 (0., -1.85, 1.1);
  d = min (d, PrCylDf (q.zyx, 0.1, trkWid - 0.15));
  if (d < dMin) { dMin = d;  idObj = idWheel; }
  return dMin;
}

float TrackDf (vec3 p, float dMin)
{
  vec3 q;
  float gHt, d;
  gHt = 2.8;
  q = p;
  q.z -= 0.5 * trkLin * clamp (p.z / (0.5 * trkLin), -1., 1.);
  q.x = abs (length (q.xz) - trkRad);
  q -= vec3 (trkWid - 0.03, - gHt + 0.41, 0.);
  d = length (max (abs (q.xy) - vec2 (0.09, 0.17), 0.));
  if (d < dMin) { dMin = d;  idObj = idRail; }
  q = p;  q -= vec3 (trkRad - trkWid - 2., - gHt + 0.6, 0.);
  d = max (PrBoxDf (q, vec3 (trkWid, 0.4, 14.)), 0.5 * (abs (q.z) - 7.) + q.y);
  if (d < dMin) { dMin = d;  idObj = idPlat;  qHit = q; }
  q = p;  q -= vec3 (trkRad - trkWid - 2.5, 0.8, 6.);
  d = PrCylDf (q.xzy, 0.15, 3.);
  if (d < dMin) { dMin = d;  idObj = idRail; }
  q.y -= 3.;  d = PrSphDf (q, 0.35);
  if (d < dMin) { dMin = d;  idObj = idSig; } 
  q = p;  q.y -= - (gHt + 0.1);
  d = max (PrRnd2BoxDf (q, vec3 (trkWid + 2.5, 0.1,
     0.5 * trkLin + trkWid + 2.5), trkRad), - PrCylDf (q.xzy, 0.7 * trkRad, 0.2));
  if (d < dMin) { dMin = d;  idObj = idBase;  qHit = q; } 
  return dMin;
}

float EgDf (vec3 p, float dMin)
{
  vec3 q, qq;
  float d, dr, a;
  q = p.xzy;
  q.xy = q.xy * sOpen.x + q.yx * (2. * step (0., q.y) - 1.) * sOpen.y *
     vec2 (-1., 1.);
  q.y = abs (q.y) - 1.25 * (egRad + wThk) * sOpen.y;
  a = 0.5 * (atan (q.z, - q.x) / pi + 1.);
  dr = wThk *
      (1. - (1. - SmoothBump (0.4, 0.6, 0.1, fract (3. * abs (q.y) / egLen))) *
      (1. - SmoothBump (0.1, 0.2, 0.06, fract (10. * a))));
  d = PrEllips2ShDf (q, vec2 (egRad + dr, egLen + dr), wThk);
  if (sOpen.y != 0.) d = max (d, - q.y);
  if (d < dMin) { dMin = d;  idObj = idEg;  qHit = q; }
  qq = q;
  q.y -= egLen - 0.3 * egRad;
  d = max (PrCapsDf (q.xzy, 0.4 * egRad, 0.005 * egRad), 0.25 * egRad - q.y);
  if (d < dMin) { dMin = d;  idObj = idCap;  qHit = qq; }
  q = qq - vec3 (0.6 * egRad, 0.2, -0.2);
  d = PrBoxDf (q, vec3 (0.4 * egRad, 0.05, 0.03));
  if (d < dMin) { dMin = d;  idObj = idArm;  qHit = q; }
  return dMin;
}

float ObjDf (vec3 p)
{
  float dMin, d;
  dMin = dstFar;
  dMin = EgDf (p, dMin);
  dMin /= szFac;
  p /= szFac;
  dMin = EngDf (trainMat[0] * (p - trainPos[0]), dMin);
  dMin = CarDf (trainMat[1] * (p - trainPos[1]), dMin);
  dMin = CarDf (trainMat[2] * (p - trainPos[2]), dMin);
  dMin = TrackDf (p, dMin);
  dMin *= szFac;
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 120; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.0002 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  int idObjT;
  idObjT = idObj;
  const vec3 e = vec3 (0.0001, -0.0001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  idObj = idObjT;
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  int idObjT;
  idObjT = idObj;
  sh = 1.;
  d = 0.02;
  for (int j = 0; j < 30; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 20. * h / d));
    d += min (0.06, 3. * h);
    if (h < 0.001) break;
  }
  idObj = idObjT;
  return 0.6 + 0.4 * sh;
}

bool ShTie ()
{
  vec2 s;
  float nt, gap, a, b;
  bool shTie;
  shTie = false;
  b = abs (qHit.z) - (0.5 * trkLin + 2.);
  nt = 2.;
  gap = trkLin / nt;
  s = qHit.xz;
  s.x = abs (s.x) - trkRad;  s.y = mod (s.y + 0.5 * gap, gap) - 0.5 * gap;
  s = abs (s) - vec2 (trkWid + 0.5, 0.4);
  if (max (s.x, s.y) < 0. && b < 0.) shTie = true;
  nt = 12.;
  s = qHit.zx;  s.x -= 0.5 * trkLin * sign (s.x);  s.y = abs (s.y);
  a = floor ((atan (s.y, s.x) + pi) * nt / (2. * pi) + 0.5) / nt;
  s.yx = Rot2D (s.yx, 2. * pi * a);
  s.x += trkRad;  s = abs (s) - vec2 (trkWid + 0.5, 0.4);
  if (max (s.x, s.y) < 0. && b > 0.) shTie = true;
  return shTie;
}

float BrickSurfShd (vec2 p)
{
  vec2 q, iq;
  q = p;
  iq = floor (q);
  if (2. * floor (iq.y / 2.) != iq.y) {
    q.x += 0.5;  iq = floor (q);
  }
  q = smoothstep (0.015, 0.025, abs (fract (q + 0.5) - 0.5));
  return 0.5 + 0.5 * q.x * q.y;
}

float BrickShd (vec3 p, vec3 n)
{
  return dot (vec3 (BrickSurfShd (p.zy), BrickSurfShd (p.xz), BrickSurfShd (p.xy)),
     abs (n));
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, vn, qh;
  float dstHit, a, s, t, sh;
  const vec4 colEg1 = vec4 (0.6, 0.6, 0., 0.5), colEg2 = vec4 (0.2, 0.4, 0.6, 0.2);
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    qh.xz = qHit.xz / egRad;
    qh.y = qHit.y / egLen;
    if (idObj == idEg || idObj == idCap) {
      a = 0.5 * (atan (qHit.z, - qHit.x) / pi + 1.);
      s = dot (qh, qh);
    }
    if (idObj == idEg) {
      if (s > wThk + 1.01) {
        t = 1.1 * qh.y;
        objCol = mix (colEg1, colEg2, step (t, SmoothBump (0.135, 0.165, 0.015,
           fract (10. * a + 0.02 * cos (50. * t)))));
      } else {
        if (s > 1.01) {
          vn = VaryNf (30. * qh.xzy, vn, 1.);
          objCol = mix (vec4 (0.5, 0.1, 0.1, 0.5), vec4 (0.1, 0.4, 0.1, 0.2),
             clamp (10. * Fbm2 (vec2 (40. * pi * a, 30. * qh.y)) - 9., 0., 1.));
        } else idObj = idInt;
      }
    } else if (idObj == idCap) {
      if (s > wThk + 1.) {
        t = length (qh.xz) - 0.12;
        t = 50. * t * t;
        objCol = mix (colEg1, colEg2, step (t, SmoothBump (0.1, 0.2, 0.015,
           fract (10. * a))));
      } else idObj = idInt;
    } else if (idObj == idArm) {
      idObj = idInt;
    } else if (idObj == idBase) {
      if (vn.y > 0. && ShTie ()) objCol = vec4 (0.4, 0., 0., 1.);
      else objCol = mix (vec4 (0., 0., 0.2, 0.2), vec4 (0.2, 0.2, 0., 0.5),
         SmoothBump (0.5, 0.9, 0.1, Fbm2 (0.7 * qHit.xz)));
    } else if (idObj == idEng || idObj == idCar) objCol = vec4 (0.7, 0.7, 0., 1.);
    else if (idObj == idWheel) objCol = vec4 (0.9, 0.9, 0.9, 1.);
    else if (idObj == idRail) objCol = vec4 (0.8, 0.8, 0.8, 1.);
    else if (idObj == idPlat)
       objCol = vec4 (vec3 (0.5, 0.1, 0.1) * BrickShd (1.5 * qHit, vn), 1.);
    else if (idObj == idLamp) objCol = vec4 (1., 0.2, 0.2, -1.);
    else if (idObj == idSig)
       objCol = sigStop ? vec4 (1., 0., 0., -1.) : vec4 (0., 1., 0., -1.);
    if (objCol.a >= 0.) {
      if (idObj == idInt) {
        vn = VaryNf (30. * qh.xzy, vn, 1.);
        objCol = vec4 (0., 0.3, 0., 0.01);
      }
      sh = ObjSShadow (ro, ltDir);
      col = objCol.rgb * (0.2 +
         0.8 * sh * max (0., max (dot (vn, ltDir), 0.))) +
         objCol.a * sh * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
      if (idObj < idEg) {
        rd = reflect (rd, vn);
        col = mix (col, vec3 (0.8) * BgShd (ro, rd),
            0.2 * (1. - pow (dot (rd, vn), 5.)));
      }
    } else col = objCol.rgb * 0.5 * (1. - dot (rd, vn));;
    col = pow (clamp (col, 0., 1.), vec3 (0.7));
  } else col = vec3 (0.1, 0., 0.);
  return col;
}

void TrainCarPM (float s)
{
  float a, ca, sa;
  s = mod (s, 2. * (pi * trkRad + trkLin));
  if (s < trkLin) {
    trPos = vec3 (trkRad, 0., s - 0.5 * trkLin);
    ca = 1.;  sa = 0.;
  } else if (s < trkLin + pi * trkRad) {
    a = (s - trkLin) / trkRad;
    ca = cos (a);  sa = sin (a);
    trPos = vec3 (trkRad * ca, 0., 0.5 * trkLin + trkRad * sa);
  } else if (s < 2. * trkLin + pi * trkRad) {
    trPos = vec3 (- trkRad, 0., 1.5 * trkLin + pi * trkRad - s);
    ca = -1.;  sa = 0.;
  } else {
    a = (s - (pi * trkRad + 2. * trkLin)) / trkRad + pi;
    ca = cos (a);  sa = sin (a);
    trPos = vec3 (trkRad * ca, 0., - 0.5 * trkLin + trkRad * sa);
  }
  trMat = mat3 (ca, 0., - sa, 0., 1., 0., sa, 0., ca);
}

void TrSetup ()
{
  float tPause, tHalt;
  trkRad = 20.;
  trkLin = 20.;
  trkWid = 1.42;
  trVel = 6.;
  tCyc = 2. * (pi * trkRad + trkLin) / trVel;
  tPause = 0.4 * tCyc;
  tCyc += tPause;
  tRun = mod (tCur, tCyc);
  tHalt = trkLin / trVel;
  sigStop = (tRun < tHalt + 0.8 * tPause);
  if (tRun > tHalt + tPause) tRun = tRun - tPause;
  else if (tRun > tHalt) tRun = tHalt;
  TrainCarPM (trVel * tRun);
  trainPos[0] = trPos;  trainMat[0] = trMat;
  TrainCarPM (trVel * tRun - 7.);
  trainPos[1] = trPos;  trainMat[1] = trMat;
  TrainCarPM (trVel * tRun - 13.4);
  trainPos[2] = trPos;  trainMat[2] = trMat;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd;
  vec2 canvas, uv, ori, ca, sa;
  float el, az, zmFac, tc;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  szFac = 0.055;
  dstFar = 20.;
  TrSetup ();
  egRad = 1.7;
  egLen = 2.;
  wThk = 0.04;
  tc = mod (tCur / tCyc + 0.77, 1.);
  egOpen = SmoothBump (0.08, 0.92, 0.05, tc);
  sOpen = vec2 (cos (0.6 * egOpen), sin (0.6 * egOpen));
  zmFac = 5. + 4. * egOpen;
  el = pi * (0.15 + 0.03 * egOpen - 0.1 * SmoothBump (0.38, 0.62, 0.05, tc));
  az = -0.5 * pi;
  if (mPtr.z > 0.) {
    el -= pi * mPtr.y;
    az -= 2. * pi * mPtr.x;
  }
  ori = vec2 (clamp (el, -0.05 * pi, 0.4 * pi), clamp (az, - 1.5 * pi, pi));
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = vec3 (0., 0., -10.) * vuMat;
  rd = normalize (vec3 (uv, zmFac)) * vuMat;
  ltDir = normalize (vec3 (1., 2., -1.)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
