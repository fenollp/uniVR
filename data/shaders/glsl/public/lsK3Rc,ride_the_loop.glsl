// Shader downloaded from https://www.shadertoy.com/view/lsK3Rc
// written by shadertoy user dr2
//
// Name: Ride the Loop
// Description: Roller-coaster ride; use the mouse for a distant view
// "Ride the Loop" by dr2 - 2016
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

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  p.z -= h * clamp (p.z / h, -1., 1.);
  return length (p) - r;
}

float PrCylAnDf (vec3 p, float r, float w, float h)
{
  return max (abs (length (p.xy) - r) - w, abs (p.z) - h);
}

mat3 AxToRMat (vec3 vz, vec3 vy)
{
  vec3 vx;
  vz = normalize (vz);
  vx = normalize (cross (vy, vz));
  vy = cross (vz, vx);
  return mat3 (vec3 (vx.x, vy.x, vz.x), vec3 (vx.y, vy.y, vz.y),
     vec3 (vx.z, vy.z, vz.z));
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

#define NCAR 5
#define NSEG 12

mat3 carMat[NCAR];
vec3 cPt[NSEG], carPos[NCAR], cPtOrg, cUpCirc, cDnCirc, sunDir;
float tLen[NSEG + 1], tCur, dstFar, hTop, rLoop, sLoop, sHzRamp, rDnCirc,
   rUpCirc, sDnRamp, sUpRamp, sHzStr, hTrk, wTrk, tWait, vfFast, vfLoop;
int idObj;
bool riding;
const int nCar = NCAR;
const int nSeg = NSEG;
const vec4 uVec = vec4 (1., 1., 1., 0.);

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 vn, col;
  vec2 w;
  float sd, f;
  vec2 e = vec2 (0.01, 0.);
  if (rd.y >= 0.) {
    ro.xz += 2. * tCur;
    sd = max (dot (rd, sunDir), 0.);
    col = vec3 (0.1, 0.2, 0.4) + 0.2 * (1. - max (rd.y, 0.)) +
       0.1 * pow (sd, 16.) + 0.2 * pow (sd, 256.);
    f = Fbm2 (0.02 * (ro.xz + rd.xz * (100. - ro.y) / max (rd.y, 0.001)));
    col = mix (col, vec3 (1.), clamp (0.2 + 0.8 * f * rd.y, 0., 1.));
  } else {
    ro -= (ro.y / rd.y) * rd;
    w = (riding ? 5. : 0.8) * ro.xz;
    f = Fbm2 (w);
    vn = normalize (vec3 (f - Fbm2 (w + e.xy), 0.1, f - Fbm2 (w + e.yx)));
    col = mix (vec3 (0.4, 0.3, 0.1), vec3 (0.4, 0.5, 0.2), f) *
         (1. - 0.1 * Noisefv2 (w));
    col = mix (vec3 (0.6, 0.5, 0.3) * (1. - 0.2 * Fbm2 (137.1 * w)),
       0.8 * col, smoothstep (7., 8.,
       0.15 * length (ro.xz * ro.xz * vec2 (2.8, 1.))));
    col *= 0.1 + 0.9 * max (dot (vn, sunDir), 0.);
    col = mix (col, vec3 (0.45, 0.55, 0.7), pow (1. + rd.y, 64.));
  }
  return col;
}

void TrkSetup ()
{
  cPtOrg = vec3 (2., 0., -3.);
  hTop = 1.5;
  rLoop = 2.2;
  sLoop = 0.3;
  sHzRamp = 0.5;
  rDnCirc = 2.;
  rUpCirc = rDnCirc + sLoop;
  sDnRamp = 1.5;
  sUpRamp = 1.3 * sDnRamp;
  sHzStr = sDnRamp - sUpRamp + 3. * sHzRamp;
  wTrk = 0.015;
  hTrk = 0.025;
  tWait = 2.;
  vfFast = 5.;
  vfLoop = 0.6;
  cDnCirc = cPtOrg + vec3 (- rDnCirc - sLoop, 0., -2. * sHzRamp);
  cUpCirc = cPtOrg + vec3 (- rUpCirc + sLoop, 2. * hTop, 2. * sDnRamp +
     6. * sHzRamp);
  cPt[0] = cDnCirc + vec3 (- rDnCirc, 0., sHzStr);
  cPt[1] = cPt[0] + sHzStr * uVec.wwz;
  cPt[3] = cUpCirc - rUpCirc * uVec.xww;
  cPt[4] = cUpCirc + rUpCirc * uVec.xww;
  cPt[2] = cPt[3] - 2. * sHzRamp * uVec.wwz;
  cPt[5] = cPt[4] - 2. * sHzRamp * uVec.wwz;
  cPt[7] = cPtOrg + sLoop * uVec.xww;
  cPt[8] = cPtOrg - sLoop * uVec.xww;
  cPt[6] = cPt[7] + 4. * sHzRamp * uVec.wwz;
  cPt[9] = cDnCirc + rDnCirc * uVec.xww;
  cPt[10] = cDnCirc - rDnCirc * uVec.xww;
  cPt[nSeg - 1] = cPt[0];
  tLen[0] = 0.;
  for (int k = 1; k < nSeg; k ++) tLen[k] = length (cPt[k] - cPt[k - 1]);
  tLen[4] = pi * rUpCirc;
  tLen[6] /= 0.5 * (1. + vfFast);
  tLen[8] = length (vec2 (2. * pi * rLoop, 2. * sLoop)) * (1. + vfLoop);
  tLen[10] = pi * rDnCirc;
  for (int k = 7; k < nSeg - 1; k ++) tLen[k] /= vfFast;
  for (int k = 1; k < nSeg; k ++) tLen[k] += tLen[k - 1];
  tLen[nSeg] = tLen[nSeg - 1] + tWait;
}

