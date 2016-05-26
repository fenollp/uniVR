// Shader downloaded from https://www.shadertoy.com/view/XllGDr
// written by shadertoy user dr2
//
// Name: Icy Moon
// Description: Who knows what they will find?
// "Icy Moon" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

vec2 Hashv2f (float p)
{
  return fract (sin (p + cHashA4.xy) * cHashM);
}

vec4 Hashv4f (float p)
{
  return fract (sin (p + cHashA4) * cHashM);
}

float Noiseff (float p)
{
  float i, f;
  i = floor (p);  f = fract (p);
  f = f * f * (3. - 2. * f);
  vec2 t = Hashv2f (i);
  return mix (t.x, t.y, f);
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
mat3 objMat;
vec3 objPos, qHit, sunDir;
float tCur;
const float dstFar = 200.;
vec3 satnPos = vec3 (-5., 25., 50.), satnCol = vec3 (1., 0.9, 0.5);
const int idBase = 1, idPlat = 2, isShel = 3, idFrm = 4, idDway = 5,
  idTwr = 6, idBrg = 7, idBrCab = 8, idRdw = 9, idGem = 10, idSat = 11,
  idRng = 12, idRefl = 13;

float IceHt (vec3 p)
{
  p *= 0.3;
  float ht = 0.;
  const float wb = 1.414;
  float w = 1.5 * wb;
  for (int j = 0; j < 3; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x);
    ht += w * abs (Noisefv3 (p) - 0.5);
  }
  return 0.5 * ht;
}

vec3 IceNf (vec3 p, float d)
{
  float ht = IceHt (p);
  vec2 e = vec2 (max (0.01, 0.001 * d * d), 0.);
  return normalize (vec3 (ht - IceHt (p + e.xyy), e.x, ht - IceHt (p + e.yyx)));
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float AngQnt (float a, float s1, float s2, float nr)
{
  return (s1 + floor (s2 + a * (nr / (2. * pi)))) * (2. * pi / nr);
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

float SatnDf (vec3 p, float dHit)
{
  const float dz = 6., radO = 9., radI = 6.5;
  vec3 q;
  float d;
  q = p;
  q -= satnPos; 
  q.yz = Rot2D (q.yz, -0.2 * pi);
  q.xz = Rot2D (q.xz, -0.2 * pi);
  d = PrSphDf (q, 5.);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idSat; }
  q.z += dz;
  d = PrTorusDf (q, radI, radO);
  q.z -= 2. * dz;
  d = max (d, PrTorusDf (q, radI, radO));
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idRng; }
  return dHit;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float d;
  float dHit = dstFar;
  dHit = SatnDf (p, dHit);
  p = objMat * (p - objPos);
  q = p;
  q.xz = Rot2D (q.xz, AngQnt (atan (q.z, - q.x), 0., 0.5, 4.));
  q.x += 20.;
  dHit = BridgeDf (q, dHit);
  q = p;  q.xz = abs (q.xz) - vec2 (10.);  q.y -= -1.;
  d = max (max (PrCylDf (q.xzy, 10.9, 0.1), - PrCylDf (q.xzy, 9.1, 0.11)),
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
  q = p;
  q.y -= -6.2;
  d = PrCylDf (q.xzy, 100., 2.);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = idRefl; }
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
  d = 0.2;
  for (int i = 0; i < 30; i ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.2;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec4 ObjCol (vec3 n)
{
  vec3 col;
  float spec;
  spec = 1.;
  if (idObj == idBase) {
    if (qHit.y < -1.) col = vec3 (0.1, 0.2, 0.1);
    else if (qHit.y > -0.6 || n.y < 0.) col = vec3 (0.1, 0.5, 0.1);
    else col = mix (vec3 (1., 1., 0.), vec3 (0., 1., 1.),
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
    col = vec3 (1., 0.1, 0.1);
    spec = 5.;
  } else if (idObj == idSat) col = satnCol * vec3 (1., 0.9, 0.9) *
     clamp (1. - 0.2 * Noiseff (12. * qHit.z), 0., 1.);
  else if (idObj == idRng) col = satnCol *
     (1. - 0.4 * SmoothBump (9.3, 9.5, 0.01, length (qHit.xy)));
  if (idObj == idSat || idObj == idRng) spec = 0.02;
  return vec4 (col, spec);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  vec4 objCol;
  float dstHit, sh;
  int idObjT;
  bool reflRay;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  reflRay = false;
  if (dstHit < dstFar && idObj == idRefl) {
    ro += rd * dstHit;
    rd = reflect (rd, IceNf (objMat * (ro - objPos), dstHit));
    ro += 0.01 * rd;
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    reflRay = true;
  }
  if (dstHit >= dstFar) col = vec3 (0., 0., 0.02) + 0.03 * satnCol *
     pow (clamp (dot (rd, normalize (satnPos - ro)), 0., 1.), 128.);
  else {
    idObjT = idObj;
    ro += rd * dstHit;
    vn = ObjNf (ro);
    if (idObj != idSat && idObj != idRng) vn = objMat * vn;
    idObj = idObjT;
    if (idObj == idBase && qHit.y < -1.) vn = VaryNf (2. * qHit, vn, 5.);
    if (idObj == idRdw) vn = VaryNf (5. * qHit, vn, 1.);
    objCol = ObjCol (vn);
    sh = ObjSShadow (ro, sunDir);
    float bBri = 0.2 +
       0.2 * max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.) +
       0.5 * max (0., max (dot (vn, sunDir), 0.)) * sh;
    if (idObj == idGem) bBri *= 1.2 + 0.2 * sin (10. * tCur);
    col = objCol.rgb * (bBri + 0.5 * objCol.a *
       pow (max (0., dot (sunDir, reflect (rd, vn))), 32.));
    if (reflRay) col = vec3 (0.1) + 0.8 * col;
  }
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  vec3 ro, rd, vd;
  float az, el, dist;
  sunDir = normalize (vec3 (cos (0.4 * tCur), 1., sin (0.4 * tCur)));
  rd = normalize (vec3 (uv, 4.));
  az = 0.1 * pi * (1. - 2. * SmoothBump (15., 45., 10., mod (tCur, 60.)));
  vec3 ca = cos (vec3 (0., az, 0.));
  vec3 sa = sin (vec3 (0., az, 0.));
  objMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  dist = 100.;
  ro = vec3 (0., 0., - dist);
  objPos = ro * objMat - ro;
  vd = normalize (vec3 (objPos - ro));
  rd.xz = Rot2D (rd.xz, atan (- vd.x, vd.z));
  rd.yz = Rot2D (rd.yz, 0.01 * pi);
  ro.y += 0.1 * dist;
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
