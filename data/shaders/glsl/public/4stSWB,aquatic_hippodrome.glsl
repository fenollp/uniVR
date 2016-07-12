// Shader downloaded from https://www.shadertoy.com/view/4stSWB
// written by shadertoy user dr2
//
// Name: Aquatic Hippodrome
// Description: Somewhere in an alternate universe... (various view modes, mousing and zooming)
// "Aquatic Hippodrome" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

vec2 Hashv2f (float p)
{
  return fract (sin (p + cHashA4.xy) * cHashM);
}

vec4 Hashv4f (float p)
{
  return fract (sin (p + cHashA4) * cHashM);
}

vec4 Hashv4v3 (vec3 p)
{
  const vec3 cHashVA3 = vec3 (37.1, 61.7, 12.4);
  const vec3 e = vec3 (1., 0., 0.);
  return fract (sin (vec4 (dot (p + e.yyy, cHashVA3), dot (p + e.xyy, cHashVA3),
     dot (p + e.yxy, cHashVA3), dot (p + e.xxy, cHashVA3))) * cHashM);
}

float Noiseff (float p)
{
  vec2 t;
  float ip, fp;
  ip = floor (p);
  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  t = Hashv2f (ip);
  return mix (t.x, t.y, fp);
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

float Noisefv3a (vec3 p)
{
  vec4 t1, t2;
  vec3 ip, fp;
  ip = floor (p);
  fp = fract (p);
  fp = fp * fp * (3. - 2. * fp);
  t1 = Hashv4v3 (ip);
  t2 = Hashv4v3 (ip + vec3 (0., 0., 1.));
  return mix (mix (mix (t1.x, t1.y, fp.x), mix (t1.z, t1.w, fp.x), fp.y),
              mix (mix (t2.x, t2.y, fp.x), mix (t2.z, t2.w, fp.x), fp.y), fp.z);
}

float Fbm1 (float p)
{
  float f, a;
  f = 0.;
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    f += a * Noiseff (p);
    a *= 0.5;
    p *= 2.;
  }
  return f;
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

float Fbm3 (vec3 p)
{
  const mat3 mr = mat3 (0., 0.8, 0.6, -0.8, 0.36, -0.48, -0.6, -0.48, 0.64);
  float f, a;
  f = 0.;
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    f += a * Noisefv3a (p);
    a *= 0.5;
    p *= 4. * mr;
  }
  return f;
}

float Fbmn (vec3 p, vec3 n)
{
  vec3 s;
  float a;
  s = vec3 (0.);
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * vec3 (Noisefv2 (p.yz), Noisefv2 (p.zx), Noisefv2 (p.xy));
    a *= 0.5;
    p *= 2.;
  }
  return dot (s, abs (n));
}

