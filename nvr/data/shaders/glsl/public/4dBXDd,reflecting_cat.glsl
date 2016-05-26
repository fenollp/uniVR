// Shader downloaded from https://www.shadertoy.com/view/4dBXDd
// written by shadertoy user dr2
//
// Name: Reflecting Cat
// Description: Felixa, the quantum cat, relaxing in the reflectorium... (see comments for more)
// "Reflecting Cat" by dr2 - 2014
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

int idObj, nRefl;
mat3 bodyMat, headMat, tailMat;
vec3 catPos, qHit, ltDir;
float bdLen, tCur;
const float dstFar = 150.;
const float pi = 3.14159;
const int idBody = 11, idLegs = 12, idTail = 13, idHead = 14, idEars = 15,
   idTongue = 16, idEyes = 17, idNose = 18, idWhisk = 19, idTable = 20,
   idFrame = 21, idOpen = 22, idFloor = 23, idCeil = 24, idMirror = 25;

vec3 SkyBg (vec3 rd)
{
  const vec3 sbCol = vec3 (0.2, 0.25, 0.7);
  vec3 col;
  col = sbCol + 0.2 * 1. * pow (1. - max (rd.y, 0.), 5.);
  return col;
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  const float skyHt = 100.;
  vec3 col;
  float cloudFac;
  if (rd.y > 0.) {
    ro.xz += 10. * tCur * vec2 (1., -0.6);
    vec2 p = 0.01 * (rd.xz * (skyHt - ro.y) / rd.y + ro.xz);
    float w = 0.65;
    float f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.3;
    }
    cloudFac = clamp (5. * (f - 0.5) * rd.y - 0.1, 0., 1.);
  } else cloudFac = 0.;
  float s = max (dot (rd, ltDir), 0.);
  col = SkyBg (rd) + 1. * (0.35 * pow (s, 6.) +
     0.65 * min (pow (s, 256.), 0.3));
  col = mix (col, vec3 (0.75), cloudFac);
  return col;
}

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
  q = p - bdLen * vec3 (0., -0.55, 0.);
  vec3 qo = q;
  q.xz = abs (q.xz) - bdLen * vec2 (0.4, 0.9);
  q.xz += q.y * vec2 (0.1, 0.3);
  h = 0.5 * bdLen;
  w = q.y / h;
  d = PrCapsDf (q, 0.15 * bdLen * (1. - 0.3 * w * w), h);
  if (d < dHit + 0.2) {
    dHit = SmoothMin (dHit, d, 0.2);  idObj = idLegs;  qHit = q * sign (qo.zyx);
  }
  q = p - bdLen * vec3 (0., 0., -1.8);
  w = q.z / bdLen;
  q.y -= bdLen * (w * (0.7 - 0.5 * w) + 0.2);
  h = 0.9 * bdLen;
  a = 0.5 * sin (0.4 * 2. * pi * tCur);
  ca = cos (a);
  sa = sin (a);
  tailMat = mat3 (ca, 0., - sa, 0., 1., 0., sa, 0., ca);
  q.z -= h;
  q = tailMat * q;
  q.z += h;
  d = PrCapsDf (q, 0.12 * bdLen * (1. - 0.1 * w), h);
  if (d < dHit + 0.1) {
    dHit = SmoothMin (dHit, d, 0.1);  idObj = idTail;  qHit = q;
  }
  return dHit;
}

float CatHeadDf (vec3 p, float dHit)
{
  vec3 q, qh;
  float r, h, d, w, rw, a, ca, sa;
  qh = p - bdLen * vec3 (0., 0.9, 1.5);
  a = 0.5 * sin (0.4 * 2. * pi * tCur);
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
  a = 0.1 * sin (0.3 * 2. * pi * tCur);
  q.z -= bdLen * (0.45 + a);
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
  return vec4 (col, spec);
}

