// Shader downloaded from https://www.shadertoy.com/view/4sG3Dt
// written by shadertoy user dr2
//
// Name: Stairway from Heaven
// Description: Balls descending (by special request)
// "Stairway from Heaven" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

mat3 QtToRMat (vec4 q) 
{
  mat3 m;
  float a1, a2, s;
  q = normalize (q);
  s = q.w * q.w - 0.5;
  m[0][0] = q.x * q.x + s;  m[1][1] = q.y * q.y + s;  m[2][2] = q.z * q.z + s;
  a1 = q.x * q.y;  a2 = q.z * q.w;  m[0][1] = a1 + a2;  m[1][0] = a1 - a2;
  a1 = q.x * q.z;  a2 = q.y * q.w;  m[2][0] = a1 + a2;  m[0][2] = a1 - a2;
  a1 = q.y * q.z;  a2 = q.x * q.w;  m[1][2] = a1 + a2;  m[2][1] = a1 - a2;
  return 2. * m;
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p;
  p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

const float txRow = 128.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

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

float Fbmn (vec3 p, vec3 n)
{
  vec3 s;
  float a;
  s = vec3 (0.);
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * vec3 (Noisefv2 (p.yz), Noisefv2 (p.zx), Noisefv2 (p.xy));
    a *= 0.5;
    p *= 2.;
  }
  return dot (s, abs (n));
}

vec3 VaryNf (vec3 p, vec3 n, float f)
{
  vec3 g, e;
  float s;
  e = vec3 (0.1, 0., 0.);
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s, Fbmn (p + e.yxy, n) - s,
     Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

const int nBall = 169;
vec3 vnBall, sunDir;
float tCur, dstFar;
int idBall, idObj;

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, fnh;
  dMin = dstFar;
  d = p.y - 0.5;
  if (d < dMin) { dMin = d;  idObj = 1; }
  for (int nh = 0; nh < 15; nh ++) {
    fnh = float (nh);
    q = p;
    q.y -= 0.5 + fnh;
    d = min (d, PrBoxDf (q, 0.48 + vec3 (30. - 2. * fnh, 0.5, 30. - 2. * fnh)));
  }
  if (d < dMin) { dMin = d;  idObj = 2; }
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
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float BallHit (vec3 ro, vec3 rd)
{
  vec4 p;
  vec3 u;
  float b, d, w, dMin, rad;
  dMin = dstFar;
  for (int n = 0; n < nBall; n ++) {
    p = Loadv4 (4 + 4 * n);
    u = ro - p.xyz;
    rad = 0.45 * p.w;
    b = dot (rd, u);
    w = b * b - dot (u, u) + rad * rad;
    if (w >= 0.) {
      d = - b - sqrt (w);
      if (d > 0. && d < dMin) {
        dMin = d;
        vnBall = (u + d * rd) / rad;
        idBall = n;
      }
    }
  }
  return dMin;
}

float BallHitSh (vec3 ro, vec3 rd, float rng)
{
  vec4 p;
  vec3 rs, u;
  float b, d, w, dMin, rad;
  dMin = dstFar;
  for (int n = 0; n < nBall; n ++) {
    p = Loadv4 (4 + 4 * n);
    u = ro - p.xyz;
    rad = 0.45 * p.w;
    b = dot (rd, u);
    w = b * b - dot (u, u) + rad * rad;
    if (w >= 0.) {
      d = - b - sqrt (w);
      if (d > 0. && d < dMin) dMin = d;
    }
  }
  return smoothstep (0., rng, dMin);
}

float BallChqr (int idBall, vec3 vnBall)
{
  vec3 u;
  u = vnBall * QtToRMat (Loadv4 (4 + 4 * idBall + 2));
  return 0.4 + 0.6 * step (0., sign (u.y) * sign (u.z) * atan (u.x, u.y));
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, vn, bgCol;
  float dstGrnd, dstBall, sh, c;
  bgCol = 0.8 * vec3 (0.45, 0.35, 0.15);
  dstGrnd = ObjRay (ro, rd);
  dstBall = BallHit (ro, rd);
  if (min (dstBall, dstGrnd) < dstFar) {
    if (dstGrnd < dstBall) {
      ro += rd * dstGrnd;
      if (idObj == 1) {
        vn = VaryNf (0.5 * ro, vec3 (0., 1., 0.), 2.);
        objCol = vec4 (mix (bgCol - 0.05, bgCol + 0.05, Fbm2 (0.5 * ro.xz)), 0.);
      } else {
        vn = VaryNf (5. * ro, ObjNf (ro), 5.);
        objCol = vec4 (vec3 (0.7, 0.75, 0.7) * (1. -
           0.4 * Fbm2 (30. * vec2 (dot (ro.yzx, vn), dot (ro.zxy, vn)))), 0.1);
      }
    } else {
      ro += rd * dstBall;
      vn = vnBall;
      c = 33. * float (idBall) / float (nBall);
      objCol = vec4 (HsvToRgb (vec3 (mod (c, 1.), 1. - 0.1 * mod (c, 8.),
         1. - 0.05 * mod (c, 13.))), 1.);
      objCol.rgb *= BallChqr (idBall, vnBall);
    }
    sh = BallHitSh (ro + 0.01 * sunDir, sunDir, 10.);
    col = objCol.rgb * (0.2 + 0.8 * sh * max (dot (vn, sunDir), 0.) +
       0.3 * max (dot (vn, vec3 (- sunDir.x, 0., - sunDir.z)), 0.)) +
       objCol.a * sh * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.);
    col = mix (col, bgCol, clamp (3. * min (dstBall, dstGrnd) / dstFar - 2.,
       0., 1.));
  } else col = bgCol;
  return pow (clamp (col, 0., 1.), vec3 (0.7));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 col, rd, ro, vd, u;
  vec2 canvas, uv;
  float az, el, zmFac, f;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  dstFar = 220.;
  az = 0.25 * pi;
  el = 0.15 * pi;
  zmFac = 5.;
  if (mPtr.z > 0.) {
    el = clamp (el - 0.5 * pi * mPtr.y, 0.02 * pi, 0.45 * pi);
    az -= 2. * pi * mPtr.x;
  }
  ro = 120. * vec3 (cos (el) * cos (az), sin (el), cos (el) * sin (az));
  vd = normalize (vec3 (0., -2., 0.) - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (uv, zmFac));
  sunDir = normalize (vec3 (cos (0.007 * tCur), 3., sin (0.007 * tCur)));
  col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
