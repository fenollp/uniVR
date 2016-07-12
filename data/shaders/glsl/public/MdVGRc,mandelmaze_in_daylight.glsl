// Shader downloaded from https://www.shadertoy.com/view/MdVGRc
// written by shadertoy user dr2
//
// Name: Mandelmaze in Daylight
// Description: Revisiting the Mandelmaze version of the Mandelbox in daylight (mouse enabled)
// "Mandelmaze in Daylight" by dr2 - 2016
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

float PrBox2Df (vec2 p, vec2 b)
{
  vec2 d = abs (p) - b;
  return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

float PrCylAnDf (vec3 p, float r, float w, float h)
{
  return max (abs (length (p.xy) - r) - w, abs (p.z) - h);
}

mat3 vuMat;
vec3 vuPos;
float tCur, dstFar, chRingO, chRingI, vuVel, bxSize, chSize, qnStep;
int idObj;

float MBoxDf (vec3 p)
{
  vec4 q, q0;
  const float mScale = 2.62;
  const int nIter = 12;
  q0 = vec4 (p, 1.);
  q = q0;
  for (int n = 0; n < nIter; n ++) {
    q.xyz = clamp (q.xyz, -1., 1.) * 2. - q.xyz;
    q = q * mScale / clamp (dot (q.xyz, q.xyz), 0.5, 1.) + q0;
  }
  return length (q.xyz) / abs (q.w);
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, dm, tWid;
  dMin = dstFar;
  d = MBoxDf (p);
  q = p;
  q.y -= vuPos.y;
  tWid = 0.7 * chSize;
  dm = min (PrCylAnDf (q.xzy, chRingO, chSize, chSize),
     PrCylAnDf (q.xzy, chRingI, tWid, chSize));
  dm = min (min (dm, PrBox2Df (q.xy, vec2 (tWid, chSize))),
     PrBox2Df (q.zy, vec2 (tWid, chSize)));
  d = max (d, - dm);
  if (d < dMin) { dMin = d;  idObj = 1; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  const int nStep = 200;
  float dHit, d, s;
  dHit = 0.;
  s = 0.;
  for (int j = 0; j < nStep; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    ++ s;
    if (d < 0.0003 || dHit > dstFar) break;
  }
  qnStep = s / float (nStep);
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

vec3 TrackPath (float t)
{
  vec3 p;
  vec2 tr;
  float ti[9], aDir, a, d, r, tO, tI, tR, rGap;
  bool rotStep;
  tO = 0.5 * pi * chRingO / vuVel;
  tI = 0.5 * pi * chRingI / vuVel;
  rGap = chRingO - chRingI;
  tR = rGap / vuVel;
  rotStep = false;
  ti[0] = 0.;
  ti[1] = ti[0] + tO;  ti[2] = ti[1] + tR;
  ti[3] = ti[2] + tI;  ti[4] = ti[3] + tR;
  ti[5] = ti[4] + tO;  ti[6] = ti[5] + tR;
  ti[7] = ti[6] + tI;  ti[8] = ti[7] + tR;
  aDir = 2. * mod (floor (t / ti[8]), 2.) - 1.;
  p.y = 0.7 * bxSize * sin (2. * pi * floor (t / (2. * ti[8])) / 11.);
  t = mod (t, ti[8]);
  r = chRingO;
  tr = vec2 (0.);
  if (t < ti[4]) {
    if (t < ti[1]) {
      rotStep = true;
      a = (t - ti[0]) / (ti[1] - ti[0]);
    } else if (t < ti[2]) {
      tr.y = chRingO - rGap * (t - ti[1]) / (ti[2] - ti[1]);
    } else if (t < ti[3]) {
      rotStep = true;
      a = 1. + (t - ti[2]) / (ti[3] - ti[2]);
      r = chRingI;
    } else {
      tr.x = - (chRingI + rGap * (t - ti[3]) / (ti[4] - ti[3]));
    }
  } else {
    if (t < ti[5]) {
      rotStep = true;
      a = 2. + (t - ti[4]) / (ti[5] - ti[4]);
    } else if (t < ti[6]) {
      tr.y = - chRingO + rGap * (t - ti[5]) / (ti[6] - ti[5]);
    } else if (t < ti[7]) {
      rotStep = true;
      a = 3. + (t - ti[6]) / (ti[7] - ti[6]);
      r = chRingI;
    } else {
      tr.x = chRingI + rGap * (t - ti[7]) / (ti[8] - ti[7]);
    }
  }
  if (rotStep) {
    a *= 0.5 * pi * aDir;
    p.xz = r * vec2 (cos (a), sin (a));
  } else {
    if (aDir < 0.) tr.y *= -1.;
    p.xz = tr;
  }
  return p;
}

void VuPM (float t)
{
  vec3 fpF, fpB, vel;
  float a, ca, sa, dt;
  dt = 0.5;
  fpF = TrackPath (t + dt);
  fpB = TrackPath (t - dt);
  vuPos = 0.5 * (fpF + fpB);
  vuPos.y = fpB.y;
  vel = (fpF - fpB) / (2. * dt);
  a = atan (vel.z, vel.x) - 0.5 * pi;
  ca = cos (a);  sa = sin (a);
  vuMat = mat3 (ca, 0., - sa, 0., 1., 0., sa, 0., ca);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.05;
  for (int j = 0; j < 25; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 20. * h / d));
    d += min (0.1, 3. * h);
    if (h < 0.001) break;
  }
  return sh;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn, ltDir[4];
  float dstHit, sh, dfSum, spSum;
  int idObjT;
  ltDir[0] = normalize (vec3 (1., 1., 0.));
  ltDir[1] = normalize (vec3 (0., 1., 1.));
  ltDir[2] = normalize (vec3 (1., 0., 1.));
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar) {
    ro += dstHit * rd;
    idObjT = idObj;
    vn = ObjNf (ro);
    if (idObjT == 1) {
      col = mix (vec3 (0.6, 0.9, 0.6), vec3 (0.9, 0.9, 1.),
         clamp (1.2 * length (ro) / bxSize, 0., 1.));
      col = col * clamp (1. - 1.2 * qnStep * qnStep, 0.2, 1.);
    }
    dfSum = 0.;
    spSum = 0.;
    for (int j = 0; j < 3; j ++) {
      sh = 0.1 + ObjSShadow (ro, ltDir[j]);
      dfSum += sh * (0.2 + max (dot (vn, ltDir[j]), 0.));
      spSum += sh * pow (max (0., dot (ltDir[j], reflect (rd, vn))), 32.);
    }
    col = col * dfSum + 1.3 * spSum;
    ltDir[3] = normalize (- ro);
    sh = ObjSShadow (ro, ltDir[3]);
    col = mix (col, vec3 (0.9, 0., 0.),
       0.5 * (1. + cos (20. * tCur)) * sh * max (dot (vn, ltDir[3]), 0.) /
       dot (ro, ro));
  } else {
    col = mix (vec3 (0., 0., 0.8), vec3 (1.),
       0.3 + 0.2 * (1. - smoothstep (0.8, 0.9, abs (rd.y))) *
       Fbm2 (8. * vec2 (2. * abs (atan (rd.z, rd.x)) / pi, rd.y)));
  }
  return pow (clamp (col, 0., 1.), vec3 (0.7));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 mPtr;
  mat3 vuMat2;
  vec3 ro, rd;
  vec2 canvas, uv, ori, ca, sa;
  float az, el;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  dstFar = 30.;
  bxSize = 4.;
  chSize = 0.08 * bxSize;
  chRingO = 0.8 * bxSize;
  chRingI = 0.4 * bxSize;
  vuVel = 0.2 * bxSize;
  el = 0.;
  az = 0.;
  if (mPtr.z > 0.) {
    el = clamp (el - 1.3 * pi * mPtr.y, - 0.49 * pi, 0.49 * pi);
    az = clamp (az - 1.8 * pi * mPtr.x, - pi, pi);
  }
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat2 = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  VuPM (tCur);
  ro = vuPos;
  rd = normalize (vec3 ((1./0.5) * sin (0.5 * uv.x), uv.y, 2.)) * vuMat2 * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
