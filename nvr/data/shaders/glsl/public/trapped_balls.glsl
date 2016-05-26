// Shader downloaded from https://www.shadertoy.com/view/4dV3RG
// written by shadertoy user dr2
//
// Name: Trapped Balls
// Description: Get the balls into any of the 4 holes within the time limit
// "Trapped Balls" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*

Get the balls into any of the 4 holes within the time limit.

Tray angle is changed by moving the knob in the control box.

Until play starts the tray angle varies gradually by itself, and while the mouse
pointer is not in the control box it adjusts the view angle.

The game stops after 2 minutes (remaining time is shown), or when all balls have
gone.

*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

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

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrShCylDf (vec3 p, float rIn, float rEx, float h)
{
  float s;
  s = length (p.xy);
  return max (max (s - rEx, rIn - s), abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  p.z -= h * clamp (p.z / h, -1., 1.);
  return length (p) - r;
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p;
  p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

const float txRow = 32.;

vec4 Loadv4 (int idVar)
{
  float fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

mat3 QToRMat (vec4 q) 
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

const int nBall = 36;
vec3 vnBall, qHit;
vec2 aTilt;
float dstFar, hbLen;
int idBall, idObj;

float ObjDf (vec3 p)
{
  vec3 q, pp;
  float dMin, d, ww, wh;
  dMin = dstFar;
  ww = 0.2;
  wh = 0.3;
  pp = p;
  pp.xy = Rot2D (pp.xy, - aTilt.x);
  pp.yz = Rot2D (pp.yz, aTilt.y);
  q = pp;  q.y -= -0.6;
  d = PrBoxDf (q, vec3 (hbLen + 0.25, 0.1, hbLen + 0.25));
  q = pp;  q.z = abs (abs (q.z) - hbLen);
  d = max (d, - PrCylDf (q.xzy, 0.55, 1.));
  q = pp;  q.x = abs (abs (q.x) - hbLen);
  d = max (d, - PrCylDf (q.xzy, 0.55, 1.));
  if (d < dMin) { dMin = d;  idObj = 1;  qHit = pp; }
  pp.y -= -0.25;
  q = pp;  q.xz = abs (q.xz) - vec2 (hbLen + 0.05, 0.5 * hbLen + 0.4);
  d = PrBoxDf (q, vec3 (ww, wh, 0.5 * hbLen + 0.25 - 0.4));
  q = pp;  q.xz = abs (q.xz) - vec2 (0.5 * hbLen + 0.4, hbLen + 0.05);
  d = min (d, PrBoxDf (q, vec3 (0.5 * hbLen + 0.25 - 0.4, wh, ww)));
  q = pp;
  d = min (d, min (PrBoxDf (q, vec3 (2., wh, ww)),
     PrBoxDf (q, vec3 (ww, wh, 2.))));
  q = pp;  q.xz = abs (q.xz) - vec2 (0.5 * hbLen, hbLen - 1.);
  d = min (d, PrBoxDf (q, vec3 (ww, wh, 1.)));
  q = pp;  q.xz = abs (q.xz) - vec2 (hbLen - 1., 0.5 * hbLen);
  d = min (d, PrBoxDf (q, vec3 (1., wh, ww)));
  q = pp;  q.x = abs (q.x) - hbLen + 3.;
  d = min (d, PrBoxDf (q, vec3 (ww, wh, 2.)));
  q = pp;  q.x = abs (q.x) - hbLen - 1.5 * ww;  q.y -= -0.5 * wh;
  d = min (d, PrBoxDf (q, vec3 (0.5 * ww, 0.5 * ww, 0.7)));
  q = pp;  q.z = abs (q.z) - hbLen + 3.;
  d = min (d, PrBoxDf (q, vec3 (2., wh, ww)));
  if (d < dMin) { dMin = d;  idObj = 2; }
  q = pp;  q.x = abs (q.x) - hbLen - 0.05;
  d = PrShCylDf (q.zyx, 0.5, 0.8, ww);
  q = pp;  q.z = abs (q.z) - hbLen - 0.05;
  d = max (min (d, PrShCylDf (q, 0.5, 0.8, ww)), - q.y);
  if (d < dMin) { dMin = d;  idObj = 2; }
  pp = p;
  pp.xy = Rot2D (pp.xy, - aTilt.x);
  pp.y -= -0.5;
  q = pp;  q.x = abs (q.x) - hbLen - 0.8;
  d = PrCylDf (q.yzx, 0.5, 0.5);
  if (d < dMin) { dMin = d;  idObj = 3; }
  d = PrBoxDf (q, vec3 (ww, ww, hbLen + 1.));  
  q = pp;  q.z = abs (q.z) - hbLen - 0.8;
  d = min (d, PrBoxDf (q, vec3 (hbLen + 1., ww, ww)));  
  if (d < dMin) { dMin = d;  idObj = 4; }
  q = p;  q.y -= -0.5;  q.z = abs (q.z) - hbLen - 0.8;
  d = PrCylDf (q, 0.5, 0.5);
  if (d < dMin) { dMin = d;  idObj = 3; }
  q = p;  q.y -= -4.6;  q.z = abs (q.z) - hbLen - 1.3;
  d = PrCapsDf (q.xzy, 0.3, 4.);  
  if (d < dMin) { dMin = d;  idObj = 4; }
  q = p;  q.y -= -8.5;  
  d = PrBoxDf (q, vec3 (1., ww, hbLen + 1.8));  
  if (d < dMin) { dMin = d;  idObj = 5; }

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
  const vec3 e = vec3 (0.0002, -0.0002, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.05;
  for (int j = 0; j < 25; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 20. * h / d));
    d += min (0.15, 3. * h);
    if (h < 0.001) break;
  }
  return 0.2 + 0.8 * sh;
}

float BallRay (vec3 ro, vec3 rd)
{
  vec3 u;
  vec2 p;
  float b, d, w, dMin, rad, radSq;
  ro.xy = Rot2D (ro.xy, - aTilt.x);
  ro.yz = Rot2D (ro.yz, aTilt.y);
  rd.xy = Rot2D (rd.xy, - aTilt.x);
  rd.yz = Rot2D (rd.yz, aTilt.y);
  dMin = dstFar;
  rad = 0.46;
  radSq = rad * rad;
  for (int n = 0; n < nBall; n ++) {
    p = Loadv4 (4 + 2 * n).xy;
    u = ro - vec3 (p.x, 0., p.y);
    b = dot (rd, u);
    w = b * b - dot (u, u) + radSq;
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

vec3 WoodCol (vec3 p, vec3 n)
{
  p *= 4.;
  float f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.xz * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return mix (vec3 (0.8, 0.4, 0.2), vec3 (0.45, 0.25, 0.1), f);
}

float BallChqr (int idBall, vec3 vnBall)
{
  vec3 u;
  u = QToRMat (Loadv4 (4 + 2 * idBall + 1)) * vnBall;
  return 0.4 + 0.6 * step (0., sign (u.y) * sign (u.z) * atan (u.x, u.y));
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 qtHit, objCol;
  vec3 col, vn, rHit, ltDir1, ltDir2;
  float dstHit, dstBall, reflCol, lcd, lcs, sh;
  int idObjT;
  bool doRefl;
  dstBall = BallRay (ro, rd);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  reflCol = 1.;
  doRefl = false;
  if (dstHit < dstBall) {
    if (idObj == 1) {
      if (qHit.y > -0.5 && max (abs (qHit.x), abs (qHit.z)) < hbLen - 0.1 &&
         mod (floor (4. * qHit.x), 2.) == mod (floor (4. * qHit.z), 2.))
         doRefl = true;
    }
  }
  if (doRefl) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    rd = reflect (rd, vn);
    ro += 0.01 * rd;
    dstBall = BallRay (ro, rd);
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
    reflCol = 0.8;
  }
  if (min (dstBall, dstHit) < dstFar) {
    ltDir1 = normalize (vec3 (0., 1., 0.));
    ltDir2 = normalize (vec3 (1., 1., 1.));
    sh = 1.;
    if (dstHit < dstBall) {
      ro += rd * dstHit;
      idObjT = idObj;
      vn = ObjNf (ro);
      idObj = idObjT;
      if (idObj == 1) objCol = vec4 (0.25, 0.2, 0.2, 0.1);
      else if (idObj == 2) objCol = vec4 (0.6, 0.5, 0.1, 0.4);
      else if (idObj == 3) objCol = vec4 (0.8, 0.8, 0., 1.);
      else if (idObj == 4) objCol = vec4 (0.6, 0.6, 0.4, 1.);
      else if (idObj == 5) objCol = vec4 (WoodCol (ro, vn), 0.3);
      if (idObj > 1) sh = ObjSShadow (ro, ltDir2);
    } else {
      vn = vnBall;
      objCol = vec4 (HsvToRgb (vec3 (float (idBall) / float (nBall), 0.8, 1.)) *
         BallChqr (idBall, vn), 0.8);
    }
    lcd = 0.4 * max (dot (vn, ltDir1), 0.) + 0.6 * sh * max (dot (vn, ltDir2), 0.);
    lcs = pow (max (0., dot (ltDir1, reflect (rd, vn))), 64.) +
       sh * pow (max (0., dot (ltDir2, reflect (rd, vn))), 64.);
    col = reflCol * objCol.rgb * (0.2 + 0.8 * lcd + objCol.a * lcs);
  } else col = mix (vec3 (0., 0., 0.6), vec3 (0., 0.4, 0.),
       0.1 + 0.2 * (1. - smoothstep (0.8, 0.9, abs (rd.y))) *
       Fbm2 (16. * vec2 (2. * abs (atan (rd.z, rd.x)) / pi, rd.y)));
  return pow (clamp (col, 0., 1.), vec3 (0.7));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr, p;
  vec3 rd, ro, col, u, vd;
  vec2 canvas, uv, us, ut, um;
  float tCur, az, el, zmFac, asp, f, tFrac, autoRot;
  canvas = iResolution.xy;
  uv = 2. * fragCoord / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  dstFar = 100.;
  p = Loadv4 (0);
  hbLen = p.y;
  autoRot = p.z;
  p = Loadv4 (1);
  aTilt = p.xy;
  tFrac = p.z;
  mPtr = Loadv4 (2);
  asp = canvas.x / canvas.y;
  el = 0.;
  az = 0.;
  zmFac = 2.5;
  um = vec2 (0.4, 0.3) * vec2 (asp, 1.);
  if (autoRot > 0.) {
    if (mPtr.z > 0. &&
       max (abs (mPtr.x - um.x) * asp, abs (mPtr.y - um.y)) > 0.125) {
      az += 6. * mPtr.x;
      el -= 5. * mPtr.y;
      el = clamp (el, -0.1 * pi, 0.4 * pi);
    } else {
      el += 0.4;
      az -= 0.1 * tCur;
    }
  } else {
    az = 0.;
    el = 0.4 * pi;
    zmFac = 3.;
  }
  ro = 30. * vec3 (cos (el) * sin (az), sin (el), cos (el) * cos (az));
  vd = normalize (vec3 (0., -1., 0.) - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (uv, zmFac));
  col = ShowScene (ro, rd);
  us = uv - 2. * um;
  ut = abs (us) - vec2 (0.25);
  if (max (ut.x, ut.y) < 0.) {
    if (min (abs (ut.x), abs (ut.y)) < 0.015) col = vec3 (0., 0.7, 0.);
    else {
      f = length (0.5 * us - (1./5.5) * aTilt) - 0.02;
      col = mix (mix (vec3 (1., 0.8, 0.1), vec3 (0., 0., 1.),
         step (0.005, abs (f))), vec3 (0.1, 0.1, 0.4), step (0., f));
    }
  }
  ut = uv - vec2 (-0.8, 0.8) * vec2 (asp, 1.);
  f = length (ut) - 0.06;
  if (f < 0.) col = mix (mix (vec3 (0., 1., 0.), vec3 (1., 0., 0.),
     step (0.5 * (atan (- ut.x, - ut.y) / pi + 1.), tFrac)),
     vec3 (0., 1., 0.), step (0.02, abs (f + 0.03)));
  fragColor = vec4 (col, 1.);
}
