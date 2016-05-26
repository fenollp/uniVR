// Shader downloaded from https://www.shadertoy.com/view/MsdSRj
// written by shadertoy user dr2
//
// Name: Boats with Drone
// Description: A combination of some earlier subjects; use the mouse to look around and  control the drone.
// "Boats with Drone" by dr2 - 2016
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

vec2 Noisev2v4 (vec4 p)
{
  vec4 i, f, t1, t2;
  i = floor (p);
  f = fract (p);
  f = f * f * (3. - 2. * f);
  t1 = Hashv4f (dot (i.xy, cHashA3.xy));
  t2 = Hashv4f (dot (i.zw, cHashA3.xy));
  return vec2 (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
               mix (mix (t2.x, t2.y, f.z), mix (t2.z, t2.w, f.z), f.w));
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
  const vec3 e = vec3 (0.1, 0., 0.);
  vec3 g;
  float s;
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
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
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
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

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrCylAnDf (vec3 p, float r, float w, float h)
{
  return max (abs (length (p.xy) - r) - w, abs (p.z) - h);
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

float PrFlatCyl2Df (vec2 p, float rhi, float rlo)
{
  return length (p - vec2 (rhi * clamp (p.x / rhi, -1., 1.), 0.)) - rlo;
}

const float txRow = 32.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

mat3 boatMat[3], droneMat;
vec3 boatPos[3], dronePos, vuPos, qHit, sunDir, waterDisp;
vec2 aTilt;
float boatAng[3], tCur, dstFar;
int idObj, idObjGrp;
bool droneVu;

vec3 SkyHrzCol (vec3 rd)
{
  vec3 col;
  float a, sd;
  a = atan (length (rd.xz), rd.y);
  if (a > 0.5 * pi + 0.012 * (Fbm1 (20. * abs (0.25 * pi +
     atan (rd.z, rd.x))) - 1.9375)) {
    col = vec3 (0.22, 0.3, 0.33) *
       (0.7 + 0.3 * Noisefv2 (1000. * vec2 (5. * atan (rd.z, rd.x), rd.y)));
  } else {
    sd = max (dot (rd, sunDir), 0.);
    rd.xz *= tan (0.9 * a);
    rd.y = 1.;
    rd = normalize (rd);
    col = mix (vec3 (0.5, 0.5, 0.8), vec3 (1.),
       clamp (0.8 * Fbm2 (vec2 (0.05 * tCur + 2. * rd.xz / rd.y)) - 0.5, 0., 1.));
    col += 0.1 * pow (sd, 16.) + 0.2 * pow (sd, 256.);
  }
  return col;
}

float WaveHt (vec3 p)
{
  const mat2 qRot = mat2 (1.6, -1.2, 1.2, 1.6);
  vec4 t4, t4o, ta4, v4;
  vec2 q2, t2, v2;
  float wFreq, wAmp, pRough, ht;
  wFreq = 0.2;  wAmp = 0.3;
  t4o.xz = tCur * vec2 (1., -1.);
  q2 = p.xz + waterDisp.xz;
  ht = 0.;
  for (int j = 0; j < 3; j ++) {
    t4 = (t4o.xxzz + vec4 (q2, q2)) * wFreq;
    t2 = Noisev2v4 (t4);
    t4 += 2. * vec4 (t2.xx, t2.yy) - 1.;
    ta4 = abs (sin (t4));
    v4 = (1. - ta4) * (ta4 + sqrt (1. - ta4 * ta4));
    v2 = pow (1. - pow (v4.xz * v4.yw, vec2 (0.65)), vec2 (8.));
    ht += (v2.x + v2.y) * wAmp;
    q2 *= qRot;  wFreq *= 2.;  wAmp *= 0.2;
  }
  return ht;
}

float WaveRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, h, s, sLo, sHi;
  s = 0.;
  sLo = 0.;
  dHit = dstFar;
  for (int j = 0; j < 50; j ++) {
    p = ro + s * rd;
    h = p.y - WaveHt (p);
    if (h < 0.) break;
    sLo = s;
    s += max (0.5, 1.3 * h) + 0.01 * s;
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
  return dHit;
}

vec3 WaveNf (vec3 p, float d)
{
  vec2 e = vec2 (max (0.1, 1e-4 * d * d), 0.);
  float h = WaveHt (p);
  return normalize (vec3 (h - WaveHt (p + e.xyy), e.x, h - WaveHt (p + e.yyx)));
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
  q.yz -= vec2 (0.8, -1.);
  d = PrCylDf (q.xzy, 0.04, 0.3);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 3; }
  q = p;
  q.x = abs (q.x) - 0.3;
  q.yz -= vec2 (-1.1, 1.6);
  d = PrRoundBoxDf (q, vec3 (0.02, 0.3, 0.1), 0.03);
  q.y -= -0.4;
  d = min (d, PrCapsDf (q, 0.1, 0.25));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + 4; }
  return dMin;
}

