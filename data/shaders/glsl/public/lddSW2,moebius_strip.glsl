// Shader downloaded from https://www.shadertoy.com/view/lddSW2
// written by shadertoy user dr2
//
// Name: Moebius Strip
// Description: Escher's static ants are now marching spiders
// "Moebius Strip" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Escher's static ants are now marching spiders.

// 2 versions:
//   original is slow and GPU-demanding
//   new is faster and more resource friendly

#define FAST_VERS 1 // set = 0 for old version

vec3 VaryNf (vec3 p, vec3 n, float f);
float SmoothBump (float lo, float hi, float w, float x);
vec2 Rot2D (vec2 q, float a);

const float pi = 3.14159;

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrEllipsDf (vec3 p, vec3 r)
{
  return (length (p / r) - 1.) * min (r.x, min (r.y, r.z));
}

#if FAST_VERS
#define N_SPD 9
#else
#define N_SPD 3   // increase if your GPU can handle it
#endif

#if ! FAST_VERS
mat3 spdMat[N_SPD];
vec3 spdPos[N_SPD];
#endif
vec3 footPos[8], kneePos[8], hipPos[8], ltDir[4], qHit;
float dstFar, tCur, mobRad, legLenU, legLenD, bdyHt, spdVel, nSpd;
int idObj;
const int idMob = 1, idBdy = 11, idHead = 12, idEye = 13, idAnt = 14, idLegU = 15,
   idLegD = 16;

float MobiusDf (vec3 p, float r, vec2 b, float rc)
{
  vec2 q;
  float a;
  q = vec2 (length (p.xz) - r, p.y);
  a = atan (p.z, p.x);
  q = Rot2D (q, 0.5 * a);
  qHit = vec3 (q, a);
  return 0.7 * (length (max (abs (q) - b, 0.)) - rc);
}

float ShpCylDf (vec3 p, vec3 v, float md, float r, float rf)
{
  float len, s;
  len = length (v);
  v = normalize (v);
  s = clamp (dot (p, v), 0., len);
  p -= s * v;
  s = s / len - md;
  return length (p) - r * (1. - rf * s * s);
}

float SpdDf (vec3 p, float dMin)
{
  vec3 q;
  float d, s, len, szFac;
  szFac = 5.5;
  p *= szFac;
  dMin *= szFac; 
  p.y -= bdyHt + 0.7;
  q = p - vec3 (0., -0.15, 0.2);
  d = PrEllipsDf (q, vec3 (0.7, 0.5, 1.3));
  if (d < dMin) { dMin = d;  idObj = idBdy;  qHit = q; }
  q = p - vec3 (0., 0.1, 1.1);
  d = PrEllipsDf (q, vec3 (0.2, 0.4, 0.5));
  if (d < dMin) { dMin = d;  idObj = idHead;  qHit = q; }
  q = p;  q.x = abs (q.x);  q -= vec3 (0.15, 0.25, 1.5);
  d = PrSphDf (q, 0.13);
  if (d < dMin) { dMin = d;  idObj = idEye; }
  q -= vec3 (0., 0.15, -0.3);
  d = ShpCylDf (q, 1.3 * vec3 (0.3, 1.1, 0.4), 0., 0.07, 0.7);
  if (d < dMin) { dMin = d;  idObj = idAnt; }
  p.y += bdyHt;
  for (int j = 0; j < 8; j ++) {
    q = p - hipPos[j];
    d = 0.6 * ShpCylDf (q, kneePos[j] - hipPos[j], 0., 0.25, 0.3);
    if (d < dMin) { dMin = d;  idObj = idLegU;  qHit = q; }
    q = p - kneePos[j];
    d = 0.6 * ShpCylDf (q, footPos[j] - kneePos[j], 0.3, 0.2, 1.3);
    if (d < dMin) { dMin = d;  idObj = idLegD;  qHit = q; }
  }
  dMin /= szFac;
  return dMin;
}

#if FAST_VERS

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, a, aq, na;
  dMin = dstFar;
  d = MobiusDf (p, mobRad, vec2 (0.07, 0.8), 0.02);
  if (d < dMin) { dMin = d;  idObj = idMob; }
  q = p;
  a = tCur * spdVel / (2. * pi * mobRad);
  q.xz = Rot2D (q.xz, a);
  na = floor (nSpd * atan (q.z, - q.x) / (2. * pi));
  aq = 2. * pi * (na + 0.5) / nSpd;
  q.xz = Rot2D (q.xz, aq);
  q.x += mobRad;
  if (PrCylDf (q.xzy, 1., 0.7) < dMin) {
    a += aq;
    if (2. * floor (0.5 * na) != na) a += 2. * pi;
    q.xy = Rot2D (q.xy, 0.5 * a);
    dMin = SpdDf (q, dMin);
  }
  return dMin;
}

#else

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d;
  dMin = dstFar;
  d = MobiusDf (p, mobRad, vec2 (0.07, 0.8), 0.02);
  if (d < dMin) { dMin = d;  idObj = idMob; }
  for (int k = 0; k < N_SPD; k ++) {
    q = p - spdPos[k];
    if (PrCylDf (q.xzy, 1., 0.7) < dMin) {
      q = spdMat[k] * q;
      q.xy = vec2 (q.y, - q.x);
      dMin = SpdDf (q, dMin);
    }
  }
  return dMin;
}

