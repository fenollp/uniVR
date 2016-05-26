// Shader downloaded from https://www.shadertoy.com/view/lsVXW1
// written by shadertoy user dr2
//
// Name: Twisted Curves
// Description: Includes knots, linked rings, Moebius strips
// "Twisted Curves" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
 Includes knots, linked rings, Moebius strips

 The three sliders (left->right) control the order, twist and connectivity;
 play with them to determine what does what.
 
 See: www.fractalforums.com/new-theories-and-research/
       not-fractal-but-funny-trefoil-knot-routine/
*/

float ShowInt (vec2 q, vec2 cBox, float mxChar, float val);
float Fbm2 (vec2 p);
vec2 Rot2D (vec2 q, float a);
vec4 Loadv4 (int idVar);

const float pi = 3.14159;

mat3 vuMat;
vec3 ltDir;
float dstFar, tCur, cvOrd, cvWrapI, cvWrapF;

float ObjDf (vec3 p)
{
  vec2 q;
  float twAng, rAng, s;
  twAng = (cvWrapI + cvWrapF / cvOrd) * atan (p.z, p.x);
  q = Rot2D (vec2 (length (p.xz) - 3., p.y), twAng);
  s = 2. * pi / cvOrd;
  rAng = s * (floor ((0.5 * pi - atan (q.x, q.y)) / s + 0.5));
  q = Rot2D (q, - rAng);
  q.x -= 0.8;
  return 0.4 * (length (max (abs (q) - vec2 (0.2), 0.)) - 0.1);
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.0005 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  vec3 vn;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  vn = normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
  return vn;
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
  vec3 vn, col;
  float dstObj;
  dstObj = ObjRay (ro, rd);
  if (dstObj < dstFar) {
    ro += rd * dstObj;
    vn = ObjNf (ro);
    col = vec3 (0.3, 0.3, 0.6);
    col *= 0.2 + 0.8 * max (dot (vn, ltDir), 0.) +
       0.5 * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
    col = mix (col, BgCol (reflect (rd, vn)), 0.5);
  } else col = vec3 (0.6, 0.8, 0.9);
  return clamp (col, 0., 1.);
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, float cvOrd, float cvWrapI,
   float cvWrapF )
{
  vec4 wgBx[3];
  vec3 cc;
  vec2 ut, ust;
  float vW[3], asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (0.35 * asp, 0., 0.012 * asp, 0.18);
  wgBx[1] = vec4 (0.4 * asp, 0., 0.012 * asp, 0.18);
  wgBx[2] = vec4 (0.45 * asp, 0., 0.012 * asp, 0.18);
  vW[0] = cvOrd / 10.;
  vW[1] = cvWrapI / 10.;
  vW[2] = cvWrapF / 10.;
  for (int k = 0; k < 3; k ++) {
    cc = vec3 (0.3, 0.3, 1.);
    ut = 0.5 * uv - wgBx[k].xy;
    ust = abs (ut) - wgBx[k].zw * vec2 (0.7, 1.);
    if (max (ust.x, ust.y) < 0.) {
      if  (min (abs (ust.x), abs (ust.y)) * canvas.y < 2.) col = vec3 (0.3);
      else col = (mod (0.5 * ((0.5 * uv.y - wgBx[k].y) / wgBx[k].w - 0.99), 0.1) *
         canvas.y < 6.) ? vec3 (1., 1., 0.) : vec3 (0.6);
    }
    ut.y -= (vW[k] - 0.5) * 2. * wgBx[k].w;
    ut = abs (ut) * vec2 (1., 1.5);
    if (max (abs (ut.x), abs (ut.y)) < 0.02 && max (ut.x, ut.y) > 0.008) col = cc;
    col = mix (col, cc, ShowInt (0.5 * uv -
       (wgBx[k].xy + wgBx[k].zw) * vec2 (1., -1.) -
       vec2 (0.0045, -0.06), 0.025 * vec2 (asp, 1.), 1.,
       clamp (floor (10. * vW[k]), 0., 9.)));
  }
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 stDat;
  vec3 ro, rd, col, cvParm;
  vec2 canvas, uv, uvs, ori, ca, sa;
  float el, az;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uvs = uv;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  cvParm = Loadv4 (0).xyz;
  cvOrd = 10. * cvParm.x;
  cvWrapI = 10. * cvParm.y;
  cvWrapF = 10. * cvParm.z;
  stDat = Loadv4 (1);
  el = stDat.x;
  az = stDat.y;
  dstFar = 50.;
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
          mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  rd = vuMat * normalize (vec3 (uv, 6.));
  ro = vuMat * vec3 (0., 0., -30.);
  ltDir = vuMat * normalize (vec3 (1., 1., -1.));
  col = ShowScene (ro, rd);
  col = ShowWg (uv, canvas, col, cvOrd, cvWrapI, cvWrapF);
  uvs *= uvs * uvs;
  uvs *= uvs * uvs;
  col *= mix (0.8, 1., pow (1. - 0.5 * length (uvs * uvs), 4.));
  fragColor = vec4 (col, 1.);
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

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

const float txRow = 32.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}
