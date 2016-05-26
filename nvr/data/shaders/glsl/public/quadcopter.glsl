// Shader downloaded from https://www.shadertoy.com/view/4sKGWG
// written by shadertoy user dr2
//
// Name: Quadcopter
// Description: Come fly with me...
// "Quadcopter" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
Drag the red ring for manual drone control; release to land.
Red/green circles show direction home and drone position (also given numerically).
Automatic (meandering) return home.
Fixed fisheye camera lens.
Tracking camera zoom depends on drone range.
(No drone rotation in horizontal plane and no inertial effects for simplicity.)
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

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

float PrRoundBoxDf (vec3 p, vec3 b, float r)
{
  return length (max (abs (p) - b, 0.)) - r;
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
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

float PrCylAnDf (vec3 p, float r, float w, float h)
{
  return max (abs (length (p.xy) - r) - w, abs (p.z) - h);
}

const float txRow = 32.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

mat3 acMat;
vec3 acPos, sunDir;
vec2 aTilt;
float tCur, dstFar;
int idObj;
bool camVu, acHide;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 vn, col;
  vec2 w, wd;
  float sd, f;
  vec2 e = vec2 (0.01, 0.);
  if (rd.y >= 0.) {
    ro.xz += 2. * tCur;
    sd = max (dot (rd, sunDir), 0.);
    col = vec3 (0.1, 0.2, 0.4) + 0.2 * (1. - max (rd.y, 0.)) +
       0.1 * pow (sd, 16.) + 0.2 * pow (sd, 256.);
    f = Fbm2 (0.02 * (ro.xz + rd.xz * (200. - ro.y) / max (rd.y, 0.001)));
    col = mix (col, vec3 (1.), clamp (0.2 + 0.8 * f * rd.y, 0., 1.));
  } else {
    ro -= (ro.y / rd.y) * rd;
    f = Fbm2 (ro.xz);
    vn = normalize (vec3 (f - Fbm2 (ro.xz + e.xy), 0.1, f - Fbm2 (ro.xz + e.yx)));
    col = mix (vec3 (0.4, 0.3, 0.1), vec3 (0.4, 0.5, 0.2), f) *
         (1. - 0.1 * Noisefv2 (ro.xz));
    col = mix (vec3 (0.6, 0.3, 0.3), col,
       smoothstep (0.05, 0.07, mod (ro.x, 2.)) *
       smoothstep (0.05, 0.07, mod (ro.z, 2.)));
    col = mix (vec3 (1., 1., 0.), col,
       smoothstep (0.1, 0.2, abs (length (ro.xz) - 3.)));
    col = mix (vec3 (1., 1., 0.), col,
       smoothstep (0.3, 0.4, length (ro.xz)));
    col *= 0.1 + 0.9 * max (dot (vn, sunDir), 0.);
    w = acPos.xz - ro.xz;
    wd = (length (acPos.xz) > 0.) ? 0.5 * normalize (acPos.xz) : vec2 (0.);
    col = mix (vec3 (1., 0.2, 0.2), col, 0.3 +
       0.7 * smoothstep (0.15, 0.17, length (w + wd)));
    col = mix (vec3 (0.2, 1., 0.2), col, 0.3 +
       0.7 * smoothstep (0.15, 0.17, length (w - wd)));
    col = mix (col, 0.95 * vec3 (0.45, 0.55, 0.7), pow (1. + rd.y, 64.));
  }
  return col;
}

float TransObjDf (vec3 p)
{
  vec3 q;
  float dMin;
  dMin = dstFar;
  q = p - acPos;
  q.yz = Rot2D (q.yz, - aTilt.y);
  q.yx = Rot2D (q.yx, - aTilt.x);
  q.xz = abs (q.xz) - 0.7;
  q.y -= -0.02;
  return min (dMin, PrCylDf (q.xzy, 0.415, 0.02));
}

float TransObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 50; j ++) {
    d = TransObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.005 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 TransObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (TransObjDf (p + e.xxx), TransObjDf (p + e.xyy),
     TransObjDf (p + e.yxy), TransObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjDf (vec3 p)
{
  vec3 q, qq, iq;
  float dMin, d;
  dMin = dstFar;
  if (! acHide) {
    qq = p - acPos;
    qq.yz = Rot2D (qq.yz, - aTilt.y);
    qq.yx = Rot2D (qq.yx, - aTilt.x);
    q = qq;
    q.y -= 0.05;
    d = PrRCylDf (q.xzy, 0.2, 0.03, 0.07);
    if (d < dMin) { dMin = d;  idObj = 1; }
    q.y -= 0.07;
    d = PrRoundBoxDf (q, vec3 (0.06, 0.02, 0.12), 0.04);
    if (d < dMin) { dMin = d;  idObj = 2; }
    q = qq;
    q.y -= -0.05;
    d = PrSphDf (q, 0.17);
    if (d < dMin) { dMin = d;  idObj = 3; }
    q = qq;
    q.xz = abs (q.xz) - 0.7;
    d = min (PrCylAnDf (q.xzy, 0.5, 0.05, 0.05), PrCylDf (q.xzy, 0.1, 0.03));
    if (d < dMin) { dMin = d;  idObj = 1; }
    q.xz += 0.4;
    q.y -= -0.15;
    d = PrRCylDf (q.xzy, 0.05, 0.03, 0.2);
    if (d < dMin) { dMin = d;  idObj = 1; }
    q.y -= 0.2;
    q.xz += 0.3;
    q.xz = Rot2D (q.xz, 0.25 * pi);
    d = min (PrRCylDf (q, 0.05, 0.02, 1.), PrRCylDf (q.zyx, 0.05, 0.02, 1.));
    if (d < dMin) { dMin = d;  idObj = 1; }
  }
  q = p;
  iq.xz = floor ((mod (q.xz, 16.) - 8.) / 8.);
  q.xz = mod (q.xz, 8.) - 4.;
  q.y -= 0.1;
  d = (iq.x != iq.z) ? PrBoxDf (q, vec3 (0.3, 0.1, 0.3)) :
     PrCylDf (q.xzy, 0.4, 0.1);
  q = p;
  d = max (d, PrBox2Df (q.xz, vec2 (64.)));
  if (d < dMin) { dMin = d;  idObj = 4; }
  d = p.y;
  if (d < dMin) { dMin = d;  idObj = 6; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.005 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 roo, rooO, ror, col, vn, iq, iiq;
  float dstHit, dstPropel, dstHitO, dstPropelO, f;
  int idObjT;
  bool isBg, reflArea, isBdy;
  isBg = true;
  dstPropel = TransObjRay (ro, rd);
  acHide = camVu;
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstPropel) dstPropel = dstFar;
  rooO = ro;
  dstHitO = dstHit;
  dstPropelO = dstPropel;
  isBdy = false;
  if (dstHit < dstFar && idObj == 6) {
    ror = ro + rd * dstHit;
    iq.xz = floor ((mod (ror.xz, 16.) - 8.) / 8.);
    iiq.xz = floor (ror.xz / 8.);
    f = length (ror.xz - 8. * (iiq.xz + 0.5));
    reflArea = (max (iiq.x, iiq.z) < 8. && min (iiq.x, iiq.z) > -9. &&
       iq.x == iq.z && (iiq.x != 0. || iiq.z != 0.) &&
       (iiq.x != -1. || iiq.z != -1.));
    isBdy = (reflArea && f > 3.9 && f < 4.);
    if (reflArea && f < 3.9) {
      ro += rd * dstHit;
      rd = reflect (rd, vec3 (0., 1., 0.));
      ro += 0.01 * rd;
      roo = ro;
      dstPropel = TransObjRay (ro, rd);
      acHide = false;
      dstHit = ObjRay (ro, rd);
      if (dstHit < dstPropel) dstPropel = dstFar;
    }
  }      
  if (dstHit < dstFar && idObj != 6) {
    ro += rd * dstHit;
    isBg = false;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == 1) objCol = vec4 (0.95, 0.95, 1., 0.8);
    else if (idObj == 2) objCol = mix (vec4 (0.3, 0.3, 1., 0.2),
       vec4 (1., 0., 0., 0.2), step (0., sin (10. * tCur)));
    else if (idObj == 3) objCol = vec4 (0.1, 0.1, 0.1, 1.);
    else if (idObj == 4) objCol = vec4 (0.8, 0.5, 0.2, 0.2);
    col = objCol.rgb * (0.3 + 0.7 * max (dot (vn, sunDir), 0.)) +
       objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 32.);
  }
  if (isBg) col = isBdy ? vec3 (0., 0.3, 0.) : BgCol (ro, rd);
  if (dstPropelO < dstFar) {
    vn = TransObjNf (rooO + rd * dstPropelO);
    col = 0.7 * col + 0.3 * max (dot (vn, sunDir), 0.1);
  }
  if (dstPropel < dstFar) {
    vn = TransObjNf (roo + rd * dstPropel);
    col = 0.7 * col + 0.3 * max (dot (vn, sunDir), 0.1);
  }
  return clamp (col, 0., 1.);
}

// 7-segment display based on shaders by Andre (Xsy3zG) and eiffie (MdyGWG)

