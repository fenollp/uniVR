// Shader downloaded from https://www.shadertoy.com/view/MljSzd
// written by shadertoy user dr2
//
// Name: Capri
// Description: The famous Faraglione di Mezzo (the spherical cow version x2) - mouse enabled.
// "Capri" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

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
  for (int i = 0; i < 6; i ++) {
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
  const vec3 e = vec3 (0.1, 0., 0.);
  vec3 g;
  float s;
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
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

float PrFlatCylDf (vec3 p, float rhi, float rlo, float h)
{
  return max (length (p.xy - vec2 (rhi * clamp (p.x / rhi, -1., 1.), 0.)) - rlo,
     abs (p.z) - h);
}

vec3 qHit, sunDir, cloudDisp, waterDisp;
float tCur;
int idObj;
const float dstFar = 100.;

vec3 SkyBg (vec3 rd)
{
  return mix (vec3 (0.2, 0.2, 0.9), vec3 (0.45, 0.45, 0.6),
     1. - max (rd.y, 0.));
}

vec3 SkyHrzCol (vec3 ro, vec3 rd)
{
  vec3 p, q, cSun, clCol, col;
  float fCloud, cloudLo, cloudRngI, atFac, colSum, attSum, s,
     att, a, dDotS, ds;
  const int nLay = 30;
  cloudLo = 300.;  cloudRngI = 1./100.;  atFac = 0.04;
  fCloud = 0.5;
  if (rd.y < 0.015 * Fbm1 (16. * rd.x)- 0.0075) {
    col = vec3 (0.2, 0.3, 0.2) *
       (0.7 + 0.3 * Noisefv2 (1000. * vec2 (5. * atan (rd.x, rd.z), rd.y)));
  } else if (rd.y > 0.) {
    fCloud = clamp (fCloud, 0., 1.);
    dDotS = max (dot (rd, sunDir), 0.);
    ro += cloudDisp;
    p = ro;
    p.xz += (cloudLo - p.y) * rd.xz / rd.y;
    p.y = cloudLo;
    ds = 1. / (cloudRngI * rd.y * (2. - rd.y) * float (nLay));
    colSum = 0.;  attSum = 0.;
    s = 0.;  att = 0.;
    for (int j = 0; j < nLay; j ++) {
      q = p + rd * s;
      att += atFac * max (fCloud - 0.5 * Fbm3 (0.0035 * q), 0.);
      a = (1. - attSum) * att;
      colSum += a * (q.y - cloudLo) * cloudRngI;
      attSum += a;  s += ds;
      if (attSum >= 1.) break;
    }
    colSum += 0.5 * min ((1. - attSum) * pow (dDotS, 3.), 1.);
    clCol = vec3 (1.) * 2.8 * (colSum + 0.05);
    cSun = vec3 (1.) * clamp ((min (pow (dDotS, 1500.) * 2., 1.) +
       min (pow (dDotS, 10.) * 0.75, 1.)), 0., 1.);
    col = clamp (mix (SkyBg (rd) + cSun, clCol, attSum), 0., 1.);
    col = mix (col, SkyBg (rd), pow (1. - rd.y, 32.));
  } else col = mix (vec3 (0.07, 0.15, 0.2), SkyBg (- rd), pow (1. + rd.y, 32.));
  return col;
}

float WaveHt (vec3 p)
{
  const mat2 qRot = mat2 (1.6, -1.2, 1.2, 1.6);
  vec4 t4, ta4, v4;
  vec2 q2, t2, v2;
  float wFreq, wAmp, pRough, ht;
  wFreq = 1.;  wAmp = 0.07;  pRough = 10.;
  q2 = p.xz + waterDisp.xz;
  ht = 0.;
  for (int j = 0; j < 5; j ++) {
    t2 = 0.6 * tCur * vec2 (1., -1.);
    t4 = vec4 (q2 + t2.xx, q2 + t2.yy) * wFreq;
    t2 = vec2 (Noisefv2 (t4.xy), Noisefv2 (t4.zw));
    t4 += 2. * vec4 (t2.xx, t2.yy) - 1.;
    ta4 = abs (sin (t4));
    v4 = (1. - ta4) * (ta4 + abs (cos (t4)));
    v2 = pow (1. - sqrt (v4.xz * v4.yw), vec2 (pRough));
    ht += (v2.x + v2.y) * wAmp;
    q2 *= qRot;  wFreq *= 2.;  wAmp *= 0.25;
    pRough = 0.8 * pRough + 0.2;
  }
  return ht;
}

float WaveRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, h, s, sLo, sHi;
  dHit = dstFar;
  if (rd.y < 0.) {
    s = 0.;
    sLo = 0.;
    for (int j = 0; j < 100; j ++) {
      p = ro + s * rd;
      h = p.y - WaveHt (p);
      if (h < 0.) break;
      sLo = s;
      s += max (0.3, h) + 0.005 * s;
      if (s > dstFar) break;
    }
    if (h < 0.) {
      sHi = s;
      for (int j = 0; j < 5; j ++) {
        s = 0.5 * (sLo + sHi);
        p = ro + s * rd;
        h = step (0., p.y - WaveHt (p));
        sLo += h * (s - sLo);
        sHi += (1. - h) * (s - sHi);
      }
      dHit = sHi;
    }
  }
  return dHit;
}

