// Shader downloaded from https://www.shadertoy.com/view/lsGXR1
// written by shadertoy user dr2
//
// Name: Punched Pi In The Sky
// Description: ** PI **
// "Punched Pi In The Sky" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Large window helps; mouse enabled.

float PrRnd2BoxDf (vec3 p, vec3 b, float r);
float ShowInt (vec2 q, vec2 cBox, float mxChar, float val);
float Fbm2 (vec2 p);

const float pi = 3.14159;

mat3 vuMat;
vec3 ltDir;
vec2 cSize;
float dstFar, tCur;

float ObjDf (vec3 p)
{
  vec3 q;
  float d;
  q = p.xzy;
  d = PrRnd2BoxDf (q, vec3 (cSize.x - 0.1, 0.003, cSize.y - 0.1), 0.1);
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
  u = vec2 (0.01 * tCur + rd.xy / rd.z);
  return mix (mix (vec3 (0., 0., 0.7), vec3 (0.8), 0.7 * Fbm2 (12. * u)),
     vec3 (0.3, 0.3, 0.6), smoothstep (0.35 * pi, 0.4 * pi, a));
}

#define NDIG  51
// 314159265358979323846264338327950288419716939937510

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col, bgCol;
  vec2 fd, id, cBox;
  float pv[NDIG], dstObj, t;
  pv[0]  = 3.;
  pv[1]  = 1.; pv[2]  = 4.; pv[3]  = 1.; pv[4]  = 5.; pv[5]  = 9.;
  pv[6]  = 2.; pv[7]  = 6.; pv[8]  = 5.; pv[9]  = 3.; pv[10] = 5.;
  pv[11] = 8.; pv[12] = 9.; pv[13] = 7.; pv[14] = 9.; pv[15] = 3.;
  pv[16] = 2.; pv[17] = 3.; pv[18] = 8.; pv[19] = 4.; pv[20] = 6.;
  pv[21] = 2.; pv[22] = 6.; pv[23] = 4.; pv[24] = 3.; pv[25] = 3.;
  pv[26] = 8.; pv[27] = 3.; pv[28] = 2.; pv[29] = 7.; pv[30] = 8.;
  pv[31] = 5.; pv[32] = 0.; pv[33] = 2.; pv[34] = 8.; pv[35] = 8.;
  pv[36] = 4.; pv[37] = 1.; pv[38] = 9.; pv[39] = 7.; pv[40] = 1.;
  pv[41] = 6.; pv[42] = 9.; pv[43] = 3.; pv[44] = 9.; pv[45] = 9.;
  pv[46] = 3.; pv[47] = 7.; pv[48] = 5.; pv[49] = 1.; pv[50] = 0.;
  t = mod (2. * tCur, 60.);
  cSize = vec2 (2.269, 1.);
  dstObj = ObjRay (ro, rd);
  bgCol = BgCol (rd);
  cBox = vec2 (0.45, 0.3);
  if (dstObj < dstFar) {
    ro += rd * dstObj;
    vn = ObjNf (ro);
    col = vec3 (1., 0.9, 0.9);
    ro.y *= -1.;
    fd = 0.5 * (ro.xy / cSize + 1.) * vec2 (84., 13.) - vec2 (2., 0.5);
    id = floor (fd) - vec2 (0., 2.);
    fd = fract (fd) - 0.5;
    fd.y *= -1.;
    if (id.y <= 9. && id.x >= 0. && id.x < 80. && vn.z < -0.99) {
      if (id.y >= 0.) {
        col *= 1. - 0.15 * (1. - smoothstep (0.35, 0.38, abs (fd.x))) *
           (1. - smoothstep (0.25, 0.27, abs (fd.y)));
        col = mix (col, vec3 (0.05), ShowInt (fd - vec2 (0.2, -0.15),
           cBox, 1., id.y));
      } else if (id.y == -1.) col = mix (col, vec3 (0.05),
         ShowInt (fd - vec2 (0.2, -0.15), 0.8 * cBox, 1., mod (id.x + 1., 10.)));
    }
    col *= (0.5 + 0.5 * max (dot (vn, ltDir), 0.));
    if (t > 2.) {
      for (int k = 0; k < NDIG; k ++) {
        if (id.x == 6. + float (k)) {
          if (id.y == pv[k]) col = mix (col, bgCol,
             (1. - step (0.38, abs (fd.x))) * (1. - step (0.27, abs (fd.y))));
          else if (id.y == -2. && vn.z < -0.99) col = mix (col, vec3 (0.2),
             ShowInt (fd - vec2 (0.2, -0.15), 1.2 * cBox, 1., pv[k]));
        }
        if (float (k + 1) >= t - 2.) break;
      }
    }
  } else col = bgCol;
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
  }
  dstFar = 15.;
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
          mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  rd = vuMat * normalize (vec3 (uv, 5.));
  ro = vuMat * vec3 (0., 0., -7.);
  ltDir = vuMat * normalize (vec3 (0., 0., -1.));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}

float PrRnd2BoxDf (vec3 p, vec3 b, float r)
{
  vec3 d;
  d = abs (p) - b;
  return max (length (max (d.xz, 0.)) - r, d.y);
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

float DigSeg (vec2 q)
{
  return (1. - smoothstep (0.23, 0.27, abs (q.x))) *
     (1. - smoothstep (0.5, 0.57, abs (q.y)));
}

float ShowDig (vec2 q, int iv)
{
  float d;
  int k, kk;
  const vec2 vp = vec2 (0.5, 0.5), vm = vec2 (-0.5, 0.5), vo = vec2 (1., 0.);
  if (iv < 5) {
    if (iv == -1) k = 8;
    else if (iv == 0) k = 119;
    else if (iv == 1) k = 36;
    else if (iv == 2) k = 93;
    else if (iv == 3) k = 109;
    else k = 46;
  } else {
    if (iv == 5) k = 107;
    else if (iv == 6) k = 122;
    else if (iv == 7) k = 37;
    else if (iv == 8) k = 127;
    else k = 47;
  }
  q = (q - 0.5) * vec2 (1.7, 2.3);
  d = 0.;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.yx - vo);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.xy - vp);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.xy - vm);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.yx);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.xy + vm);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.xy + vp);
  k = kk;  kk = k / 2;  if (kk * 2 != k) d += DigSeg (q.yx + vo);
  return d;
}

float ShowInt (vec2 q, vec2 cBox, float mxChar, float val)
{
  float nDig, idChar, s, sgn, v;
  q = vec2 (- q.x, q.y) / cBox;
  s = 0.;
  if (min (q.x, q.y) >= 0. && max (q.x, q.y) < 1.) {
    q.x *= mxChar;
    sgn = sign (val);
    val = abs (val);
    nDig = (val > 0.) ? floor (max (log (val) / log (10.), 0.) + 0.001) + 1. : 1.;
    idChar = mxChar - 1. - floor (q.x);
    q.x = fract (q.x);
    v = val / pow (10., mxChar - idChar - 1.);
    if (sgn < 0.) {
      if (idChar == mxChar - nDig - 1.) s = ShowDig (q, -1);
      else ++ v;
    }
    if (idChar >= mxChar - nDig) s = ShowDig (q, int (mod (floor (v), 10.)));
  }
  return s;
}
