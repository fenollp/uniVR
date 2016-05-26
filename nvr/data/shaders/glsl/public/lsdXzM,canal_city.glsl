// Shader downloaded from https://www.shadertoy.com/view/lsdXzM
// written by shadertoy user dr2
//
// Name: Canal City
// Description: Explore a modern version of Venice (Canaletto meets Bauhaus)
// "Canal City" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  Vertical slider controls flight speed.
  Horizontal sliders control zoom and Pannini factor (see "Pannini's Rotunda"
    for details; note that here the transformation is applied to both x and y
    coordinates).
  Look around using the mouse (centered marker shows forward direction).
  Buildings are individually numbered (zoom in to read, there are thousands
    of them).
  Each restart is from a different location.
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

float Hashfv2 (vec2 p)
{
  return fract (sin (dot (p, cHashA3.xy)) * cHashM);
}

vec2 Hashv2f (float p)
{
  return fract (sin (p + cHashA4.xy) * cHashM);
}

vec4 Hashv4f (float p)
{
  return fract (sin (p + cHashA4) * cHashM);
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

float Fbm2 (vec2 p)
{
  float f, a;
  f = 0.;
  a = 1.;
  for (int j = 0; j < 5; j ++) {
    f += a * Noisefv2 (p);
    a *= 0.5;
    p *= 2.;
  }
  return f;
}

float IFbm1 (float p)
{
  float s, a;
  p *= 5.;
  s = 0.;
  a = 10.;
  for (int j = 0; j < 4; j ++) {
    s += floor (a * Noiseff (p));
    a *= 0.5;
    p *= 2.;
  }
  return 0.1 * s;
}

float Fbmn (vec3 p, vec3 n)
{
  vec3 s;
  float a;
  s = vec3 (0.);
  a = 1.;
  for (int j = 0; j < 5; j ++) {
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

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d;
  d = abs (p) - b;
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

float PrFlatCylIDf (vec3 p, float w, float r)
{
  p.x -= clamp (p.x, - w, w);
  return length (p.xy) - r;
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

const float txRow = 64.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

mat3 vuMat;
vec3 vuPos, qHit, sunDir;
vec2 iqBlk;
float dstFar, tCur, flrHt;
int idObj;
const int idBldg = 1, idArc = 2, idCan = 3, idPlaza = 4, idBrdg = 5, idCurb = 6,
   idPost = 7, idBoat = 8, idLamp = 9, idBLamp = 10, idFLamp = 11, idPLamp = 12;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col, skyCol, sunCol, p;
  float ds, fd, att, attSum, d, sd;
  if (rd.y >= 0.) {
    p = rd * (200. - ro.y) / max (rd.y, 0.0001);
    ds = 0.1 * sqrt (length (p));
    p += ro;
    fd = 0.002 / (smoothstep (0., 10., ds) + 0.1);
    p.xz *= fd;
    p.xz += 0.1 * tCur;
    att = Fbm2 (p.xz);
    attSum = att;
    d = fd;
    ds *= fd;
    for (int j = 0; j < 4; j ++) {
      attSum += Fbm2 (p.xz + d * sunDir.xz);
      d += ds;
    }
    attSum *= 0.3;
    att *= 0.3;
    sd = clamp (dot (sunDir, rd), 0., 1.);
    skyCol = mix (vec3 (0.7, 1., 1.), vec3 (1., 0.4, 0.1), 0.25 + 0.75 * sd);
    sunCol = vec3 (1., 0.8, 0.7) * pow (sd, 1024.) +
       vec3 (1., 0.4, 0.2) * pow (sd, 256.);
    col = mix (vec3 (0.5, 0.75, 1.), skyCol, exp (-2. * (3. - sd) *
       max (rd.y - 0.1, 0.))) + 0.3 * sunCol;
    attSum = 1. - smoothstep (1., 9., attSum);
    col = mix (vec3 (0.4, 0., 0.2), mix (col, vec3 (0.3, 0.3, 0.3), att), attSum) +
       vec3 (1., 0.4, 0.) * pow (attSum * att, 3.) * (pow (sd, 10.) + 0.5);
  } else col = vec3 (0.2);
  return col;
}

float BldgDf (vec3 p)
{
  vec3 q, qq;
  vec2 ip;
  float dMin, d, db, bWid, bHt, arWid, nFlr, nAr;
  arWid = 0.5 * flrHt;
  dMin = dstFar;
  ip = floor (p.xz);
  nAr = 2. * floor (3.9 + 4.9 * Hashfv2 (11. * ip)) + 1.;
  bWid = nAr * arWid;
  nFlr = floor (2. + 3. * Hashfv2 (13. * ip));
  bHt = nFlr * flrHt;
  q = p;  q.xz = fract (q.xz) - vec2 (0.5);  q.y -= 0.5 * flrHt;
  qq = q;
  d = PrBoxDf (qq, vec3 (0.5 * bWid, 0.55 * flrHt, 0.5 * bWid));
  qq.y -= 0.51 * flrHt;
  d = max (d, - PrBoxDf (qq, vec3 (0.5 * bWid - 0.1 * arWid, 0.05 * flrHt,
     0.5 * bWid - 0.1 * arWid)));
  qq = q;  qq.y -= -0.17 * flrHt;
  qq.x = mod (qq.x + 0.5 * arWid, arWid) - 0.5 * arWid;
  db = PrFlatCylIDf (qq.yxz, 0.3 * flrHt, 0.32 * arWid);
  qq = q;  qq.y -= -0.17 * flrHt;
  qq.z = mod (qq.z + 0.5 * arWid, arWid) - 0.5 * arWid;
  db = max (min (db, PrFlatCylIDf (qq.yzx, 0.3 * flrHt, 0.32 * arWid)),
     - q.y - 0.8 * flrHt);
  d = max (d, - db);
  if (d < dMin) { dMin = d;  idObj = idArc;  qHit = q;  iqBlk = ip; }
  if (nFlr > 1.) {
    qq = q;    qq.y -= 0.5 * flrHt;
    bWid -= 2. * arWid;
    d = PrBoxDf (qq, vec3 (0.5 * bWid, 1.05 * flrHt, 0.5 * bWid));
    qq.y -= 1.01 * flrHt;
    d = max (d, - PrBoxDf (qq, vec3 (0.5 * bWid - 0.1 * arWid, 0.05 * flrHt,
       0.5 * bWid - 0.1 * arWid)));
    if (d < dMin) { dMin = d;  idObj = idBldg;  qHit = q;  iqBlk = ip; }
  }
  if (nFlr > 2.) {
    qq = q;    qq.y -= 0.5 * (flrHt + bHt);
    bWid -= 2. * arWid;
    d = PrBoxDf (qq, vec3 (0.5 * bWid, 0.5 * (bHt - 2. * flrHt) + 0.05 * flrHt,
       0.5 * bWid));
    qq.y -= 0.5 * (bHt - 2. * flrHt) + 0.01 * flrHt;
    d = max (d, - PrBoxDf (qq, vec3 (0.5 * bWid - 0.1 * arWid, 0.05 * flrHt,
       0.5 * bWid - 0.1 * arWid)));
    if (d < dMin) { dMin = d;  idObj = idBldg;  qHit = q;  iqBlk = ip; }
  }
  return dMin;
}

float BldRay (vec3 ro, vec3 rd)
{
  vec3 p;
  vec2 srd, dda, h;
  float dHit, d;
  srd = 1. - 2. * step (0., rd.xz);
  dda = - srd / (rd.xz + 0.0001);
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    p = ro + dHit * rd;
    h = fract (dda * fract (srd * p.xz));
    d = BldgDf (p);
    dHit += min (d, 0.1 + max (0., min (h.x, h.y)));
    if (d < 0.0002 || dHit > dstFar) break;
  }
  return dHit;
}

float BoatDf (vec3 p, float dMin)
{
  vec3 q;
  float d, s, cDir, ds;
  p.y -= -0.001;
  q.xz = mod (p.xz + 0.5, 1.) - 0.5;
  s = 0.11 * tCur;
  cDir = (max (abs (q.x), abs (q.z)) < 0.1) ? step (0.5, mod (s, 1.)) :
     step (abs (q.z), abs (q.x));
  q = p;
  if (cDir == 0.) {
    q.xz = q.zx;
    s = - s;
  }
  s += 0.25;
  q.z = mod (q.z + 0.5, 1.) - 0.5;
  ds = 2. * step (0., q.z) - 1.;
  q.x = mod (q.x + 0.5 + ds * s, 1.) - 0.5;
  q.z = abs (q.z) - 0.03;
  d = max (PrCapsDf (q.zyx, 0.011, 0.025),
     - PrCapsDf (q.zyx + vec3 (0., -0.002, 0.), 0.01, 0.024));
  if (d < dMin) { dMin = d;  idObj = idBoat; }
  q.y -= 0.007;
  ds *= (1. - 2. * cDir);
  q.x -= 0.035 * ds;
  d = PrSphDf (q, 0.002);
  if (d < dMin) { dMin = d;  idObj = idFLamp; }
  q.x -= -0.07 * ds;
  d = PrSphDf (q, 0.002);
  if (d < dMin) { dMin = d;  idObj = idBLamp; }
  return dMin;
}

float CanDf (vec3 p)
{
  vec3 q;
  float dMin, d;
  dMin = dstFar;
  d = p.y + 0.01;
  if (d < dMin) { dMin = d;  idObj = idCan; }
  q = p;  q.xz = fract (q.xz) - 0.5;  q.y -= -0.0015;
  d = PrBoxDf (q, vec3 (0.4, 0.0015, 0.4));
  if (d < dMin) { dMin = d;  idObj = idPlaza;  qHit = p; }
  q.y -= -0.003;
  if (abs (q.x) < abs (q.z)) q.xz = q.zx;
  q.x = abs (q.x) - 0.403;
  d = PrBoxDf (q, vec3 (0.003, 0.01, 0.406));
  if (d < dMin) { dMin = d;  idObj = idCurb;  qHit = p; }
  q = p;  q.xz = abs (mod (q.xz + 0.5, 1.) - 0.5) - 0.1;
  d = PrCylDf (q.xzy, 0.0025, 0.07);
  if (d < dMin) { dMin = d;  idObj = idPost;  qHit = p; }
  q.y -= 0.07;
  d = PrSphDf (q, 0.007);
  if (d < dMin) { dMin = d;  idObj = idLamp; }
  q = p;  q.xz = mod (q.xz + 0.5, 1.) - 0.5;  q.y -= -0.01;
  d = PrCylDf (q.xzy, 0.006, 0.02);
  if (d < dMin) { dMin = d;  idObj = idPost;  qHit = p; }
  q.y -= 0.02;
  d = PrSphDf (q, 0.006);
  if (d < dMin) { dMin = d;  idObj = idPLamp;  qHit = p; }
  q.y = p.y - 0.003;
  if (abs (q.x) > abs (q.z)) q.xz = q.zx;
  q.z = abs (q.z) - 0.275;  q.y -= -0.17;
  d = max (PrShCylDf (q, 0.2, 0.22, 0.02), - PrShCylDf (q, 0.21, 0.23, 0.016));
  if (d < dMin) { dMin = d;  idObj = idBrdg;  qHit = p; }
  dMin = BoatDf (p, dMin);
  return dMin;
}

float CanRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = CanDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.0001 || dHit > dstFar) break;
  }
  return dHit;
}