float TableDf (vec3 p, float dHit)
{
  vec3 q;
  float d, d1, d2;
  float br = 1.9 * bdLen;
  float bl = 1.1 * bdLen;
  p -= vec3 (0., - 2.2 * bdLen - 0.01 * br, 0.);
  q = p;
  d = PrCylDf (q.xzy, br, 0.04 * br);
  p.xz += 0.05 * br * vec2 (1., 1.5);
  q = p;
  q.xz += 0.05 * br * vec2 (sin (4. * p.y), cos (4. * p.y));
  q.y += bl;
  d1 = PrCylDf (q.xzy, 0.07 * br, bl);
  q = p;
  q.y += 2. * bl;
  d2 = PrCylDf (q.xzy, 0.5 * br, 0.15 * br * (1. -
     0.7 * smoothstep (0.2 * br, 0.35 * br, length (p.xz))));
  d = min (d, min (d1, d2));
  if (d < dHit) {
    dHit = d;  idObj = idTable;  qHit = q;
  }
  return dHit;
}

float RoomDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  float bh = 4.5 * bdLen;
  float bw = 6. * bdLen;
  float bl = 4. * bdLen;
  float bt = 0.4 * bdLen;
  q = p;
  d = max (PrBoxDf (q, vec3 (bw, bh, bl) + bt),
     - min (PrBoxDf (q, vec3 (bw, bh, bl + 2. * bt)),
     min (PrBoxDf (q, vec3 (bw, bh + 2. * bt, bl)),
     PrBoxDf (q, vec3 (bw + 2. * bt, bh, bl)))));
  if (d < dHit) {
    dHit = d;  idObj = idFrame;  qHit = q;
  }
  float ar = 1.4;
  float rf = 0.95;
  d = max (PrBoxDf (q, vec3 (bw, bh, bl) + 0.7 * bt),
     - PrBoxDf (q, vec3 (bw, bh, bl) + 0.3 * bt));
  if (nRefl == 0 && p.z > 0.) {
    q.z -= bh - bt;
    q *= vec3 (1., ar, 1.);
    d = max (d, - PrCylDf (q, rf * ar * bl, 2. * bt));
  }
  if (d < dHit) {
    dHit = d;  idObj = idMirror;  qHit = q;
  }
  if (nRefl == 0 && p.z > 0.) {
    d = max (PrCylDf (q, rf * ar * bl + 0.4 * bt, 0.4 * bt),
       - PrCylDf (q, rf * ar * bl - 0.4 * bt, 0.45 * bt));
    if (d < dHit) {
      dHit = d;  idObj = idOpen;  qHit = q;
    }
  }
  q = p;
  q.y += bh - 0.05 * bt;
  d = PrBoxDf (q, vec3 (bw, 0.05 * bt, bl));
  if (d < dHit) {
    dHit = d;  idObj = idFloor;  qHit = q;
  }
  q = p;
  q.y -= bh - 0.05 * bt;
  d = PrBoxDf (q, vec3 (bw, 0.05 * bt, bl));
  if (d < dHit) {
    dHit = d;  idObj = idCeil;  qHit = q;
  }
  return dHit;
}