vec3 VaryNf (vec3 p, vec3 n, float f)
{
  vec3 g;
  float s;
  vec3 e = vec3 (0.1, 0., 0.);
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float PrBox2Df (vec2 p, vec2 b)
{
  vec2 d;
  d = abs (p) - b;
  return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

float PrRoundBoxDf (vec3 p, vec3 b, float r)
{
  return length (max (abs (p) - b, 0.)) - r;
}

float PrSphDf (vec3 p, float r)
{
  return length (p) - r;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrFlatCylDf (vec3 p, float b, float r, float h)
{
  p.x -= b * clamp (p.x / b, -1., 1.);
  return max (length (p.xy ) - r, abs (p.z) - h);
}

float PrFlatCylAnDf (vec3 p, float b, float r, float w, float h)
{
  p.x -= b * clamp (p.x / b, -1., 1.);
  return max (abs (length (p.xy) - r) - w, abs (p.z) - h);
}

float PrFlatCyl2Df (vec2 p, float b, float r)
{
  p.x -= b * clamp (p.x / b, -1., 1.);
  return length (p) - r;
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

vec2 SSBump (float w, float s, float x)
{
  return vec2 (step (x + s, w) * step (- w, x + s),
     step (x - s, w) * step (- w, x - s));
}

float SmoothMin (float a, float b, float r)
{
  float h;
  h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
  return mix (b, a, h) - r * h * (1. - h);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

const float txRow = 32.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

mat3 boatMat[3];
vec3 boatPos[3], sunDir, qHit;
float boatAng[3], dstFar, tCur, owLen, owRad, owThk, iwLen, iwRad, flHt;
int idObj, idObjGrp;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col, p;
  if (rd.y > 0.) {
    col = vec3 (0.1, 0.2, 0.4) + 0.2 * pow (1. - max (rd.y, 0.), 8.) +
       0.35 * pow (max (dot (rd, sunDir), 0.), 6.);
    col = mix (col, vec3 (1.), clamp (0.1 +
       0.8 * Fbm2 (0.01 * tCur + 3. * rd.xz / rd.y) * rd.y, 0., 1.));
  } else {
    p = ro - (ro.y / rd.y) * rd;
    col = 0.6 * mix (vec3 (0.4, 0.4, 0.1), vec3 (0.5, 0.5, 0.2),
       Fbm2 (9. * p.xz)) * (1. - 0.1 * Noisefv2 (150. * p.xz));
    col = mix (col, vec3 (0.35, 0.45, 0.65), pow (1. + rd.y, 32.));
  }
  return col;
}

float BldgDf (vec3 p, float dMin)
{
  vec3 q;
  vec2 rh, drh;
  float d;
  q = p;  q.y -= 0.59;
  d = PrFlatCylAnDf (q.xzy, owLen, owRad, owThk, 0.59);
  q = p;  q.y = mod (q.y + 0.5, flHt) - 0.15;
  if (d < owLen - 0.13 - abs (p.x)) {
    q.x = mod (q.x + 0.14, 0.28) - 0.14;
  } else {
    q.x = abs (q.x) - owLen;
    q.xz = Rot2D (q.xz, 2. * pi / 64.);
    q.xz = Rot2D (q.xz, 2. * pi * (floor (32. * atan (q.z, - q.x) /
       (2. * pi)) + 0.5) / 32.);
    q.x = q.z;
  }
  d = max (d, - max (PrFlatCyl2Df (q.yx, 0.15, 0.1), -0.03 - q.y));
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = p;  q.y -= 0.35;
  rh = vec2 (iwRad, 0.35);
  drh = vec2 (0.05, 0.035);
  d = PrFlatCylAnDf (q.xzy, iwLen, rh.x, 0.5 * drh.x, rh.y);
  for (int k = 0; k < 9; k ++) {
    q.y -= - drh.y;  rh -= drh;
    d = min (d, PrFlatCylAnDf (q.xzy, iwLen, rh.x, 0.5 * drh.x, rh.y));
  }
  q = p;  q.y -= 0.07;
  if (d < owLen - abs (p.x)) q.x = abs (q.x) - owLen + 0.27;
  else q.x = q.z;
  d = max (d, - max (PrFlatCyl2Df (q.yx, 0.15, 0.08), -0.05 - q.y));
  if (d < dMin) { dMin = d;  idObj = 2; }
  q = p;  q.y -= 0.02;
  d = PrFlatCylDf (q.xzy, owLen - 0.2, 0.15, 0.02);
  if (d < dMin) { dMin = d;  idObj = 3; }
  q = p;  q.y -= -0.003;
  d = PrFlatCylDf (q.xzy, owLen, 1.6, 0.003);
  if (d < dMin) { dMin = d;  idObj = 4; }
  return dMin;
}

float BoatDf (vec3 p, float dMin)
{
  vec3 q;
  float d;
  p.y -= 0.7;
  q = p;
  d = max (max (PrRCylDf (q, 1.2, 2., 3.5),
     - max (PrRCylDf (q - vec3 (0., 0.1, 0.), 1.15, 2., 3.5),
     max (q.y - 0.1, - q.y - 0.1))), max (q.y - 0., - q.y - 0.2));
  q.y -= -0.2;
  d = max (SmoothMin (d, max (PrRCylDf (q, 1., 2., 3.3), q.y), 0.1), q.z - 2.);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 1;  qHit = q; }
  q = p;
  q.yz -= vec2 (-0.5, -0.2);
  d = max (PrRCylDf (q, 1., 1.1, 2.3), max (0.4 - q.y, q.z - 1.2));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 2;  qHit = q; }
  q = p;
  q.yz -= vec2 (0.7, -1.);
  d = PrCylDf (q.xzy, 0.03, 0.2);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 3; }
  return dMin;
}

float RobDf (vec3 p, float dMin)
{
  vec3 q;
  vec2 s;
  float d, szFac, bf, spx;
  bf = max (abs (p.x) - 0.8, 0.);
  spx = sign (floor ((p.x + 0.32) / 0.64));
  p.x = mod (p.x + 0.32, 0.64) - 0.32;
  if (spx != 0.) p.xz = vec2 (- p.z, p.x * spx);
  p.y -= 0.04;
  szFac = 15.;
  p *= szFac;
  dMin *= szFac;
  q = p;  q.y -= 2.2;
  d = max (PrSphDf (q, 0.85), - q.y);
  q = p;  q.y -= 1.55;
  d = min (d, PrRCylDf (q.xzy, 0.9, 0.28, 0.7));
  q = p;  q.x = abs (q.x) - 0.3;  q.y -= 3.2;
  d = min (d, PrRCylDf (q.xzy, 0.06, 0.04, 0.3));
  q = p;  q.x = abs (q.x) - 1.05;  q.y -= 1.5;
  d = min (d, PrRCylDf (q.xzy, 0.2, 0.15, 0.6));
  q = p;  q.x = abs (q.x) - 0.4;  q.y -= 0.475;
  d = max (bf, min (d, PrRCylDf (q.xzy, 0.25, 0.15, 0.55)));
  if (d < dMin) { dMin = d;  idObj = 11; }
  q = p;
  if (spx == 0.) q.z = abs (q.z);
  q.x = abs (q.x) - 0.4;  q.yz -= vec2 (2.6, 0.7);
  d = max (bf, PrSphDf (q, 0.15));
  if (d < dMin) { dMin = d;  idObj = 12; }
  dMin /= szFac;
  return dMin;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float d, dMin, dLim;
  const float bSzFac = 25.;
  dMin = dstFar;
  dMin = BldgDf (p, dMin);
  dMin = RobDf (p, dMin);
  dLim = 0.5 * bSzFac;
  dMin *= bSzFac;
  for (int k = 0; k < 3; k ++) {
    q = p - boatPos[k];
    idObjGrp = (k + 1) * 256;
    d = PrCylDf (q.xzy, 2., 2.);
    dMin = (d < dLim) ? BoatDf (bSzFac * boatMat[k] * q, dMin) : min (dMin, d);
  }
  dMin /= bSzFac;
  return dMin;
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
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy), ObjDf (p + e.yxy),
     ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float BrickSurfShd (vec2 p)
{
  vec2 q, iq;
  q = p;
  iq = floor (q);
  if (2. * floor (iq.y / 2.) != iq.y) {
    q.x += 0.5;  iq = floor (q);
  }
  q = smoothstep (0.02, 0.04, abs (fract (q + 0.5) - 0.5));
  return 0.7 + 0.3 * q.x * q.y;
}

#define SHADOWS 0

float ObjSShadow (vec3 ro, vec3 rd)
{
#if SHADOWS
  float sh, d, h;
  sh = 1.;
  d = 0.02;
  for (int j = 0; j < 30; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 0.07 * d, h));
    d += max (0.04, 0.08 * d);
    if (sh < 0.05) break;
  }
  return 0.6 + 0.4 * sh;
