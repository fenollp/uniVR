// Shader downloaded from https://www.shadertoy.com/view/MtXXDl
// written by shadertoy user dr2
//
// Name: Mandelmaze
// Description: Touring the Mandelbox (best viewed in fullscreen mode, a complete trip
//    takes about 20 min).
// "Mandelmaze" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

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
vec3 gloPos[2], vuPos;
float tCur, chRingO, chRingI, vuVel, bxSize, chSize, qnStep;
int idObj;
const float mScale = 2.62;
const float dstFar = 30.;
const float pi = 3.14159;

float MBoxDf (vec3 p)
{
  vec4 q, q0;
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
  tWid = 0.9 * chSize;
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
  const int nStep = 150;
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
  dt = 1.;
  fpF = TrackPath (t + dt);
  fpB = TrackPath (t - dt);
  vuPos = 0.5 * (fpF + fpB);
  vuPos.y = fpB.y;
  vel = (fpF - fpB) / (2. * dt);
  a = atan (vel.z, vel.x) - 0.5 * pi;
  ca = cos (a);  sa = sin (a);
  vuMat = mat3 (ca, 0., - sa, 0., 1., 0., sa, 0., ca);
}

float GlowCol (vec3 ro, vec3 rd, float dstHit)
{
  vec3 gloDir;
  float gloDist, wGlow;
  wGlow = 0.;
  for (int j = 0; j < 2; j ++) {
    gloDir = gloPos[j] - ro;
    gloDist = length (gloDir);
    gloDir /= gloDist;
    if (gloDist < dstHit) wGlow +=
       pow (max (dot (rd, gloDir), 0.), 1024.) / sqrt (gloDist);
  }
  return (0.7 + 0.2 * sin (10. * tCur)) * clamp (wGlow, 0., 1.);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 roo, rdo, col, vn, ltDir;
  float dstHit;
  int idObjT;
  ltDir = normalize (vec3 (0.5, 1., -0.5));
  idObj = -1;
  roo = ro;
  dstHit = ObjRay (ro, rd);
  idObjT = idObj;
  if (dstHit < dstFar) {
    ro += dstHit * rd;
    vn = ObjNf (ro);
    if (idObjT == 1) {
      col = mix (vec3 (1., 1., 0.), vec3 (1., 1., 0.8),
	 clamp (1.2 * length (ro) / bxSize, 0., 1.));
      col = col * clamp (1. - 1.5 * qnStep * qnStep, 0.3, 1.);
    }
    col = col * (0.2 +
       0.6 * max (dot (vn, ltDir), 0.)) +
       0.5 * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
  } else {
    col = vec3 (0., 0., 0.1);
    rdo = rd;
    rdo += vec3 (1.);
    for (int j = 0; j < 10; j ++)
       rdo = 11. * abs (rdo) / dot (rdo, rdo) - 3.;
    col += min (1., 1.5e-6 * pow (min (16., length (rdo)), 5.)) *
       vec3 (0.7, 0.6, 0.6);
  }
  col = mix (col, vec3 (1., 0.5, 0.3), GlowCol (roo, rd, dstHit));
  return clamp (col, 0., 1.);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  vec3 ro, rd;
  bxSize = 4.;
  chSize = 0.08 * bxSize;
  chRingO = 0.8 * bxSize;
  chRingI = 0.4 * bxSize;
  vuVel = 0.1 * bxSize;
  gloPos[0] = vec3 (0.);
  VuPM (tCur + 1.5 * vuVel);
  gloPos[1] = vuPos;
  VuPM (tCur);
  gloPos[0].y = vuPos.y;
  gloPos[1].y = vuPos.y - 0.2 * chSize;
  ro = vuPos;
  rd = normalize (vec3 (uv, 1.1)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
