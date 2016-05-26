// Shader downloaded from https://www.shadertoy.com/view/MsdSDM
// written by shadertoy user dr2
//
// Name: Express Train
// Description: Another toy train; speed and view are user-controlled.
// "Express Train" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

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
  vec3 g;
  float s;
  vec3 e = vec3 (0.1, 0., 0.);
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

float PrOBoxDf (vec3 p, vec3 b)
{
  return length (max (abs (p) - b, 0.));
}

float PrRoundBoxDf (vec3 p, vec3 b, float r)
{
  return length (max (abs (p) - b, 0.)) - r;
}

float PrBox2Df (vec2 p, vec2 b)
{
  vec2 d;
  d = abs (p) - b;
  return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

float PrOBox2Df (vec2 p, vec2 b)
{
  return length (max (abs (p) - b, 0.));
}

float PrRoundBox2Df (vec2 p, vec2 b, float r)
{
  return length (max (abs (p) - b, 0.)) - r;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
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

const float txRow = 64.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

#define N_CAR 6

vec3 qHit, sunDir;
vec2 rlSize;
float dstFar, tCur, szFac, angX, rgHSize, trkWid, dR, dB;
int idObj;

const int idRail = 1, idRbase = 2, idXingV = 3, idXingB = 4, idPlatB = 5,
   idPlatU = 6, idCar = 11, idCon = 12, idWhl = 13, idFLamp = 14, idBLamp = 15;
const int dirNS = 0, dirEW = 1, dirSW = 2, dirNW = 3, dirSE = 4, dirNE = 5,
   dirX = 6;

vec3 GrndCol (vec3 ro, vec3 rd)
{
  vec3 vn, col;
  vec2 w, e;
  float f;
  e = vec2 (0.01, 0.);
  w = 5. * ro.xz;
  f = Fbm2 (w);
  vn = normalize (vec3 (f - Fbm2 (w + e), 0.08, f - Fbm2 (w + e.yx)));
  col = 0.4 * mix (vec3 (0.4, 0.3, 0.1), vec3 (0.4, 0.5, 0.2), f) *
       (1. - 0.1 * Noisefv2 (31. * w));
  col *= 0.1 + 0.9 * max (dot (vn, sunDir), 0.);
  col = mix (col, vec3 (0.15, 0.2, 0.15), pow (1. + rd.y, 16.));
  return col;
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  vec3 col;
  float sr, f;
  ro.xz += 2. * tCur;
  sr = max (dot (rd, sunDir), 0.);
  col = vec3 (0.05, 0.1, 0.25) + 0.2 * pow (1. - rd.y, 8.) +
     0.2 * pow (sr, 6.) + 0.4 * min (pow (sr, 256.), 0.3);
  f = Fbm2 (0.05 * (ro + rd * (100. - ro.y) / rd.y).xz);
  col = mix (col, vec3 (1.), clamp (0.1 + 0.8 * f * rd.y, 0., 1.));
  return col;
}

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col;
  if (rd.y > -0.04 && rd.y < max (0.012 * Fbm1 (20. * abs (atan (rd.z, rd.x))) -
     0.005, 0.)) {
    ro -= (ro.y / rd.y) * rd;
    col = 0.8 * mix (vec3 (0.22, 0.15, 0.15), vec3 (0.15, 0.22, 0.15),
       Fbm2 (32. * ro.xz));
  } else if (rd.y > 0.) col = SkyCol (ro, rd);
  else col = GrndCol (ro - (ro.y / rd.y) * rd, rd);
  return col;
}

void SimpSeg (vec3 q, int indx)
{
  if (indx == dirEW) q.xz = q.zx;
  else if (indx == dirNW) q.z *= -1.;
  else if (indx == dirSE) q.x *= -1.;
  else if (indx == dirNE) q.xz *= -1.;
  if (indx <= dirEW) {
    q.x = abs (q.x);
  } else {
    q.xz += 0.5;  q.x = abs (length (q.xz) - 0.5);
  }
  dB = PrOBox2Df (q.xy, vec2 (2. * trkWid, 0.2 * rlSize.y));
  q.xy -= vec2 (trkWid, 0.7 * rlSize.y);
  dR = PrRoundBox2Df (q.xy, rlSize, 0.5 * rlSize.x);
}

void CrossSeg (vec3 q, int indx)
{
  vec3 qq;
  qq = q;
  q = qq;  q.x = abs (q.x);
  dB = PrOBoxDf (q, vec3 (2. * trkWid, 0.2 * rlSize.y, 0.5));
  q = qq;  q.xz = q.zx;   q.x = abs (q.x);
  dB = min (dB, PrOBoxDf (q, vec3 (2. * trkWid, 0.2 * rlSize.y, 0.5)));
  qq.y -= 0.7 * rlSize.y;
  q = qq;  q.x = abs (q.x) - trkWid;  q.z += 0.5;
  dR = PrRoundBox2Df (q.xy, rlSize, 0.5 * rlSize.x);
  q = qq;  q.xz = q.zx;  q.z += 0.5;  q.x = abs (q.x) - trkWid;
  dR = min (dR, PrRoundBox2Df (q.xy, rlSize, 0.5 * rlSize.x));
  q = qq;  q.xz = abs (q.xz) - trkWid + 2.1 * rlSize.x;
  dR = max (dR, - min (PrBox2Df (q.xz, vec2 (trkWid, 0.7 * rlSize.x)),
     PrBox2Df (q.zx, vec2 (trkWid, 0.7 * rlSize.x))));
}

int GetIx (int isq)
{
  int indx;
  indx = -1;
  if (isq == 1 || isq == 2 || isq == 3 || isq == 4 || isq == 13 ||
     isq == 16 || isq == 19 || isq == 22 || isq == 31 || isq == 34) indx = dirEW;
  else if (isq == 6 || isq == 11 || isq == 24 || isq == 26 || isq == 27 ||
     isq == 29) indx = dirNS;
  else if (isq == 12 || isq == 30 || isq == 33) indx = dirSE;
  else if (isq == 17 || isq == 32 || isq == 35) indx = dirSW;
  else if (isq == 0 || isq == 15 || isq == 18) indx = dirNE;
  else if (isq == 5 || isq == 14 || isq == 23) indx = dirNW;
  else if (isq == 20 || isq == 21) indx = dirX;
  return indx;
}

float TrackDf (vec3 p)
{
  vec3 q;
  vec2 ip;
  float dMin, dUsq;
  int indx, isq;
  const float sqWid = 0.4999;
  dMin = dstFar;
  ip = floor (p.xz);
  q = p;  q.xz = fract (q.xz) - vec2 (0.5);
  isq = int (2. * rgHSize * mod (ip.y + rgHSize, 2. * rgHSize) +
     mod (ip.x + rgHSize, 2. * rgHSize));
  indx = GetIx (isq);
  if (indx >= 0 && indx <= dirX) {
    q.y -= 0.5 * rlSize.y;
    if (indx < dirX) SimpSeg (q, indx);
    else CrossSeg (q, indx);
    dUsq = max (PrOBox2Df (p.xz, vec2 (2. * sqWid * rgHSize)),
       PrBox2Df (q.xz, vec2 (sqWid)));
    dR = max (dR, dUsq);
    if (dR < dMin) { dMin = dR;  idObj = idRail; }
    dB = max (dB, dUsq);
    if (dB < dMin) { dMin = dB;  idObj = idRbase; }
  }
  return dMin;
}

float TrackRay (vec3 ro, vec3 rd)
{
  vec3 p;
  vec2 srd, dda, h;
  float dHit, d;
  const float eps = 0.0001;
  srd = - sign (rd.xz);
  dda = - srd / (rd.xz + 0.0001);
  dHit = max (0., PrBox2Df (ro.xz, vec2 (rgHSize)));
  for (int j = 0; j < 160; j ++) {
    p = ro + dHit * rd;
    h = fract (dda * fract (srd * p.xz));
    d = TrackDf (p);
    dHit += min (d, 0.001 + max (0., min (h.x, h.y)));
    if (d < eps || dHit > dstFar || p.y < 0.) break;
  }
  if (d >= eps) dHit = dstFar;
  return dHit;
}

float CarDf (vec3 p, float dMin, float dir)
{
  vec3 q;
  float d, s, ds;
  q = p;
  s = 0.25;
  if (q.z * dir > 0.5) {
    ds = -0.25 * (q.z * dir - 0.5);
    s += ds;
    q.y -= ds;
  }
  d = PrRoundBoxDf (q, vec3 (0.3, s, 1.55), 0.4);
  if (d < dMin) { dMin = d;  idObj = idCar;  qHit = p; }
  q = p;  q.xz = abs (q.xz);  q.z = abs (q.z - 0.9);
  q -= vec3 (0.39, -0.6, 0.2);
  d = PrCylDf (q.yzx, 0.15, 0.07);
  if (d < dMin) { dMin = d;  idObj = idWhl;  qHit = q; }
  q = p;  q.z = (dir == 0.) ? abs (q.z) - 1.8 : q.z + 1.8 * dir;
  d = PrCylDf (q.xzy, 0.3, 0.5);
  if (d < dMin) { dMin = d;  idObj = idCon; }
  if (dir > 0.) {
    q = p;  q.yz -= vec2 (-0.25, 1.9);
    d = PrCylDf (q, 0.1, 0.1);
    if (d < dMin) { dMin = d;  idObj = idFLamp;  qHit = q; }
  } else if (dir < 0.) {
    q = p;  q.x = abs (q.x) - 0.2;  q.yz -= vec2 (-0.25, -1.9);
    d = PrCylDf (q, 0.08, 0.1);
    if (d < dMin) { dMin = d;  idObj = idBLamp;  qHit = q; }
  }
  return dMin;
}

float SceneDf (vec3 p)
{
  vec4 pCar;
  vec3 q;
  float dMin, d;
  dMin = dstFar;
  q = p;  q.yz -= vec2 (1.5 * rlSize.y, -2.32);
  d = PrOBoxDf (q, vec3 (0.9, 1.5 * rlSize.y, 0.12));
  if (d < dMin) { dMin = d;  idObj = idPlatB; }
  q.x = abs (q.x) - 0.4;  q.yz -= vec2 (0.07, 0.08);
  d = max (PrBoxDf (q, vec3 (0.24, 0.09, 0.035)),
     - PrBoxDf (q, vec3 (0.22, 0.08, 0.04)));
  if (d < dMin) { dMin = d;  idObj = idPlatU; }
  q = p;  q.z = abs (q.z - 0.5);
  d = PrOBoxDf (q, vec3 (0.3, 0.7 * rlSize.y, 0.3));
  if (d < dMin) { dMin = d;  idObj = idRbase; }
  q = p;  q.xy -= vec2 (0.27 * sign (q.z - 0.5), 0.05);
  q.z = abs (q.z - 0.5) - 0.16;
  d = PrCapsDf (q.xzy, 0.017, 0.05);
  if (d < dMin) { dMin = d;  idObj = idXingV; }
  q = p;  q -= vec3 (0.25, 0.03, 0.66);
  q.xy = Rot2D (q.xy, angX);  q.xy -= vec2 (-0.22, 0.05);
  d = PrOBoxDf (q, vec3 (0.2, 0.008, 0.005)); 
  if (d < dMin) { dMin = d;  idObj = idXingB;  qHit = q; }
  q = p;  q -= vec3 (-0.25, 0.03, 0.34);
  q.xy = Rot2D (q.xy, - angX);  q.xy -= vec2 (0.22, 0.05);
  q.x *= -1.;
  d = PrOBoxDf (q, vec3 (0.2, 0.008, 0.005)); 
  if (d < dMin) { dMin = d;  idObj = idXingB;  qHit = q; }
  dMin /= szFac;
  for (int k = 0; k < N_CAR; k ++) {
    pCar = Loadv4 (k);
    pCar.y = 2.7 * rlSize.y + 0.06;
    q = p;  q -= pCar.xyz;
    q.xz = Rot2D (q.xz, pCar.w);
    dMin = CarDf (q / szFac, dMin, (k > 0) ? ((k < N_CAR - 1) ? 0. : -1.) : 1.);
  }
  dMin *= szFac;
  return dMin;
}

float SceneRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, d;
  const float eps = 0.0001;
  dHit = 0.;
  for (int j = 0; j < 120; j ++) {
    p = ro + dHit * rd;
    d = SceneDf (ro + dHit * rd);
    dHit += d;
    if (d < eps || dHit > dstFar || p.y < 0.) break;
  }
  if (d >= eps) dHit = dstFar;
  return dHit;
}