#else
  return 1.;
#endif
}

vec4 BoatCol (vec3 n)
{
  vec4 objCol;
  vec3 nn, cc;
  int ig, id;
  ig = idObj / 256;
  id = idObj - 256 * ig;
  if (ig == 1) nn = boatMat[0] * n;
  else if (ig == 2) nn = boatMat[1] * n;
  else nn = boatMat[2] * n;
  if (id == 1) {
    if (qHit.y < 0.1 && nn.y > 0.99) {
      objCol.rgb = vec3 (0.8, 0.5, 0.3) *
         (1. - 0.4 * SmoothBump (0.42, 0.58, 0.05, mod (7. * qHit.x, 1.)));
      objCol.a = 0.5;
    } else {
      cc = vec3 (0.9, 0.3, 0.3);
      if (qHit.y > -0.2) objCol.rgb = (ig == 1) ? cc :
         ((ig == 2) ? cc.yzx : cc.zxy);
      else objCol.rgb = vec3 (0.7, 0.7, 0.8);
      objCol.a = 0.7;
    }
  } else if (id == 2) {
    if (abs (abs (qHit.x) - 0.4) < 0.36 && qHit.y > 0.45 && 
       length (vec2 (abs (qHit.x) - 0.1, qHit.y - 0.2)) < 0.7 ||
       abs (abs (qHit.z + 0.2) - 0.6) < 0.5 && abs (qHit.y - 0.65) < 0.2)
       objCol = vec4 (0., 0., 0.1, -1.);
    else objCol = vec4 (1.);
  } else if (id == 3) objCol = vec4 (1., 1., 1., 0.3);
  return objCol;
}

