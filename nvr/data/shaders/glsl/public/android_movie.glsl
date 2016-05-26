// Shader downloaded from https://www.shadertoy.com/view/lsdGRS
// written by shadertoy user dr2
//
// Name: Android Movie
// Description: Family movies anyone (mouse enabled)?
// "Android Movie" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

#define WALL_ILLUM   // (undefine to reduce workload)

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

float PrBox2Df (vec2 p, vec2 b)
{
  vec2 d = abs (p) - b;
  return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrERCylDf (vec3 p, float r, float rt, float h)
{
  vec2 dc;
  float dxy, dz;
  dxy = length (p.xy) - r;
  dz = abs (p.z - 0.5 * h) - h;
  dc = vec2 (dxy, dz) + rt;
  return min (min (max (dc.x, dz), max (dc.y, dxy)), length (dc) - rt);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

vec3 sunDir, qHit, rmSize;
vec2 scrnSize;
float dstFar, tCur, rAngH, rAngL, rAngA, gDisp, scrnUp;
int idObj, idObjMv;
bool walk;

vec3 BgColMv (vec3 ro, vec3 rd)
{
  vec3 col;
  float sd, f;
  if (rd.y > 0.) {
    ro.xz += 2. * tCur;
    sd = max (dot (rd, sunDir), 0.);
    col = vec3 (0.1, 0.2, 0.4) + 0.2 * pow (1. - max (rd.y, 0.), 8.) +
       0.35 * pow (sd, 6.) + 0.65 * min (pow (sd, 256.), 0.3);
    f = Fbm2 (0.05 * (ro.xz + rd.xz * (50. - ro.y) / rd.y));
    col = mix (col, vec3 (1.), clamp (0.1 + 0.8 * f * rd.y, 0., 1.));
  } else {
    sd = - ro.y / rd.y;
    col = mix (vec3 (0.6, 0.5, 0.3),
       0.9 * (vec3 (0.1, 0.2, 0.4) + 0.2) + 0.1, pow (1. + rd.y, 5.));
  }
  return col;
}

float ObjDfMv (vec3 p)
{
  vec3 q, pp;
  vec2 ip;
  float dMin, d, bf, hGap, bFac, ah;
  hGap = 2.5;
  bf = PrBox2Df (p.xz, vec2 (7. * hGap));
  pp = p;
  ip = floor ((pp.xz + hGap) / (2. * hGap));
  pp.xz = pp.xz - 2. * hGap * ip;
  bFac = (ip.x == 0. && ip.y == 0.) ? 1.6 : 1.;
  ah = rAngH * (walk ? sign (1.1 - bFac) : - step (1.1, bFac));
  dMin = dstFar;
  q = pp;
  q.y -= 1.2;
  d = max (PrSphDf (q, 0.85), - q.y);
  q = pp;
  q.y -= 0.2;
  d = min (d, PrERCylDf (q.xzy, 0.9, 0.28, 0.7));
  q = pp;
  q.xz = Rot2D (q.xz, ah);
  q.x = abs (q.x) - 0.4;
  q.y -= 1.9;
  q.xy = Rot2D (q.xy, 0.2 * pi);
  d = min (d, PrERCylDf (q.xzy, 0.06, 0.04, 0.4 * (2. * bFac - 1.)));
  q = pp;
  q.x = abs (q.x) - 1.05;
  q.y -= 1.1;
  q.yz = Rot2D (q.yz, rAngA * (walk ? sign (pp.x) : 1.));
  q.y -= -0.9;
  d = min (d, PrERCylDf (q.xzy, 0.2, 0.15, 0.6));
  q = pp;
  q.x = abs (q.x) - 0.4;
  q.yz = Rot2D (q.yz, - rAngL * sign (pp.x));
  q.y -= -0.8;
  d = min (d, PrERCylDf (q.xzy, 0.25, 0.15, 0.55));
  d = max (d, bf);
  if (d < dMin) { dMin = d;  idObjMv = 1; }
  q = pp;
  q.xz = Rot2D (q.xz, ah);
  q.x = abs (q.x) - 0.4;
  q -= vec3 (0., 1.6 + 0.3 * (bFac - 1.), 0.7 - 0.3 * (bFac - 1.));
  d = PrSphDf (q, 0.15 * bFac);
  d = max (d, bf);
  if (d < dMin) { dMin = d;  idObjMv = 2; }
  d = p.y + 1.;
  if (d < dMin) { dMin = d;  idObjMv = 0;  qHit = p; }
  return dMin;
}

float ObjRayMv (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDfMv (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNfMv (vec3 p)
{
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDfMv (p + e.xxx), ObjDfMv (p + e.xyy),
     ObjDfMv (p + e.yxy), ObjDfMv (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ChqPat (vec3 p, float dHit)
{
  vec2 q, iq;
  float f, s;
  p.z += gDisp;
  q = p.xz + vec2 (0.5, 0.25);
  iq = floor (q);
  s = 0.5 + 0.5 * Noisefv2 (q * 107.);
  if (2. * floor (iq.x / 2.) != iq.x) q.y += 0.5;
  q = smoothstep (0., 0.02, abs (fract (q + 0.5) - 0.5));
  f = dHit / dstFar;
  return s * (1. - 0.9 * exp (-2. * f * f) * (1. - q.x * q.y));
}

vec3 ObjColMv (vec3 rd, vec3 vn, float dHit)
{
  vec3 col;
  if (idObjMv == 1) col = vec3 (0.65, 0.8, 0.2);
  else if (idObjMv == 2) col = vec3 (0.8, 0.8, 0.);
  else col = mix (vec3 (0.4, 0.3, 0.2), vec3 (0.6, 0.5, 0.4),
     (0.5 + 0.5 * ChqPat (qHit / 5., dHit)));
  return col * (0.3 + 0.7 * max (dot (vn, sunDir), 0.)) +
     0.3 * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.);
}

float ObjSShadowMv (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.05;
  for (int j = 0; j < 15; j ++) {
    h = ObjDfMv (ro + rd * d);
    sh = min (sh, 10. * h / d);
    d += 0.2;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 TrackPath (float t)
{
  vec3 p;
  vec2 tr;
  float ti[5], rPath, a, r, tC, tL, tWf, tWb;
  bool rotStep;
  rPath = 28.;
  tC = pi * rPath / 8.;
  tL = 2. * rPath / 5.;
  tWf = 4.;
  tWb = 2.;
  rotStep = false;
  ti[0] = 0.;
  ti[1] = ti[0] + tWf;
  ti[2] = ti[1] + tL;
  ti[3] = ti[2] + tWb;
  ti[4] = ti[3] + tC;
  p.y = 1.;
  t = mod (t, ti[4]);
  tr = vec2 (0.);
  if (t < ti[1]) {
    tr.y = rPath;
  } else if (t < ti[2]) {
    tr.y = rPath - 2. * rPath * (t - ti[1]) / (ti[2] - ti[1]);
  } else if (t < ti[3]) {
    tr.y = - rPath;
  } else {
    rotStep = true;
    a = 1.5 + (t - ti[3]) / (ti[4] - ti[3]);
    r = rPath;
  }
  if (rotStep) {
    a *= pi;
    p.xz = r * vec2 (cos (a), sin (a));
  } else {
    p.xz = tr;
  }
  p.xz -= 2.5;
  return p;
}

vec3 ShowSceneMv (vec3 ro, vec3 rd)
{
  vec3 vn, col, c;
  float dstHit, refl;
  int idObjT;
  dstHit = ObjRayMv (ro, rd);
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObjMv;
    vn = ObjNfMv (ro);
    col = ObjColMv (rd, vn, dstHit);
    idObjMv = idObjT;
    if (idObjMv > 0) {
      rd = reflect (rd, vn);
      ro += 0.01 * rd;
      refl = 0.2 + 0.3 * pow (1. - dot (vn, rd), 4.);
      dstHit = ObjRayMv (ro, rd);
      if (dstHit < dstFar) {
        ro += rd * dstHit;
	c = ObjColMv (rd, ObjNfMv (ro), dstHit);
      } else {
        c = BgColMv (ro, rd);
      }
      col = mix (col, c, refl);
    }
    col *= (0.8 + 0.2 * ObjSShadowMv (ro, sunDir));
  } else {
    col = BgColMv (ro, rd);
  }
  return col;
}

float ObjDf (vec3 p)
{
  vec3 q, qq;
  float d, dMin, bf;
  dMin = dstFar;
  d = p.y;
  if (d < dMin) { dMin = d;  idObj = 10; }
  d = 2. * rmSize.y - p.y;
  if (d < dMin) { dMin = d;  idObj = 11; }
  d = rmSize.x - abs (p.x);
  if (d < dMin) { dMin = d;  idObj = 12; }
  d = p.z + rmSize.z;
  if (d < dMin) { dMin = d;  idObj = 13; }
  d = - p.z + rmSize.z;
  if (d < dMin) { dMin = d;  idObj = 14; }
  bf = PrBox2Df (p.xz - vec2 (0., -1.), vec2 (7.5, 6.));
  q = p;
  q.xz = mod (q.xz + 1.5, 3.) - 1.5;
  q.y -= 0.25 * rmSize.y;
  qq = q;
  qq.y -= 1.2;
  d = max (PrSphDf (qq, 0.85), - qq.y);
  qq = q;
  qq.y -= 0.2;
  d = min (d, PrERCylDf (qq.xzy, 0.9, 0.28, 0.7));
  qq = q;
  qq.x = abs (qq.x) - 0.4;
  qq.y -= 1.9;
  qq.xy = Rot2D (qq.xy, 0.2 * pi);
  d = min (d, PrERCylDf (qq.xzy, 0.06, 0.04, 0.2));
  qq = q;
  qq.x = abs (qq.x) - 1.05;
  qq.y -= 1.1;
  qq.yz = Rot2D (qq.yz, 0.1 + 0.85 * rAngA * (walk ? 0. : 1.));
  qq.y -= -0.9;
  d = min (d, PrERCylDf (qq.xzy, 0.2, 0.15, 0.6));
  qq = q;
  qq.x = abs (qq.x) - 0.4;
  qq.y -= -0.8;
  d = min (d, PrERCylDf (qq.xzy, 0.25, 0.15, 0.55));
  qq = q;
  qq.x = abs (qq.x) - 0.4;
  qq -= vec3 (0., 1.6, 0.7);
  d = min (d, PrSphDf (qq, 0.25));
  d = max (bf, d);
  if (d < dMin) { dMin = d;  idObj = 15; }
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

vec3 BrickCol (vec2 p)
{
  vec2 q, iq;
  q = p * vec2 (1./62., 1./31.);
  iq = floor (q);
  if (2. * floor (iq.y / 2.) != iq.y) q.x += 0.5;
  q = smoothstep (0.02, 0.05, abs (fract (q + 0.5) - 0.5));
  return (0.7 + 0.3 * q.x * q.y) * vec3 (0.6, 0.55, 0.5);
}

vec3 ObjCol (vec3 p)
{
  vec3 col;
  if (idObj == 10) col = vec3 (0.2, 0.15, 0.1);
  else if (idObj == 11) col = vec3 (0.8, 0.8, 0.9);
  else if (idObj == 12) {
    col = BrickCol (40. * p.zy);
  } else if (idObj == 13) {
    col = BrickCol (40. * p.xy);
  } else if (idObj == 15) col = vec3 (0.6);
  return col;
}

vec3 ScrnCol (vec2 w)
{
  mat3 vuMat;
  vec3 ro, rd, vd, u;
  float f;
  ro = TrackPath (tCur);
  vd = normalize (vec3 (0., 0.3 * rmSize.y, 0.) - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (w / scrnSize.y, 3.));
  return ShowSceneMv (ro, rd);
}

vec3 RgbToHsv (vec3 c)
{
  vec4 p, q;
  float d;
  const float e = 1.e-10;
  p = mix (vec4 (c.bg, vec2 (-1., 2./3.)), vec4 (c.gb, vec2 (0., -1./3.)),
     step (c.b, c.g));
  q = mix (vec4 (p.xyw, c.r), vec4 (c.r, p.yzx), step (p.x, c.r));
  d = q.x - min (q.w, q.y);
  return vec3 (abs (q.z + (q.w - q.y) / (6. * d + e)), d / (q.x + e), q.x);
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p;
  p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

vec3 ScrnProj (vec3 ro)
{
  vec3 vd, col;
  vd = normalize (vec3 (0., 1., 3.5) * rmSize - ro);
  ro += vd * (rmSize.z - ro.z) / vd.z;
  ro.y -= rmSize.y + scrnUp;
  if (abs (ro.x) < scrnSize.x && abs (ro.y) < scrnSize.y) {
    col = ScrnCol (ro.xy);
    col = HsvToRgb (vec3 (1., 0.5, 1.) * RgbToHsv (col));
  } else col = vec3 (0.);
  return col;
}

void SetState ()
{
  float tCyc, wkSpd;
  wkSpd = 0.7;
  tCyc = mod (wkSpd * tCur, 7.);
  if (tCyc < 4.) {
    walk = true;
    tCyc = mod (tCyc, 1.);
    gDisp = mod (wkSpd * tCur, 1.);
    rAngH = -0.7 * sin (2. * pi * tCyc);
    rAngA = 1.1 * sin (2. * pi * tCyc);
    rAngL = 0.6 * sin (2. * pi * tCyc);
  } else {
    walk = false;
    tCyc = mod (tCyc, 1.);
    gDisp = 0.;
    rAngH = 0.4 * sin (2. * pi * tCyc);
    rAngA = 2. * pi * (0.5 - abs (tCyc - 0.5)); 
    rAngL = 0.;
  }
  rmSize = vec3 (12., 5., 12.);
  scrnUp = 0.15 * rmSize.y;
  scrnSize = vec2 (0.85, 0.8) * rmSize.xy;
  dstFar = 150.;
  sunDir = normalize (vec3 (1., 2., 1.));
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn, ltDir, scrCol, refFac;
  float dHit;
  int idObjT;
  idObj = -1;
  dHit = ObjRay (ro, rd);
  ro += dHit * rd;
  vn = ObjNf (ro);
  col = vec3 (0.);
  refFac = vec3 (1.);
  if (idObj == 15) {
    refFac = vec3 (0.8, 1., 0.8);
    for (int j = 0; j < 3; j ++) {
      refFac *= vec3 (0.8, 0.9, 0.8);
      rd = reflect (rd, vn);
      ro += 0.01 * rd;
      idObj = -1;
      dHit = ObjRay (ro, rd);
      ro += dHit * rd;
      if (idObj != 15) break;
    }
  }
  idObjT = idObj;
  vn = ObjNf (ro);
  idObj = idObjT;
  if (idObj == 14) {
    vec2 w = ro.xy;
    w.y -= rmSize.y + scrnUp;
    col = (abs (w.x) < scrnSize.x && abs (w.y) < scrnSize.y) ? ScrnCol (w) :
       vec3 (0.);
  } else {
    col = ObjCol (ro);
#ifdef WALL_ILLUM
    scrCol = (idObj != 10) ? ScrnProj (ro) : vec3 (0.);
#else
    scrCol = vec3 (0.);
#endif
    col *= 0.2 * (1. + scrCol * (1. + max (dot (vn,
       normalize (vec3 (0., scrnUp, rmSize.z))), 0.)));
  }
  return clamp (refFac * col, 0., 1.);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd, vd, u;
  vec2 canvas, uv, ori, ca, sa;
  float az, el;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  SetState ();
  az = -2. * pi * max (mod (0.011 * tCur, 1.) - 0.1, 0.) / 0.9;
  el = 0.1 * (cos (2. * az) - 1.);
  if (mPtr.z > 0.) {
    el += 1. * mPtr.y;
    az += 8. * mPtr.x;
  }
  el = clamp (el, -0.5, 0.5);
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = vec3 (0., rmSize.y, -0.99 * rmSize.z) * vuMat;
  ro.xz = clamp (ro.xz, - 0.98 * rmSize.xz, 0.98 * rmSize.xz);
  ro.y = clamp (ro.y - 0.2 * rmSize.y, 0.02 * rmSize.y, 1.98 * rmSize.y);
  rd = normalize (vec3 (uv, 3.)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
