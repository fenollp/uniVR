// Shader downloaded from https://www.shadertoy.com/view/MtXGRs
// written by shadertoy user dr2
//
// Name: Gyrating Gyroscope
// Description: Gyroscope; see source for more details.
// "Gyrating Gyroscope" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  Simulation of a simulated gyroscope. A "real" simulated gyroscope
  requires solving differential equations; since this cannot be done
  without "historical" information, trajectories here are approximated
  by cycloids. The parameters change every 20s to show different
  combinations of precession and nutation; the red dots trace the
  trajectory.
*/

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
  vec2 i = floor (p);
  vec2 f = fract (p);
  f = f * f * (3. - 2. * f);
  vec4 t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

float Fbm2 (vec2 p)
{
  float s = 0.;
  float a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * Noisefv2 (p);
    a *= 0.5;
    p *= 2.;
  }
  return s;
}

vec3 WoodCol (vec3 p, vec3 n)
{
  p *= 4.;
  float f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.zx * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return mix (vec3 (0.8, 0.4, 0.2), vec3 (0.45, 0.25, 0.1), f);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  return length (vec2 (length (p.xy) - rc, p.z)) - ri;
}

int idObj;
vec3 qHit, ltDir;
float tCur, tSeq, tGap, pnRel, avSpin, amNut, frNut, tha0, phi0;
bool isShadw;
const float dstFar = 100.;

float ObjDf (vec3 p)
{
  vec3 q;
  const float bLen = 6., bRad = 0.6, axLen = 10., wlRad = 6.;
  float dMin, d, a, psi, tha, phi, t, ti;
  q = p;
  dMin = dstFar;
  d = PrCapsDf (q.xzy, bRad * (1.1 - 0.3 * q.y / bLen), 0.9 * bLen);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = 2; }
  q.y -= bLen;
  d = PrSphDf (q, 0.07 * wlRad);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = 5; }
  q.y -= -2.05 * bLen;
  d = PrCylDf (q.xzy, 10. * bRad, 0.08 * bLen);
  if (d < dMin) { dMin = d;  qHit = q;  idObj = 3; }
  q = p;  q.y -= bLen;
  t = frNut * tSeq;
  tha = tha0 + amNut * (pnRel * t - sin (t));
  phi = phi0 + amNut * (pnRel - cos (t));
  psi = - avSpin * tSeq;
  q.xz = Rot2D (q.xz, tha);  q.xy = Rot2D (q.xy, phi);
  q.x -= axLen;
  d = PrTorusDf (q.zyx, 0.05 * wlRad, wlRad);
  d = min (d, PrCylDf (q.zyx, 0.07 * wlRad, 0.05 * wlRad));
  if (d < dMin) { dMin = d;  idObj = 5; }
  q.x += 0.5 * axLen;
  d = min (d, PrCylDf (q.zyx, 0.03 * wlRad, 0.5 * axLen));
  if (d < dMin) { dMin = d;  idObj = 4; }
  q.x -= 0.5 * axLen;
  q.yz = Rot2D (q.yz, psi);  
  q.yz = Rot2D (q.yz, 0.25 * pi *
     floor ((atan (q.y, q.z) + pi) * 4. / pi + 0.5));
  q.z += 0.5 * wlRad;
  d = PrCylDf (q, 0.03 * wlRad, 0.5 * wlRad);
  if (d < dMin) { dMin = d;  idObj = 5; }
  if (! isShadw) {
    p.y -= bLen;
    ti = tGap * floor (tSeq / tGap);
    d = dstFar;
    for (int j = 0; j < 40; j ++) {
      t = frNut * ti;
      tha = tha0 + amNut * (pnRel * t - sin (t));
      phi = phi0 + amNut * (pnRel - cos (t));
      q = p;  
      q.xz = Rot2D (q.xz, tha);  q.xy = Rot2D (q.xy, phi);
      q.x -= 0.8 * axLen;
      d = min (d, PrSphDf (q, 0.03 * wlRad));
      ti -= tGap;
      if (ti < 0.) break;
    }
  }
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
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float d, h, sh;
  sh = 1.;
  d = 0.1;
  for (int i = 0; i < 60; i++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.4;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 ObjCol (vec3 n, float dstHit)
{
  vec3 col;
  if (idObj == 1) col = vec3 (0.9, 0., 0.) *
     (1. - 0.5 * (dstHit - 40.) / (dstFar - 40.));
  else if (idObj == 2) col = WoodCol (3. * qHit.xzy, n);
  else if (idObj == 3) col = WoodCol (qHit, n);
  else if (idObj == 4) col = vec3 (0.6, 0.6, 0.7);
  else if (idObj == 5) col = vec3 (0.8, 0.8, 0.1);
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, objCol, col;
  float dstHit, sh;
  int idObjT;
  idObj = -1;
  isShadw = false;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  idObjT = idObj;
  if (dstHit >= dstFar)
     col = (1. - 2. * dot (rd.xy, rd.xy)) * vec3 (0.2, 0.25, 0.3);
  else {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = ObjCol (vn, dstHit);
    isShadw = true;
    sh = (idObj != 1) ? ObjSShadow (ro, ltDir) : 1.;
    col = objCol * (0.4 + 0.6 * sh * max (dot (vn, ltDir), 0.)) +
       sh * pow (max (0., dot (ltDir, reflect (rd, vn))), 128.);
  }
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  float tCyc = 20.;
  float nSeq = floor (tCur / tCyc);
  tSeq = tCur - nSeq * tCyc;
  pnRel = 0.2 + 0.4 * mod (nSeq, 5.);
  amNut = 0.12 * pi * (1. - 0.5 * (pnRel - 1.));
  frNut = 1.1 * pi;
  avSpin = 1.2 * pi;
  phi0 = -0.12 * pi - amNut * (pnRel - 0.2);
  tha0 = 0.1 * pi;
  tGap = 0.08;
  float dist = 50.;
  vec3 rd = normalize (vec3 (uv, 3.2));
  vec3 ro = vec3 (0., 0.12, -1.) * dist;
  ltDir = normalize (vec3 (-0.5, 0.8, -0.4));
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
