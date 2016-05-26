// Shader downloaded from https://www.shadertoy.com/view/XdGSRD
// written by shadertoy user dr2
//
// Name: Gyroscope
// Description: Gyroscope simulation; (unlike an earlier version) the differential
//      equations describing the dynamics are solved numerically.
//    Usage described in source.
// "Gyroscope" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  Gyroscope simulation; (unlike an earlier version) the differential
  equations describing the dynamics are solved numerically. The balls
  trace the trajectory which includes both precession and nutation
  (the total energy can be shown - it should remain constant).

  The sliders control four of the five independent parameters of the
  system (the fifth is the spin rate). From left to right:
    Initial elevation
    Initial precession rate
    Ratio of moments of inertia
    Gravity (owest value is zero)
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

mat3 QtToRMat (vec4 q);
vec2 Rot2D (vec2 q, float a);
float PrSphDf (vec3 p, float s);
float PrCylDf (vec3 p, float r, float h);
float PrRCylDf (vec3 p, float r, float rt, float h);
float PrCapsDf (vec3 p, float r, float h);
float PrTorusDf (vec3 p, float ri, float rc);
float ShowInt (vec2 q, vec2 cBox, float mxChar, float val);
vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, vec4 slVal);
vec4 Loadv4 (int idVar);

const float pi = 3.14159;
const float txRow = 32.;