float ObjDf (vec3 p)
{
  float dHit = dstFar;
  dHit = CatDf (bodyMat * (p - catPos), dHit);
  dHit = TableDf (p, dHit);
  dHit = RoomDf (p, dHit);
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
  float d = 0.15;
  for (int i = 0; i < 100; i++) {
    float h = ObjDf (ro + rd * d);
    if (idObj < idFrame) sh = min (sh, 20. * h / d);
    d += 0.15;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 WoodCol (vec3 p, vec3 n)
{
  p *= 2.;
  float f = dot (vec3 (Fbm2 (p.yz * vec2 (1., 0.1)),
     Fbm2 (p.zx * vec2 (1., 0.1)), Fbm2 (p.yx * vec2 (1., 0.1))), abs (n));
  return 0.7 * mix (vec3 (0.8, 0.4, 0.2), vec3 (0.45, 0.25, 0.1), f);
}

vec4 ObjCol (vec3 n)
{
  vec4 col4 = vec4 (0.);
  if (idObj >= idBody && idObj <= idWhisk) col4 = CatCol (bodyMat * n);
  else if (idObj == idTable) col4 = vec4 (WoodCol (qHit, n), 2.);
  else if (idObj == idFrame) col4 = vec4 (2. * WoodCol (3. * qHit, n), 1.);
  else if (idObj == idOpen) col4 = vec4 (2. * WoodCol (3. *
     vec3 (5. * atan (qHit.x, qHit.z) / pi, 3. * length (qHit.xy), qHit.z), n), 1.);
  else if (idObj == idFloor) col4 = vec4 (0., 0.4, 0.4, 1.);
  else if (idObj == idCeil) col4 = vec4 (2., 2., 1.2, 1.);
  return col4;
}

void CatPM (float t)
{
  float rl = 0.;
  float az = -0.15 * pi;
  float el = 0.;
  catPos = vec3 (0., -1.42 * bdLen, 0.);
  vec3 ca = cos (vec3 (el, az, rl));
  vec3 sa = sin (vec3 (el, az, rl));
  bodyMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  const int maxRefl = 6;
  const float atten = 0.93;
  vec3 vn, objCol, col1, col2;
  float dstHit;
  vec3 col = vec3 (0., 0., 0.04);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  float reflFac = 1.;
  nRefl = 0;
  bool notFstMir = true;
  if (idObj == idMirror) col2 = SkyCol (ro, rd);
  for (int nf = 0; nf < maxRefl; nf ++) {
    if (idObj == idMirror) {
      ro += rd * dstHit;
      rd = reflect (rd, ObjNf (ro));
      ro += 0.01 * rd;
      ++ nRefl;
      idObj = -1;
      dstHit = ObjRay (ro, rd);
      reflFac *= atten * reflFac;
      if (nf == 0) notFstMir = false;
    } else break;
  }
  int idObjT = idObj;
  if (idObj < 0 || idObj == idMirror) dstHit = dstFar;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj >= idBody && idObj <= idTongue || idObj == idFloor)
       vn = VaryNf (20. * qHit, vn, 0.4);
    vec4 col4 = ObjCol (vn);
    objCol = col4.xyz;
    float spec = col4.w;
    float dif = max (dot (vn, ltDir), 0.);
    vec3 vl = 30. * ltDir - ro;
    float di = 1. / length (vl);
    float br = min (1.1, 40. * di);
    float f = dot (ltDir, vl) * di;
    col1 = reflFac * ((0.1 + pow (f, 16.)) * br * objCol * (0.2 * (1. +
       max (dot (vn, - normalize (vec3 (ltDir.x, 0., ltDir.z))), 0.)) +
       max (0., dif) * ObjSShadow (ro, ltDir) *
       (dif + spec * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.))));
    if (notFstMir) col2 = col1;
  } else {
    col1 = pow (reflFac, 0.3) * SkyCol (ro, rd);
  }
  col = mix (col2, col1, SmoothBump (8., 25., 3., mod (tCur, 30.)));
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  float zmFac = 1.02;
  tCur = iGlobalTime;
  bdLen = 2.;
  float dist = 15.;
  float el = 0.;
  float az = pi;
  float cEl = cos (el);
  float sEl = sin (el);
  float cAz = cos (az);
  float sAz = sin (az);
  mat3 vuMat = mat3 (1., 0., 0., 0., cEl, - sEl, 0., sEl, cEl) *
     mat3 (cAz, 0., sAz, 0., 1., 0., - sAz, 0., cAz);
  vec3 rd = normalize (vec3 (uv, zmFac)) * vuMat;
  vec3 ro = - vec3 (0., 0., dist) * vuMat;
  float a = - pi * (0.5 - 0.5 * cos (0.02 * 2. * pi * tCur));
  ltDir = normalize (vec3 (0.8 * cos (a), 1., 0.8 * sin (a)));
  ltDir *= vuMat;
  CatPM (tCur);
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
