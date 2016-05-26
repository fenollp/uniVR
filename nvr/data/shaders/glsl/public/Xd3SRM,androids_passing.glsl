// Shader downloaded from https://www.shadertoy.com/view/Xd3SRM
// written by shadertoy user dr2
//
// Name: Androids Passing
// Description: Perhaps a tunnel full of androids (mousing enabled)?
// "Androids Passing" by dr2 - 2016
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

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
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

vec3 sunDirMv, qHit, ltDir;
vec2 scrnSize, wallSpc;
float dstFar, dstFarMv, tCur, rAngH, rAngL, rAngA, gDisp, wDisp;
int idObj, idObjMv;
bool walk;

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
    col = mix (vec3 (0.6, 0.5, 0.3), vec3 (0.4, 0.5, 0.6), pow (1. + rd.y, 5.));
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
  vec4 v;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDfMv (p + e.xxx), ObjDfMv (p + e.xyy),
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
  q = smoothstep (0.03, 0.04, abs (fract (q + 0.5) - 0.5));
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
    sh = min (sh, smoothstep (0., 1., 10. * h / d));
    d += 0.2;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 TrackPathMv (float t)
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
  vec3 ro, rd, vd, u;
  float f;
  w /= scrnSize.x;
  ro = TrackPathMv (tCur);
  vd = normalize (vec3 (0., 2., 0.) - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (w, 2.));
  return ShowSceneMv (ro, rd);
}

float RobDf (vec3 p, float dMin)
{
  vec3 q;
  float d, ah, szFac;
  szFac = 1.8;
  p.x = abs (abs (p.x) - 0.35 * wallSpc.x) - 0.175 * wallSpc.x;
  p.z = mod (p.z + 0.8 * wallSpc.x, 1.6 * wallSpc.x) - 0.8 * wallSpc.x;
  p.y -= -1. - 0.5 * (szFac -  1.);
  p *= szFac;
  dMin *= szFac;
  q = p;
  q.y -= 1.2;
  d = max (PrSphDf (q, 0.85), - q.y);
  q = p;
  q.y -= 0.2;
  d = min (d, PrERCylDf (q.xzy, 0.9, 0.28, 0.7));
  q = p;
  ah = rAngH * (walk ? 1. : 0.);
  q.xz = Rot2D (q.xz, ah);
  q.x = abs (q.x) - 0.4;
  q.y -= 1.9;
  q.xy = Rot2D (q.xy, 0.2 * pi);
  d = min (d, PrERCylDf (q.xzy, 0.06, 0.04, 0.4));
  q = p;
  q.x = abs (q.x) - 1.05;
  q.y -= 1.1;
  q.yz = Rot2D (q.yz, rAngA * (walk ? sign (p.x) : 1.));
  q.y -= -0.9;
  d = min (d, PrERCylDf (q.xzy, 0.2, 0.15, 0.6));
  q = p;
  q.x = abs (q.x) - 0.4;
  q.yz = Rot2D (q.yz, - rAngL * sign (p.x));
  q.y -= -0.8;
  d = min (d, PrERCylDf (q.xzy, 0.25, 0.15, 0.55));
  if (d < dMin) { dMin = d;  idObj = 11; }
  q = p;
  q.xz = Rot2D (q.xz, ah);
  q.x = abs (q.x) - 0.4;
  q -= vec3 (0., 1.6, 0.7);
  d = PrSphDf (q, 0.15);
  if (d < dMin) { dMin = d;  idObj = 12; }
  dMin /= szFac;
  return dMin;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d;
  dMin = dstFar;
  d = wallSpc.x - abs (p.x);
  if (d < dMin) { dMin = d;  idObj = 1; }
  d = wallSpc.y + p.y;
  if (d < dMin) { dMin = d;  idObj = 2; }
  d = wallSpc.y - p.y;
  if (d < dMin) { dMin = d;  idObj = 3; }
  dMin = RobDf (p, dMin);
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 200; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.0001, -0.0001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.05;
  for (int j = 0; j < 20; j ++) {
    h = RobDf (ro + rd * d, dstFar);
    sh = min (sh, smoothstep (0., 1., 10. * h / d));
    d += min (0.1, 2. * h);
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col, rs;
  float dstHit, spec, sh;
  int idObjT;
  bool isScrn;
  dstFar = 250.;
  dstHit = ObjRay (ro, rd);
  isScrn = false;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    spec = 0.5;
    if (idObj == 1) {
      rs = ro;
      rs.x = abs (rs.x) - wallSpc.x;
      rs.z += wDisp;
      rs.z = (mod (rs.z + 2., 4.) - 2.) * sign (rs.x);
      if (abs (rs.z) < scrnSize.x && abs (rs.y) < scrnSize.y) {
        col = ScrnCol (rs.zy);
        isScrn = true;
      } else col = vec3 (0.8, 0.4, 0.2) *
         (0.5 + 0.5 * smoothstep (0.05, 0.1, mod (5. * ro.y, 1.)));
    } else if (idObj == 2) col = mix (vec3 (0.3, 0.25, 0.1), vec3 (0.5, 0.45, 0.3),
         (0.7 + 0.3 * ChqPat (ro / 1.25, dstHit)));
    else if (idObj == 3) {
      rs = ro;
      rs.z += wDisp;
      rs.z = (mod (rs.z + 2., 4.) - 2.) * sign (rs.x);
      rs.xz /= vec2 (wallSpc.x, 2.);
      col = vec3 (1., 1., 0.5) * (1. - 0.5 * min (1.,
         length (pow (abs (1.2 * rs.xz), vec2 (8.)))));
    } else if (idObj == 11) col = vec3 (0.2, 0.8, 0.2);
    else if (idObj == 12) col = vec3 (0.8, 0.3, 0.);
    if (! isScrn && idObj != 3) {
      sh = 0.3 + 0.7 * ObjSShadow (ro, ltDir);
      col = col * (0.2 + 0.8 * sh * max (dot (vn, ltDir), 0.)) +
         spec * sh * 0.6 * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
    }
  } else col = vec3 (0.);
  col = mix (col, 0.5 * vec3 (1., 1., 0.5), smoothstep (0.7, 1., dstHit / dstFar));
  if (! isScrn) col = pow (col, vec3 (0.7));
  return col;
}

