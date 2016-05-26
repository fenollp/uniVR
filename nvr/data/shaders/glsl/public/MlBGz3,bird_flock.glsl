// Shader downloaded from https://www.shadertoy.com/view/MlBGz3
// written by shadertoy user dr2
//
// Name: Bird Flock
// Description: Searching for all those fish
// "Bird Flock" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

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

float Noisefv3 (vec3 p)
{
  vec3 i = floor (p);
  vec3 f = fract (p);
  f = f * f * (3. - 2. * f);
  float q = dot (i, cHashA3);
  vec4 t1 = Hashv4f (q);
  vec4 t2 = Hashv4f (q + cHashA3.z);
  return mix (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
     mix (mix (t2.x, t2.y, f.x), mix (t2.z, t2.w, f.x), f.y), f.z);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrFlatCylDf (vec3 p, float rhi, float rlo, float h)
{
  return max (length (p.xy - vec2 (rhi *
     clamp (p.x / rhi, -1., 1.), 0.)) - rlo, abs (p.z) - h);
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  return length (vec2 (length (p.xy) - rc, p.z)) - ri;
}

int idObj;
mat3 birdMat;
vec3 qHit, sunDir, waterDisp, cloudDisp;
float tCur, birdLen, vbOff, wngAng, wngAngL;
bool lastRow, isColr, qIsColr;
const float dstFar = 100.;
const int idWing = 21, idBdy = 22, idEye = 23, idBk = 24;

vec3 SkyBg (vec3 rd)
{
  const vec3 sbCol = vec3 (0.1, 0.1, 0.6);
  vec3 col;
  col = sbCol + 0.2 * pow (1. - max (rd.y, 0.), 5.);
  return col;
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  const float skyHt = 150.;
  vec3 col;
  float cloudFac;
  if (rd.y > 0.) {
    ro += cloudDisp;
    vec2 p = 0.01 * (rd.xz * (skyHt - ro.y) / rd.y + ro.xz);
    float w = 0.65;
    float f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.3;
    }
    cloudFac = clamp (5. * (f - 0.5) * rd.y + 0.1, 0., 1.);
  } else cloudFac = 0.;
  float s = max (dot (rd, sunDir), 0.);
  col = SkyBg (rd) + (0.35 * pow (s, 6.) + 0.65 * min (pow (s, 256.), 0.3));
  col = mix (col, vec3 (0.75), cloudFac);
  return col;
}

float WaterHt (vec3 p)
{
  p *= 0.05;
  p += waterDisp;
  float ht = 0.;
  const float wb = 1.414;
  float w = wb;
  for (int j = 0; j < 6; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x) + 10. * waterDisp;
    ht += w * abs (Noisefv3 (p) - 0.5);
  }
  return ht;
}

vec3 WaterNf (vec3 p, float d)
{
  vec2 e = vec2 (max (0.01, 0.001 * d * d), 0.);
  float ht = WaterHt (p);
  return normalize (vec3 (ht - WaterHt (p + e.xyy), e.x, ht - WaterHt (p + e.yyx)));
}

float BirdWingDf (vec3 p, float dMin)
{
  vec3 q, qh;
  float d, dd, a, wr;
  float wSegLen = 0.15 * birdLen;
  float wChord = 0.3 * birdLen;
  float wSpar = 0.03 * birdLen;
  float fTap = 8.;
  float tFac = (1. - 1. / fTap);
  q = p - vec3 (0., 0., 0.3 * birdLen);
  q.x = abs (q.x) - 0.1 * birdLen;
  float wf = 1.;
  a = lastRow ? wngAngL : wngAng;
  d = dMin;
  qh = q;
  for (int k = 0; k < 5; k ++) {
    q.xy = Rot2D (q.xy, a);
    q.x -= wSegLen;
    wr = wf * (1. - 0.5 * q.x / (fTap * wSegLen));
    dd = PrFlatCylDf (q.zyx, wr * wChord, wr * wSpar, wSegLen);
    if (k < 4) {
      q.x -= wSegLen;
      dd = min (dd, PrCapsDf (q, wr * wSpar, wr * wChord));
    } else {
      q.x += wSegLen;
      dd = max (dd, PrCylDf (q.xzy, wr * wChord, wSpar));
      dd = min (dd, max (PrTorusDf (q.xzy, 0.98 * wr * wSpar,
         wr * wChord), - q.x));
    }
    if (dd < d) { d = dd;  qh = q; }
    a *= 1.03;
    wf *= tFac;
  }
  if (d < dMin) { dMin = min (dMin, d);  idObj = idWing;  qHit = qh;
     qIsColr = isColr; }
  return dMin;
}

