// Shader downloaded from https://www.shadertoy.com/view/XsGXR1
// written by shadertoy user dr2
//
// Name: Linked Rings
// Description: Two Moebius strips
// "Linked Rings" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

float PrBoxDf (vec3 p, vec3 b);
float PrBox2Df (vec2 p, vec2 b);
vec2 Rot2D (vec2 q, float a);
float Fbm2 (vec2 p);

const float pi = 3.14159;

mat3 vuMat;
vec3 ltDir;
float dstFar, tCur, mobRad;

float MobiusTDf (vec3 p, float r, float b, float rc, float ns)
{
  vec3 q;
  float d, a, na, aq;
  p.xz = Rot2D (p.xz, 0.1 * tCur);
  q = vec3 (length (p.xz) - r, 0., p.y);
  a = atan (p.z, p.x);
  q.xz = Rot2D (q.xz, 0.5 * a);
  d = length (max (abs (q.xz) - b, 0.)) - rc;
  q = p;
  na = floor (ns * atan (q.z, - q.x) / (2. * pi));
  aq = 2. * pi * (na + 0.5) / ns;
  q.xz = Rot2D (q.xz, aq);
  q.x += r;
  q.xy = Rot2D (q.xy, 0.5 * aq);
  d = max (d, - max (PrBoxDf (q, vec3 (1.1, 1.1, 0.18) * b),
    - PrBox2Df (q.xy, vec2 (0.5, 0.5) * b)));
  return 0.7 * d;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float d, a, aq, na;
  q = p;
  q.z -= 0.5 * mobRad;
  d = MobiusTDf (q, mobRad, 0.6, 0.01, 16.);
  q = p;
  q.z += 0.5 * mobRad;
  d = min (d, MobiusTDf (q.zxy, mobRad, 0.6, 0.01, 16.));
  return d;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 120; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.0005 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

vec3 BgCol (vec3 rd)
{
  vec2 u;
  float a;
  rd = rd * vuMat;
  a = 0.5 * atan (length (rd.xy), rd.z);
  rd = normalize (vec3 (rd.xy * tan (a), 1.));
  u = vec2 (0.1 * tCur + rd.xy / rd.z);
  return mix (mix (vec3 (0., 0., 0.6), vec3 (1.), 0.7 * Fbm2 (2. * u)),
     vec3 (0.3, 0.3, 0.6), smoothstep (0.35 * pi, 0.4 * pi, a));
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 ror, rdr, vn, col;
  float dstObj, dstObjR, reflFac;
  dstObj = ObjRay (ro, rd);
  reflFac = 1.;
  if (dstObj < dstFar) {
    ror = ro + rd * dstObj;
    rdr = reflect (rd, ObjNf (ror));
    ror += 0.01 * rdr;
    dstObjR = ObjRay (ror, rdr);
    if (dstObjR < dstFar) {
      dstObj = dstObjR;
      ro = ror;
      rd = rdr;
      reflFac = 0.7;
    }
  }
  if (dstObj < dstFar) {
    ro += rd * dstObj;
    vn = ObjNf (ro);
    col = vec3 (0.3, 0.3, 0.6) * (0.2 + 0.8 * max (dot (vn, ltDir), 0.) +
       0.5 * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.));
    col = reflFac * mix (col, BgCol (reflect (rd, vn)), 0.5);
  } else col = vec3 (0., 0.2, 0.2);
  return clamp (col, 0., 1.);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 mPtr;
  vec3 ro, rd;
  vec2 canvas, uv, ori, ca, sa;
  float el, az;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  az = 0.;
  el = 0.;
  if (mPtr.z > 0.) {
    az += 3. * pi * mPtr.x;
    el += 1.5 * pi * mPtr.y;
  } else {
    az -= 0.2 * tCur;
    el -= 0.2 * pi * cos (0.2 * tCur);
  }
  dstFar = 20.;
  mobRad = 1.8;
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
          mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  rd = vuMat * normalize (vec3 (uv, 2.8));
  ro = vuMat * vec3 (0., 0., -10.);
  ltDir = vuMat * normalize (vec3 (1., 1., -1.));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrBox2Df (vec2 p, vec2 b)
{
  vec2 d = abs (p) - b;
  return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

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