mat3 BoatPM (float bAng)
{
  mat3 bMat;
  float bAz, c, s;
  bAz = 0.5 * pi - bAng;
  bMat[2] = vec3 (1., 0., 0.);
  bMat[0] = normalize (vec3 (0., 0.1, 1.));
  bMat[1] = cross (bMat[0], bMat[2]);
  c = cos (bAz);
  s = sin (bAz);
  bMat *= mat3 (c, 0., s, 0., 1., 0., - s, 0., c);
  return bMat;
}

float WakeFac (vec3 p)
{
  vec3 twa;
  vec2 tw[3];
  float twLen[3], wkFac;
  for (int k = 0; k < 3; k ++) {
    tw[k] = p.xz - (boatPos[k].xz - Rot2D (vec2 (0., 0.12), boatAng[k]));
    twLen[k] = length (tw[k]);
  }
  if (twLen[0] < min (twLen[1], twLen[2])) twa = vec3 (tw[0], boatAng[0]);
  else if (twLen[1] < twLen[2]) twa = vec3 (tw[1], boatAng[1]);
  else twa = vec3 (tw[2], boatAng[2]);
  twa.xy = Rot2D (twa.xy, - twa.z);
  wkFac = 1. - smoothstep (0.01, 0.04, length (twa.xy * vec2 (1., 0.7)));
  twa.x = abs (twa.x);
  twa.xy = Rot2D (twa.xy, -0.08 * pi);
  twa.x = abs (twa.x) - 0.045;
  wkFac += (1. - smoothstep (0.002, 0.006, abs (twa.x))) *
           (1. - smoothstep (0.01, 0.04, abs (twa.y)));
  return wkFac;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 vn, col, q, row;
  vec2 ss;
  float dstObj, g, fw, sh, reflFac, wkFac;
  int idObjT;
  bool isRuf;
  dstObj = ObjRay (ro, rd);
  reflFac = 1.;
  wkFac = 0.;
  if (dstObj < dstFar) {
    ro += rd * dstObj;
    if (idObj == 4 && (abs (ro.x) < iwLen && abs (ro.z) < iwRad - 0.45 ||
       abs (ro.x) >= iwLen && length (vec2 (abs (ro.x) - iwLen, ro.z)) <
       iwRad - 0.45)) {
      row = ro;
      wkFac = WakeFac (row);
      if (wkFac > 0.) vn = VaryNf (200. * ro, vec3 (0., 1., 0.), 0.3 * wkFac);
      else vn = VaryNf (5. * ro + 0.1 * sin (tCur), vec3 (0., 1., 0.), 0.05);
      rd = reflect (rd, vn);
      ro += 0.001 * rd;
      dstObj = ObjRay (ro, rd);
      if (dstObj < dstFar) ro += rd * dstObj;
      reflFac = 0.8;
    }
  }
  isRuf = false;
  if (dstObj < dstFar) {
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == 1) {
      fw = 0.;
      if (abs (ro.x) < owLen) {
        g = abs (ro.z);
      } else {
        q = ro;  q.x = abs (q.x) - owLen;  g = length (q.xz);
      }
      g -= owRad;
      if (abs (g) > owThk - 0.001) fw = sign (g);
      if (fw == 1.) {
        objCol = vec4 (1., 0.9, 0.9, 0.7);
        objCol.rgb *= BrickSurfShd (vec2 (((abs (ro.x) < owLen) ? ro.x :
           1.39 * atan (q.x, q.z)), ro.y) * vec2 (20., 30.));
      } else if (fw == -1.) {
        objCol = vec4 (0.8, 0.6, 0.3, 0.2);
        isRuf = true;
      } else objCol = vec4 (0.8, 0.8, 0.2, 1.) *
         (0.5 + 0.5 * smoothstep (0., 0.004, abs (g)));
      g = mod (ro.y, flHt) - 0.35;
      if (abs (g) < 0.021) {
        ss = SSBump (0.008, 0.01, g);
        if (ss.x + ss.y != 0.) {
          vn.y += 0.3 * (ss.y - ss.x);
          vn = normalize (vn);
          objCol.rgb *= 0.8 * ss.x + 1.1 * ss.y;
        }
      }
    } else if (idObj == 2) {
      g = 0.;
      if (abs (ro.x) < iwLen) {
        if (abs (ro.z) > iwRad + 0.02) g = ro.x;
      } else {
        q = ro;  q.x = abs (q.x) - iwLen;
        if (length (q.xz) > iwRad + 0.02) g = owRad * atan (q.x, q.z);
      }
      objCol = (g != 0.) ? mix (vec4 (0.6, 0.8, 0.6, 0.5),
         vec4 (0.6, 0.6, 0.8, 0.5),
         SmoothBump (0.7, 1.1, 0.1, Fbm2 (20. * vec2 (g, ro.y)))) :
         vec4 (0.6, 0.7, 0.6, 0.2) * mix (1., 0.9, Noisefv3a (200. * ro));
    } else if (idObj == 3) {
      objCol = (length (vec2 (mod (ro.x + 0.16, 0.32) - 0.16, ro.z)) < 0.1) ?
         vec4 (0.1, 0.4, 0.1, 0.1) : vec4 (0.5, 0.3, 0.1, 0.1);
      isRuf = true;
    } else if (idObj == 4) {
      if (abs (ro.x) < owLen) {
        g = abs (ro.z);
      } else {
        q = ro;  q.x = abs (q.x) - owLen;  g = length (q.xz);
      }
      g -= owRad + owThk;
      objCol = (g > 0.) ? vec4 (0.4, 0.4, 0.3, 0.1) * (1. -
         0.1 * SmoothBump (0.1, 0.3, 0.05, mod (30. * g, 1.))) :
         vec4 (0.5, 0.5, 0.45, 0.1);
      isRuf = true;
    } else if (idObj == 11) {
      objCol = vec4 (0.75, 0.7, 0.7, 0.1);
      isRuf = true;
    } else if (idObj == 12) {
      objCol = vec4 (vec3 (1., 0., 0.) * (1. - 0.2 * abs (vn.y)) *
         (0.8 + 0.2 * sin (3. * tCur)), -1.);
    } else if (idObj >= 256) {
      objCol = BoatCol (vn);
      if (objCol.a == -1.) {
        reflFac = 0.3;
        objCol.rgb = BgCol (ro, reflect (rd, vn));
      }
    }
    sh = ObjSShadow (ro, sunDir);
    if (isRuf) vn = VaryNf (200. * ro, vn, 1.);
    col = objCol.rgb;
    if (objCol.a >= 0.) col *= 0.3 +
       sh * (0.1 * max (vn.y, 0.) + 0.7 * max (dot (vn, sunDir), 0.)) +
       sh * objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.);
  } else {
    sh = (rd.y < 0.) ? ObjSShadow (ro - (ro.y / rd.y) * rd, sunDir) : 1.;
    col = sh * BgCol (ro, rd);
  }
  if (wkFac > 0.) col = mix (col, vec3 (0.7),
     wkFac * clamp (0.1 + 0.6 * Fbm3 (100. * row), 0., 1.));
  col *= reflFac;
  return pow (clamp (col, 0., 1.), vec3 (0.7));
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, float vuMode, float zmVar)
{
  vec4 wgBx[2];
  vec2 ust;
  float asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (0.47 * asp, -0.4, 0.03, 0.);
  wgBx[1] = vec4 (0.47 * asp, -0.1, 0.012 * asp, 0.18);
  ust = abs (0.5 * uv - wgBx[0].xy) - wgBx[0].zw;
  if (max (ust.x, ust.y) < 0.) {
    if (abs (max (ust.x, ust.y)) * canvas.y < 1.5) col = vec3 (0.8, 0.8, 0.);
    else col = vec3 (0.8, 0.8, 0.) * mix (1., 0., abs (ust.x) / wgBx[0].z);
  }
  if (length (0.5 * uv - wgBx[0].xy) < wgBx[0].z) {
    if (length (0.5 * uv - wgBx[0].xy) < 0.8 * wgBx[0].z) col =
       (vuMode == 0.) ? vec3 (0.7, 0.7, 0.2) : ((vuMode == 1.) ?
       vec3 (0.2, 0.2, 1.) :  vec3 (0.2, 1., 0.2));
    else col = vec3 (1., 0.2, 0.2);
  }
  ust = abs (0.5 * uv - wgBx[1].xy) - wgBx[1].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.8, 0.8, 0.);
  ust = 0.5 * uv - wgBx[1].xy;
  ust.y -= (zmVar - 0.5) * 2. * wgBx[1].w;
  ust = abs (ust) - 0.6 * wgBx[1].zz;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.5) col = vec3 (1., 1., 0.);
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 stDat;
  vec3 ro, rd, vd, col, vuPos;
  vec2 canvas, uv, ori, ca, sa;
  float el, az, zmVar, zmFac, vuMode;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  dstFar = 12.;
  owRad = 1.4;  owLen = 0.83;  iwRad = 1.3;
  iwLen = 0.7;  owThk = 0.03;  flHt = 0.4;
  stDat = Loadv4 (0);
  vuPos = stDat.xyz;
  vuMode = stDat.w;
  stDat = Loadv4 (1);
  el = stDat.x;
  az = stDat.y;
  zmVar = stDat.z;
  for (int k = 0; k < 3; k ++) {
    stDat = Loadv4 (3 + k);
    boatPos[k].xz = stDat.xy;
    boatPos[k].y = 0.003 * Fbm1 (0.033 * float (k) + 5. * tCur);;
    boatAng[k] = stDat.z;
    boatMat[k] = BoatPM (boatAng[k]);
  }
  sunDir = normalize (vec3 (1., 1., -1.));
  ro = vuPos;
  if (vuMode == 0.) {
    el = min (el, 0.);
    zmFac = 2. + 10. * zmVar;
  } else if (vuMode == 1.) {
    vd = normalize (vec3 (clamp (ro.x, - (owLen - 0.27), owLen - 0.27),
       0.1, 0.) - ro);
    az = clamp (az, -0.7 * pi, 0.7 * pi);
    el = clamp (el, -0.2 * pi, 0.2 * pi);
    az += 0.5 * pi + atan (- vd.z, vd.x);
    el += asin (vd.y);
    zmFac = (1. + 0.4 * ((abs (ro.x) < owLen - 0.27) ? abs (ro.z) :
       length (abs (ro.xz) - vec2 (owLen - 0.27, 0.)))) * (0.4 + 3. * zmVar);
  } else if (vuMode == 2. || vuMode == 3.) {
    vd.xz = ((vuMode == 2.) ? boatPos[0] : boatPos[2]).xz - ro.xz;
    vd.y = - ro.y;
    vd = normalize (vd);
    az = clamp (az, - pi, pi);
    el = clamp (el, -0.2 * pi, 0.2 * pi);
    az += 0.5 * pi + atan (- vd.z, vd.x);
    el += asin (vd.y);
    zmFac = 1. * (1. + 3. * zmVar);
  }
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
          mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  rd = vuMat * normalize (vec3 (uv, zmFac));
  if (vuMode == 0.) {
    ro = vuMat * ro;
  }
  col = ShowScene (ro, rd);
  col = ShowWg (uv, canvas, col, vuMode, zmVar);
  fragColor = vec4 (col, 1.);
}