vec3 TrkPath (float t, out vec3 oDir, out vec3 oNorm)
{
  vec3 p, p1, p2, u;
  float w, ft, s;
  int ik;
  t = mod (t, tLen[nSeg]);
  ik = -1;
  for (int k = 1; k < nSeg; k ++) {
    if (t < tLen[k]) {
      t -= tLen[k - 1];
      p1 = cPt[k - 1];
      p2 = cPt[k];
      w = tLen[k] - tLen[k - 1];
      ik = k;
      break;
    }
  }
  oNorm = uVec.wyw;
  ft = t / w;
  if (ik < 0) {
    p = cPt[0];
    oDir = uVec.wwz;
  } else if (ik == 2 || ik == 6) {
    oDir = p2 - p1;
    if (ik == 6) ft *= (2. + (vfFast - 1.) * ft) / (vfFast + 1.);
    p.xz = p1.xz + oDir.xz * ft;
    p.y = p1.y + oDir.y * smoothstep (0., 1., ft);
    oDir.y *= 6. * ft * (1. - ft);
    oDir = normalize (oDir);
  } else if (ik == 4) {
    ft *= pi;
    p = cUpCirc;
    u = vec3 (- cos (ft), 0., sin (ft));
    p.xz += rUpCirc * u.xz;
    oDir = cross (oNorm, u);
  } else if (ik == 8) {
    ft = (ft < 0.5) ? ft * (1. + vfLoop * (1. - 2. * ft)) :
       ft * (1. + 2. * vfLoop * (ft - 1.5)) + vfLoop;
    p = 0.5 * (cPt[7] + cPt[8]);
    p.x += sLoop * (1. - 2. * ft);
    ft *= 2. * pi;
    u = vec3 (0., cos (ft), sin (ft));
    p.yz += rLoop * (vec2 (1., 0.) - u.yz);
    oNorm = u;
    oDir = normalize (vec3 (-2. * sLoop, 2. * pi * rLoop *
       vec2 (sin (ft), - cos (ft))));
  } else if (ik == 10) {
    ft *= pi;
    p = cDnCirc;
    u = vec3 (cos (ft), 0., - sin (ft));
    p.xz += rDnCirc * u.xz;
    oDir = cross (oNorm, u);
  } else if (ik < nSeg) {
    oDir = p2 - p1;
    p = p1 + oDir * ft;
    oDir = normalize (oDir);
  }
  return p;
}

