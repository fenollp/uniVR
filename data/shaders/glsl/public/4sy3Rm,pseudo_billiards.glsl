// Shader downloaded from https://www.shadertoy.com/view/4sy3Rm
// written by shadertoy user dr2
//
// Name: Pseudo Billiards
// Description: Colliding elastic balls
// "Pseudo Billiards" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
Colliding elastic balls (no rolling) with some friction. Based on "Puck Dynamics".

The white ball is hit in a random direction; the rest is simple dynamics.

The game restarts automatically, or with a mouse click. (There are no pockets, so
no scores.)
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

const float txRow = 32.;

vec4 Loadv4 (int idVar)
{
  float fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

const int nMolEdge = 5;
const int nMol = nMolEdge * nMolEdge;

vec3 ltDir;
vec2 pBall[nMol];
float dstFar, hbLen;
int idObj;
const float pi = 3.14159;

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d;
  dMin = dstFar;
  for (int n = 0; n < nMol; n ++) {
    q = p;
    q.xz -= pBall[n];
    d = PrSphDf (q, 0.46);
    if (d < dMin) { dMin = d;  idObj = 10 + n; }
  }
  q = p;
  d = PrBoxDf (q, vec3 (hbLen, 0.4, hbLen));
  q.y -= -0.3;
  d = max (PrBoxDf (q, vec3 (hbLen + 0.2, 0.5, hbLen + 0.2)), - d);
  if (d < dMin) { dMin = d;  idObj = 1; }
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
  float dstHit, spec, c;
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
      objCol = vec3 (0.1, 0.3, 0.);
      for (int n = 0; n < nMol; n ++) {
        c = length (ro.xz - pBall[n]);
        if (c < 0.5) {
          objCol *= 0.7 + 0.3 * smoothstep (0.2, 0.5, c);
          break;
        }
      }
      spec = 0.1;
    } else {
      c = float (idObj - 10);
      if (c == 0.) objCol = vec3 (1.);
      else {
        c -= 1.;
        objCol = HsvToRgb (vec3 (mod (c / float (nMol), 1.),
           1. - 0.3 * mod (c, 3.), 1. - 0.3 * mod (c, 2.)));
      }
      spec = 0.5;
    }
    col = objCol * (0.3 + 0.7 * max (dot (vn, ltDir), 0.) +
       spec * pow (max (0., dot (ltDir, reflect (rd, vn))), 32.));
  } else col = vec3 (0.4, 0.25, 0.1);
  return clamp (col, 0., 1.);
}

void GetMols ()
{
  for (int n = 0; n < nMol; n ++) pBall[n] = Loadv4 (2 * n).xy;
  hbLen = Loadv4 (2 * nMol).y - 0.45;
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
  dstFar = 100.;
  ltDir = normalize (vec3 (1., 3., 1.));
  ori = vec2 (0.8 + 0.3 * sin (2. * pi * 0.07 * tCur), 0.1 * tCur);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  rd = normalize (vec3 (uv, 4.)) * vuMat;
  ro = vec3 (0., 0., -35.) * vuMat;
  GetMols ();
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
