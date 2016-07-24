// Shader downloaded from https://www.shadertoy.com/view/4s3Xzn
// written by shadertoy user dr2
//
// Name: Jumping Cubes
// Description: The cubes are free!!
// "Jumping Cubes" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

mat3 QtToRMat (vec4 q) 
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
  const vec3 e = vec3 (0.1, 0., 0.);
  vec3 g;
  float s;
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

const int nBlock = 64;
const int nSiteBk = 27;
const vec3 blkSph = vec3 (3.);
const vec3 blkGap = vec3 (0.4);

vec3 vnBlk, fcBlk, sunDir;
vec2 qBlk;
float tCur, dstFar;
int idBlk;

float BlkHit (vec3 ro, vec3 rd)
{
  mat3 m;
  vec3 rm, rdm, v, tm, tp, bSize, u;
  float dMin, dn, df;
  bSize = 0.5 * blkGap * (blkSph - 1.) + 0.4;
  dMin = dstFar;
  for (int n = 0; n < nBlock; n ++) {
    rm = Loadv4 (4 + 4 * n).xyz;
    m = QtToRMat (Loadv4 (4 + 4 * n + 2));
    rdm = rd * m;
    v = ((ro - rm) * m) / rdm;
    tp = bSize / abs (rdm) - v;
    tm = - tp - 2. * v;
    dn = max (max (tm.x, tm.y), tm.z);
    df = min (min (tp.x, tp.y), tp.z);
    if (df > 0. && dn < min (df, dMin)) {
      dMin = dn;
      fcBlk = - sign (rdm) * step (tm.zxy, tm) * step (tm.yzx, tm);
      idBlk = n;
      u = (v + dn) * rdm;
    }
  }
  if (dMin < dstFar) {
    qBlk = vec2 (dot (u.zxy, fcBlk), dot (u.yzx, fcBlk));
    vnBlk = QtToRMat (Loadv4 (4 + 4 * idBlk + 2)) * fcBlk;
  }
  return dMin;
}

float BlkHitSh (vec3 ro, vec3 rd, float rng)
{
  mat3 m;
  vec3 rm, rdm, v, tm, tp, bSize;
  float dMin, dn, df;
  bSize = 0.5 * blkGap * (blkSph - 1.) + 0.4;
  dMin = dstFar;
  for (int n = 0; n < nBlock; n ++) {
    rm = Loadv4 (4 + 4 * n).xyz;
    m = QtToRMat (Loadv4 (4 + 4 * n + 2));
    rdm = rd * m;
    v = ((ro - rm) * m) / rdm;
    tp = bSize / abs (rdm) - v;
    tm = - tp - 2. * v;
    dn = max (max (tm.x, tm.y), tm.z);
    df = min (min (tp.x, tp.y), tp.z);
    if (df > 0. && dn < min (df, dMin)) dMin = dn;
  }
  return smoothstep (0., rng, dMin);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, vn, grCol, bgCol;
  vec2 w, iw;
  float dstBlk, sh, dstGrnd;
  bgCol = vec3 (0.2, 0.4, 0.7);
  grCol = vec3 (0.3, 0.5, 0.2);
  dstBlk = BlkHit (ro, rd);
  dstGrnd = (rd.y < 0.) ? - (ro.y - 0.5) / rd.y : dstFar;
  if (min (dstBlk, dstGrnd) < dstFar) {
    if (dstBlk < dstFar) {
      ro += rd * dstBlk;
      vn = vnBlk;
      if (max (abs (qBlk.x), abs (qBlk.y)) > 0.7) objCol = vec4 (1.);
      else objCol = vec4 (abs (fcBlk), 1.);
    } else if (dstGrnd < dstFar) {
      ro += rd * dstGrnd;
      vn = VaryNf (0.5 * ro, vec3 (0., 1., 0.), 2.);
      objCol = vec4 (mix (grCol - 0.05, grCol + 0.05, Fbm2 (0.5 * ro.xz)), 0.);
    }
    sh = 0.2 + 0.8 * BlkHitSh (ro + 0.01 * sunDir, sunDir, 30.);
    col = objCol.rgb * (0.1 + 0.9 * sh * max (dot (vn, sunDir), 0.) +
       0.2 * max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.)) +
       objCol.a * sh * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.);
    col = mix (col, bgCol, clamp (4. * min (dstBlk, dstGrnd) / dstFar - 3.,
       0., 1.));
  } else col = bgCol;
  return clamp (col, 0., 1.);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 col, rd, ro;
  vec2 canvas, uv, ori, ca, sa;
  float az, el;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  dstFar = 200.;
  az = 0.;
  el = 0.1 * pi;
  if (mPtr.z > 0.) {
    el = clamp (el - 2. * mPtr.y, 0.05 * pi, 0.45 * pi);
    az -= 7. * mPtr.x;
  }
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = vec3 (0., 5., - 100.) * vuMat;
  rd = normalize (vec3 (uv, 6.)) * vuMat;
  sunDir = normalize (vec3 (-0.5, 1., -1.));
  col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