void SetState ()
{
  float tCyc, wkSpd;
  wkSpd = 0.7;
  tCyc = mod (wkSpd * tCur, 7.);
  if (tCyc < 4.) {
    walk = true;
    wDisp = mod (tCyc, 4.);
    tCyc = mod (tCyc, 1.);
    gDisp = mod (tCyc, 1.);
    rAngH = -0.7 * sin (2. * pi * tCyc);
    rAngA = 1.1 * sin (2. * pi * tCyc);
    rAngL = 0.6 * sin (2. * pi * tCyc);
  } else {
    walk = false;
    wDisp = 0.;
    tCyc = mod (tCyc, 1.);
    gDisp = 0.;
    rAngH = 0.4 * sin (2. * pi * tCyc);
    rAngA = 2. * pi * (0.5 - abs (tCyc - 0.5)); 
    rAngL = 0.;
  }
  sunDirMv = normalize (vec3 (1., 2., 1.));
  dstFarMv = 150.;
  scrnSize = vec2 (1.7, 1.4);
  wallSpc = vec2 (6., 2.);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd, u, vd;
  vec2 canvas, uv;
  float f;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  SetState ();
  ro = vec3 (0., 0., 8.); 
  if (mPtr.z > 0.) ro.xy =
     clamp (mPtr.xy * vec2 (- canvas.x / canvas.y, 1.), - 0.9, 0.9) * wallSpc.xy;
  vd = normalize (- ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (uv, 3.));
  ltDir = normalize (vec3 (0.1, 1., 0.1));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
