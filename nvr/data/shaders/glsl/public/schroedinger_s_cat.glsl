// Shader downloaded from https://www.shadertoy.com/view/lsjXW3
// written by shadertoy user dr2
//
// Name: Schroedinger's Cat
// Description: I'm Felixa, the quantum cat with existential issues... (see comments for more)
// "Schroedinger's Cat" by dr2 - 2014
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

float Hashfv2 (vec2 p)
{
  return fract (sin (dot (p, cHashA3.xy)) * cHashM);
}

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

float Fbmn (vec3 p, vec3 n)
{
  vec3 s = vec3 (0.);
  float a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * vec3 (Noisefv2 (p.yz), Noisefv2 (p.zx), Noisefv2 (p.xy));
    a *= 0.5;
    p *= 2.;
  }
  return dot (s, abs (n));
}

vec3 VaryNf (vec3 p, vec3 n, float f)
{
  vec3 e = vec3 (0.2, 0., 0.);
  float s = Fbmn (p, n);
  vec3 g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float SmoothMin (float a, float b, float r)
{
  float h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
  return mix (b, a, h) - r * h * (1. - h);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

float Length4 (vec2 p)
{
  p *= p;
  p *= p;
  return pow (p.x + p.y, 1./4.);
}

float Length8 (vec2 p)
{
  p *= p;
  p *= p;
  p *= p;
  return pow (p.x + p.y, 1./8.);
}

vec3 RgbToHsv (vec3 c)
{
  vec4 p = mix (vec4 (c.bg, vec2 (-1., 2./3.)), vec4 (c.gb, vec2 (0., -1./3.)),
     step (c.b, c.g));
  vec4 q = mix (vec4 (p.xyw, c.r), vec4 (c.r, p.yzx), step (p.x, c.r));
  float d = q.x - min (q.w, q.y);
  const float e = 1.e-10;
  return vec3 (abs (q.z + (q.w - q.y) / (6. * d + e)), d / (q.x + e), q.x);
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

float PrSphDf (vec3 p, float r)
{
  return length (p) - r;
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

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrTorus88Df (vec3 p, float ri, float rc)
{
  vec2 q = vec2 (Length8 (p.xy) - rc, p.z);
  return Length8 (q) - ri;
}

int idObj;
mat3 bodyMat, headMat, tailMat, boxMat, boxMatR;
vec3 catPos, qHit, ltDir;
float bdLen, boxSize, tCur, tSeq, nSeq;
bool isLive;
const float dstFar = 150.;
const float pi = 3.14159;
const int idBody = 11, idLegs = 12, idTail = 13, idHead = 14, idEars = 15,
   idTongue = 16, idEyes = 17, idNose = 18, idWhisk = 19, idFloor = 20,
   idWall = 21, idWallR = 22, idHinge = 23, idJar = 24;

float CatBodyDf (vec3 p, float dHit)
{
  vec3 q, qh;
  float h, d, w, a, ca, sa;
  q = p;
  w = q.z / bdLen;
  d = PrCapsDf (q * vec3 (1.3, 1., 1.), 0.7 * bdLen * (1. - 0.07 * w * w), bdLen);
  if (d < dHit) {
    dHit = d;  idObj = idBody;  qHit = q;
  }
  q = p - bdLen * vec3 (0., -0.8, 0.);
  vec3 qo = q;
  q.xz = abs (q.xz) - bdLen * vec2 (0.5, 0.9);
  q.xz += q.y * vec2 (0.1, 0.3);
  h = 0.6 * bdLen;
  w = q.y / h;
  d = PrCapsDf (q.xzy, 0.15 * bdLen * (1. - 0.3 * w * w), h);
  if (d < dHit + 0.2) {
    dHit = SmoothMin (dHit, d, 0.2);  idObj = idLegs;  qHit = q * sign (qo.zyx);
  }
  q = p - bdLen * vec3 (0., 0., -1.8);
  w = q.z / bdLen;
  if (isLive) q.y += bdLen * (w * (1.1 - 0.3 * w) - 1.1);
  h = 0.7 * bdLen;
  if (isLive) a = 0.8 * sin (0.7 * 2. * pi * tCur);
  else a = 0.;
  ca = cos (a);
  sa = sin (a);
  tailMat = mat3 (ca, 0., - sa, 0., 1., 0., sa, 0., ca);
  q.z -= h;
  q = tailMat * q;
  q.z += h;
  d = PrCapsDf (q, 0.12 * bdLen * (1. - 0.1 * w), h);
  if (d < dHit + 0.2) {
    dHit = SmoothMin (dHit, d, 0.2);  idObj = idTail;  qHit = q;
  }
  return dHit;
}

float CatHeadDf (vec3 p, float dHit)
{
  vec3 q, qh;
  float r, h, d, w, rw, a, ca, sa;
  qh = p - bdLen * vec3 (0., 0.9, 1.5);
  if (isLive) a = 0.8 * sin (0.7 * 2. * pi * tCur);
  else a = 0.;
  ca = cos (a);
  sa = sin (a);
  headMat = mat3 (ca, 0., - sa, 0., 1., 0., sa, 0., ca);
  qh = headMat * qh;
  q = qh;
  q.y += 0.4 * q.z;
  d = PrCapsDf (q * vec3 (1., 1.2, 1.), 0.65 * bdLen, 0.05 * bdLen);
  d = max (d, - PrCylDf (q * vec3 (1., 2., 1.) - bdLen * vec3 (0., -0.42, 0.7),
     0.15 * bdLen, 0.2 * bdLen));
  if (d < dHit + 0.1) {
    dHit = SmoothMin (dHit, d, 0.1);  idObj = idHead;  qHit = q;
  }
  q.y += 0.22 * bdLen;
  if (isLive) a = 0.15 * sin (0.9 * 2. * pi * tCur);
  else a = -0.15;
  q.z -= bdLen * (0.5 + a);
  d = PrCapsDf (q * vec3 (1., 2., 1.), 0.12 * bdLen, 0.17 * bdLen);
  if (d < dHit) {
    dHit = d;  idObj = idTongue;  qHit = q;
  }
  vec3 qe = qh - bdLen * vec3 (0., 0.75, -0.1);
  vec3 qo = qe;
  qe.x = abs (q.x) - 0.4 * bdLen;
  r = 0.3 * bdLen;
  w = qe.x / r;
  rw = r * (1. - 0.5 * w * w);
  q = qe;
  q.z -= 0.5 * q.x;
  float d1 = max (PrCylDf (q.yxz, rw, 0.03 * bdLen), - q.x);
  q = qe;
  q.z += 0.1 * q.x;
  float d2 = max (PrCylDf (q.yxz, rw, 0.03 * bdLen), q.x);
  d = min (d1, d2);
  if (d < dHit + 0.1) {
    dHit = SmoothMin (dHit, d, 0.1);  idObj = idEars;  qHit = q * sign (qo.zyx);
  }
  q = qh - bdLen * vec3 (0., 0., 0.37);
  q.x = abs (q.x) - 0.3 * bdLen;
  d = PrSphDf (q * vec3 (1., 1.5, 1.), 0.2 * bdLen);
  if (d < dHit) {
    dHit = d;  idObj = idEyes;  qHit = q;
  }
  q = qh - bdLen * vec3 (0., -0.2, 0.65);
  q.z += 0.5 * q.y;
  d = PrCapsDf (q, 0.1 * bdLen, 0.03 * bdLen);
  if (d < dHit + 0.05) {
    dHit = SmoothMin (dHit, d, 0.05);  idObj = idNose;  qHit = q;
  }
  q = qh - bdLen * vec3 (0., -0.3, 0.65);
  q.xy = abs (q.xy) - bdLen * vec2 (0.1, -0.005);
  q.yz += 0.1 * q.x * vec2 (-1., 1.);
  d = PrCylDf (q.zyx, 0.01 * bdLen, 0.6 * bdLen);
  if (d < dHit) {
    dHit = d;  idObj = idWhisk;  qHit = q;
  }
  return dHit;
}

float CatDf (vec3 p, float dHit)
{
  vec3 q = p; 
  if (! isLive) {
    q.x -= 1.05 * bdLen;
    q *= vec3 (1.5, 1., 1.);
  }
  dHit = CatBodyDf (q, dHit);
  dHit = CatHeadDf (q, dHit);
  return 0.5 * dHit;
}

vec3 FurCol (vec3 p, vec3 n)
{
  const vec3 c1 = vec3 (0.7, 0.6, 0.), c2 = vec3 (0.1), c3 = vec3 (0.9);
  p *= 2.5;
  float s = Fbmn (p, n);
  return mix (mix (c1, c2, smoothstep (0.8, 1.2, s)), c3,
     smoothstep (1.4, 1.7, s));
}

vec4 CatCol (vec3 n)
{
  vec3 col = vec3 (0.);
  float spec = 1.;
  const vec3 wCol = vec3 (0.9);
  vec3 q = 2. * qHit / bdLen;
  if (idObj >= idBody && idObj <= idEars) {
    if (idObj == idLegs || idObj == idHead) q *= 1.5;
    else if (idObj == idTail || idObj == idEars) q *= 2.;
    if (idObj == idTail) n = tailMat * n;
    else if (idObj == idHead || idObj == idEars) n = headMat * n;
    if (idObj == idEars && n.z > 0.4) col = vec3 (0.8, 0.6, 0.6);
    else {
      vec3 anis = vec3 (1.);
      if (idObj == idBody) anis = vec3 (1., 0.7, 1.);
      else if (idObj == idHead) anis = vec3 (1., 1., 1.3);
      col = FurCol (q * anis, n);
    }
    qHit /= bdLen;
    if (idObj == idBody) col = mix (mix (wCol, col,
       smoothstep (-0.65, -0.35, qHit.y)),
       wCol, (1. - smoothstep (-1.15, -0.95, qHit.z)) *
       smoothstep (0.3, 0.5, qHit.y));
    else if (idObj == idHead)
       col = mix (col, wCol, smoothstep (0.25, 0.45, qHit.z));
    else if (idObj == idTail)
      col = mix (col, wCol, smoothstep (0.25, 0.45, qHit.z));
    spec = 0.1;
  } else if (idObj == idTongue) {
    col = vec3 (0.9, 0.4, 0.4);
  } else if (idObj == idEyes) {
    n = headMat * n;
    col = vec3 (0., 0.7, 0.2);
    if (length (qHit - bdLen * vec3 (0.16, 0.12, 0.3)) < 0.4) {
      col = vec3 (0.4, 0., 0.);
      spec = 5.;
    }
  } else if (idObj == idNose) {
    col = vec3 (0.3, 0.2, 0.1);
  } else if (idObj == idWhisk) {
    col = vec3 (0.9, 0.7, 0.);
    spec = 5.;
  }
  if (! isLive && idObj != idTongue)
     col = HsvToRgb (RgbToHsv (col) * vec3 (1., 0.3, 0.8));
  return vec4 (col, spec);
}

float BoxDf (vec3 p, float dHit)
{
  vec3 q, qb, qh;
  float d;
  float bb = 4. * boxSize;
  float bh = 2.5 * boxSize;
  float bt = 0.08 * boxSize;
  q = p - vec3 (0., -0.5 * bt, 0.);
  d = PrBoxDf (q, vec3 (bb - bt, bt, bb - bt));
  if (d < dHit) {
    dHit = d;  idObj = idFloor;  qHit = q;
  }
  qb = q;
  int nx = 0;
  if (qb.x < 0.) nx = 1;
  qb.x = abs (qb.x) - 0.5 * bb;
  qh = qb;
  float a = 0.;
  if (tSeq > 1. && tSeq < 2.) a = - pi * (tSeq - 1.);
  else if (tSeq > 8. && tSeq < 9.) a = - pi * (9. - tSeq);
  else if (tSeq >= 2. && tSeq <= 8.) a = - pi;
  float ca = cos (a);
  float sa = sin (a);
  boxMat = mat3 (ca, - sa, 0., sa, ca, 0., 0., 0., 1.);
  boxMatR = mat3 (ca, sa, 0., - sa, ca, 0., 0., 0., 1.);
  qb.x -= 0.5 * bb;
  qb = boxMat * qb;
  qb.x += 0.5 * bb;
  q = qb - vec3 (0.5 * bb, bh - bt, 0.);
  d = PrBoxDf (q, vec3 (bt, bh, bb - bt));
  if (d < dHit) {
    dHit = d;  idObj = idWall + nx;  qHit = q;
  }
  q = qb - vec3 (0., bh - bt, 0.);
  q.z = abs (q.z) - bb;
  d = PrBoxDf (q, vec3 (0.5 * bb + bt, bh, bt));
  if (d < dHit) {
    dHit = d;  idObj = idWall;  qHit = q;
  }
  q = qb - vec3 (0., 2. * bh - 0.5 * bt, 0.);
  d = PrBoxDf (q, vec3 (0.5 * bb + bt, bt, bb + bt));
  if (d < dHit) {
    dHit = d;  idObj = idWall;  qHit = q;
  }

  q = qb - vec3 (-0.1 * bb, bt + 2. * bh - 0.5 * bt, 0.);
  d = PrTorus88Df (q.yzx, 1.5 * bt, 0.2 * bb);
  d = max (d, - q.y);
  if (d < dHit) {
    dHit = d;  idObj = idWall;  qHit = q;
  }
  q = qh - vec3 (0.5 * bb, 0., 0.);
  q.z = abs (q.z) - 0.5 * bb;
  d = PrCylDf (q.yxz, 1.8 * bt, 0.25 * bb);
  if (d < dHit) {
    dHit = d;  idObj = idHinge;  qHit = q;
  }
  return dHit;
}

vec3 WoodCol (vec3 p, vec3 n)
{
  p *= 4.;
  float f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.zx * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return 2. * mix (vec3 (0.8, 0.4, 0.2), vec3 (0.45, 0.25, 0.1), f);
}

vec4 BoxCol (vec3 n)
{
  vec3 col = vec3 (0.);
  float spec = 1.;
  if (idObj == idFloor) {
    col = WoodCol (qHit, n);
  } else if (idObj == idWall) {
    col = WoodCol (qHit, boxMat * n);
  } else if (idObj == idWallR) {
    col = WoodCol (qHit, boxMatR * n);
  } else if (idObj == idHinge) {
    col = vec3 (0.7, 0.5, 0.1);
    spec = 10.;
  }
  return vec4 (col, spec);
}

float JarDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  q = p - boxSize * vec3 (-3., 0.5, 3.);
  d = PrCylDf (q.xzy, 0.5 * boxSize, 0.5 * boxSize);
  if (d < dHit) {
    dHit = d;  idObj = idJar;  qHit = q;
  }
  return dHit;
}

vec4 JarCol (vec3 n)
{
  vec3 col;
  float spec = 1.;
  vec3 q = qHit;
  if (n.y < 0.95) {
    float a = abs (atan (qHit.x, qHit.z));
    a = min (a, abs (pi - a));
    col = vec3 (1., 1., 0.) *
       (1. - SmoothBump (-0.25, 0.25, 0.03, a - 1.3 * abs (qHit.y))) *
       (1. - SmoothBump (-0.1, 0.25, 0.03, Length4 (vec2 (a, qHit.y -
       0.3 * boxSize))));
  } else {
    if (isLive) col = vec3 (0., 1., 0.);
    else col = vec3 (1., 0., 0.);
    col *= 0.6 * (1. + cos (3. * 2. * pi * tSeq));
  }
  return vec4 (col, spec);
}

float ObjDf (vec3 p)
{
  float dHit = dstFar;
  dHit = CatDf (bodyMat * (p - catPos), dHit);
  dHit = BoxDf (p, dHit);
  dHit = JarDf (p, dHit);
  return dHit;
}

float ObjRay (vec3 ro, vec3 rd)
{
  const float dTol = 0.001;
  float d;
  float dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < dTol || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.001, -0.001, 0.);
  float v0 = ObjDf (p + e.xxx);
  float v1 = ObjDf (p + e.xyy);
  float v2 = ObjDf (p + e.yxy);
  float v3 = ObjDf (p + e.yyx);
  return normalize (vec3 (v0 - v1 - v2 - v3) + 2. * vec3 (v1, v2, v3));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh = 1.;
  float d = 0.1;
  for (int i = 0; i < 100; i++) {
    float h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.1;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec4 ObjCol (vec3 n)
{
  vec4 col4 = vec4 (0.);
  if (idObj >= idBody && idObj <= idWhisk) col4 = CatCol (bodyMat * n);
  else if (idObj >= idFloor && idObj <= idHinge) col4 = BoxCol (n);
  else if (idObj == idJar) col4 = JarCol (n);
  return col4;
}

void CatPM (float t)
{
  float frq = 0.44;
  float rl = 0.;
  float az = 0.;
  float el = 0.;
  if (isLive) {
    catPos = vec3 (0., bdLen * (1.94 + 0.4 * sin (2. * pi * frq * tCur)), 0.);
    az += 0.7 * sin (pi * frq * tCur);
    el -= 0.4 * (1. + sin (2. * pi * frq * tCur));
  } else {
    float ps = 2. * mod (nSeq, 2.) - 1.;
    catPos = vec3 (0., bdLen * (0.45 + 1.05 * ps), 0.);
    rl -= 0.5 * pi * ps;
  }
  vec3 ca = cos (vec3 (el, az, rl));
  vec3 sa = sin (vec3 (el, az, rl));
  bodyMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, objCol;
  float dstHit;
  vec3 col = vec3 (0., 0., 0.02);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  int idObjT = idObj;
  if (idObj < 0) dstHit = dstFar;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj >= idBody && idObj <= idTongue) vn = VaryNf (20. * qHit, vn, 0.4);
    vec4 col4 = ObjCol (vn);
    objCol = col4.xyz;
    float spec = col4.w;
    float dif = max (dot (vn, ltDir), 0.);
    vec3 vl = 30. * ltDir - ro;
    float di = 1. / length (vl);
    float br = min (1.1, 40. * di);
    float f = dot (ltDir, vl) * di;
    col = (0.1 + pow (f, 16.)) * br * objCol * (0.2 * (1. +
       max (dot (vn, - normalize (vec3 (ltDir.x, 0., ltDir.z))), 0.)) +
       max (0., dif) * ObjSShadow (ro, ltDir) *
       (dif + spec * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.)));
  }
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  float zmFac = 4.8;
  tCur = iGlobalTime;
  tCur = max (tCur - 2., 0.);
  const float tPer = 10.;
  nSeq = floor (tCur / tPer);
  float tBase = tPer * nSeq;
  tSeq = tCur - tBase;
  isLive = (sin (tBase) + sin (1.7 * tBase) + sin (2.7 * tBase)) > -0.5;
  boxSize = 2.;
  bdLen = boxSize;
  if (! isLive) {
    float s = tSeq / tPer;
    bdLen *= 1. - 0.95 * s * s * s;
  }
  float dist = 50.;
  float el = 0.4 + 0.2 * sin (0.042 * tCur);
  float az = pi + 0.6 * sin (0.093 * tCur);
  float cEl = cos (el);
  float sEl = sin (el);
  float cAz = cos (az);
  float sAz = sin (az);
  mat3 vuMat = mat3 (1., 0., 0., 0., cEl, - sEl, 0., sEl, cEl) *
     mat3 (cAz, 0., sAz, 0., 1., 0., - sAz, 0., cAz);
  vec3 rd = normalize (vec3 (uv, zmFac)) * vuMat;
  vec3 ro = - vec3 (0., 0., dist) * vuMat;
  ro.y += 0.08 * dist;
  ltDir = normalize (vec3 (0.5, 1., -1.));
  ltDir *= vuMat;
  CatPM (tCur);
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