float DroneDf (vec3 p, float dMin)
{
  vec3 q, qq;
  float d;
  const float dSzFac = 2.;
  dMin *= dSzFac;
  qq = dSzFac * (p - dronePos);
  qq.yz = Rot2D (qq.yz, - aTilt.y);
  qq.yx = Rot2D (qq.yx, - aTilt.x);
  q = qq;  q.y -= 0.05;
  d = PrRCylDf (q.xzy, 0.2, 0.03, 0.07);
  if (d < dMin) { dMin = d;  idObj = 1; }
  q.y -= 0.07;
  d = PrRoundBoxDf (q, vec3 (0.06, 0.02, 0.12), 0.04);
  if (d < dMin) { dMin = d;  idObj = 2; }
  q = qq;  q.y -= -0.05;
  d = PrSphDf (q, 0.17);
  if (d < dMin) { dMin = d;  idObj = 3; }
  q = qq;  q.xz = abs (q.xz) - 0.7;
  d = min (PrCylAnDf (q.xzy, 0.5, 0.05, 0.05), PrCylDf (q.xzy, 0.1, 0.03));
  q -= vec3 (-0.4, -0.15, -0.4);
  d = min (d, PrRCylDf (q.xzy, 0.05, 0.03, 0.2));
  q -= vec3 (-0.3, 0.2, -0.3);
  q.xz = Rot2D (q.xz, 0.25 * pi);
  d = min (d, min (PrRCylDf (q, 0.05, 0.02, 1.), PrRCylDf (q.zyx, 0.05, 0.02, 1.)));
  if (d < dMin) { dMin = d;  idObj = 1; }
  return dMin / dSzFac;
}

float RockDf (vec3 p, float dMin)
{
  vec3 q;
  float d, a, r, rb, h;
  const float rSzFac = 0.3;
  dMin *= rSzFac;
  q = p * rSzFac;
  q.y -= 0.25;
  rb = 1.8;
  h = 2.;
  d = PrCylDf (q.xzy, rb, h + 0.02);
  if (d < dMin) {
    h += 0.02 * cos (23. * q.x * q.z);
    r = max (0., rb - 0.5 * q.y / h - 0.005 * sin (61. * q.y / h));
    a = atan (q.z, q.x) + 0.03 * sin (16.2 * q.y / h);
    d = PrRCylDf (q.xzy, r + 0.04 * max (r - rb + 0.6, 0.) * sin (30. * a),
       0.5, h);
    q *= 1. + 0.02 * sin (43. * atan (q.y, length (q.xz)) +
       sin (22.2 * length (q.xz) / rb));
    d = max (d, - SmoothMin (PrFlatCyl2Df (q.yx, 0.4, 0.5),
       PrFlatCyl2Df (q.yz, 0.4, 0.5), 0.1));
    if (d < dMin) { dMin = d;  idObj = 11;  qHit = q; }
    dMin *= 0.9;
  }
  return dMin / rSzFac;;
}

float ObjDf (vec3 p)
{
  vec3 q;
  float d, dMin, dLim;
  const float bSzFac = 1.5;
  dMin = dstFar;
  dLim = 0.5 * bSzFac;
  dMin *= bSzFac;
  for (int k = 0; k < 3; k ++) {
    q = p - boatPos[k];
    idObjGrp = (k + 1) * 256;
    d = PrCylDf (q.xzy, 2., 2.);
    dMin = (d < dLim) ? BoatDf (bSzFac * boatMat[k] * q, dMin) : min (dMin, d);
  }
  dMin /= bSzFac;
  if (! droneVu) dMin = DroneDf (p, dMin);
  dMin = RockDf (p, dMin);
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
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.05;
  for (int j = 0; j < 25; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 20. * h / d));
    d += min (0.3, 3. * h);
    if (h < 0.001) break;
  }
  return sh;
}

vec4 BoatCol (vec3 n)
{
  vec4 objCol;
  vec3 nn;
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
    } else if (qHit.x * nn.x > 0. && nn.y < 0. && qHit.z < 1.99 &&
       abs (qHit.y - 0.1) < 0.095) objCol = vec4 (1., 1., 0.2, 0.3);
    else {
      if (qHit.y > -0.3) objCol.rgb = (ig == 1) ? vec3 (0.3, 0.9, 0.3) :
         ((ig == 2) ? vec3 (0.9, 0.3, 0.3) : vec3 (0.3, 0.3, 0.9));
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
  else if (id == 4) objCol = vec4 (0.5, 0.5, 0.2, 0.1);
  return objCol;
}

