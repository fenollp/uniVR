// Shader downloaded from https://www.shadertoy.com/view/4tlGz8
// written by shadertoy user dr2
//
// Name: Spinning Tree
// Description: A spinning, flapping mechanical tree.
// "Spinning Tree" by dr2 - 2014
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

vec3 WoodCol (vec3 p, vec3 n)
{
  p *= 4.;
  float f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.zx * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return 0.5 * mix (vec3 (0.8, 0.4, 0.2), vec3 (0.45, 0.25, 0.1), f);
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float AngQnt (float a, float s1, float s2, float nr)
{
  return (s1 + floor (s2 + a * (nr / (2. * pi)))) * (2. * pi / nr);
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

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

int idObj;
vec3 qHit, ltDir;
float tCur, qLevl;
const float dstFar = 150.;

float ObjDf (vec3 p)
{
  const float tLen = 8., tRad = 0.6, bhLen = 1., blLen = 3., dt = 0.15;
  float d, mt1, mt2, sFac, kf, tSeq, r;
  vec3 q = p;
  float dHit = dstFar;
  d = PrCylDf (q.xzy, tRad, tLen);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = 2; }
  q.y -= -1.05 * tLen;
  d = PrCylDf (q.xzy, 6. * tRad, 0.05 * tLen);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = 3; }
  q.y -= 2.05 * tLen + 1.4 * tRad;
  d = PrSphDf (q, 1.5 * tRad);
  if (d < dHit) { dHit = d;  qHit = q;  idObj = 4; }
  tSeq = mod (tCur, 10.) / 10.;
  for (int k = 0; k < 7; k ++) {
    kf = float (k);
    sFac = 1. - 0.1 * kf;
    q = p;  q.y -= (-0.3 + 0.21 * kf) * tLen;
    mt1 = tSeq - 0.3;
    mt2 = 0.9 - tSeq;
    q.xz = Rot2D (q.xz, pi * (0.1 * (1. + kf) + (1. + 0.5 * kf) *
      (mt1 * step (abs (mt1 - dt), dt) + mt2 * step (abs (mt2 - dt), dt))));
    q.xz = Rot2D (q.xz, AngQnt (atan (q.z, - q.x), 0.5, 0., 12.));
    q.x -= - sFac * bhLen;
    d = PrBoxDf (q, sFac * vec3 (bhLen, 0.1 * bhLen, 0.5 * bhLen));
    if (d < dHit) { dHit = d;  qHit = q;  idObj = 1; }
    q.x -= - sFac * bhLen;
    q.xy = Rot2D (q.xy, pi * (-0.36 + 0.25 * smoothstep (0.25, 0.4, tSeq - 0.01 * kf) *
       (1. - smoothstep (0.8, 0.95, tSeq + 0.01 * kf))) * (1. + 0.08 / sFac));
    q.x -= - sFac * blLen;
    r = 0.5 * (1. - q.x / (sFac * blLen));
    d = PrBoxDf (q, sFac *
       vec3 (blLen, 0.1 * bhLen * (1. - 0.8 * r), 0.5 * bhLen * (1. + 0.7 * r)));
    if (d < dHit) { dHit = d;  qHit = q / (sFac * blLen);  idObj = 1;  qLevl = kf; }
  }
  return dHit;
}

float ObjRay (vec3 ro, vec3 rd)
{
  const float dTol = 0.001;
  float d;
  float dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < dTol || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh = 1.;
  float d = 0.1;
  for (int i = 0; i < 100; i++) {
    float h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.1;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 ObjCol (vec3 n)
{
  vec3 col;
  if (idObj == 1) {
    if (length (vec2 (qHit.x + 0.85, qHit.z)) < 0.1)
       col = HsvToRgb (vec3 (mod (0.5 * tCur - qLevl / 7., 1.), 1., 1.));
    else col = vec3 (0.1, 1., 0.1);
  } else if (idObj == 2) col = WoodCol (3. * qHit.xzy, n);
  else if (idObj == 3) col = WoodCol (qHit, n);
  else if (idObj == 4) col = HsvToRgb (vec3 (mod (0.3 * tCur, 1.), 1., 1.));
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, objCol, col;
  float dstHit, dif;
  int idObjT;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  idObjT = idObj;
  if (dstHit >= dstFar) col = vec3 (0., 0., 0.04);
  else {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = ObjCol (vn);
    dif = max (dot (vn, ltDir), 0.);
    col = objCol * (0.2 + max (0., dif) * ObjSShadow (ro, ltDir) *
       (dif + pow (max (0., dot (ltDir, reflect (rd, vn))), 128.)));
  }
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  float dist = 30.;
  float az = 0.;
  float el = 0.2;
  float cEl = cos (el);
  float sEl = sin (el);
  float cAz = cos (az);
  float sAz = sin (az);
  mat3 vuMat = mat3 (1., 0., 0., 0., cEl, - sEl, 0., sEl, cEl) *
     mat3 (cAz, 0., sAz, 0., 1., 0., - sAz, 0., cAz);
  vec3 rd = normalize (vec3 (uv, 2.4)) * vuMat;
  vec3 ro = - vec3 (0., 0., dist) * vuMat;
  ltDir = normalize (vec3 (-0.5, 0.8, -0.4));
  vec3 col = ShowScene (ro, rd);
  float vv = dot (uv, uv);
  col = mix (col, vec3 (1., 1., 0.1), smoothstep (0.8, 1., vv * vv));
  fragColor = vec4 (col, 1.);
}