float ObjDf (vec3 p)
{
  return min (SceneDf (p), TrackDf (p));
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = 0.0001 * vec3 (1., -1., 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.007;
  for (int j = 0; j < 15; j ++) {
    h = SceneDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 20. * h / d));
    d += min (0.016, 3. * h);
    if (h < 0.001) break;
  }
  return 0.6 + 0.4 * sh;
}

vec4 CarCol (vec3 vn)
{
  vec4 objCol, carCol;
  carCol = vec4 (0.1, 0.3, 1., 1.);
  if (idObj == idCar) {
    if (abs (qHit.y - 0.22) < 0.26)
       objCol = vec4 (0.2, 0.2, 0.2, 1.);
    else objCol = (abs (abs (qHit.y - 0.22) - 0.28) < 0.02) ?
       vec4 (1., 0.2, 0.2, 1.) : carCol;
  } else if (idObj == idCon) {
    objCol = carCol;
  } else if (idObj == idWhl) {
    objCol = (length (qHit.yz) < 0.07) ? vec4 (0.2, 0.2, 0.2, 0.1) :
       vec4 (0.6, 0.6, 0.6, 1.);
  } else if (idObj == idFLamp) {
    objCol = (qHit.z > 0.1) ? vec4 (1., 1., 0., -1.) : carCol;
  } else if (idObj == idBLamp) {
    objCol = (qHit.z < -0.1) ? vec4 (1., 0., 0., -1.) : carCol;
  }
  return objCol;
}