vec4 DroneCol ()
{
  vec4 objCol;
  if (idObj == 1) objCol = vec4 (1., 1., 0.5, 1.);
  else if (idObj == 2) objCol = mix (vec4 (0.3, 0.3, 1., -2.),
     vec4 (1., 0., 0., 0.2), step (0., sin (10. * tCur)));
  else if (idObj == 3) objCol = vec4 (0.1, 0.1, 0.1, 1.);
  return objCol;
}

float WakeFac (vec3 row)
{
  vec2 tw[3], twa;
  float twLen[3], wkFac, ba;
  for (int k = 0; k < 3; k ++) {
    tw[k] = row.xz - (boatPos[k].xz - Rot2D (vec2 (0., 2.5), boatAng[k]));
    twLen[k] = length (tw[k]);
  }
  if (twLen[0] < min (twLen[1], twLen[2])) {
    twa = tw[0];
    ba = boatAng[0];
  } else if (twLen[1] < twLen[2]) {
    twa = tw[1];
    ba = boatAng[1];
  } else {
    twa = tw[2];
    ba = boatAng[2];
  }
  twa = Rot2D (twa, - ba);
  wkFac = 0.;
  if (length (twa * vec2 (1., 0.5)) < 1.) wkFac =
     clamp (1. - 1.5 * abs (twa.x), 0., 1.) * clamp (1. + 0.5 * twa.y, 0., 1.);
  return wkFac;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, vn, vnw, rdd, row, rdw;
  float dstObj, dstWat, wkFac, reflFac, sh;
  int idObjT;
  bool waterRefl;
  dstObj = ObjRay (ro, rd);
  dstWat = WaveRay (ro, rd);
  waterRefl = (dstWat < min (dstFar, dstObj));
  if (waterRefl) {
    ro += rd * dstWat;
    row = ro;
    rdw = rd;
    wkFac = WakeFac (row);
    vnw = WaveNf (ro, dstWat);
    if (wkFac > 0.) vnw = VaryNf (10. * row, vnw, 5. * wkFac);
    rd = reflect (rd, vnw);
    ro += 0.1 * rd;
    dstObj = ObjRay (ro, rd);
  }
  reflFac = 0.;
  if (dstObj < dstWat) {
    ro += rd * dstObj;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj >= 1 && idObj <= 3) objCol = DroneCol ();
    else if (idObj == 11) {
      vn = VaryNf (21.1 * qHit, vn, 5.);
      objCol.rgb = mix (vec3 (0.45, 0.4, 0.4), vec3 (0.3, 0.3, 0.35),
         clamp (Fbm2 (vec2 (50. * (atan (qHit.z, qHit.x) / pi + 1.),
         21. * qHit.y)) - 0.6, 0., 1.));
      objCol.rgb *= mix (vec3 (0.5, 0.6, 0.5), vec3 (1.),
         smoothstep (-0.2, -0.15, qHit.y));
      objCol.a = 0.4;
    } else if (idObj >= 256) {
      objCol = BoatCol (vn);
      if (objCol.a == -1.) {
        objCol.a = 1.;
        reflFac = 0.3;
        rdd = reflect (rd, vn);
      }
    }
    if (objCol.a != -2.) {
      sh = 0.5 + 0.5 * ObjSShadow (ro, sunDir);
      col = objCol.rgb * (0.2 +
         0.2 * max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.) +
         0.8 * sh * max (dot (vn, sunDir), 0.) +
         objCol.a * sh * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.));
    } else col = objCol.rgb;
  } else col = SkyHrzCol (rd);
  if (reflFac > 0.) col = mix (col, 0.7 * SkyHrzCol (rdd), reflFac);
  if (waterRefl) {
    col = mix (vec3 (0.12, 0.24, 0.28), col,
       0.5 * pow (1. - abs (dot (rdw, vnw)), 5.));
    col = mix (col, vec3 (0.9),
       pow (clamp (1.1 * WaveHt (row) + 0.1 * Fbm3 (16. * row), 0., 1.), 8.) *
       (1. - smoothstep (-0.06, -0.04, rdw.y)));
    if (wkFac > 0.) col = mix (col, vec3 (0.9),
       wkFac * clamp (0.1 + 0.5 * Fbm3 (4.1 * row), 0., 1.));
  }
  if (waterRefl) {
    col = mix (col, SkyHrzCol (rdw), smoothstep (0.8, 1., dstWat / dstFar));
  }
  return pow (clamp (col, 0., 1.), vec3 (0.8));
}

