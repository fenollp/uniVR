// Shader downloaded from https://www.shadertoy.com/view/MsV3zw
// written by shadertoy user dr2
//
// Name: Balls and Springs
// Description: Elastic balls connected by springs. Use the mouse to spin the box.
// "Balls and Springs" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
Elastic balls connected by springs (diagonal springs are not shown); there are
also damping forces and gravity (always acts downwards). The front-facing walls
are transparent. Use the mouse to spin the box.
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

mat3 QToRMat (vec4 q) 
{
  mat3 m;
  float a1, a2, s;
  s = q.w * q.w - 0.5;
  m[0][0] = q.x * q.x + s;  m[1][1] = q.y * q.y + s;  m[2][2] = q.z * q.z + s;
  a1 = q.x * q.y;  a2 = q.z * q.w;  m[0][1] = a1 + a2;  m[1][0] = a1 - a2;
  a1 = q.x * q.z;  a2 = q.y * q.w;  m[2][0] = a1 + a2;  m[0][2] = a1 - a2;
  a1 = q.y * q.z;  a2 = q.x * q.w;  m[1][2] = a1 + a2;  m[2][1] = a1 - a2;
  return 2. * m;
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylEEDf (vec3 p, vec3 e1, vec3 e2, float r)
{
  vec3 u;
  p -= e1;
  u = e2 - e1;
  return length (p - clamp (dot (p, u) / dot (u, u), 0., 1.) * u) - r;
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p;
  p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

const float txRow = 64.;

vec4 Loadv4 (int idVar)
{
  float fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

const float pi = 3.14159;
const int nMol = 8, nSpring = 12;
vec3 pMol[nMol], pSpring[2 * nSpring], ltDir, rdSign;
float wSpring[nSpring], dstFar, hbLen;
int idObj;

float ObjDf (vec3 p)
{
  vec4 fVec;
  vec3 q, eLen, eShift;
  float dMin, d, eWid, sLen;
  dMin = dstFar;
  sLen = hbLen - 0.5;
  eWid = 0.04;
  eShift = vec3 (0., sLen, sLen);
  eLen = vec3 (sLen + eWid, eWid, eWid);
  fVec = sLen * vec4 (rdSign, 0.);
  d = min (min (PrBoxDf (p - fVec.xww, eLen.yxx),
     PrBoxDf (p - fVec.wyw, eLen.xyx)), PrBoxDf (p - fVec.wwz, eLen.xxy));
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = abs (p);
  d = min (min (PrBoxDf (q - eShift, eLen), PrBoxDf (q - eShift.yxz, eLen.yxz)),
     PrBoxDf (q - eShift.yzx, eLen.yzx));
  if (d < dMin) { dMin = d;  idObj = 2; }
  for (int n = 0; n < nSpring; n ++) {
    d = PrCylEEDf (p, pSpring[2 * n], pSpring[2 * n + 1], wSpring[n]);
    if (d < dMin) { dMin = d;  idObj = 3; }
  }
  for (int n = 0; n < nMol; n ++) {
    d = PrSphDf (p - pMol[n], 0.45);
    if (d < dMin) { dMin = d;  idObj = 10 + n; }
  }
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
  vec4 v;
  const vec3 e = vec3 (0.0002, -0.0002, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ObjAO (vec3 ro, vec3 rd)
{
  float ao, d;
  ao = 0.;
  for (int j = 0; j < 5; j ++) {
    d = 0.1 + float (j) / 8.;
    ao += max (0., d - 3. * ObjDf (ro + rd * d));
  }
  return 0.3 + 0.7 * clamp (1. - 0.1 * ao, 0., 1.);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, vn, w;
  float dstHit, ao;
  int idObjT;
  idObj = -1;
  rdSign = sign (rd);
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == 1) {
      w = smoothstep (0., 0.1, abs (fract (1.95 * ro + 0.5) - 0.5));
      objCol = vec4 (mix (vec3 (0.5, 0.5, 0.2), vec3 (0.4, 0.4, 1.),
         dot (abs (vn) * w.yzx * w.zxy, vec3 (1.))), 0.4);
    } else if (idObj == 2) objCol = vec4 (0.5, 0.5, 0.2, 0.4);
    else if (idObj == 3) objCol = vec4 (0.7, 0.6, 0.6, 1.);
    else  objCol = vec4 (HsvToRgb (vec3 (float (idObj - 10) / float (nMol),
       1., 1.)), 1.);
    ao = ObjAO (ro, vn);
    col = objCol.rgb * (0.4 + 0.6 * ao * max (dot (vn, ltDir), 0.)) +
       objCol.a * ao * pow (max (0., dot (ltDir, reflect (rd, vn))), 128.);
  } else col = vec3 (0., 0.1, 0.);
  return clamp (col, 0., 1.);
}

void GetMols ()
{
  vec2 mPair[nSpring];
  float spLen, sd;
  for (int n = 0; n < nMol; n ++) pMol[n] = Loadv4 (2 * n).xyz;
  hbLen = Loadv4 (2 * nMol).y;
  mPair[0] = vec2 (0, 1);  mPair[1] = vec2 (0, 2);  mPair[2] = vec2 (1, 3);
  mPair[3] = vec2 (2, 3);  mPair[4] = vec2 (4, 5);  mPair[5] = vec2 (4, 6);
  mPair[6] = vec2 (5, 7);  mPair[7] = vec2 (6, 7);  mPair[8] = vec2 (0, 4);
  mPair[9] = vec2 (1, 5);  mPair[10] = vec2 (2, 6); mPair[11] = vec2 (3, 7);
  spLen = 1.5;
  for (int n = 0; n < nSpring; n ++) {
    pSpring[2 * n] = Loadv4 (2 * int (mPair[n].x)).xyz;
    pSpring[2 * n + 1] = Loadv4 (2 * int (mPair[n].y)).xyz;
    sd = length (pSpring[2 * n + 1] - pSpring[2 * n]) / spLen;
    wSpring[n] = clamp (0.2 * (1. - sd * sd), 0.05, 0.2);
  }
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 qtVu;
  vec3 col, rd, ro;
  vec2 canvas, uv, ut;
  float tCur;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  ut = abs (uv) - vec2 (1.);
  if (max (ut.x, ut.y) > 0.003) col = vec3 (0.82);
  else {
    dstFar = 100.;
    qtVu = Loadv4 (2 * nMol + 1);
    vuMat = QToRMat (qtVu);
    rd = normalize (vec3 (uv, 8.)) * vuMat;
    ro = vec3 (0., 0., -35.) * vuMat;
    ltDir = normalize (vec3 (1., 1.5, -1.2)) * vuMat;
    GetMols ();
    col = ShowScene (ro, rd);
  }
  fragColor = vec4 (col, 1.);
}
