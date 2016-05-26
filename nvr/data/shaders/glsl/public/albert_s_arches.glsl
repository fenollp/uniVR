// Shader downloaded from https://www.shadertoy.com/view/ltlGRX
// written by shadertoy user dr2
//
// Name: Albert's Arches
// Description: When moving at relativistic speeds things appear a little different; speed is controlled by the mouse (more information in the source).
// "Albert's Arches" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
   An earlier OpenGL version of this program (inspired by a
   visit to the Einstein centenary exhibition in Berne) used
   polygon rendering, after applying Lorentz contraction in
   the direction of the observer's motion. In this raymarched
   version, ray direction is altered by relativistic
   aberration, as in iapafoto's "Relativistic Starter", but
   the end result is exactly the same. Geometric aspects are
   covered, but lighting effects are not included. The mouse
   controls speed (default 0.9 c).
*/

int idObj;
vec3 qHit, ltDir;
float tCur;
const float dstFar = 100.;

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float ObjDf (vec3 p)
{
  vec3 q, qq;
  float d, dHit;
  float nArch = 12.;
  dHit = dstFar;
  d = dHit;
  p.y -= 0.5;
  q = p;
  q.z = mod (q.z + 1., 2.) - 1.;
  d = PrBoxDf (q, vec3 (2., 2., 0.25));
  q.y -= - 0.5;
  d = max (d, - PrBoxDf (q, vec3 (1.5, 2., 0.55)));
  q = p;  q.z -= nArch - 1.;
  d = max (d, PrBoxDf (q, vec3 (2.2, 2.2, nArch)));
  if (d < dHit) { dHit = d;  idObj = 1; qHit = q; }
  q = p;  q.y -= -2.1875;  q.z -= nArch - 1.;
  d = PrBoxDf (q, vec3 (2.75, 0.0625, nArch));
  if (d < dHit) { dHit = d;  idObj = 2; qHit = q; }
  q.x = abs (q.x) - 1.75;  q.y -= 0.125;
  d = PrBoxDf (q, vec3 (0.5, 0.0625, nArch));
  if (d < dHit) { dHit = d;  idObj = 3; qHit = q; }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec3 e = 1e-5 * vec3 (1., -1., 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 200; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

float CheqCol (vec3 p, vec3 n)
{
  p = floor (mod (p, 2.));
  return dot (abs (n), 0.5 * vec3 (1.) +
     0.5 * mod (vec3 (p.y + p.z, p.x + p.z, p.x + p.y), 2.));
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  float dstHit;
  int idObjT;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit >= dstFar) col = vec3 (0., 0., 0.15);
  else {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == 1) col = vec3 (0.8, 0.2, 0.2) * CheqCol (4. * ro, vn);
    else if (idObj == 2) col = vec3 (0.2, 0.8, 0.2) * CheqCol (ro, vn);
    else col = vec3 (0.8, 0.8, 0.2) * CheqCol (2. * ro, vn);
    col = col * (0.5 + 0.5 * max (dot (vn, ltDir), 0.));
  }
  return clamp (col, 0., 1.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  vec2 uvs = uv;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  vec4 mPtr = iMouse;
  mPtr.xy = mPtr.xy / iResolution.xy - 0.5;
  float beta, cPhi, w, cLen;
  vec3 ro, rd, col;
  ltDir = normalize (vec3 (1., 1., -1.));
  w = (mPtr.z > 0.) ? clamp (0.5 + mPtr.y, 0.07, 1.) : 0.9;
  beta = clamp (pow (w, 0.25), 0.1, 0.999);
  rd = normalize (vec3 (uv, 4.5));
  cPhi = (rd.z - beta) / (1. - rd.z * beta);
  rd = vec3 (0., 0., cPhi) +
     sqrt (1. - cPhi * cPhi) * normalize (rd - vec3 (0., 0., rd.z));
  ro = vec3 (0.);
  ro.z += (0.3 + 1.7 * beta) * mod (tCur, 10.) - 16. * (1. - beta) - 2.;
  col = ShowScene (ro, rd);
  cLen = 0.3;
  uvs.x = abs (uvs.x - 0.96);
  if (uvs.x < 0.02 && abs (uvs.y) < cLen) {
    col = 0.3 * col + 0.5;
    uvs.y += cLen;
    if (uvs.x < 0.015 && uvs.y > 0.01 && uvs.y < (2. * cLen - 0.01) *
       (2. * beta - 1.)) col = vec3 (1., 1., 0.5);
  }
  fragColor = vec4 (col, 1.);
}
