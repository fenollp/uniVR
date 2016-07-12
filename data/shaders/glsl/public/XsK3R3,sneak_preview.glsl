// Shader downloaded from https://www.shadertoy.com/view/XsK3R3
// written by shadertoy user dr2
//
// Name: Sneak Preview
// Description: When the fog clears you will see a model of the latest roller-coaster; perhaps you will be able to take a ride soon.
//    
// "Sneak Preview" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
When the fog clears you will see a model of the latest roller-coaster; perhaps you
will be able to take a ride soon.
*/

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
  vec2 ip = floor (p);
  vec2 fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  vec4 t = Hashv4f (dot (ip, cHashA3.xy));
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

float PrRnd2BoxDf (vec3 p, vec3 b, float r)
{
  vec3 d = abs (p) - b;
  return max (length (max (d.xz, 0.)) - r, d.y);
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

#define NCAR 5

mat3 carMat[NCAR];
vec3 cp[12], carPos[NCAR], cOrg, oPos, cUpCurve, cDnCurve, sunDir, qHit, qnHit,
   ballPos, noiseDisp;
float cLen[13], tCur, dstFar, hTop, rLoop, lenLoop, hzRamp, rDnCurve,
   rUpCurve, rampDn, rampUp, lenStr, hTrk, wTrk, tWait, vFast, vfLoop, ballRad;
int idObj;
const int nCar = NCAR;
const vec4 uVec = vec4 (1., 1., 1., 0.);

vec3 BgCol (vec3 ro, vec3 rd)
{
  return vec3 (0.5) * max ((1. - 1.5 * abs (rd.y)), 0.);
}

void TrkSetup ()
{
  cOrg = vec3 (2., 0., -3.);
  hTop = 1.5;
  rLoop = 2.2;
  lenLoop = 0.3;
  hzRamp = 0.5;
  rDnCurve = 2.;
  rUpCurve = rDnCurve + lenLoop;
  rampDn = 1.5;
  rampUp = 1.3 * rampDn;
  lenStr = rampDn - rampUp + 3. * hzRamp;
  wTrk = 0.03;
  hTrk = 0.05;
  tWait = 2.;
  vFast = 3.;
  vfLoop = 0.6;
  cDnCurve = cOrg + vec3 (- rDnCurve - lenLoop, 0., -2. * hzRamp);
  cUpCurve = cOrg + vec3 (- rUpCurve + lenLoop, 2. * hTop, 2. * rampDn +
     6. * hzRamp);
  cp[0] = cDnCurve + vec3 (- rDnCurve, 0., lenStr);
  cp[1] = cp[0] + lenStr * uVec.wwz;
  cp[3] = cUpCurve - rUpCurve * uVec.xww;
  cp[4] = cUpCurve + rUpCurve * uVec.xww;
  cp[2] = cp[3] - 2. * hzRamp * uVec.wwz;
  cp[5] = cp[4] - 2. * hzRamp * uVec.wwz;
  cp[7] = cOrg + lenLoop * uVec.xww;
  cp[8] = cOrg - lenLoop * uVec.xww;
  cp[6] = cp[7] + 4. * hzRamp * uVec.wwz;
  cp[9] = cDnCurve + rDnCurve * uVec.xww;
  cp[10] = cDnCurve - rDnCurve * uVec.xww;
  cp[11] = cp[0];
  cLen[0] = 0.;
  for (int k = 1; k <= 11; k ++) cLen[k] = length (cp[k] - cp[k - 1]);
  cLen[4] = pi * rUpCurve;
  cLen[8] = length (vec2 (2. * pi * rLoop, 2. * lenLoop)) * (1. + vfLoop);
  cLen[10] = pi * rDnCurve;
  for (int k = 6; k <= 10; k ++) cLen[k] /= vFast;
  for (int k = 1; k <= 11; k ++) cLen[k] += cLen[k - 1];
  cLen[12] = cLen[11] + tWait;
}

vec3 TrkPath (float t, out vec3 oDir, out vec3 oNorm)
{
  vec3 p, p1, p2, u;
  float w, a, s;
  int ik;
  t = mod (t, cLen[12]);
  ik = -1;
  for (int k = 1; k <= 11; k ++) {
    if (t < cLen[k]) {
      t -= cLen[k - 1];
      p1 = cp[k - 1];
      p2 = cp[k];
      w = cLen[k] - cLen[k - 1];
      ik = k;
      break;
    }
  }
  oNorm = vec3 (0., 1., 0.);
  if (ik < 0) {
    p = cp[0];
    oDir = vec3 (0., 0., 1.);
  } else if (ik == 2 || ik == 6) {
    oDir = p2 - p1;
    p.xz = p1.xz + oDir.xz * t / w;
    p.y = p1.y + oDir.y * smoothstep (0., 1., t / w);
    oDir.xz /= w;
    oDir.y *= 6. * (t  / w) * (1. - t / w) / w;
    oDir = normalize (oDir);
  } else if (ik == 4) {
    a = pi * t / w;
    p = cUpCurve;
    u = vec3 (- cos (a), 0., sin (a));
    p.xz += rUpCurve * u.xz;
    oDir = cross (oNorm, u);
  } else if (ik == 8) {
    a = t / w;
    a = (a < 0.5) ? a * (1. + vfLoop * (1. - 2. * a)) :
       a * (1. + 2. * vfLoop * (a - 1.5)) + vfLoop;
    p = 0.5 * (cp[7] + cp[8]);
    p.x += lenLoop * (1. - 2. * a);
    a = 2. * pi * a;
    u = vec3 (0., cos (a), sin (a));
    p.yz += rLoop * (vec2 (1., 0.) - u.yz);
    oNorm = u;
    oDir = normalize (vec3 (-2. * lenLoop,
       2. * pi * rLoop * vec2 (sin (a), - cos (a))));
  } else if (ik == 10) {
    a = pi * t / w;
    p = cDnCurve;
    u = vec3 (cos (a), 0., - sin (a));
    p.xz += rDnCurve * u.xz;
    oDir = cross (oNorm, u);
  } else if (ik <= 11) {
    oDir = p2 - p1;
    p = p1 + oDir * t / w;
    oDir = normalize (oDir);
  }
  return p;
}

float TrkDf (vec3 p, float dMin)
{
  vec3 q;
  vec2 trkCs, tr;
  float d, f;
  trkCs = vec2 (wTrk, hTrk);
  q = p - cOrg;
  q.y -= rLoop;
  f = smoothstep (0., 1., atan (abs (q.z), - q.y) / pi);
  tr = vec2 (length (q.yz) - rLoop, q.x - sign (q.z) * lenLoop * f);
  d = min (max (max (PrBox2Df (tr - lenLoop * uVec.wy, trkCs.yx), q.z),
     q.x - lenLoop - wTrk), max (max (PrBox2Df (tr + lenLoop * uVec.wy,
     trkCs.yx), - q.z), - q.x - lenLoop - wTrk));
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = p - 0.5 * (cp[5] + cp[6]);
  f = clamp ((0.5 / rampDn) * q.z + 0.5, 0., 1.);
  q.y -= hTop * (2. * smoothstep (0., 1., f) - 1.);
  d = max (PrBoxDf (q, vec3 (wTrk, hTrk * (1. + 2. * abs (f * (1. - f))),
     rampDn)), abs (q.z) - rampDn);
  q = p - 0.5 * (cp[1] + cp[2]);
  f = clamp ((0.5 / rampUp) * q.z + 0.5, 0., 1.);
  q.y -= hTop * (2. * smoothstep (0., 1., f) - 1.);
  d = min (d, max (PrBoxDf (q, vec3 (wTrk, hTrk * (1. + 2. * abs (f * (1. - f))),
     rampUp)), abs (q.z) - rampUp));
  d = min (d, PrBoxDf (p - 0.5 * (cp[2] + cp[3]), vec3 (trkCs, hzRamp)));
  d = min (d, PrBoxDf (p - 0.5 * (cp[4] + cp[5]), vec3 (trkCs, hzRamp)));
  d = min (d, PrBoxDf (p - 0.5 * (cp[6] + cp[7]), vec3 (trkCs, 2. * hzRamp)));
  d = min (d, PrBoxDf (p - 0.5 * (cp[8] + cp[9]), vec3 (trkCs, hzRamp)));
  d = min (d, PrBoxDf (p - 0.5 * (cp[1] + cp[10]), vec3 (trkCs, lenStr)));
  q = p - 0.5 * (cp[9] + cp[10]);
  d = min (max (PrBox2Df (vec2 (length (q.xz) - rDnCurve, q.y), trkCs), q.z), d);
  q = p - 0.5 * (cp[3] + cp[4]);
  d = min (d, max (PrBox2Df (vec2 (length (q.xz) - rUpCurve, q.y), trkCs),
     - q.z));
  if (d < dMin) { dMin = d;  idObj = 1; }
  return 0.7 * dMin;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, f, colRad, szFac;
  p.y -= -2.;
  dMin = dstFar;
  dMin = TrkDf (p, dMin);
  q = p - cp[0] - 0.5 * hTrk * uVec.wyw;
  q.x = abs (q.x) - 0.2;
  d = PrBoxDf (q, vec3 (0.15, 0.5 * hTrk, 0.4));
  q = p - cDnCurve + (rDnCurve - 0.1) * uVec.wwz;
  d = min (d, max (min (PrCylAnDf (q.yzx, 0.3, 0.015, 0.6),
     PrBoxDf (q, vec3 (0.6, 0.005, 0.3))), - q.y));
  if (d < dMin) { dMin = d;  idObj = 2; }
  colRad = 0.04;
  q = p - cUpCurve - vec3 (0., - hTop, rUpCurve);
  d = PrCylDf (q.xzy, colRad, hTop);
  q = p - cUpCurve - vec3 (0., - hTop, - hzRamp);
  q.x = abs (q.x) - rUpCurve;
  d = min (d, PrCylDf (q.xzy, colRad, hTop));
  q = p - 0.5 * (cp[1] + cp[2]) + 0.5 * (hTop + colRad) * uVec.wyw;
  d = min (d, PrCylDf (q.xzy, colRad, 0.5 * hTop + colRad));
  q = p - 0.5 * (cp[5] + cp[6]) + 0.5 * hTop * uVec.wyw;
  d = min (d, PrCylDf (q.xzy, colRad, 0.5 * hTop));
  q = p - cOrg - (rLoop + 0.03) * uVec.wyw;
  q.x = abs (q.x) - lenLoop - wTrk - 0.15;
  d = min (d, PrCylDf (q.xzy, colRad, rLoop + 0.03));
  q = p - cOrg - vec3 (0., 2. * (rLoop + 0.03), 0.);
  d = min (d, PrCylDf (q.yzx, colRad, lenLoop + wTrk + 0.15));
  if (d < dMin) { dMin = d;  idObj = 2; }
  q = p;
  q.y -= -0.003;
  d = PrRnd2BoxDf (q, vec3 (2.5, 0.002, 5.5), 1.);
  if (d < dMin) { dMin = d;  idObj = 7; }
  szFac = 0.8;
  dMin *= szFac;
  for (int k = 0; k < nCar; k ++) {
    q = carMat[k] * (p - carPos[k]);
    q.y -= hTrk + 0.04;
    q *= szFac;
    d = max (PrCapsDf (q, 0.085, 0.125),
       - max (PrCapsDf (q + vec3 (0., -0.03, 0.), 0.08, 0.12), -0.015 - q.y));
    if (d < dMin) { dMin = d;  idObj = 4; }
  }
  dMin /= szFac;
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
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float BallHit (vec3 ro, vec3 rd, vec3 p, float s)
{
  vec3 v;
  float h, b, d;
  v = ro - p;
  b = dot (rd, v);
  d = b * b + s * s - dot (v, v);
  h = dstFar;
  if (d >= 0.) {
    h = - b - sqrt (d);
    qHit = ro + h * rd;
    qnHit = (qHit - p) / s;
  }
  return h;
}

float FrAbsf (float p)
{
  return abs (fract (p) - 0.5);
}

vec3 FrAbsv3 (vec3 p)
{
  return abs (fract (p) - 0.5);
}

float TriNoise3d (vec3 p)
{
  const mat3 mr = mat3 (0., 0.8, 0.6, -0.8, 0.36, -0.48, -0.6, -0.48, 0.64);
  vec3 q;
  float a, f;
  a = 1.;
  f = 0.;
  p *= 0.005;
  q = p;
  for (int j = 0; j < 5; j ++) {
    p += FrAbsv3 (q + FrAbsv3 (q).yzx) + noiseDisp;
    p *= 1.2;
    f += a * (FrAbsf (p.x + FrAbsf (p.y + FrAbsf (p.z))));
    q *= 2. * mr;
    q += 0.21;
    a *= 0.9;
  }
  return 0.1 * clamp (2. * f - 1.5, 0., 1.);
}

vec3 FogCol (vec3 col, vec3 ro, vec3 rd, float dHit, float tRot)
{
  vec3 p, roo;
  const vec3 cFog = vec3 (1.);
  float diAx, d, b, f;
  roo = ro;
  ro -= ballPos;
  ro.xz = Rot2D (ro.xz, tRot);
  rd.xz = Rot2D (rd.xz, tRot);
  diAx = 1. / max (0.001, length (ro - dot (rd, ro) * rd));
  b = 0.05 * ballRad;
  d = 0.;
  for (int i = 0; i < 20; i ++) {
    d += b;
    f = smoothstep (1., 1.3, sqrt (d * (2. * ballRad - d)) * diAx);
    p = ro + d * rd;
    f = clamp (TriNoise3d (p) * f * f, 0., 1.);
    col += f * (cFog - col);
    if (length (p) > ballRad || length (roo + d * rd) > dHit) break;
  }
  return col;
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, roo, rdo, vn;
  float dstHit, dstBHit, s;
  int idObjT;
  dstFar = 100.;
  roo = ro;
  rdo = rd;
  noiseDisp = 0.05 * tCur * vec3 (-1., 0., 1.);
  dstBHit = BallHit (ro, rd, ballPos, ballRad);
  dstHit = dstFar;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    col = vec3 (0.7, 0.7, 0.);
    col = col * (0.5 + 0.5 * max (dot (vn, sunDir), 0.)) +
       0.5 * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.);
  } else col = BgCol (ro, rd);
  if (dstBHit < dstFar) {
    ro = roo;
    rd = rdo;
    ro += rd * dstBHit;
    col = HsvToRgb (vec3 (mod (0.3 * tCur, 1.), 1., 1.)) *
       FogCol (col, ro, rd, dstHit, 0.1 * tCur);
    rd = reflect (rd, qnHit);
    col = col + 0.1 + 0.2 * max (dot (qnHit, sunDir), 0.) +
       0.2 * pow (max (0., dot (sunDir, rd)), 64.);
  }
  if (dstBHit < dstFar) {
    s = 1. - abs (dot (rd, qnHit));
    if (s > 0.) col = mix (col, BgCol (ro, rd), pow (s, 4.));
  }
  col = pow (clamp (col, 0., 1.), vec3 (0.8));
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec3 ro, rd, oDir, oNorm, col;
  vec2 canvas, uv, ori, ca, sa;
  float az, el, vel;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  dstFar = 100.;
  TrkSetup ();
  vel = 0.8;
  for (int k = 0; k < nCar; k ++) {
    carPos[k] = TrkPath (vel * tCur - tWait + cLen[12] *
       float (nCar - 1 - k) / float (nCar), oDir, oNorm);
    carMat[k] = AxToRMat (oDir, oNorm);
  }
  ballPos = vec3 (0.);
  ballRad = 8.;
  el = 0.1 * pi;
  az = 0.1 * tCur;
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = vec3 (0., 1., -15.) * vuMat;
  sunDir = normalize (vec3 (1., 2., 1.));
  rd = normalize (vec3 (uv, 6.)) * vuMat;
  ro = vec3 (0., 0., -50.) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
