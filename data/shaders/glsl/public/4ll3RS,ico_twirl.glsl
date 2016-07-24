// Shader downloaded from https://www.shadertoy.com/view/4ll3RS
// written by shadertoy user dr2
//
// Name: Ico-Twirl
// Description: Sometimes you need a REAL polyhedron (joke)...
// "Ico-Twirl" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

int idObj;
mat3 rMat[20];
vec3 ltDir, qHit;
float tCur, eLen, faLen, faThk, faRot;
const float dstFar = 20.;
const float C_ab = -0.364863828, C_ia = 0.55357435, C_d = 0.288675135,
   C_r = 0.80901699;
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
  vec2 i = floor (p);
  vec2 f = fract (p);
  f = f * f * (3. - 2. * f);
  vec4 t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

float Fbm2 (vec2 p)
{
  float s = 0.;
  float a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * Noisefv2 (p);
    a *= 0.5;
    p *= 2.;
  }
  return s;
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrSphDf (vec3 p, float r)
{
  return length (p) - r;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

vec3 WoodColP (vec2 p)
{
  return mix (vec3 (0.35, 0.2, 0.1), vec3 (0.25, 0.1, 0.),
     Fbm2 (p * vec2 (2., 20.)));
}

float FacetDf (vec3 p, float dHit)
{
  vec3 q;
  float d, df, dc, a;
  q = p;
  q.z -= C_r * eLen;
  q.yz = Rot2D (q.yz, C_ab);
  q.y += C_d * eLen;
  q.z += 0.5 * C_r * eLen;
  dc = PrCylDf (q, 0.05, 0.5 * C_r * eLen);
  q.z -= 0.5 * C_r * eLen;
  df = PrCylDf (q, 0.75 * faLen, faThk);
  a = faRot;
  df = max (df, dot (q, vec3 (sin (a), cos (a), C_ab)) - C_d * faLen);
  a += (2./3.) * pi;
  df = max (df, dot (q, vec3 (sin (a), cos (a), C_ab)) - C_d * faLen);
  a += (2./3.) * pi;
  df = max (df, dot (q, vec3 (sin (a), cos (a), C_ab)) - C_d * faLen);
  d = min (df, dc);
  if (d < dHit) {
    dHit = d;
    qHit = q;
    if (df < dc) idObj = 1;
    else idObj = 2;
  }
  return dHit;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float d, dHit;
  dHit = dstFar;
  q = p * rMat[0] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[1] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[2] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[3] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[4] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[5] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[6] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[7] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[8] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[9] ;  dHit = FacetDf (q, dHit);
  q = p * rMat[10];  dHit = FacetDf (q, dHit);
  q = p * rMat[11];  dHit = FacetDf (q, dHit);
  q = p * rMat[12];  dHit = FacetDf (q, dHit);
  q = p * rMat[13];  dHit = FacetDf (q, dHit);
  q = p * rMat[14];  dHit = FacetDf (q, dHit);
  q = p * rMat[15];  dHit = FacetDf (q, dHit);
  q = p * rMat[16];  dHit = FacetDf (q, dHit);
  q = p * rMat[17];  dHit = FacetDf (q, dHit);
  q = p * rMat[18];  dHit = FacetDf (q, dHit);
  q = p * rMat[19];  dHit = FacetDf (q, dHit);
  d = PrSphDf (p, 0.2);
  if (d < dHit) { dHit = d;  idObj = 2;  qHit = p; }
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

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, vn;
  float dstHit, tSeq;
  tSeq = mod (tCur, 30.);
  eLen = 1. + 1.4 * SmoothBump (5., 25., 3., tSeq);
  faRot = 0.;
  if (tSeq > 8. && tSeq < 22.) faRot = 4. * pi * (tSeq - 8.) / 14.;
  faLen = 1.01;
  faThk = 0.2;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit >= dstFar) col = vec3 (0.005, 0., 0.);
  else {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    if (idObj == 1) {
      qHit.xy = Rot2D (qHit.xy, faRot);
      objCol = (qHit.z > 0.9 * faThk) ?
        vec4 (WoodColP (qHit.xy), 0.3) :
        vec4 (0.2, 0.15, 0.05, 0.1) *
        (1. - 0.3 * Fbm2 (100. * qHit.xy));
    } else objCol = vec4 (0.2, 0.4, 0.1, 1.);
    col = objCol.rgb * (0.3 + 0.7 * max (dot (vn, ltDir), 0.)) +
       objCol.a * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
  }
  return sqrt (clamp (col, 0., 1.));
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
  az = -0.11 * tCur;
  vEl = vec2 (cos (el), sin (el));
  vAz = vec2 (cos (az), sin (az));
  vuMat = mat3 (1., 0., 0., 0., vEl.x, - vEl.y, 0., vEl.y, vEl.x) *
     mat3 (vAz.x, 0., vAz.y, 0., 1., 0., - vAz.y, 0., vAz.x);
  rd = normalize (vec3 (uv, 3.5)) * vuMat;
  ro = - vec3 (0., 0., 8.) * vuMat;
  ltDir = normalize (vec3 (1., 1., -1.)) * vuMat;
  BuildRMats ();
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