vec4 SceneCol (vec3 ro, vec3 vn)
{
  vec4 objCol;
  if (idObj == idRail) objCol = vec4 (0.7, 0.7, 0.7, 0.8);
  else if (idObj == idRbase) objCol = vec4 (mix (vec3 (0.25, 0.25, 0.27),
     vec3 (0.32, 0.32, 0.34), smoothstep (0.6, 0.9, Noisefv2 (500. * ro.xz))), 0.1);
  else if (idObj == idXingV) objCol = vec4 (0.7, 0.8, 0.7, 0.8);
  else if (idObj == idXingB) objCol = mix (vec4 (1., 0., 0., 1.),
     vec4 (1.), step (0.5, mod (10. * qHit.x, 1.)));
  else if (idObj == idPlatB) objCol = mix (vec4 (0.2, 0.2, 0.22, 0.1),
     vec4 (0.25, 0.25, 0.2, 0.1), Noisefv2 (1000. * ro.xz));
  else if (idObj == idPlatU) objCol = vec4 (0.5, 0.3, 0.1, 0.2) *
     BrickShd (50. * ro, vn);
  return objCol;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 rdd, qHitT, col, vn;
  float dstHit, d, reflFac, sh;
  int idObjT;
  dstHit = dstFar;
  d = TrackRay (ro, rd);
  if (d < dstHit) dstHit = d;
  idObjT = idObj;
  qHitT = qHit;
  d = SceneRay (ro, rd);
  if (d < dstHit) dstHit = d;
  else {
    idObj = idObjT;
    qHit = qHitT;
  }
  reflFac = 0.;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    qHitT = qHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    qHit = qHitT;
    if (idObj == idCar) {
      rdd = reflect (rd, vn);
      reflFac = (abs (qHit.y - 0.22) < 0.26) ? 0.6 : 0.2;
    }
    if (idObj < idCar) {
      if (idObj == idRbase) vn = VaryNf (200. * ro, vn, 2.);
      objCol = SceneCol (ro, vn);
    } else objCol = CarCol (vn);
    col = objCol.rgb;
    if (objCol.a >= 0.) {
      sh = ObjSShadow (ro, sunDir);
      col = col * (0.2 + 0.8 * sh * max (dot (vn, sunDir), 0.) +
         objCol.a * sh * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.));
    }
  } else if (rd.y <= -0.04) {
    d = - ro.y / rd.y;
    ro += d * rd;
    sh = (d < dstFar) ? ObjSShadow (ro, sunDir) : 1.;
    col = sh * GrndCol (ro, rd);
  } else col = BgCol (ro, rd);
  if (reflFac > 0.) col = mix (col, 0.7 * BgCol (ro, rdd), reflFac);
  return pow (clamp (col, 0., 1.), vec3 (0.7));
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, float fvVar, int vuMode)
{
  vec4 wgBx[2];
  vec2 ust;
  float asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (0.47 * asp, -0.1, 0.012 * asp, 0.15);
  wgBx[1] = vec4 (0.47 * asp, -0.4, 0.022, 0.);
  ust = abs (0.5 * uv - wgBx[0].xy) - wgBx[0].zw;
  if (max (ust.x, ust.y) < 0.) {
    if (abs (max (ust.x, ust.y)) * canvas.y < 1.5) col = vec3 (0.8, 0.8, 0.);
    else col = vec3 (0.8, 0.8, 0.) * mix (1., 0., abs (ust.x) / wgBx[0].z);
  }
  ust = 0.5 * uv - wgBx[0].xy;
  ust.y -= (fvVar - 0.5) * 2. * wgBx[0].w;
  if (length (ust) < 1.1 * wgBx[0].z) {
    if (length (ust) < 0.6 * wgBx[0].z)
       col = (fvVar * canvas.y > 5.) ? vec3 (0.1, 1., 0.1) : vec3 (1., 0.1, 0.1);
    else col = vec3 (0.8, 0.6, 0.);
  }
  if (length (0.5 * uv - wgBx[1].xy) < wgBx[1].z) {
    if (length (0.5 * uv - wgBx[1].xy) < 0.8 * wgBx[1].z) col =
       (vuMode == 0 || vuMode == 2) ? vec3 (0.7, 0.7, 0.2) : vec3 (0.2, 0.2, 1.);
    else col = vec3 (1., 0.2, 0.2);
  }
  return col;
}

