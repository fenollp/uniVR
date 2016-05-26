// Shader downloaded from https://www.shadertoy.com/view/XsGGRm
// written by shadertoy user dr2
//
// Name: Colliding Balls
// Description: Colliding elastic balls
// "Colliding Balls" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
Colliding elastic balls. The 3D version of "Molecular Dynamics"
(with softer interactions and a larger integration time step).

Two compute steps for each display update.

Mouse click restarts run.
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

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

const int nMolEdge = 3;
const int nMol = nMolEdge * nMolEdge * nMolEdge;

vec3 ltDir;
vec3 pMol[nMol];
float dstFar, hbLen;
int idObj;
const float pi = 3.14159;

float ObjDf (vec3 p)
{
  vec3 q, eShift, eLen;
  float dMin, d, eWid;
  dMin = dstFar;
  eWid = 0.05;
  eShift = vec3 (0., hbLen, hbLen);
  eLen = vec3 (hbLen + eWid, eWid, eWid);
  q = abs (p);
  d = min (min (PrBoxDf (q - eShift, eLen), PrBoxDf (q - eShift.yxz, eLen.yxz)),
     PrBoxDf (q - eShift.yzx, eLen.yzx));
  if (d < dMin) { dMin = d;  idObj = 1; }
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

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 objCol, col, vn;
  float dstHit, c, spec;
  int idObjT;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == 1) {
      objCol = vec3 (0.5, 0.35, 0.2);
      spec = 0.1;
    } else {
      c = float (idObj - 10);
      objCol = HsvToRgb (vec3 (mod (1.7 * c / float (nMol), 1.),
         1. - 0.3 * mod (c, 3.), 1. - 0.3 * mod (c, 2.)));
      spec = 0.5;
    }
    col = objCol * (0.2 +
       0.1 * max (dot (vn, ltDir * vec3 (-1., 0., -1.)), 0.) +
       0.8 * max (dot (vn, ltDir), 0.)) +
       spec * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
  } else col = vec3 (0., 0.4, 0.);
  return clamp (col, 0., 1.);
}

void GetMols ()
{
  for (int n = 0; n < nMol; n ++) pMol[n] = Loadv4 (2 * n).xyz;
  hbLen = Loadv4 (2 * nMol).y - 0.3;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec3 rd, ro;
  vec2 ori, ca, sa;
  float tCur;
  vec2 canvas = iResolution.xy;
  vec2 uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  dstFar = 50.;
  ltDir = normalize (vec3 (1., 2., 1.));
  ori = vec2 (0.8 + 0.3 * sin (2. * pi * 0.07 * tCur), -0.1 * tCur);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  rd = normalize (vec3 (uv, 6.)) * vuMat;
  ro = vec3 (0., 0., -25.) * vuMat;
  GetMols ();
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}