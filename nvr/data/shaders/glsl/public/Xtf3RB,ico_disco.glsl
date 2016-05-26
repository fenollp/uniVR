// Shader downloaded from https://www.shadertoy.com/view/Xtf3RB
// written by shadertoy user dr2
//
// Name: Ico-Disco
// Description: This is the answer to nimitz's next question; the dodecahedron (see MtsGW7) is left as an exercise.
// "Ico-Disco" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

int idObj;
mat3 rMat[20];
vec3 ltDir;
float tCur, eLen, chLen, chRad;
const float C_ab = -0.364863828, C_ia = 0.55357435, C_d = 0.288675135,
   C_r = 0.80901699;
const float pi = 3.14159;
const float dstFar = 20.;

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float IcosDf (vec3 p)
{
  p.z -= C_r * eLen;
  p.yz = Rot2D (p.yz, C_ab);
  p.y += C_d * eLen;
  p.xy = Rot2D (p.xy, floor (0.5 + atan (p.x, p.y) * (1.5 / pi)) * (pi / 1.5));
  p.y -= C_d * chLen;  
  return PrCapsDf (p.yzx, chRad, 0.5 * chLen);
}

float ObjDf (vec3 p)
{
  vec3 q;
  float d, dHit;
  dHit = dstFar;
  d = dHit;
  q = p * rMat[0] ;  d = min (d, IcosDf (q));
  q = p * rMat[1] ;  d = min (d, IcosDf (q));
  q = p * rMat[2] ;  d = min (d, IcosDf (q));
  q = p * rMat[3] ;  d = min (d, IcosDf (q));
  q = p * rMat[4] ;  d = min (d, IcosDf (q));
  q = p * rMat[5] ;  d = min (d, IcosDf (q));
  q = p * rMat[6] ;  d = min (d, IcosDf (q));
  q = p * rMat[7] ;  d = min (d, IcosDf (q));
  q = p * rMat[8] ;  d = min (d, IcosDf (q));
  q = p * rMat[9] ;  d = min (d, IcosDf (q));
  q = p * rMat[10];  d = min (d, IcosDf (q));
  q = p * rMat[11];  d = min (d, IcosDf (q));
  q = p * rMat[12];  d = min (d, IcosDf (q));
  q = p * rMat[13];  d = min (d, IcosDf (q));
  q = p * rMat[14];  d = min (d, IcosDf (q));
  q = p * rMat[15];  d = min (d, IcosDf (q));
  q = p * rMat[16];  d = min (d, IcosDf (q));
  q = p * rMat[17];  d = min (d, IcosDf (q));
  q = p * rMat[18];  d = min (d, IcosDf (q));
  q = p * rMat[19];  d = min (d, IcosDf (q));
  if (d < dHit) { dHit = d;  idObj = 1; }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
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

mat3 RotToRMat (vec3 v, float a)
{
  mat3 m;
  float c, s, a1, a2;
  c = cos (a);
  s = sin (a);
  m[0][0] = (1. - c) * v.x * v.x + c;
  m[1][1] = (1. - c) * v.y * v.y + c;
  m[2][2] = (1. - c) * v.z * v.z + c;
  a1 = (1. - c) * v.x * v.y;
  a2 = -s * v.z;
  m[0][1] = a1 + a2;
  m[1][0] = a1 - a2;
  a1 = (1. - c) * v.z * v.x;
  a2 = -s * v.y;
  m[2][0] = a1 + a2;
  m[0][2] = a1 - a2;
  a1 = (1. - c) * v.y * v.z;
  a2 = -s * v.x;
  m[1][2] = a1 + a2;
  m[2][1] = a1 - a2;
  return m;
}

void BuildRMats ()
{
  mat3 axMat[3];
  axMat[0] = RotToRMat (vec3 (1., 0., 0.), pi);
  axMat[1] = RotToRMat (vec3 (0., cos (C_ia), sin (C_ia)), 0.4 * pi);
  axMat[2] = RotToRMat (vec3 (0., 1., 0.), pi);
  for (int i = 0; i < 3; i ++) {
    for (int j = 0; j < 3; j ++) rMat[0][i][j] = 0.;
    rMat[0][i][i] = 1.;
  }
  rMat[1]  = axMat[0];
  rMat[2]  = axMat[1];
  rMat[3]  = rMat[2] * axMat[1];
  rMat[4]  = rMat[3] * axMat[1];
  rMat[5]  = rMat[4] * axMat[1];
  rMat[6]  = rMat[1] * axMat[1];
  rMat[7]  = rMat[6] * axMat[1];
  rMat[8]  = rMat[7] * axMat[1];
  rMat[9]  = rMat[8] * axMat[1];
  rMat[10] = axMat[2];
  rMat[11] = rMat[1] * axMat[2];
  rMat[12] = rMat[2] * axMat[2];
  rMat[13] = rMat[3] * axMat[2];
  rMat[14] = rMat[4] * axMat[2];
  rMat[15] = rMat[5] * axMat[2];
  rMat[16] = rMat[6] * axMat[2];
  rMat[17] = rMat[7] * axMat[2];
  rMat[18] = rMat[8] * axMat[2];
  rMat[19] = rMat[9] * axMat[2];
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  float dstHit;
  eLen = 1. + 0.3 * (1. + cos (tCur));
  chLen = 0.85;
  chRad = 0.03;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit >= dstFar) col = vec3 (0.05);
  else {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    col = HsvToRgb (vec3 (mod (0.5 * tCur, 1.), 1., 1.)) *
       (0.3 + 0.8 * max (dot (vn, ltDir), 0.)) +
       0.5 * pow (max (0., dot (ltDir, reflect (rd, vn))), 128.);
  }
  return clamp (col, 0., 1.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  vec3 ro, rd;
  vec2 vEl, vAz;
  float az, el;
  el = 0.05 * tCur;
  az = 0.11 * tCur;
  vEl = vec2 (cos (el), sin (el));
  vAz = vec2 (cos (az), sin (az));
  vuMat = mat3 (1., 0., 0., 0., vEl.x, - vEl.y, 0., vEl.y, vEl.x) *
     mat3 (vAz.x, 0., vAz.y, 0., 1., 0., - vAz.y, 0., vAz.x);
  rd = normalize (vec3 (uv, 5.5)) * vuMat;
  ro = - vec3 (0., 0., 8.) * vuMat;
  ltDir = normalize (vec3 (1., 1., -1.)) * vuMat;
  BuildRMats ();
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