float TrkDf (vec3 p, float dMin)
{
  vec3 q;
  vec2 csTrk, tr;
  float d, f;
  csTrk = vec2 (wTrk, hTrk);
  q = p - cPtOrg;
  q.y -= rLoop;
  f = smoothstep (0., 1., atan (abs (q.z), - q.y) / pi);
  tr = vec2 (length (q.yz) - rLoop, q.x - sign (q.z) * sLoop * f);
  d = 0.9 * min (max (max (PrBox2Df (tr - sLoop * uVec.wy, csTrk.yx), q.z),
     q.x - sLoop - wTrk), max (max (PrBox2Df (tr + sLoop * uVec.wy,
     csTrk.yx), - q.z), - q.x - sLoop - wTrk));
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = p - 0.5 * (cPt[5] + cPt[6]);
  f = 0.5 * clamp (q.z / sDnRamp + 1., 0., 2.);
  q.y -= hTop * (2. * smoothstep (0., 1., f) - 1.);
  d = max (0.6 * PrBoxDf (q, vec3 (wTrk, hTrk * (1. +
     2. * abs (f * (1. - f))), sDnRamp)), abs (q.z) - sDnRamp);
  q = p - 0.5 * (cPt[1] + cPt[2]);
  f = 0.5 * clamp (q.z / sUpRamp + 1., 0., 2.);
  q.y -= hTop * (2. * smoothstep (0., 1., f) - 1.);
  d = min (d, max (0.6 * PrBoxDf (q, vec3 (wTrk, hTrk * (1. +
     2. * abs (f * (1. - f))), sUpRamp)), abs (q.z) - sUpRamp));
  d = min (d, PrBoxDf (p - 0.5 * (cPt[2] + cPt[3]), vec3 (csTrk, sHzRamp)));
  d = min (d, PrBoxDf (p - 0.5 * (cPt[4] + cPt[5]), vec3 (csTrk, sHzRamp)));
  d = min (d, PrBoxDf (p - 0.5 * (cPt[6] + cPt[7]), vec3 (csTrk, 2. * sHzRamp)));
  d = min (d, PrBoxDf (p - 0.5 * (cPt[8] + cPt[9]), vec3 (csTrk, sHzRamp)));
  d = min (d, PrBoxDf (p - 0.5 * (cPt[1] + cPt[10]), vec3 (csTrk, sHzStr)));
  q = p - 0.5 * (cPt[9] + cPt[10]);
  d = min (max (PrBox2Df (vec2 (length (q.xz) - rDnCirc, q.y), csTrk), q.z), d);
  q = p - 0.5 * (cPt[3] + cPt[4]);
  d = min (d, max (PrBox2Df (vec2 (length (q.xz) - rUpCirc, q.y), csTrk), - q.z));
  if (d < dMin) { dMin = d;  idObj = 1; }
  return dMin;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, colRad, szFac;
  dMin = dstFar;
  dMin = TrkDf (p, dMin);
  szFac = 1.;
  colRad = 0.02;
  q = p - cUpCirc - vec3 (0., - hTop, rUpCirc);
  d = PrCylDf (q.xzy, colRad, hTop);
  q = p - cUpCirc - vec3 (0., - hTop, - sHzRamp);
  q.x = abs (q.x) - rUpCirc;
  d = min (d, PrCylDf (q.xzy, colRad, hTop));
  q = p - 0.5 * (cPt[1] + cPt[2]) + 0.5 * (hTop + colRad) * uVec.wyw;
  d = min (d, PrCylDf (q.xzy, colRad, 0.5 * hTop + colRad));
  q = p - 0.5 * (cPt[5] + cPt[6]) + 0.5 * hTop * uVec.wyw;
  d = min (d, PrCylDf (q.xzy, colRad, 0.5 * hTop));
  q = p - cPtOrg - (rLoop + 0.03) * uVec.wyw;
  q.x = abs (q.x) - sLoop - wTrk - 0.15;
  d = min (d, PrCylDf (q.xzy, colRad, rLoop + 0.03));
  q = p - cPtOrg - vec3 (0., 2. * (rLoop + 0.03), 0.);
  d = min (d, PrCylDf (q.yzx, colRad, sLoop + wTrk + 0.18));
  if (d < dMin) { dMin = d;  idObj = 2; }
  dMin *= szFac;
  for (int k = 0; k < nCar; k ++) {
    if (riding && k == nCar - 1) continue;
    q = carMat[k] * (p - carPos[k]);
    q.y -= hTrk + 0.04;
    q *= szFac;
    d = max (PrCapsDf (q, 0.085, 0.125),
       - max (PrCapsDf (q + vec3 (0., -0.03, 0.), 0.08, 0.12), -0.015 - q.y));
    if (d < dMin) { dMin = d;  idObj = 3; }
  }
  dMin /= szFac;
  q = p - 0.5 * uVec.wyw;
  q.xz = Rot2D (q.xz, (0.5 + floor (atan (q.z, - q.x) * (4. / pi))) * pi / 4.);
  q.x += 10.;
  d = PrCylDf (q.xzy, 0.05, 0.5);
  if (d < dMin) { dMin = d;  idObj = 4; }
  q.y -= 0.6;
  q.xz = abs (q.xz) - 0.1;
  d = PrSphDf (q, 0.15);
  if (d < dMin) { dMin = d;  idObj = 5; }
  q = p - cPt[0] - 0.5 * hTrk * uVec.wyw;
  q.x = abs (q.x) - 0.2;
  d = PrBoxDf (q, vec3 (0.15, 0.5 * hTrk, 0.4));
  q = p - cDnCirc + (rDnCirc - 0.1) * uVec.wwz;
  d = min (d, max (min (PrCylAnDf (q.yzx, 0.3, 0.015, 0.6),
     PrBoxDf (q, vec3 (0.6, 0.005, 0.3))), - q.y));
  if (d < dMin) { dMin = d;  idObj = 2; }
  d = p.y;
  if (d < dMin) { dMin = d;  idObj = 6; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.0005 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = vec3 (0.0002, -0.0002, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.03;
  for (int j = 0; j < 25; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 30. * h / d));
    d += min (0.25, 2. * h);
    if (h < 0.001) break;
  }
  return 0.8 + 0.2 * sh;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, vn;
  float dstHit;
  int idObjT;
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = (idObj == 6) ? uVec.wyw : ObjNf (ro);
    idObj = idObjT;
    if (idObj != 6) {
      if (idObj == 1) {
        objCol = vec4 (0.9, 0.9, 1., 0.5);
        for (int k = 0; k <= 10; k ++) {
          if (length (ro - cPt[k]) < 0.035) { 
            objCol.rgb *= 0.7;
            break;
          }
        }
      } else if (idObj == 2)
         objCol = vec4 (0.8, 0.5, 0.2, 0.1) * (1. - 0.2 * Fbm2 (100. * ro.xz));
      else if (idObj == 3) objCol = vec4 (1., 0., 0., 0.5);
      else if (idObj == 4) objCol = vec4 (0.5, 0.3, 0., 0.1);
      else if (idObj == 5) objCol = vec4 (0., 1., 0., 0.1);
      col = objCol.rgb * (0.3 + 0.7 * max (dot (vn, sunDir), 0.)) +
         objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 32.);
    } else col = BgCol (ro, rd);
    if (! riding) col *= ObjSShadow (ro, sunDir);
  } else col = BgCol (ro, rd);
  return clamp (col, 0., 1.);
}

