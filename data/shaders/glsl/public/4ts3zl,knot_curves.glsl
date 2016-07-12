// Shader downloaded from https://www.shadertoy.com/view/4ts3zl
// written by shadertoy user dr2
//
// Name: Knot Curves
// Description: Simple parametric knot curves.
// "Knot Curves" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Simple parametric knot curves.

//#define ALL_KNOTS  // cycle through all knots (enable this at your peril)...

#ifdef ALL_KNOTS
#define KNOT_A
#define KNOT_B
#define KNOT_C

#else

#define KNOT_A  // ...OR choose one of the knots
//#define KNOT_B
//#define KNOT_C
#endif

const float pi = 3.14159;

float PrFlatCylDf (vec3 p, vec3 b)
{
  return max (length (p.yz - vec2 (b.y *
     clamp (p.y / b.y, -1., 1.), 0.)) - b.z, abs (p.x) - b.x);
}

float tCur, pScale, dAng, eAng, ei2Ang;
vec3 qHit, ltDir;
int idObj;
const int nAngInc = 30, nMarStep = 50;
const float dstFar = 40.;
const vec3 cSize = vec3 (0.3, 0.12, 0.05);

#ifdef ALL_KNOTS
int idKnot;
#endif

/* separate distance function for each knot to avoid performance hit (!?) */

mat3 EvalRMat (vec3 r, vec3 rp, vec3 rm)
{
  vec3 ddr, vt, vn;
  vt = normalize (rp - rm);
  ddr = ei2Ang * (rp + rm - 2. * r);
  vn = normalize (ddr - vt * dot (vt, ddr));
  return mat3 (vt, vn, cross (vt, vn));
}

#ifdef KNOT_A

vec3 KtPointA (float a)  //trefoil knot
{
  const vec3
     gc1 = vec3 ( 41,   36,   0),
     gs1 = vec3 (-18,   27,   45),
     gc2 = vec3 (-83, -113,  -30),
     gs2 = vec3 (-83,   30,  113),
     gc3 = vec3 (-11,   11,  -11),
     gs3 = vec3 ( 27,  -27,   27);
  return gc1 * cos (a)      + gs1 * sin (a) +
         gc2 * cos (2. * a) + gs2 * sin (2. * a) +
         gc3 * cos (3. * a) + gs3 * sin (3. * a);
}

float ObjDfA (vec3 p)
{
  vec3 q, r, rp, rm;
  float d, a;
  d = dstFar;
  a = 0.;
  for (int j = 0; j < nAngInc; j ++) {
    r = KtPointA (a);
    rp = KtPointA (a + eAng);
    rm = KtPointA (a - eAng);
    q = (p - r * pScale) * EvalRMat (r, rp, rm);
    d = min (d, PrFlatCylDf (q, cSize));
    a += dAng;
  }
  if (d < dstFar) idObj = 1;
  return d;
}