mat3 StdVuMat (float el, float az)
{
  vec2 ori, ca, sa;
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  return mat3 (ca.y, 0., sa.y, 0., 1., 0., - sa.y, 0., ca.y) *
         mat3 (1., 0., 0., 0., ca.x, sa.x, 0., - sa.x, ca.x);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 stDat, pVu;
  mat3 vuMat;
  vec3 ro, rd, col, u, vd;
  vec2 canvas, uv, uvs;
  float el, az, zmFac, f, trVar, trMov, trCyc;
  int vuMode;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uvs = uv;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  dstFar = 30.;
  rgHSize = 3.;
  szFac = 0.08;
  trkWid = 0.03;
  rlSize = vec2 (0.003, 0.005);
  stDat = Loadv4 (N_CAR + 1);
  trMov = stDat.x;
  trCyc = stDat.w;
  angX = 0.3 * pi * (1. - SmoothBump (0.55, 0.69, 0.02, mod (trMov / trCyc, 1.)));
  stDat = Loadv4 (N_CAR + 2);
  vuMode = int (stDat.x);
  el = stDat.y;
  az = stDat.z;
  trVar = stDat.w;
  if (vuMode == 0) {
    vuMat = StdVuMat (clamp (el + 0.1 * pi, 0.02 * pi, 0.45 * pi), az);
    ro = vuMat * vec3 (0., 0., -10.);
    zmFac = 5.;
  } else if (vuMode == 1) {
    ro = vec3 (0., 1., -5.);
    vd = normalize (Loadv4 (2).xyz - ro);
    u = - vd.y * vd;
    f = 1. / sqrt (1. - vd.y * vd.y);
    vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
    zmFac = 8. * (atan (length (vd.xz), vd.y) / pi);
  } else if (vuMode == 2 || vuMode == 3) {
    pVu = Loadv4 (N_CAR);
    ro.xz = pVu.xz;
    ro.y = 0.25;
    vuMat = StdVuMat (clamp (0.2 * el + 0.07 * pi, -0.25 * pi, 0.15 * pi),
       az + pVu.w);
    zmFac = 3.5;
  }
  rd = vuMat * normalize (vec3 (uv, zmFac));
  sunDir = normalize (vec3 (1., 1.4, -1.));
  col = ShowScene (ro, rd);
  col = ShowWg (uv, canvas, col, trVar, vuMode);
  fragColor = vec4 (col, 1.);
}