vec3 GlareCol (vec3 rd, vec3 sd, vec2 uv)
{
  vec3 col;
  vec2 sa;
  const vec3 e = vec3 (1., 0., -1.);
  const vec2 hax = vec2 (0.866, 0.5);
  uv *= 2.;
  if (sd.z > 0.) {
    sa = uv + 0.3 * sd.xy;
    col = 0.05 * pow (sd.z, 8.) *
       (e.xyy * max (dot (normalize (rd + vec3 (0., 0.3, 0.)), sunDir), 0.) +
       e.xxy * (1. - smoothstep (0.11, 0.12, max (abs (sa.y),
       max (abs (dot (sa, hax)), abs (dot (sa, hax * e.xz)))))) +
       e.xyx * SmoothBump (0.32, 0.4, 0.04, length (uv - 0.7 * sd.xy)) +
       0.8 * e.yxx * SmoothBump (0.72, 0.8, 0.04, length (uv + sd.xy)));
  } else col = vec3 (0.);
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd, oDir, oNorm, col;
  vec2 canvas, uv, uvs, ori, ca, sa;
  float az, el, zmFac, vel;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uvs = uv;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  dstFar = 60.;
  TrkSetup ();
  vel = 0.8;
  for (int k = 0; k < nCar; k ++) {
    carPos[k] = TrkPath (vel * tCur - tWait + tLen[nSeg] *
       float (nCar - 1 - k) / float (nCar), oDir, oNorm);
    carMat[k] = AxToRMat (oDir, oNorm);
  }
  riding = (mPtr.z <= 0.);
  if (riding) {
    ro = carPos[nCar - 1];
    vuMat = carMat[nCar - 1];
    ro += (hTrk + 0.2) * oNorm - 0.3 * oDir +
       3. * wTrk * cross (oNorm, oDir).x * uVec.xww;
    zmFac = 2.2;
    rd = normalize (vec3 ((1./0.5) * sin (0.5 * uv.x), uv.y, zmFac)) * vuMat;
  } else {
    el = 0.05;
    az = -0.5 * pi;
    if (mPtr.z > 0.) {
      el = clamp (el - 8. * mPtr.y, 0., 0.45 * pi);
      az -= 7. * mPtr.x;
    }
    ori = vec2 (el, az);
    ca = cos (ori);
    sa = sin (ori);
    vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
       mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
    ro = vec3 (0., 1., -15.) * vuMat;
    zmFac = 3.;
    rd = normalize (vec3 (uv, 3.)) * vuMat;
  }
  sunDir = normalize (vec3 (cos (0.02 * tCur), 1., sin (0.02 * tCur)));
  col = (! riding || abs (uvs.y) < 0.85) ? 
     ShowScene (ro, rd) + GlareCol (rd, vuMat * sunDir, uv) : vec3 (0.);
  fragColor = vec4 (col, 1.);
}