mat3 rMat;
vec3 vnBall, ltDir;
float dstFar, axLen, bLen;
int idObj;
const int ntPoint = 100;

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, bRad, wlRad;
  bRad = 0.06;
  wlRad = 0.45;
  dMin = dstFar;
  q = p;
  d = PrCapsDf (q.xzy, bRad * (1. - 0.4 * q.y / bLen), 0.9 * bLen);
  if (d < dMin) { dMin = d;  idObj = 1; }
  q.y -= bLen;
  d = PrSphDf (q, 0.07 * wlRad);
  if (d < dMin) { dMin = d;  idObj = 3; }
  q.y -= -2.05 * bLen;
  d = PrRCylDf (q.xzy, 10. * bRad, 0.03 * bLen, 0.08 * bLen);
  if (d < dMin) { dMin = d;  idObj = 2; }
  q = p;  q.y -= bLen;
  q.xz = Rot2D (q.xz, -0.5 * pi);
  q = q.xzy * rMat;
  q.z -= axLen;
  d = PrTorusDf (q, 0.06 * wlRad, wlRad);
  d = min (d, PrCylDf (q, 0.07 * wlRad, 0.05 * wlRad));
  if (d < dMin) { dMin = d;  idObj = 3; }
  q.z += 0.5 * axLen;
  d = min (d, PrCylDf (q, 0.03 * wlRad, 0.5 * axLen));
  if (d < dMin) { dMin = d;  idObj = 4; }
  q.z -= 0.5 * axLen;
  q.xy = Rot2D (q.xy, 2. * pi *
     (floor (3. * atan (q.y, - q.x) / (2. * pi)) + 0.5) / 3.);
  q.x += 0.5 * wlRad;
  d = PrCylDf (q.yzx, 0.04 * wlRad, 0.5 * wlRad);
  if (d < dMin) { dMin = d;  idObj = 4; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
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

float TBallHit (vec3 ro, vec3 rd)
{
  vec3 p, v;
  vec2 e;
  float b, d, w, dMin, sz;
  dMin = dstFar;
  sz = 0.018;
  for (int n = 0; n < ntPoint; n ++) {
    e = Loadv4 (9 + n).xy;
    p = 0.93 * axLen * vec3 (sin (e.y) * cos (e.x), cos (e.y),
       sin (e.y) * sin (e.x));
    p.y += bLen;
    v = ro - p;
    b = dot (rd, v);
    w = b * b + sz * sz - dot (v, v);
    if (w >= 0.) {
      d = - b - sqrt (w);
      if (d > 0. && d < dMin) {
        dMin = d;
        vnBall = (v + d * rd) / sz;
      }
    }
  }
  return dMin;
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.04;
  for (int j = 0; j < 50; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 0.04 * d, h));
    d += max (0.04, 0.05 * d);
    if (sh < 0.05) break;
  }
  return 0.5 + 0.5 * sh;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col;
  float dstObj, dstBall, sh;
  int idObjT;
  dstBall = TBallHit (ro, rd);
  dstObj = ObjRay (ro, rd);
  if (dstBall < min (dstObj, dstFar)) {
    col = vec3 (0., 1., 0.2) * (0.4 + 0.6 * max (dot (vnBall, ltDir), 0.));
  } else if (dstObj < dstFar) {
    ro += rd * dstObj;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if      (idObj == 1) col = vec3 (0.5, 0.1, 0.1);
    else if (idObj == 2) col = vec3 (0.2, 0.2, 0.7);
    else if (idObj == 3) col = vec3 (0.8, 0.8, 0.1);
    else if (idObj == 4) col = vec3 (0.6, 0.6, 0.7);
    sh = ObjSShadow (ro, ltDir);
    col = col * (0.2 + 0.8 * sh * max (dot (vn, ltDir), 0.) +
       0.8 * sh * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.));
  } else col = (1. - 2. * dot (rd.xy, rd.xy)) * vec3 (0.2, 0.25, 0.3);
  col = clamp (col, 0., 1.);
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 stDat, slVal;
  vec3 ro, rd, col;
  vec2 canvas, uv, ori, ca, sa;
  float asp, eTot;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  dstFar = 15.;
  asp = canvas.x / canvas.y;
  stDat = Loadv4 (0);
  eTot = stDat.y;
  ori = stDat.zw;
  rMat = QtToRMat (Loadv4 (1));
  slVal = Loadv4 (7);
  axLen = 0.8 + 0.3 * slVal.z;
  bLen = 0.7;
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  rd = vuMat * normalize (vec3 (uv, 3.));
  ro = vuMat * vec3 (0., 0.6, -5.);
  ltDir = vuMat * normalize (vec3 (1., 2., -1.));
  col = ShowScene (ro, rd);
  col = ShowWg (uv, canvas, col, slVal);
  if (false) col = mix (col, vec3 (1., 1., 0.),
     ShowInt (0.5 * uv - vec2 (0.47 * asp, - 0.45),
     vec2 (0.06 * asp, 0.03), 4., floor (0.1 * eTot)));
  fragColor = vec4 (col, 1.);
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrRCylDf (vec3 p, float r, float rt, float h)
{
  vec2 dc;
  float dxy, dz;
  dxy = length (p.xy) - r;
  dz = abs (p.z) - h;
  dc = vec2 (dxy, dz) + rt;
  return min (min (max (dc.x, dz), max (dc.y, dxy)), length (dc) - rt);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  return length (vec2 (length (p.xy) - rc, p.z)) - ri;
}

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

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, vec4 slVal)
{
  vec4 wgBx[4];
  vec3 cc[4];
  vec2 ut, ust;
  float vW[4], asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (-0.43 * asp, -0.05, 0.012 * asp, 0.2);
  wgBx[1] = vec4 (-0.35 * asp, -0.05, 0.012 * asp, 0.2);
  wgBx[2] = vec4 ( 0.35 * asp, -0.05, 0.012 * asp, 0.2);
  wgBx[3] = vec4 ( 0.43 * asp, -0.05, 0.012 * asp, 0.2);
  vW[0] = slVal.x;
  vW[1] = slVal.y;
  vW[2] = slVal.z;
  vW[3] = slVal.w;
  cc[0] = vec3 (1., 0., 0.);
  cc[1] = vec3 (1., 0.4, 0.4);
  cc[2] = vec3 (0., 0., 1.);
  cc[3] = vec3 (0.4, 0.4, 1.);
  for (int k = 0; k < 4; k ++) {
    ut = 0.5 * uv - wgBx[k].xy;
    ust = abs (ut) - wgBx[k].zw * vec2 (0.7, 1.);
    if (max (ust.x, ust.y) < 0.) {
      if  (min (abs (ust.x), abs (ust.y)) * canvas.y < 2.) col = vec3 (1., 1., 0.);
      else col = (mod (0.5 * ((0.5 * uv.y - wgBx[k].y) / wgBx[k].w - 0.99), 0.1) *
         canvas.y < 6.) ? vec3 (1., 1., 0.) : vec3 (0.6);
    }
    ut.y -= (vW[k] - 0.5) * 2. * wgBx[k].w;
    ut = abs (ut) * vec2 (1., 2.);
    if (length (ut) < 0.03 && max (ut.x, ut.y) > 0.01) col = cc[k];
  }
  return col;
}

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

float DigSeg (vec2 q)
{
  return (1. - smoothstep (0.13, 0.17, abs (q.x))) *
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

