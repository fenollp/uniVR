// Shader downloaded from https://www.shadertoy.com/view/lsG3Wd
// written by shadertoy user dr2
//
// Name: Colliding Blocks
// Description: Blocks in a sphere
// "Colliding Blocks" by dr2 - 2016
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

const int nBlock = 64;
const int nSiteBk = 27;
const vec3 blkSph = vec3 (3.);
const vec3 blkGap = vec3 (0.4);

vec3 vnBlk, vnSph, ltDir;
vec2 qBlk;
float tCur, dstFar, spRad;
int idBlk;

float SphHit (vec3 ro, vec3 rd)
{
  float b, d, w;
  b = dot (rd, ro);
  w = b * b + spRad * spRad - dot (ro, ro);
  d = dstFar;
  if (w >= 0.) {
    d = - b - sqrt (w);
    vnSph = (ro + d * rd) / spRad;
  }
  return d;
}

float SphHitSh (vec3 ro, vec3 rd, float rng)
{
  float b, d, w;
  b = dot (rd, ro);
  w = b * b + spRad * spRad - dot (ro, ro);
  d = dstFar;
  if (w >= 0.) d = - b - sqrt (w);
  return smoothstep (0., rng, d);
}

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
      vnBlk = - sign (rdm) * step (tm.zxy, tm) * step (tm.yzx, tm);
      idBlk = n;
      u = (v + dn) * rdm;
    }
  }
  if (dMin < dstFar) {
    qBlk = vec2 (dot (u.zxy, vnBlk), dot (u.yzx, vnBlk));
    vnBlk = QtToRMat (Loadv4 (4 + 4 * idBlk + 2)) * vnBlk;
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
  vec3 col, vn, ltDirUp;
  vec2 w, iw;
  float dstBlk, dstSph, c, sh, dstFloor, dstBack;
  bool isBg, isBlk;
  isBg = false;
  isBlk = false;
  ltDirUp = vec3 (0., -1., 0.);
  dstSph = SphHit (ro, rd);
  dstBlk = BlkHit (ro, rd);
  dstFloor = (rd.y < 0.) ? - (ro.y + 1.4 * spRad) / rd.y : dstFar;
  dstBack = (rd.z > 0.) ? (- ro.z + 1.4 * spRad) / rd.z : dstFar;
  if (dstBlk < dstFar) {
    ro += rd * dstBlk;
    vn = vnBlk;
    c = float (idBlk) / float (nBlock);
    objCol = (max (abs (qBlk.x), abs (qBlk.y)) > 0.7) ? vec4 (1.) :
       vec4 (HsvToRgb (vec3 (c, 1. - 0.3 * mod (4. * c, 1.),
       1. - 0.4 * mod (7. * c, 1.))), 0.5);
    isBlk = true;
  } else if (min (dstBack, dstFloor) < dstFar) {
    if (dstBack < dstFloor) {
      ro += dstBack * rd;
      w = 0.25 * ro.xy * vec2 (1., 2.);
      iw = floor (w);
      if (2. * floor (iw.y / 2.) != iw.y) w.x += 0.5;
      w = smoothstep (0.03, 0.05, abs (fract (w + 0.5) - 0.5));
      objCol = vec4 ((1. - 0.4 * w.x * w.y) * vec3 (0.6, 0.65, 0.6), 0.2);
      vn = vec3 (0., 0., -1.);
    } else if (dstFloor < dstFar) {
      ro += dstFloor * rd;
      objCol = vec4 (mix (vec3 (0.8, 0.4, 0.2), vec3 (0.45, 0.25, 0.1),
         Fbm2 (ro.xz * vec2 (1., 0.1))), 0.1) *
         (0.5 + 0.5 * smoothstep (0.05, 0.1, mod (ro.x, 4.)));
      vn = vec3 (0., 1., 0.);
    } else isBg = true;
  } else isBg = true;
  if (isBg) col = vec3 (0., 0., 0.1);
  else {
    sh = min (BlkHitSh (ro + 0.01 * ltDir, ltDir, 100.),
       0.7 + 0.3 * SphHitSh (ro + 0.01 * ltDir, ltDir, 100.));
    col = objCol.rgb * (0.1 + 0.9 * sh * max (dot (vn, ltDir), 0.)) +
       0.5 * objCol.a * sh * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
    if (isBlk) {
      sh = BlkHitSh (vec3 (0., - 1.1 * spRad, 0.), ltDirUp, 100.);
      col += objCol.rgb * (0.3 * sh * max (dot (vn, ltDirUp), 0.)) +
         0.3 * objCol.a * sh * pow (max (0., dot (ltDirUp, reflect (rd, vn))), 64.);
    }
  }
  if (dstSph < dstFar) {
    col = mix (col, vec3 (0.15), pow (1. - abs (dot (rd, vnSph)), 4.));
    col += 0.01 + 0.07 * max (dot (vnSph, ltDir), 0.) +
       0.1 * pow (max (0., dot (ltDir, reflect (rd, vnSph))), 32.) +
       0.06 * max (dot (vnSph, ltDirUp), 0.) +
       0.08 * pow (max (0., dot (ltDirUp, reflect (rd, vnSph))), 32.);
  }

  return clamp (col, 0., 1.);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec3 col, rd, ro;
  vec2 canvas, uv, ori, ca, sa;
  float az, el, ltAng;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  spRad = Loadv4 (0).y;
  dstFar = 150.;
  az = 0.15 * pi * cos (0.05 * pi * tCur);
  el = 0.1 * pi + 0.08 * pi * sin (0.027 * pi * tCur);
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = vec3 (0., 0., - spRad * 3.) * vuMat;
  rd = normalize (vec3 (uv, 2.3)) * vuMat;
  ltAng = 0.35 * pi * sin (0.023 * pi * tCur);
  ltDir = normalize (vec3 (sin (ltAng), 1., - cos (ltAng)));
  col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