void BoatPM (out mat3 bMat, inout vec3 bPos, float bAng)
{
  vec3 bd;
  float h[5], bAz, c, s;
  bAz = 0.5 * pi - bAng;
  bd = vec3 (0., 0., 1.);
  bd.xz = Rot2D (bd.xz, bAz);
  h[0] = WaveHt (bPos);
  h[1] = WaveHt (bPos + 0.5 * bd);
  h[2] = WaveHt (bPos - 0.5 * bd);
  bd.xz = Rot2D (bd.xz, -0.5 * pi);
  h[3] = WaveHt (bPos + 1.3 * bd);
  h[4] = WaveHt (bPos - 1.3 * bd);
  bPos.y = 0.13 + (2. * h[0] + h[1] + h[2] + h[3] + h[4]) / 6.;
  bMat[2] = normalize (vec3 (2., h[2] - h[1], 0.));
  bMat[0] = normalize (vec3 (0., max (0.6 + h[3] - h[4], 0.), 4.));
  bMat[1] = cross (bMat[0], bMat[2]);
  c = cos (bAz);
  s = sin (bAz);
  bMat *= mat3 (c, 0., s, 0., 1., 0., - s, 0., c);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 stDat;
  vec3 ro, rd, vd, col;
  vec2 canvas, uv, us, uc, ori, ca, sa;
  float zmFac, asp, aLim, mRad, el, az, elV, azV, vuMode, f;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  dstFar = 70.;
  aTilt = Loadv4 (0).xy;
  stDat = Loadv4 (2);
  vuPos.xz = stDat.xy;
  vuPos.y = 3.;
  el = stDat.z;
  az = stDat.w;
  stDat = Loadv4 (3);
  dronePos = stDat.xyz;
  vuMode = stDat.w;
  for (int k = 0; k < 3; k ++) {
    stDat = Loadv4 (5 + k);
    boatPos[k].xz = stDat.xy;
    boatPos[k].y = 0.;
    boatAng[k] = stDat.z;
    BoatPM (boatMat[k], boatPos[k], boatAng[k]);
  }
  asp = canvas.x / canvas.y;
  mRad = 0.45;
  uc = uv - vec2 (0.73, 0.53) * vec2 (asp, 1.);
  droneVu = (length (uc) < mRad);
  if (droneVu) {
    ro = dronePos;
    zmFac = 0.7;
    uv = - uc / mRad;
    rd = normalize (vec3 ((1./0.9) * sin (0.9 * uv), zmFac));
    rd.yz = Rot2D (rd.yz, 0.5 * pi + aTilt.y);
    rd.yx = Rot2D (rd.yx, aTilt.x);
  } else {
    if (vuMode == 0.) vd = 0.5 * (boatPos[0] + boatPos[1]);
    else if (vuMode == 1.) vd = 0.5 * (boatPos[2] + boatPos[1]);
    else if (vuMode == 2.) vd = dronePos;
    ro = vuPos;
    if (vuMode == 2.) {
      ro.y = 9.;
      zmFac = 1.5 + clamp (0.1 * length (vd - ro) - 1., 0., 8.);
    } else zmFac = 2.5;
    vd = normalize (vd - ro);
    azV = 0.5 * pi - atan (vd.z, - vd.x);
    elV = - asin (vd.y);
    if (vuMode == 2.) {
      az = azV;
      el = elV;
    } else {
      az += azV;
      el += -0.03 * pi + elV;
      el = clamp (el, -0.15 * pi, 0.15 * pi);
    }
    ori = vec2 (el, az);
    ca = cos (ori);
    sa = sin (ori);
    vuMat = mat3 (ca.y, 0., sa.y, 0., 1., 0., - sa.y, 0., ca.y) *
            mat3 (1., 0., 0., 0., ca.x, sa.x, 0., - sa.x, ca.x);
    rd = vuMat * normalize (vec3 (uv, zmFac));
  }
  sunDir = normalize (vec3 (-0.5, 0.5, -1.));
  waterDisp = 0.1 * tCur * vec3 (-1., 0., 1.);
  col = ShowScene (ro, rd);
  us = 0.5 * uv - vec2 (0.4, -0.32) * vec2 (asp, 1.);
  f = (length (us) - 0.135) * canvas.y;
  if (abs (f) < 1.5 || f < 0. && min (abs (us.x), abs (us.y)) * canvas.y < 1.)
     col = vec3 (0., 0.7, 0.);
  if (f < 0. && abs (length (us + (1./5.5) * aTilt) - 0.02) * canvas.y < 1.)
     col = vec3 (1., 1., 0.);
  if (droneVu && (length (uc) - mRad) * canvas.y > -3.) col = vec3 (0., 0., 1.);
  fragColor = vec4 (col, 1.);
}
