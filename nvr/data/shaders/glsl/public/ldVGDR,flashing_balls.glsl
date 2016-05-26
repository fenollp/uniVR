// Shader downloaded from https://www.shadertoy.com/view/ldVGDR
// written by shadertoy user dr2
//
// Name: Flashing Balls
// Description: Another bouncing balls variation
// "Flashing Balls" by dr2 - 2016

// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
Another bouncing balls variation. As before, the balls are elastic, and there is
damping and gravity. Colliding balls now flash and then fade back to their original
colors. The mouse controls box rotation.
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
const vec3 nmEdge = vec3 (3, 3, 3);
const int nMol = int (nmEdge.x * nmEdge.y * nmEdge.z);
vec3 pMol[nMol], ltDir, rdSign;
float szMol[nMol], tmrMol[nMol], dstFar, hbLen, tmrMax;
int idObj;

float ObjDf (vec3 p)
{
  vec4 fVec;
  vec3 q, eLen, eShift;
  float dMin, d, eWid, sLen;
  dMin = dstFar;
  sLen = hbLen - 0.3;
  eWid = 0.03;
  eShift = vec3 (0., sLen, sLen);
  eLen = vec3 (sLen + eWid, eWid, eWid);
  fVec = vec4 (sLen * rdSign, 0.);
  q = p;
  d = min (min (PrBoxDf (q - fVec.xww, eLen.yxx),
     PrBoxDf (q - fVec.wyw, eLen.xyx)), PrBoxDf (q - fVec.wwz, eLen.xxy));
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = abs (p);
  d = min (min (PrBoxDf (q - eShift, eLen), PrBoxDf (q - eShift.yxz, eLen.yxz)),
     PrBoxDf (q - eShift.yzx, eLen.yzx));
  if (d < dMin) { dMin = d;  idObj = 2; }
  for (int n = 0; n < nMol; n ++) {
    d = PrSphDf (p - pMol[n], 0.45 * szMol[n]);
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
  return 0.7 + 0.3 * clamp (1. - 0.1 * ao, 0., 1.);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 c, col, vn;
  float dstHit, tmr, ao;
  int idObjT, idMol;
  rdSign = sign (rd);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    tmr = 0.;
    if (idObj == 1) objCol = vec4 (0.8, 0.8, 1., 0.4);
    else if (idObj == 2) objCol = vec4 (0.7, 0.7, 0.9, 0.4);
    else {
      idMol = idObj - 10;
      for (int n = 0; n < nMol; n ++) {
        if (n == idMol) {
          tmr = tmrMol[n];
          break;
        }
      }
      tmr = sqrt (tmr / tmrMax);
      c = vec3 (mix (float (idMol) / float (nMol), 0.2, tmr),
         1. - 0.7 * tmr, 0.5 + 0.5 * tmr);
      objCol = vec4 (min (HsvToRgb (c) + 0.2 * tmr * vec3 (1., 1., 0.5), 1.), 1.);
    }
    ao = (idObj == 1) ? ObjAO (ro, vn) : 1.;
    col = objCol.rgb * (0.3 + 0.7 * ao * max (dot (vn, ltDir), 0.)) +
       objCol.a * ao * pow (max (0., dot (ltDir, reflect (rd, vn))), 128.);
  } else col = vec3 (0., 0., 0.1);
  return clamp (col, 0., 1.);
}

void GetMols ()
{
  vec4 p;
  for (int n = 0; n < nMol; n ++) {
    p = Loadv4 (2 * n);
    pMol[n] = p.xyz;
    szMol[n] = p.w;
    tmrMol[n] = Loadv4 (2 * n + 1).w;
  }
  hbLen = Loadv4 (2 * nMol).y;
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
    ro = vec3 (0., 0., -48.) * vuMat;
    ltDir = normalize (vec3 (1., 1.5, -1.2)) * vuMat;
    GetMols ();
    tmrMax = 20.;
    col = ShowScene (ro, rd);
  }
  fragColor = vec4 (col, 1.);
}