float BirdBodyDf (vec3 p, float dMin)
{
  vec3 q;
  float d, a, wr;
  float bkLen = 0.2 * birdLen;
  q = p;
  wr = q.z / birdLen;
  float tr, u;
  if (wr > 0.5) {
    u = (wr - 0.5) / 0.5;
    tr = 0.17 - 0.11 * u * u;
  } else {
    u = clamp ((wr - 0.5) / 1.5, -1., 1.);
    u *= u;
    tr = 0.17 - u * (0.34 - 0.18 * u); 
  }
  d = PrCapsDf (q, tr * birdLen, birdLen);
  if (d < dMin) {
    dMin = d;  idObj = idBdy;  qHit = q;
  }
  q = p;
  q.x = abs (q.x);
  wr = (wr + 1.) * (wr + 1.);
  q -= birdLen * vec3 (0.3 * wr, 0.1 * wr, -1.2);
  d = PrCylDf (q, 0.009 * birdLen, 0.2 * birdLen);
  if (d < dMin) { dMin = min (dMin, d);  idObj = idBdy;  qHit = q; }
  q = p;
  q.x = abs (q.x);
  q -= birdLen * vec3 (0.08, 0.05, 0.9);
  d = PrSphDf (q, 0.04 * birdLen);
  if (d < dMin) { dMin = d;  idObj = idEye;  qHit = q; }
  q = p;  q -= birdLen * vec3 (0., -0.015, 1.15);
  wr = clamp (0.5 - 0.3 * q.z / bkLen, 0., 1.);
  d = PrFlatCylDf (q, 0.2 * wr * bkLen, 0.2 * wr * bkLen, bkLen);
  if (d < dMin) { dMin = d;  idObj = idBk;  qHit = q; }
  return dMin;
}

float ObjDf (vec3 p)
{
  vec3 g, q;
  float szArray, exArray, hGap, bb;
  szArray = 7.;
  exArray = floor (szArray / 2.);
  hGap = 1.;
  bb = PrBoxDf (p, vec3 (szArray * hGap, 4. * hGap, szArray * hGap));
  g.xz = floor ((p.xz + hGap) / (2. * hGap));
  p.xz -= g.xz * 2. * hGap;
  p.y += vbOff * mod (g.x + g.z, 2.);
  lastRow = (g.x == exArray || g.z == exArray);
  isColr = (g.x == 0. && g.z == 0.);
  p.xz += 0.2 * vbOff * mod (g.xz, 2.);
  q = birdMat * p;
  return max (0.8 * BirdBodyDf (q, BirdWingDf (q, dstFar)), bb);
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
  vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

vec4 BirdCol (vec3 n)
{
  vec3 col, nn;
  float spec;
  spec = 0.2;
  if (idObj == idWing) {
    float gw = 0.15 * birdLen;
    float w = mod (qHit.x, gw);
    w = SmoothBump (0.15 * gw, 0.65 * gw, 0.1 * gw, w);
    col = qIsColr ? mix (vec3 (1., 0., 0.), vec3 (0., 1., 0.), w) :
       mix (vec3 (1.), vec3 (0.1), w);
  } else if (idObj == idEye) {
    col = vec3 (0., 0., 0.6);
    spec = 0.7;
  } else if (idObj == idBdy) {
    nn = birdMat * n;
    col = mix (mix (vec3 (1., 0.8, 0.8), vec3 (0.05, 0.2, 0.05),
       smoothstep (0.5, 1., nn.y)), vec3 (0., 0., 0.8),
       1. - smoothstep (-1., -0.3, nn.y));
  } else if (idObj == idBk) {
    col = vec3 (1., 0.4, 0.1);
  }
  return vec4 (col, spec);
}


float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.01;
  for (int i = 0; i < 50; i++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.01;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 col4;
  vec3 vn, col;
  float dstHit, reflFac, htWat, dw, bk, sh;
  int idObjT;
  htWat = -2.5;
  reflFac = 1.;
  col = vec3 (0.);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (rd.y < 0. && dstHit >= dstFar) {
    dw = - (ro.y - htWat) / rd.y;
    ro += dw * rd;
    rd = reflect (rd, WaterNf (ro, dw));
    ro += 0.01 * rd;
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    reflFac *= 0.7;
  }
  if (idObj < 0) dstHit = dstFar;
  if (dstHit >= dstFar) col = reflFac * SkyCol (ro, rd);
  else {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    col4 = BirdCol (vn);
    sh = ObjSShadow (ro, sunDir);
    bk = max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.);
    col = reflFac * (col4.rgb * (0.3 + 0.2 * bk +
       0.7 * sh * max (dot (vn, sunDir), 0.)) +
       sh * col4.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.));
  }
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 uv = 2. * (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  vec3 ro, rd, ori, ca, sa;
  sunDir = normalize (vec3 (cos (0.031 * tCur), 0.5, sin (0.031 * tCur)));
  waterDisp = 0.005 * tCur * vec3 (-1., 0., -1.);
  cloudDisp = 10. * tCur * vec3 (-1., 0., -1.);
  birdLen = 0.4;
  vbOff = 0.8 * birdLen * cos (0.3 * tCur);
  wngAng = -0.1 + 0.2 * sin (7. * tCur);
  wngAngL = -0.1 + 0.25 * sin (12. * tCur);
  ori = vec3 (0., 0.75 * pi, 0.25 * sin (0.77 * tCur));
  ca = cos (ori);
  sa = sin (ori);
  birdMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ori = vec3 (0.1 + 0.2 * cos (0.07 * tCur), -0.25 * pi - 0.033 * tCur, 0.);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  ro = vec3 (0., 0., - 15. - 6. * cos (0.1 * tCur)) * vuMat;
  rd = normalize (vec3 (uv, 4.5)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
