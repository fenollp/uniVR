// Shader downloaded from https://www.shadertoy.com/view/4dcSRf
// written by shadertoy user dr2
//
// Name: Interactive Mandelbulb
// Description: Explore the sublime Mandelbulb; use the mouse to travel and the slider to zoom.
// "Interactive Mandelbulb" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  Adapted from something I wrote a long time ago while learning CUDA; further
  details can be found at the skytopia, subblue and iquilezles sites.
*/

precision mediump float;

uniform float gTimeU;
uniform int nFrameU;
uniform vec4 shMouseU;
uniform vec3 lookU;
uniform vec2 canvasU;
uniform vec2 txSizeU;
uniform sampler2D txBufU;
varying vec2 vPosV;

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

const float txRow = 32.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

const float pi = 3.14159;

vec3 ltDir;
float dstFar, tCur;
int nIt, nStep;

float ObjDf (vec3 p)
{
  vec4 aa, sa, ca;
  vec3 c, q, qd;
  float qLen, qdLen, q2, q4, phi, theta, thetad, phid;
  q = p.xzy;
  c = q;
  qLen = length (q);
  phi = atan (q.y, q.x);
  theta = (qLen > 0.) ? acos (q.z / qLen) : 0.;
  thetad = 0.;
  phid = 0.;
  qdLen = 1.;
  nIt = 0;
  for (int n = 0; n < 5; n ++) {
    q2 = qLen * qLen;
    q4 = q2 * q2;
    aa.xy = 8. * vec2 (theta, phi);
    aa.zw = 7. * vec2 (theta, phi) + vec2 (thetad, phid);
    sa = sin (aa);
    ca = cos (aa);
    q = q4 * q4 * vec3 (sa.x * ca.y, sa.x * sa.y, ca.x) + c;
    qd = 8. * q4 * q2 * qLen * qdLen *
       vec3 (sa.z * ca.w, sa.z * sa.w, ca.z) + vec3 (1.);
    qLen = length (q);
    phi = atan (q.y, q.x);
    theta = (qLen > 0.) ? acos (q.z / qLen) : 0.;
    qdLen = length (qd);
    phid = atan (qd.y, qd.x);
    thetad = (qdLen > 0.) ? asin (qd.z / qdLen) : 0.;
    ++ nIt;
    if (qLen > 3.1623) break;
  }
  return (qLen > 0.) ? 0.5 * qLen * log (qLen) / qdLen : 0.;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  nStep = 0;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    ++ nStep;
    if (d < 0.001 || dHit > dstFar) break;
  }
  if (d >= 0.001) dHit = dstFar;
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = 1e-5 * vec3 (1., -1., 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, float zmVar)
{
  vec4 wgBx[1];
  vec2 ust;
  float asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (0.47 * asp, -0.25, 0.012 * asp, 0.18);
  ust = abs (0.5 * uv - wgBx[0].xy) - wgBx[0].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.5, 0.5, 0.);
  ust = 0.5 * uv - wgBx[0].xy;
  ust.y -= (zmVar - 0.5) * 2. * wgBx[0].w;
  ust = abs (ust) - 0.6 * wgBx[0].zz;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.5) col = vec3 (1., 1., 0.);
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col;
  float dstHit, b;
  int nItT;
  b = - dot (ro, rd);
  dstHit = b * b - dot (ro, ro) + 3.;
  if (dstHit > 0.) {
    ro += (b - sqrt (dstHit)) * rd;
    dstHit = ObjRay (ro, rd);
  } else dstHit = dstFar;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    nItT = nIt;
    vn = ObjNf (ro);
    col = HsvToRgb (vec3 (mod (0.6 * log (float (nItT)), 1.) +
       mod (0.1 * tCur, 1.), 1., 1. - smoothstep (0.7, 1., float (nStep) / 150.)));
    col = col * (0.1 + 0.9 * max (dot (vn, ltDir), 0.) +
       pow (max (0., dot (ltDir, reflect (rd, vn))), 128.));
  } else col = vec3 (0.3, 0.3, 0.5);
  col = clamp (col, 0., 1.);
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 stDat;
  vec3 ro, rd, col;
  vec2 canvas, uv, ori, ca, sa;;
  float az, el, zmFac, zmVar;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  stDat = Loadv4 (0);
  el = stDat.x;
  az = stDat.y;
  zmVar = stDat.z;
  zmFac = 30. * zmVar + 5.;
  dstFar = 15.;
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) * 
          mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  ro = vuMat * vec3 (0., 0., -6.);
  rd = vuMat * normalize (vec3 (uv, zmFac));
  ltDir = vuMat * normalize (vec3 (1., 1., -1.));
  col = ShowScene (ro, rd);
  col = ShowWg (uv, canvas, col, zmVar);
  fragColor = vec4 (col, 1.);
}