float ObjRay (vec3 ro, vec3 rd)
{
  vec3 qHitT;
  float dMin, d;
  int idObjT;
  dMin = dstFar;
  d = BldRay (ro, rd);
  if (d < dMin) dMin = d;
  idObjT = idObj;
  qHitT = qHit;
  d = CanRay (ro, rd);
  if (d < dMin) dMin = d;
  else {
    idObj = idObjT;
    qHit = qHitT;
  }
  return dMin;
}

float ObjDf (vec3 p)
{
  float dMin;
  dMin = dstFar;
  dMin = min (dMin, BldgDf (p));
  dMin = min (dMin, CanDf (p));
  return dMin;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  vec3 qHitT;
  int idObjT;
  const vec3 e = vec3 (0.0001, -0.0001, 0.);
  idObjT = idObj;
  qHitT = qHit;
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  idObj = idObjT;
  qHit = qHitT;
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float DigSeg (vec2 q)
{
  return step (abs (q.x), 0.12) * step (abs (q.y), 0.6);
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
  q = (q - 0.5) * vec2 (1.5, 2.2);
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
    nDig = (val > 0.) ? floor (max (log (val) / log (10.), 0.)) + 1. : 1.;
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

vec4 ObjCol (vec3 ro, vec3 rd, vec3 vn)
{
  vec4 objCol;
  vec2 g, b;
  float wWid, bn;
  bool doRefl, isLit;
  doRefl = false;
  isLit = false;
  wWid = 0.5 * flrHt;
  if (idObj == idBldg || idObj == idArc) {
    if (abs (vn.y) < 0.05) {
      vn.z *= -1.;
      g = vec2 (dot (qHit.xz, normalize (vn.zx)), qHit.y) / vec2 (wWid, flrHt);
      if (idObj == idBldg) {
        g = mod (g - 0.25, 1.) * vec2 (wWid / flrHt, 1.);
        if (step (0.2, g.x) * step (0.3, g.y) *  step (0.015,
           min (abs (g.x - 0.35), abs (g.y - 0.65))) > 0.) doRefl = true;
      } else {
        if (length (vec2 (0.25 * abs (g.x), abs (g.y - 0.42))) < 0.08) {
          bn = (10. + mod (iqBlk.y, 90.)) * 100. + mod (iqBlk.x, 100.);
          if (ShowInt (vec2 (g.x - 0.2, g.y - 0.37),
             vec2 (0.4, 0.1), 4., bn) == 0.) isLit = true;
        }
      }
    }
    if (doRefl) {
      rd = reflect (rd, vn);
      g = Rot2D (rd.xz, 5.1 * atan (0.3 + iqBlk.y, 0.3 + iqBlk.x));
      objCol = vec4 (0.7 * (0.4 + 0.6 * (step (1., 10. * (ro.y + 2. * rd.y) -
         0.3 * floor (5. * IFbm1 (0.3 * atan (g.y, g.x) + pi) + 0.05)))) *
         BgCol (ro, rd), -1.);
    } else if (isLit) {
      objCol = vec4 (1., 1., 0.5, -2.);
    } else {
      objCol = vec4 (0.1 + 0.8 * HsvToRgb (vec3 (Hashfv2 (19. * iqBlk),
         0.2 + 0.2 * Hashfv2 (21. * iqBlk),
         0.6 + 0.2 * Hashfv2 (23. * iqBlk))), 0.3);
      if (abs (vn.y) > 0.95) {
        g = step (0.05, fract (qHit.xz * 70.));
        objCol *= mix (0.8, 1., g.x * g.y);
      } else objCol *= (0.9 + 0.1 *
         Noisefv2 (2100. * vec2 (qHit.x + qHit.z, qHit.y)));
    }
  } else if (idObj == idPlaza) {
    g = step (0.05, fract (qHit.xz * 20.));
    objCol = vec4 (0.4, 0.3, 0.3, 0.1) * mix (0.7, 1., g.x * g.y);
  } else if (idObj == idBrdg) objCol = vec4 (0.4, 0.4, 0.2, 0.1) *
     (0.8 + 0.2 * Noisefv2 (1000. * vec2 (qHit.x * qHit.z, qHit.y)));
  else if (idObj == idCurb) objCol = vec4 (0.3, 0.4, 0.3, 0.1) *
     (0.8 + 0.2 * Noisefv2 (512. * 512. * vec2 (qHit.x * qHit.z, qHit.y)));
  else if (idObj == idPost) objCol = vec4 (0.6, 0.6, 0.65, 0.5);
  else if (idObj == idBoat) objCol = vec4 (0.2, 0.07, 0., 0.2);
  else if (idObj == idLamp) objCol = vec4 (1., 1., 0.5, -2.);
  else if (idObj == idFLamp) objCol = vec4 (0., 1., 0., -2.);
  else if (idObj == idBLamp) objCol = vec4 (1., 0., 0., -2.);
  else if (idObj == idPLamp) objCol = vec4 (0., 0., 1., -2.);
  return objCol;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, vn;
  float dstHit, refFac;
  dstHit = ObjRay (ro, rd);
  refFac = 1.;
  if (dstHit < dstFar) {
    if (idObj == idCan) {
      ro += rd * dstHit;
      vn = VaryNf (10. * ro + 0.3 * tCur, vec3 (0., 1., 0.), 0.05);
      rd = reflect (rd, vn);
      ro += 0.001 * rd;
      dstHit = ObjRay (ro, rd);
      refFac = 0.7;
    }
  }
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    objCol = ObjCol (ro, rd, vn);
    col = objCol.rgb;
    if (objCol.a >= 0.) {
      if (idObj == idCan) vn = VaryNf (500. * qHit, vn, 2.);
      else if (idObj == idBldg || idObj == idArc)
         vn = VaryNf (500. * qHit, vn, 0.5);
      col = col * (0.2 + 0.1 * max (dot (vn, sunDir * vec3 (-1., 1., -1.)), 0.) +
         0.8 * max (dot (vn, sunDir), 0.) +
         objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 128.));
    } else if (objCol.a == -2.) {
      col *= (0.5 - 0.5 * dot (vn, rd));
    }
    col = mix (col, BgCol (ro, rd), smoothstep (0.4, 1., dstHit / dstFar));
  } else col = BgCol (ro, rd);
  col *= refFac;
  return pow (clamp (col, 0., 1.), vec3 (0.8));
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, float zmVar, float pnVar, float fvVar)
{
  vec4 wgBx[3];
  vec2 ust;
  float asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (0.47 * asp, -0.2, 0.012 * asp, 0.15);
  wgBx[1] = vec4 (0.13 * asp, -0.46, 0.1 * asp, 0.022);
  wgBx[2] = vec4 (0.37 * asp, -0.46, 0.1 * asp, 0.022);
  ust = abs (0.5 * uv - wgBx[0].xy) - wgBx[0].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.8);
  ust = 0.5 * uv - wgBx[0].xy;
  ust.y -= (fvVar - 0.5) * 2. * wgBx[0].w;
  if (abs (length (ust) - 0.8 * wgBx[0].z) * canvas.y < 2.)
     col = (fvVar * canvas.y > 15.) ? vec3 (0.1, 1., 0.1) : vec3 (1., 0.1, 0.1);
  ust = abs (0.5 * uv - wgBx[1].xy) - wgBx[1].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.8);
  ust = 0.5 * uv - wgBx[1].xy;
  ust.x -= (zmVar - 0.5) * 2. * wgBx[1].z;
  ust = abs (ust) - 0.6 * wgBx[1].ww;
  if (abs (max (ust.x, ust.y)) * canvas.y < 2.) col = vec3 (1., 0.3, 1.);
  ust = abs (0.5 * uv - wgBx[2].xy) - wgBx[2].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.8);
  ust = 0.5 * uv - wgBx[2].xy;
  ust.x -= (pnVar - 0.5) * 2. * wgBx[2].z;
  ust = abs (ust) - 0.6 * wgBx[2].ww;
  if (abs (max (ust.x, ust.y)) * canvas.y < 2.) col =
     (pnVar > 0.3) ? vec3 (1., 0., 0.1) : ((pnVar > 0.1) ?
     vec3 (1., 1., 0.1) : vec3 (0.1, 1., 0.1));
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 stDat, mPtr;
  vec3 ro, rd, col;
  vec2 canvas, uv, ori, ca, sa, aa;
  float el, az, asp, zmVar, pnVar, fvVar, zmFac, pnFac;
  int wgSel;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  stDat = Loadv4 (0);
  zmVar = stDat.x;
  pnVar = stDat.y;
  el = stDat.z;
  az = stDat.w;
  stDat = Loadv4 (1);
  wgSel = int (stDat.x);
  fvVar = stDat.y;
  dstFar = 20.;
  flrHt = 0.075;
  stDat = Loadv4 (2);
  mPtr = vec4 (stDat.xyz, 0.);
  stDat = Loadv4 (3);
  ro = stDat.xyz;
  ori = vec2 (el, az + stDat.w);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  asp = canvas.x / canvas.y;
  zmFac = 0.3 + 3.7 * zmVar;
  pnFac = exp (5. * pnVar) - 1.;  
  aa = atan (uv / zmFac);
  rd = vuMat * normalize (vec3 ((1. + pnFac) * sin (aa) / (pnFac + cos (aa)), 1.));
  sunDir = normalize (vec3 (1., 0.2, -1.));
  col = ShowScene (ro, rd);
  col = ShowWg (uv, canvas, col, zmVar, pnVar, fvVar);
  if (mPtr.z > 0. && wgSel < 0) {
    if (max (abs (uv.x), abs (uv.y)) < 0.05 &&
       min (abs (uv.x), abs (uv.y)) < 0.003) col = vec3 (0.1, 1., 0.1);
  }
  fragColor = vec4 (col, 1.);
}
