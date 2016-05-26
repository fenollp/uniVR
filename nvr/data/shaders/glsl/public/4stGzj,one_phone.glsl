// Shader downloaded from https://www.shadertoy.com/view/4stGzj
// written by shadertoy user dr2
//
// Name: One Phone
// Description: .. to rule them all
// "One Phone" by dr2 - 2015
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

float PrRoundBoxDf (vec3 p, vec3 b, float r) {
  return length (max (abs (p) - b, 0.)) - r;
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

float PrShCylDf (vec3 p, float rIn, float rEx, float h)
{
  float s;
  s = length (p.xy);
  return max (max (s - rEx, rIn - s), abs (p.z) - h);
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

mat3 RMatFromEuAng (vec3 eu)
{
  vec4 q, p1, p2, p3;
  float a1, a2, a3, c1, s1, p4w;
  a1 = 0.5 * eu.y;
  a2 = 0.5 * (eu.x - eu.z);
  a3 = 0.5 * (eu.x + eu.z);
  s1 = sin (a1);
  c1 = cos (a1);
  q = vec4 (s1 * cos (a2), s1 * sin (a2), c1 * sin (a3), c1 * cos (a3));
  p1 = 2. * q.x * q;
  p2.yzw = 2. * q.y * q.yzw;
  p3.zw  = 2. * q.z * q.zw;
  p4w    = 2. * q.w * q.w - 1.;
  return mat3 (p1.x + p4w,  p1.y - p3.w, p1.z + p2.w,
               p1.y + p3.w, p2.y + p4w,  p2.z - p1.w,
               p1.z - p2.w, p2.z + p1.w, p3.z + p4w);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

mat3 objMat;
vec3 sunDirMv, qHit, ltDir, phSize;
vec2 scrnSize;
float dstFar, dstFarMv, tCur, rAngH, rAngL, rAngA, gDisp;
int idObj, idObjMv;
bool walk, hOr, vOr;
const int idPhScrn = 10, idPhFace = 11, idRing = 12, idLens = 13,
   idBut = 14, idSock = 15;

vec3 BgColMv (vec3 ro, vec3 rd)
{
  vec3 col;
  float sd, f;
  if (rd.y > 0.) {
    ro.xz += 2. * tCur;
    sd = max (dot (rd, sunDirMv), 0.);
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
  dMin = dstFarMv;
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
    if (d < 0.001 || dHit > dstFarMv) break;
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
  f = dHit / dstFarMv;
  return s * (1. - 0.9 * exp (-2. * f * f) * (1. - q.x * q.y));
}

vec3 ObjColMv (vec3 rd, vec3 vn, float dHit)
{
  vec3 col;
  if (idObjMv == 1) col = vec3 (0.65, 0.8, 0.2);
  else if (idObjMv == 2) col = vec3 (0.8, 0.8, 0.);
  else col = mix (vec3 (0.4, 0.3, 0.2), vec3 (0.6, 0.5, 0.4),
     (0.5 + 0.5 * ChqPat (qHit / 5., dHit)));
  return col * (0.3 + 0.7 * max (dot (vn, sunDirMv), 0.)) +
     0.3 * pow (max (0., dot (sunDirMv, reflect (rd, vn))), 64.);
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
  if (dstHit < dstFarMv) {
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
      if (dstHit < dstFarMv) {
        ro += rd * dstHit;
	    c = ObjColMv (rd, ObjNfMv (ro), dstHit);
      } else {
        c = BgColMv (ro, rd);
      }
      col = mix (col, c, refl);
    }
    col *= (0.8 + 0.2 * ObjSShadowMv (ro, sunDirMv));
  } else {
    col = BgColMv (ro, rd);
  }
  return col;
}

vec3 ScrnCol (vec2 w)
{
  mat3 vuMat;
  vec3 ro, rd, vd, u, col;
  float f;
  bool isMv;
  isMv = true;
  if (hOr) {
    w = w.yx;
    w.x *= -1.;
    w /= scrnSize.y;
  } else {
    w /= scrnSize.x;
    if (abs (w.y) > scrnSize.x / scrnSize.y) isMv = false;
  }
  if (! vOr) w *= -1.;
  if (isMv) {
    ro = TrackPath (tCur);
    vd = normalize (vec3 (0., 2., 0.) - ro);
    u = - vd.y * vd;
    f = 1. / sqrt (1. - vd.y * vd.y);
    vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
    rd = vuMat * normalize (vec3 (w, 1.));
    col = ShowSceneMv (ro, rd);
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
  phSize = vec3 (0.85, 0.015, 1.55);
  scrnSize = phSize.xz - vec2 (0.05, 0.2);
  sunDirMv = normalize (vec3 (1., 2., 1.));
  dstFarMv = 150.;
  dstFar = 50.;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d;
  dMin = dstFar;
  p = objMat * p;
  q = p;
  d = min (PrCylDf (q - vec3 (0.5, 0., 1.) * phSize, phSize.y, 0.05 * phSize.z),
     PrCylDf (q - vec3 (0., 0., -1.) * phSize, 1.2 * phSize.y, 0.05 * phSize.z));
  d = max (PrRoundBoxDf (q, phSize, 0.03), - d); 
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idPhFace; }
  q = p;
  q.yz -= vec2 (- 2.3, 0.8) * phSize.yz;
  d = PrShCylDf (q.xzy, 0.1 * phSize.x, 0.12 * phSize.x, 2.3 * phSize.y);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idRing; }
  d = PrCylDf (q.xzy, 0.1 * phSize.x, 1.5 * phSize.y);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idLens; }
  q = p;
  q.yz -= vec2 (- 1.8, 0.75) * phSize.yz;
  q.x = abs (q.x) - 0.3 * phSize.x;
  d = PrShCylDf (q.xzy, 0.04 * phSize.x, 0.05 * phSize.x, 1.8 * phSize.y);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idRing; }
  q = p;
  q.yz -= vec2 (- 2., 0.45) * phSize.yz;
  q.z = abs (q.z) - 0.09 * phSize.z;
  d = PrRoundBoxDf (q, vec3 (0.16, 0.05, 0.06) * phSize, 0.03);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idBut; }
  q = p;
  d = min (PrCylDf (q - vec3 (0.5, 0., 0.97) * phSize, phSize.y, 0.05 * phSize.z),
     PrCylDf (q - vec3 (0., 0., -0.97) * phSize, 1.2 * phSize.y, 0.05 * phSize.z));
  if (d < dMin) { dMin = d;  qHit = q;  idObj = idSock; }
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
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, vnn, col;
  float dstHit;
  int idObjT;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  idObjT = idObj;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == idPhFace) {
      vnn = objMat * vn;
      if (vnn.y > 0.999) {
        if (abs (qHit.x) < scrnSize.x && abs (qHit.z) < scrnSize.y) {
	      col = ScrnCol (qHit.xz);
	      idObj = idPhScrn;
	    } else col = (abs (qHit.x) < 0.1 * phSize.x &&
	       abs (qHit.z + 0.93 * phSize.z) < 0.03 * phSize.z) ?
	       vec3 (0.8, 0.8, 0.3) : vec3 (0.1);
      } else if (vnn.y < -0.999) {
        if (abs (abs (qHit.x) - 0.02 * phSize.x) < 0.006 * phSize.x) {
	      col = vec3 (0.5) * SmoothBump (0.15, 0.85, 0.1,
	         mod (30. * qHit.z / phSize.z, 1.));
        } else {
	      vnn = VaryNf (31. * qHit, vec3 (0., -1., 0.), 0.5);
          vn = vnn * objMat;
          col = vec3 (0.);
	    }
      } else col = vec3 (0.48, 0.48, 0.5);
    } else if (idObj == idRing) col = vec3 (0.6, 0.65, 0.6);
    else if (idObj == idLens) col = vec3 (0.1);
    else if (idObj == idBut) col = vec3 (0.65, 0.6, 0.6);
    else if (idObj == idSock) col = vec3 (0.1);
    if (idObj != idPhScrn) col = col * (0.1 + 0.9 * max (dot (vn, ltDir), 0.)) +
       0.5 * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
  } else col = vec3 (0.7, 0.5, 0.);
  return clamp (col, 0., 1.);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd, sv, col;
  vec2 canvas, uv, ori, ca, sa;
  float az, el, ss;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  SetState ();
  az = 0.;
  el = 0.;
  if (mPtr.z > 0.) {
    az += 2. * pi * mPtr.x;
    el += 2. * pi * mPtr.y;
  }
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  objMat = RMatFromEuAng (2. * pi * mod (vec3 (0.27, 0.34, 0.11) *
     0.3 * tCur, 1.));
  sv = objMat[1];
  if (abs (sv.y) > 4. * max (abs (sv.x), abs (sv.z))) {
    hOr = false;
    vOr = true;
  } else {
    hOr = (abs (sv.z) < abs (sv.x));
    vOr = (hOr ? (sv.x >= 0.) : (sv.z >= 0.));
  }
  rd = normalize (vec3 (uv, 5.)) * vuMat;
  ro = vec3 (0., 0., -10.) * vuMat;
  ltDir = normalize (vec3 (1., 1., -1.));
  col = ShowScene (ro, rd);
  ss = dot (uv, uv);
  col = mix (col, vec3 (0.1, 0.1, 0.5), smoothstep (0.9, 1., ss * ss));
  fragColor = vec4 (col, 1.);
}
