// Shader downloaded from https://www.shadertoy.com/view/MdtSzn
// written by shadertoy user dr2
//
// Name: Wave Tank
// Description: Surace waves; see source for details (mousing enabled).
// "Wave Tank" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  The underlying model is a square array of vertically oscillating masses
  coupled to their neighbors by simple springs (for small oscillations the
  forces depend only on height difference). The surface is based on
  (nonplanar) quadrilaterals with vertices at the mass positions, and the
  normals are interpolated so that it appears smooth. Surface waves are driven
  by inputs at one or more narrow slits, and are damped near the boundaries to
  reduce reflection. Diffraction and interference effects are demonstrated.

  Restarts with different number of slits when waves reach far end.
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

const float pi = 3.14159;

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

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

vec3 ltDir;
vec2 gHit;
float txRow, tCur, dstFar, gSizef, nSlit;
int idObj, gSize, igHit;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

float SurfHt (vec2 p)
{
  vec2 cg;
  float h;
  gHit = (p + 0.5) * (gSizef - 1.);
  cg = floor (gHit);
  if (min (cg.x, cg.y) >= 0. && max (cg.x, cg.y) < gSizef - 1.) {
    gHit -= cg;
    igHit = int (gSizef * cg.y + cg.x);
    h = mix (mix (Loadv4 (igHit).x, Loadv4 (igHit + gSize).x, gHit.y),
       mix (Loadv4 (igHit + 1).x, Loadv4 (igHit + gSize + 1).x, gHit.y), gHit.x);
    h = clamp (h, -0.02, 0.02);
  } else h = 0.;
  return h;
}

float SurfRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, h, s, sLo, sHi;
  s = 0.;
  sLo = 0.;
  dHit = dstFar;
  for (int j = 0; j < 150; j ++) {
    p = ro + s * rd;
    h = p.y - SurfHt (p.xz);
    if (h < 0.) break;
    sLo = s;
    s += max (0.01, 0.5 * h);
    if (s > dstFar) break;
  }
  if (h < 0.) {
    sHi = s;
    for (int j = 0; j < 5; j ++) {
      s = 0.5 * (sLo + sHi);
      p = ro + s * rd;
      h = step (0., p.y - SurfHt (p.xz));
      sLo += h * (s - sLo);
      sHi += (1. - h) * (s - sHi);
    }
    dHit = sHi;
  }
  return (max (abs (p.x), abs (p.z)) > 0.5 * (1. - 6. / gSizef)) ? dstFar : dHit;
}

vec3 SurfNf ()
{
  vec2 vn;
  vn = mix (mix (Loadv4 (igHit).zw, Loadv4 (igHit + gSize).zw, gHit.y),
     mix (Loadv4 (igHit + 1).zw, Loadv4 (igHit + gSize + 1).zw, gHit.y), gHit.x);
  return normalize (vec3 (vn.x, 1., vn.y));
}

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d, ds, w, b, s;
  dMin = dstFar;
  w = 0.5 * (1. - 6. / gSizef);
  q = p;
  q.xy -= vec2 (- w + 0.002, -0.005);
  b = q.z;
  s = 1. / (nSlit + 1.);
  if (2. * floor (0.5 * nSlit) != nSlit) q.z += 0.5 * s;
  q.z = mod (q.z, s) - 0.5 * s;
  ds = max (PrCylDf (q.xzy, 0.01, 0.03), abs (b) - 0.45);
  q = p;
  q.y -= -0.01;
  d = max (max (PrBoxDf (q, vec3 (w + 0.015, 0.04, w + 0.015)),
     - PrBox2Df (q.xz, vec2 (w))), - ds);
  if (d < dMin) { dMin = d;  idObj = 1; }
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
  vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  float dstSurf, dstObj;
  ltDir = normalize (vec3 (0.3, 1., 0.));
  dstObj = ObjRay (ro, rd);
  dstSurf = SurfRay (ro, rd);
  if (min (dstObj, dstSurf) < dstFar) {
    if (dstSurf < dstObj) {
      vn = SurfNf ();
      col = vec3 (0.4, 0.4, 1.);
    } else {
      vn = ObjNf (ro + rd * dstObj);
      col = vec3 (0.7, 0.4, 0.2);
    }
    col = col * (0.2 + 0.3 * max (dot (vn, vec3 (- ltDir.x, 0., - ltDir.z)), 0.) +
       0.8 * max (dot (vn, ltDir), 0.)) +       
       0.15 * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
    col = pow (clamp (col, 0., 1.), vec3 (0.7));
  } else col = vec3 (0.1, 0.2, 0.4);
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd;
  vec2 canvas, uv, ori, ca, sa;
  float az, el;
  int gSizeSq;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  gSize = (canvas.y > 160.) ? 160 : 40;
  txRow = float (gSize);
  dstFar = 60.;
  gSizef = float (gSize);
  gSizeSq = gSize * gSize;
  nSlit = Loadv4 (gSizeSq).y;
  el = 0.27 * pi;
  az = 0.5 * pi;
  if (mPtr.z > 0.) {
    el = clamp (el - 1.5 * mPtr.y, 0.1 * pi, 0.35 * pi);
    az -= 7. * mPtr.x;
  }
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = vec3 (0., -0.02, -3.) * vuMat;
  rd = normalize (vec3 (uv, 6.6)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