#endif

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
#if FAST_VERS
  for (int j = 0; j < 120; j ++) {
#else
  for (int j = 0; j < 60; j ++) {
#endif
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

void Setup ()
{
  vec3 v;
  vec2 ca, sa;
  float gDisp, a, az, fz, d, ll;
  nSpd = float (N_SPD);
  spdVel = 1.5;
  for (int j = 0; j < 4; j ++) {
    a = 0.2 * (1. + float (j)) * pi;
    hipPos[j] = 0.5 * vec3 (- sin (a), 0., 1.5 * cos (a));
    hipPos[j + 4] = hipPos[j];  hipPos[j + 4].x *= -1.;
  }
  gDisp = spdVel * tCur;
  bdyHt = 1.5;
  legLenU = 2.2;
  legLenD = 3.;
  ll = legLenD * legLenD - legLenU * legLenU;
  for (int j = 0; j < 8; j ++) {
    fz = fract ((gDisp + 0.93 + ((j < 4) ? -1. : 1.) +
       mod (7. - float (j), 4.)) / 3.);
    az = smoothstep (0.7, 1., fz);
    footPos[j] = 5. * hipPos[j];
    footPos[j].x *= 1.7;
    footPos[j].y += 0.7 * sin (pi * clamp (1.4 * az - 0.4, 0., 1.));
    footPos[j].z += ((j < 3) ? 0.5 : 1.) - 3. * (fz - az);
    hipPos[j] += vec3 (0., bdyHt - 0.3, 0.2);
    v = footPos[j] - hipPos[j];
    d = length (v);
    a = asin ((hipPos[j].y - footPos[j].y) / d);
    kneePos[j].y = footPos[j].y + legLenD *
       sin (acos ((d * d + ll) / (2. * d *  legLenD)) + a);
    kneePos[j].xz = hipPos[j].xz + legLenU * sin (acos ((d * d - ll) /
       (2. * d *  legLenU)) + 0.5 * pi - a) * normalize (v.xz);
  }
#if ! FAST_VERS
  for (int k = 0; k < N_SPD; k ++) {
    a = tCur * spdVel / (2. * pi * mobRad) + (4. / nSpd) * pi * float (k);
    spdPos[k] = vec3 (mobRad, 0., 0.);
    spdPos[k].xz = Rot2D (spdPos[k].xz, a);
    ca = vec2 (cos (a), cos (-0.5 * a));
    sa = vec2 (sin (a), sin (-0.5 * a));
    spdMat[k] = mat3 (ca.y, - sa.y, 0., sa.y, ca.y, 0., 0., 0., 1.) *
                mat3 (ca.x, 0., - sa.x, 0., 1., 0., sa.x, 0., ca.x);
  }
#endif
}

vec3 SpdCol (vec3 vn)
{
  vec3 col;
  if (idObj == idBdy) {
    col = mix (vec3 (0.9, 0.9, 0.1), vec3 (0.2, 0.5, 0.2),
      SmoothBump (0.2, 0.7, 0.05, mod (4. * qHit.z, 1.)));
  } else if (idObj == idHead) {
    col = vec3 (0.2, 0.5, 0.2);
    if (qHit.z > 0.4) col = mix (vec3 (0.2, 0.05, 0.05), col,
       smoothstep (0.02, 0.04, abs (qHit.x)));
  } else if (idObj == idEye) {
    col = (vn.z < 0.6) ? vec3 (1., 0., 0.) : vec3 (0.9, 0.9, 0.1);
  } else if (idObj == idLegU || idObj == idLegD) {
    col = mix (vec3 (0.2, 0.5, 0.2), vec3 (0.9, 0.9, 0.1), 
       SmoothBump (0.4, 1., 0.2, fract (3.5 * length (qHit))));
  } else if (idObj == idAnt) {
    col = vec3 (0.7, 0.7, 0.3);
  }
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col;
  float dstObj, f, spec, cd, cs;
  int idObjT;
  dstObj = ObjRay (ro, rd);
  if (dstObj < dstFar) {
    ro += rd * dstObj;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == idMob) {
      if (abs (qHit.y) > 0.6 ||  mod (10. * (qHit.z / pi + 1.), 1.) > 0.7) {
        col = vec3 (0.3, 0.3, 0.33);
        spec = 0.1;
        f = 5.;
      } else {
        col = vec3 (0.4, 0.2, 0.2);
        spec = 0.5;
        f = 0.2;
      }
      vn = VaryNf (30. * ro, vn, f);
    } else if (idObj >= idBdy) {
      col = SpdCol (vn);
      spec = 1.;
    }
    cd = 0.;
    cs = 0.;
    for (int k = 0; k < 4; k ++) {
      cd += max (dot (vn, ltDir[k]), 0.);
      cs += pow (max (0., dot (ltDir[k], reflect (rd, vn))), 64.);
    }
    col = col * (0.1 + 0.5 * cd + 0.5 * spec * cs);
  } else col = vec3 (0.2, 0.3, 0.4);
  return pow (clamp (col, 0., 1.), vec3 (0.8));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec3 ro, rd, col;
  vec2 canvas, uv, uvs, ori, ca, sa;
  float el, az;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uvs = uv;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  az = 0.1 * tCur;
  el = 0.2 * pi * cos (0.06 * tCur);
  dstFar = 20.;
  mobRad = 3.;
  Setup ();
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
          mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  rd = vuMat * normalize (vec3 (uv, 3.5));
  ro = vuMat * vec3 (0., 0., -12.);
  ltDir[0] = normalize (vec3 (1., 1., 1.));
  ltDir[1] = normalize (vec3 (1., 1., -1.));
  ltDir[2] = normalize (vec3 (-1., -1., 1.));
  ltDir[3] = normalize (vec3 (-1., -1., -1.));
  col = ShowScene (ro, rd);
  uvs *= uvs * uvs;
  col *= mix (0.8, 1., pow (1. - 0.5 * length (uvs * uvs), 4.));
  fragColor = vec4 (col, 1.);
}

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
  const vec3 e = vec3 (0.1, 0., 0.);
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s, Fbmn (p + e.yxy, n) - s,
     Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}