float ShowSeg (vec2 q)
{
  return ((1. - smoothstep (0.08, 0.11, abs (q.x))) *
     (1. - smoothstep (0.46, 0.49, abs (q.x) + abs (q.y)))) *
     (1. - length (q * vec2 (3.8, 0.9)));
}

float ShowDig (vec2 q, int iv)
{
  float d;
  const vec2 vh = vec2 (0.5, 0.5), vs = vec2 (0.5, -0.5), vo = vec2 (1., 0.);
  q = (q - 0.5) * vec2 (1.5, 2.2);
  d = 0.;
  if (iv != -1) {
    if (iv != 1) {
      d += (iv != 2 && iv != 3 && iv != 7) ? ShowSeg (q.xy - vh) : 0.;
      d += (iv != 4) ? ShowSeg (q.yx - vo) : 0.;
      d += (iv != 4 && iv != 7) ? ShowSeg (q.yx + vo) : 0.;
    }
    d += (iv != 5 && iv != 6) ? ShowSeg (q.xy + vs) : 0.;
    d += (iv != 0 && iv != 1 && iv != 7) ? ShowSeg (q.yx) : 0.;
    d += (iv == 0 || iv == 2 || iv == 6 || iv == 8) ? ShowSeg (q.xy - vs) : 0.;
    d += (iv != 2) ? ShowSeg (q.xy + vh) : 0.;
  } else d += ShowSeg (q.yx);
  return d;
}

float ShowNum (vec2 q, vec2 cBox, float mxChar, float val)
{
  float nDig, idChar, s, sgn, v;
  q = vec2 (- q.x, q.y) / cBox;
  s = 0.;
  if (q.x < 0. || q.y < 0. || q.x >= 1. || q.y >= 1.) return s;
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
  return s;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat, vuMatT;
  vec4 mPtr;
  vec3 ro, rd, u, vd, col;
  vec2 canvas, uv, us, uc, um, mMid, g;
  float zmFac, asp, aLim, mRad, f;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  asp = canvas.x / canvas.y;
  aTilt = Loadv4 (0).xy;
  mPtr = Loadv4 (1);
  dstFar = 200.;
  acPos = Loadv4 (2).xyz;
  mMid = vec2 (0.75, 0.55) * vec2 (asp, 1.);
  mRad = 0.4;
  uc = uv - mMid;
  camVu = (length (uc) < mRad);
  if (camVu) {
    zmFac = 0.7;
    uv = - (uv - mMid) / mRad;
    ro = acPos;
    rd = normalize (vec3 ((1./0.9) * sin (0.9 * uv), zmFac));
    rd.yz = Rot2D (rd.yz, 0.5 * pi + aTilt.y);
    rd.yx = Rot2D (rd.yx, aTilt.x);
  } else {
    ro = vec3 (0., 10., 15.);
    vd = acPos - ro;
    zmFac = 1.6 + 0.1 * length (vd);
    vd.y *= 1.2;
    vd = normalize (vd);
    u = - vd.y * vd;
    f = 1. / sqrt (1. - vd.y * vd.y);
    vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
    rd = vuMat * normalize (vec3 (uv, zmFac));
  }
  sunDir = normalize (vec3 (1., 2., 1.));
  col = ShowScene (ro, rd);
  um = vec2 (0.38, -0.3) * vec2 (asp, 1.);
  us = 0.5 * uv - um;
  f = (length (us) - 0.135) * canvas.y;
  if (abs (f) < 1.5 || f < 0. && min (abs (us.x), abs (us.y)) * canvas.y < 1.)
     col = vec3 (0., 0.7, 0.);
  if (f < 0.) col = mix (vec3 (1., 0., 0.), col, step (3.,
     abs (length (us + (1./5.5) * aTilt) * canvas.y - 10.)));
  if (camVu && (length (uc) - mRad) * canvas.y > -3.) col = vec3 (0., 0., 1.);
  if (! camVu) {
    um = vec2 (0., -0.97) * vec2 (asp, 1.);
    uc = uv - um;
    uc = abs (uc) - vec2 (0.22, 0.05);
    if (max (uc.x, uc.y) < 0.) {
      uv -= um + vec2 (0.06, -0.02);
      us = vec2 (0.1, 0.06) * vec2 (asp, 1.);
      g = floor (-10. * acPos.xz);
      col = mix (col, vec3 (0., 0., 1.), 0.2);
      f = ShowNum (uv + vec2 (0.1, 0.), us, 5., g.x) +
          ShowNum (uv - vec2 (0.1, 0.), us, 5., g.y);
      col = mix (col, vec3 (1., 0., 0.), f);
    }
  }
  fragColor = vec4 (col, 1.);
}