float ObjRayA (vec3 ro, vec3 rd)
{
  float d, dHit;
  dHit = 0.;
  for (int j = 0; j < nMarStep; j ++) {
    d = ObjDfA (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;              
  }
  return dHit;
}

#endif

#ifdef KNOT_B

vec3 KtPointB (float a)  //figure 8 knot
{
  const vec3
     gc1 = vec3 (  32,   94,   16),
     gs1 = vec3 ( -51,   41,   73),
     gc2 = vec3 (-104,  113, -211), 
     gs2 = vec3 ( -34,    0,  -39),
     gc3 = vec3 ( 104,  -68,  -99),
     gs3 = vec3 ( -91, -124,  -21);
  return gc1 * cos (a)      + gs1 * sin (a) +
         gc2 * cos (2. * a) + gs2 * sin (2. * a) +
         gc3 * cos (3. * a) + gs3 * sin (3. * a);
}

float ObjDfB (vec3 p)
{
  vec3 q, r, rp, rm;
  float d, a;
  d = dstFar;
  a = 0.;
  for (int j = 0; j < nAngInc; j ++) {
    r = KtPointB (a);
    rp = KtPointB (a + eAng);
    rm = KtPointB (a - eAng);
    q = (p - r * pScale) * EvalRMat (r, rp, rm);
    d = min (d, PrFlatCylDf (q, cSize));
    a += dAng;
  }
  if (d < dstFar) idObj = 2;
  return d;
}

float ObjRayB (vec3 ro, vec3 rd)
{
  float d, dHit;
  dHit = 0.;
  for (int j = 0; j < nMarStep; j ++) {
    d = ObjDfB (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;              
  }
  return dHit;
}

#endif

#ifdef KNOT_C

vec3 KtPointC (float a)  //square knot
{
  const vec3
     gc1 = vec3 ( -22,  11,   0),
     gs1 = vec3 (-128,   0,   0),
     gc3 = vec3 ( -44, -43,  70),
     gs3 = vec3 ( -78,   0, -40),
     gc5 = vec3 (   0,  34,   8),
     gs5 = vec3 (   0, -39,  -9);
  return gc1 * cos (a)      + gs1 * sin (a) +
         gc3 * cos (3. * a) + gs3 * sin (3. * a) +
         gc5 * cos (5. * a) + gs5 * sin (5. * a);
}

float ObjDfC (vec3 p)
{
  vec3 q, r, rp, rm;
  float d, a;
  d = dstFar;
  a = 0.;
  for (int j = 0; j < nAngInc; j ++) {
    r = KtPointC (a);
    rp = KtPointC (a + eAng);
    rm = KtPointC (a - eAng);
    q = (p - r * pScale) * EvalRMat (r, rp, rm);
    d = min (d, PrFlatCylDf (q, cSize));
    a += dAng;
  }
  if (d < dstFar) idObj = 3;
  return d;
}

float ObjRayC (vec3 ro, vec3 rd)
{
  float d, dHit;
  dHit = 0.;
  for (int j = 0; j < nMarStep; j ++) {
    d = ObjDfC (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;              
  }
  return dHit;
}

#endif

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = vec3 (0.001, -0.001, 0.);
#ifdef ALL_KNOTS
  if (idKnot == 1)
#endif
#ifdef KNOT_A
     v = vec4 (ObjDfA (p + e.xxx), ObjDfA (p + e.xyy),
	ObjDfA (p + e.yxy), ObjDfA (p + e.yyx));
#endif
#ifdef ALL_KNOTS
  else if (idKnot == 2)
#endif
#ifdef KNOT_B
     v = vec4 (ObjDfB (p + e.xxx), ObjDfB (p + e.xyy),
	ObjDfB (p + e.yxy), ObjDfB (p + e.yyx));
#endif
#ifdef ALL_KNOTS
  else if (idKnot == 3)
#endif
#ifdef KNOT_C
     v = vec4 (ObjDfC (p + e.xxx), ObjDfC (p + e.xyy),
	ObjDfC (p + e.yxy), ObjDfC (p + e.yyx));
#endif
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  float dstHit;
  int idObjT;
  idObj = -1;
#ifdef ALL_KNOTS
  if (idKnot == 1) {
#endif
#ifdef KNOT_A
    pScale = 0.015;
    dstHit = ObjRayA (ro, rd);
#endif
#ifdef ALL_KNOTS
  } else if (idKnot == 2) {
#endif
#ifdef KNOT_B
    pScale = 0.008;
    dstHit = ObjRayB (ro, rd);
#endif
#ifdef ALL_KNOTS
  } else if (idKnot == 3) {
#endif
#ifdef KNOT_C
    pScale = 0.016;
    dstHit = ObjRayC (ro, rd);
#endif
#ifdef ALL_KNOTS
  }
#endif
  if (idObj < 0) dstHit = dstFar;
  if (dstHit >= dstFar) col = vec3 (0.2, 0.25, 0.3);
  else {
    ro += dstHit * rd;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
#ifdef ALL_KNOTS
    if (idKnot == 1)
#endif
#ifdef KNOT_A
       col = vec3 (0.9, 0.3, 0.6);
#endif
#ifdef ALL_KNOTS
    else if (idKnot == 2)
#endif
#ifdef KNOT_B
       col = vec3 (0.3, 0.9, 0.6);
#endif
#ifdef ALL_KNOTS
    else if (idKnot == 3)
#endif
#ifdef KNOT_C
       col = vec3 (0.9, 0.6, 0.3);
#endif
    col = col * (0.1 + 0.7 * max (dot (vn, ltDir), 0.)) +
       0.5 * pow (max (0., dot (ltDir, reflect (rd, vn))), 128.);
  }
  return sqrt (clamp (col, 0., 1.));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  float az, el, rl;
  vec3 rd, ro, ca, sa;
#ifdef ALL_KNOTS
  idKnot = 1 + int (mod (floor (tCur / 10.), 3.));
#endif
  dAng = 2. * pi / float (nAngInc);
  eAng = 0.1 * dAng;
  ei2Ang = 1. / (eAng * eAng);
  rl = 0.26 * tCur;
  az = 0.15 * tCur;
  el = 0.19 * tCur;
  ca = cos (vec3 (el, az, rl));
  sa = sin (vec3 (el, az, rl));
  vuMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = - vec3 (0., 0., 25.) * vuMat;
  rd = normalize (vec3 (uv, 7.5)) * vuMat;
  ltDir = normalize (vec3 (1., 1., -1.)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