vec3 WaveNf (vec3 p, float d)
{
  vec2 e = vec2 (max (0.01, 0.005 * d * d), 0.);
  float ht = WaveHt (p);
  return normalize (vec3 (ht - WaveHt (p + e.xyy), e.x, ht - WaveHt (p + e.yyx)));
}

float ObjDf (vec3 p)
{
  vec3 q;
  float d, dMin, a, r, rb, h, dr;
  dMin = dstFar;
  p.z = abs (p.z) - 6.;
  h = 2.5 + 0.02 * sin (23. * q.x);
  q = p;
  q.y -= 0.25;
  rb = 1.8;
  r = max (0., rb - 0.5 * q.y / h - 0.005 * sin (61. * q.y / h));
  a = atan (q.z, q.x) + 0.03 * sin (16.2 * q.y / h);
  dr = 0.04 * max (r - rb + 0.6, 0.) * sin (30. * a);
  d = PrRCylDf (q.xzy, r + dr, 0.5, h);
  a = atan (q.y, q.x) + 0.03 * sin (22.2 * q.z / rb);
  dr = 0.006 * sin (33. * a) + 0.004 * sin (43. * a + 1.);
  d = max (d, - PrFlatCylDf (q.yxz, 0.4 + dr, 0.5 + dr, h));
  d = max (d, - 0.5 - q.y);
  if (d < dMin) { dMin = d;  idObj = 1;  qHit = q; }
  return 0.9 * dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float d;
  float dHit = 0.;
  for (int j = 0; j < 100; j ++) {
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
  float sh = 1.;
  float d = 0.05;
  for (int i = 0; i < 20; i ++) {
    float h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.15;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 TrackPath (float t)
{
  vec3 p;
  vec2 trkBox, rp;
  float ti[9], tTurn, rdTurn, a, dt, rSeg;
  trkBox = vec2 (1.7, 14.);
  rdTurn = 0.9999 * min (trkBox.x, trkBox.y);
  tTurn = 0.5 * pi * rdTurn * 1.5;
  ti[0] = 0.;
  ti[1] = ti[0] + trkBox.y - rdTurn;
  ti[2] = ti[1] + tTurn;
  ti[3] = ti[2] + trkBox.x - rdTurn;
  ti[4] = ti[3] + tTurn;
  ti[5] = ti[4] + trkBox.y - rdTurn;
  ti[6] = ti[5] + tTurn;
  ti[7] = ti[6] + trkBox.x - rdTurn;
  ti[8] = ti[7] + tTurn;
  t = mod (0.5 * t, ti[8]);
  rSeg = -1.;
  rp = vec2 (1.) - rdTurn / trkBox;
  p.xz = trkBox;
  p.y = 0.;
  if (t < ti[4]) {
    if (t < ti[1]) {
      dt = (t - ti[0]) / (ti[1] - ti[0]);
      p.xz *= vec2 (1., rp.y * (2. * dt - 1.));
    } else if (t < ti[2]) {
      dt = (t - ti[1]) / (ti[2] - ti[1]);
      rSeg = 0.;
      p.xz *= rp;
    } else if (t < ti[3]) {
      dt = (t - ti[2]) / (ti[3] - ti[2]);
      p.xz *= vec2 (rp.x * (1. - 2. * dt), 1.);
    } else {
      dt = (t - ti[3]) / (ti[4] - ti[3]);
      rSeg = 1.;
      p.xz *= rp * vec2 (-1., 1.);
    }
  } else {
    if (t < ti[5]) {
      dt = (t - ti[4]) / (ti[5] - ti[4]);
      p.xz *= vec2 (- 1., rp.y * (1. - 2. * dt));
    } else if (t < ti[6]) {
      dt = (t - ti[5]) / (ti[6] - ti[5]);
      rSeg = 2.;
      p.xz *= - rp;
    } else if (t < ti[7]) {
      dt = (t - ti[6]) / (ti[7] - ti[6]);
      p.xz *= vec2 (rp.x * (2. * dt - 1.), - 1.);
    } else {
      dt = (t - ti[7]) / (ti[8] - ti[7]);
      rSeg = 3.;
      p.xz *= rp * vec2 (1., -1.);
    }
  }
  if (rSeg >= 0.) {
    a = 0.5 * pi * (rSeg + dt);
    p += rdTurn * vec3 (cos (a), 0., sin (a));
  }
  p.x -= trkBox.x;
  return p;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 objCol, col, rdd, vn, vnw;
  float dstHit, dstWat, sh;
  int idObjT;
  bool waterRefl;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  dstWat = WaveRay (ro, rd);
  waterRefl = (dstWat < min (dstFar, dstHit));
  if (waterRefl) {
    ro += rd * dstWat;
    vnw = WaveNf (ro, dstWat);
    rdd = rd;
    rd = reflect (rd, vnw);
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    if (idObj < 0) dstHit = dstFar;
  }
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == 1) {
      vn = VaryNf (21.1 * qHit, vn, 5.);
      objCol = mix (vec3 (0.45, 0.4, 0.4), vec3 (0.6),
         clamp (Fbm2 (vec2 (50. * (atan (qHit.z, qHit.x) / pi + 1.),
	 21. * qHit.y)) - 0.6, 0., 1.));
      objCol *= mix (vec3 (0.5, 0.6, 0.5), vec3 (1.),
         smoothstep (-0.2, -0.15, qHit.y));
    }
    sh = 0.5 + 0.5 * ObjSShadow (ro, sunDir);
    col = objCol * (0.2 +
       0.2 * max (dot (vn, sunDir * vec3 (-1., 1., -1.)), 0.) +
       sh * max (dot (vn, sunDir), 0.)) +
       0.4 * sh * pow (max (0., dot (sunDir, reflect (rd, vn))), 32.);
  } else col = SkyHrzCol (ro, rd);
  if (waterRefl) {
    col = mix (vec3 (0.07, 0.15, 0.2), col,
       0.8 * pow (1. - abs (dot (rdd, vnw)), 4.));
    col = mix (col, vec3 (0.9),
       pow (clamp (WaveHt (ro) + 0.5 * Fbm3 (4. * ro), 0., 1.), 8.));
  }
  return clamp (col, 0., 1.);
}

vec3 GlareCol (vec3 rd, vec3 sd, vec2 uv)
{
  vec3 col;
  vec2 sa;
  const vec3 e = vec3 (1., 0., -1.);
  const vec2 hax = vec2 (0.866, 0.5);
  uv *= 2.;
  if (sd.z > 0.) {
    sa = uv + 0.3 * sd.xy;
    col = 0.2 * pow (sd.z, 8.) *
       (1.5 * e.xyy * max (dot (normalize (rd + vec3 (0., 0.3, 0.)), sunDir), 0.) +
       e.xxy * (1. - smoothstep (0.11, 0.12, max (abs (sa.y),
       max (abs (dot (sa, hax)), abs (dot (sa, hax * e.xz)))))) +
       e.xyx * SmoothBump (0.32, 0.4, 0.04, length (uv - 0.7 * sd.xy)) +
       0.8 * e.yxx * SmoothBump (0.72, 0.8, 0.04, length (uv + sd.xy)));
  } else col = vec3 (0.);
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd, ca, sa, vd, u;
  vec2 uv;
  float el, az, rl, f;
  uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / iResolution.xy - 0.5;
  sunDir = normalize (vec3 (-0.5, 0.5, -1.));
  cloudDisp = 10. * tCur * vec3 (1., 0., -1.);
  waterDisp = 0.1 * tCur * vec3 (-1., 0., 1.);
  ro = TrackPath (tCur);
  vd = normalize (TrackPath (tCur + 0.2) - ro);
  ro.y = 0.6;
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (- vd.z, 0., vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  az = 0.15 * sin (0.22 * tCur + 0.2) + 0.1 * sin (0.53 * tCur);
  el = -0.05 * pi + 0.05 * (1. + sin (0.5 * tCur + 0.3)) +
     0.034 * (1. + sin (0.8 * tCur));
  if (mPtr.z > 0.) {
    az = clamp (az - 1.5 * pi * mPtr.x, -0.5 * pi, 0.5 * pi);
    el = clamp (el - 0.3 * pi * mPtr.y, -0.2 * pi, 0.4 * pi);
  }
  rl = 0.1 * sin (0.5 * tCur) + 0.06 * sin (0.8 * tCur + 0.3);
  ca = cos (vec3 (el, az, rl));
  sa = sin (vec3 (el, az, rl));
  vuMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) * vuMat;
  rd = normalize (vec3 (uv, 2.5)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd) + GlareCol (rd, vuMat * sunDir, uv), 1.);
}
