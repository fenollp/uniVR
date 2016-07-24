// Shader downloaded from https://www.shadertoy.com/view/Xdc3Wr
// written by shadertoy user dr2
//
// Name: Wedding Cake
// Description: A cake made from two cylinders and some decoration.
// "Wedding Cake" by dr2 - 2015
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
  vec2 t;
  float ip, fp;
  ip = floor (p);
  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  t = Hashv2f (ip);
  return mix (t.x, t.y, fp);
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

float Fbm1 (float p)
{
  float f, a;
  f = 0.;
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    f += a * Noiseff (p);
    a *= 0.5;
    p *= 2.;
  }
  return f;
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
  g = vec3 (Fbmn (p + e.xyy, n) - s, Fbmn (p + e.yxy, n) - s,
     Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d;
  float s;
  d = abs (p) - b;
  s = length (max (d, 0.));
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

float PrRCylDf (vec3 p, float r, float rt, float h)
{
  vec2 dc;
  float dxy, dz;
  dxy = length (p.xy) - r;
  dz = abs (p.z) - h;
  dc = vec2 (dxy, dz) + rt;
  return min (min (max (dc.x, dz), max (dc.y, dxy)), length (dc) - rt);
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  vec2 q = vec2 (length (p.xy) - rc, p.z);
  return length (q) - ri;
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float AngQnt (float a, float s, float nr)
{
  return (s + floor (a * (nr / (2. * pi)))) * (2. * pi / nr);
}

vec3 qHit, ltPos, ltDir;
float tCur, qRad, ltAng, fGlow;
int idObj;
const float dstFar = 40.;
const int idSlab = 1, idCol = 2, idBall = 3, idCand = 4, idBulb = 5,
   idRing = 6, idPlate = 7, idTable = 8, idBWall = 9, idSWall = 10;

float ObjDf (vec3 p)
{
  vec3 q;
  float d, db, dMin, iy, a, aa, da, r, a1, a2;
  dMin = dstFar;
  db = PrBoxDf (p - vec3 (0., -0.3, 0.), vec3 (3., 1.699, 3.));
  p.y -= -2.;
  iy = floor (p.y);
  q = p;
  q.y = mod (q.y, 1.) - 0.2;
  r = 1.4 - 0.2 * iy;
  d = max (PrRCylDf (q.xzy, r, 0.1, 0.2), db);
  if (d < dMin) { dMin = d;  qHit = q;  qRad = r;  idObj = idSlab; }
  q.y -= 0.2;
  d = max (PrTorusDf (q.xzy, 0.03, 0.8 - 0.2 * iy), db);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idRing; }
  da = max (8. - 2. * iy, 1.);
  aa = atan (q.z, q.x);
  a = AngQnt (aa, 0.5, da);
  q.y -= 0.3;
  q.xz -= (1.05 - 0.2 * iy) * vec2 (cos (a), sin (a));
  r = 0.06 + 0.003 * sin (8. * (atan (q.z, q.x) + pi * q.y));
  d = max (min (d, PrCylDf (q.xzy, r, 0.3)), db);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idCol; }
  q.y -= -0.27;
  q.xz = Rot2D (p.xz, pi / da);
  a = AngQnt (aa + pi / da, 0.5, da);
  q.xz -= (1.2 - 0.2 * iy) * vec2 (cos (a), sin (a));
  d = max (min (d, PrSphDf (q, 0.1)), db);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idBall; }
  q = p;
  q.y -= 3.4;
  d = PrTorusDf (q.xzy, 0.03, 0.2);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idRing; }
  q = p;
  q.z += 0.03;
  a1 = 1.24 * pi - 0.05 * pi;
  a2 = a1 + 0.1 * pi;
  dMin = max (dMin, min (1. - q.y, min (dot (q.xz, vec2 (sin (a1), cos (a1))),
     - dot (q.xz, vec2 (sin (a2), cos (a2))))));
  q = p;
  q.y -= 3.67;
  r = 0.07 * (1. + 0.07 * sin (12. * (aa - 1.5 * pi * q.y)));
  d = PrCylDf (q.xzy, r, 0.3);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idCand; }
  q.y -= 0.42;
  d = PrSphDf (q, 0.15);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idBulb; }
  q = p;
  q.y -= -0.03;
  d = PrRCylDf (q.xzy, 1.6, 0.01, 0.03);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idPlate; }
  q = p;
  d = q.y + 0.06;
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idTable; }
  q.y -= -0.1;
  d = min (4. - q.z, 20. + q.z);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idBWall; }
  d = 20. - abs (q.x);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idSWall; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float d, dHit, srd, dda;
  dHit = 0.;
  srd = - sign (rd.y);
  dda = - srd / (rd.y + 0.00001);
  for (int j = 0; j < 200; j ++) {
    p = ro + dHit * rd;
    d = ObjDf (p);
    dHit += min (d, 0.01 + max (0., fract (dda * fract (srd * p.y))));
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
  d = 0.05;
  for (int j = 0; j < 50; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 40. * h / d);
    d += 0.1;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

float GlowCol (vec3 ro, vec3 rd, float dstHit)
{
  vec3 ltDir;
  float ltDist, wGlow;
  wGlow = 0.;
  ltDir = vec3 (0., 2.2, 0.) - ro;
  ltDist = length (ltDir);
  ltDir /= ltDist;
  if (ltDist < dstHit - 0.5)
     wGlow += pow (max (dot (rd, ltDir), 0.), 2048.) / ltDist;
  return clamp (wGlow * fGlow, 0., 1.);
}

vec3 BrickCol (vec2 p)
{
  vec2 q, iq;
  q = p * vec2 (1., 1.67);
  iq = floor (q);
  if (2. * floor (iq.y / 2.) != iq.y) q.x += 0.5;
  q = smoothstep (0.02, 0.04, abs (fract (q + 0.5) - 0.5));
  return (0.5 + 0.5 * q.x * q.y) * vec3 (0.5, 0.55, 0.5);
}

vec3 WoodCol (vec3 p, vec3 n)
{
  float f;
  p *= 4.;
  f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.zx * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return vec3 (1., 0.9, 0.9) * mix (1., 0.8, f);
}

float EvalLight (vec3 ro)
{
 return 0.02 + 0.98 * smoothstep (0., 0.02,
    ltAng - acos (dot (normalize (ltPos - ro), ltDir)));
}

vec3 EvalCol (vec3 ro, vec3 rd, vec3 vn, vec4 col4)
{
  float illum, sh;
  illum = EvalLight (ro);
  sh = 0.3 * illum;
  if (illum > 0.1) sh += 0.7 * illum * (0.2 +
     0.8 * ObjSShadow (ro + 0.01 * vn, ltDir));
  return col4.rgb * (0.025 + sh * max (dot (vn, ltDir), 0.)) +
     sh * col4.a * pow (max (0., dot (ltDir, reflect (rd, vn))), 128.);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 col4;
  vec3 col, wCol, bgCol, vn, rog, rdg;
  float dstHit, dstHitg;
  int idObjT;
  bool hitWall;
  idObj = -1;
  hitWall = false;
  dstHit = ObjRay (ro, rd);
  rog = ro;
  rdg = rd;
  dstHitg = dstHit;
  if (idObj == idBWall) {
    hitWall = true;
    ro += dstHit * rd;
    vn = ObjNf (ro);
    col4 = vec4 (BrickCol (qHit.xy), 0.2);
    wCol = EvalCol (ro, rd, vn, col4);
    rd = reflect (rd, vn);
    ro += 0.1 * rd;
    idObj = -1;
    dstHit = ObjRay (ro, rd);
  }
  if (idObj < 0) dstHit = dstFar;
  idObjT = idObj;
  bgCol = vec3 (0.01);
  if (dstHit >= dstFar) col = bgCol;
  else {
    ro += dstHit * rd;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == idSlab) {
      if (length (qHit.xz) < qRad - 0.08 &&
         abs (qHit.y) < 0.16) {
        col4 = vec4 (0.3, 0.1, 0.1, 0.2);
	vn = VaryNf (50. * qHit, vn, 2.);
      } else {
        col4 = vec4 (1., 1., 1., 0.4);
	vn = VaryNf (100. * qHit, vn, 0.3);
      }
    } else if (idObj == idCol) {
      col4 = vec4 (0.8, 0.8, 0.9, 0.2);
    } else if (idObj == idBall) {
      col4 = vec4 (0., 0.3, 0.7, 0.5);
    } else if (idObj == idCand) {
      col4 = vec4 (0.7, 0.7, 0.3, 0.2);
    } else if (idObj == idBulb) {
      col4 = vec4 (vec3 (0.5, 0., 0.) * fGlow, 1.);
    } else if (idObj == idRing) {
      col4 = vec4 (0.8, 0.8, 0.9, 1.);
    } else if (idObj == idPlate) {
      col4 = vec4 (0.8, 0.8, 0.2, 1.);
    } else if (idObj == idTable) {
      col4 = vec4 (WoodCol (ro, vn), 0.2);
    } else if (idObj == idSWall) {
      col4 = vec4 (BrickCol (qHit.zy), 0.2);
    } else if (idObj == idBWall) {
      col4 = vec4 (BrickCol (qHit.xy), 0.2);
    }
    if (idObj != idBulb) col = EvalCol (ro, rd, vn, col4);
    else col = col4.rgb * (0.7 + 0.3 * EvalLight (ro));
  }
  if (hitWall) col = mix (col, wCol, 0.6);
  col = mix (col, 0.7 * vec3 (1., 0.8, 0.5), 5. * GlowCol (rog, rdg, dstHitg));
  return sqrt (clamp (col, 0., 1.));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec2 canvas, uv, vf, cf, sf;
  vec3 ro, rd;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  ltPos = vec3 (8., 10., -30.) + 3. * vec3 (sin (tCur), cos (tCur), 0.);
  ltDir = normalize (ltPos - vec3 (0., -0.3, 0.));
  ltAng = 0.1 * (0.8 + 0.4 * sin (0.7 * tCur));
  fGlow = 0.3 + 0.6 * Fbm1 (2. * tCur);
  vf = vec2 (0.2, 0.5 * sin (0.3 * tCur));
  cf = cos (vf);
  sf = sin (vf);
  vuMat = mat3 (1., 0., 0., 0., cf.x, - sf.x, 0., sf.x, cf.x) *
     mat3 (cf.y, 0., sf.y, 0., 1., 0., - sf.y, 0., cf.y);
  rd = normalize (vec3 (uv, 5.)) * vuMat;
  ro = vec3 (0., 0., -15.) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
