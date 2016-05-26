// Shader downloaded from https://www.shadertoy.com/view/4tjSDc
// written by shadertoy user dr2
//
// Name: Octopod
// Description: For arachnophiles only (use the mouse for a closer look).
// "Octopod" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Gait based on Dave_H's "Spider"; knee positions computed using trig.

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

float PrOBoxDf (vec3 p, vec3 b)
{
  return length (max (abs (p) - b, 0.));
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrEllipsDf (vec3 p, vec3 r, float dFac) {
  return dFac * (length (p / r) - 1.);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

vec3 footPos[8], kneePos[8], hipPos[8], sunDir, qHit;
float tCur, legLenU, legLenD, gDisp, bdyHt, bdyEl;
int idObj;
const int idBdy = 1, idHead = 2, idEye = 3, idAnt = 4, idLegU = 5, idLegD = 6;
bool multi;
const float dstFar = 200.;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  float sd, f;
  if (rd.y > 0.) {
    ro.xz += 2. * tCur;
    sd = max (dot (rd, sunDir), 0.);
    col = vec3 (0.1, 0.2, 0.4) + 0.2 * pow (1. - max (rd.y, 0.), 8.) +
       0.35 * pow (sd, 6.) + 0.65 * min (pow (sd, 256.), 0.3);
    f = Fbm2 (0.05 * (ro.xz + rd.xz * (50. - ro.y) / rd.y));
    col = mix (col, vec3 (1.), clamp (0.1 + 0.8 * f * rd.y, 0., 1.));
  } else {
    sd = - ro.y / rd.y;
    ro += sd * rd;
    ro.z += gDisp;
    sd /= dstFar;
    f = Fbm2 (0.2 * ro.xz);
    vn = normalize (vec3 (f - Fbm2 (0.2 * (ro.xz + vec2 (0.2, 0.))), 0.4,
       f - Fbm2 (0.2 * (ro.xz + vec2 (0., 0.2)))));
    f = 0.5 + 0.5 * smoothstep (0.8, 1.1, f * exp (-2. * sd * sd));
    col = mix (vec3 (0.4, 0.3, 0.2), vec3 (0.3, 0.5, 0.2), f) *
       (1. - 0.1 * Noisefv2 (21. * ro.xz));
    col *= 0.1 + 0.9 * max (dot (vn, sunDir), 0.);
    col = mix (col, vec3 (0.1, 0.2, 0.4) + 0.25, pow (1. + rd.y, 32.));
  }
  return col;
}

float ShpCylDf (vec3 p, vec3 v, float md, float r, float rf)
{
  float len, s;
  len = length (v);
  v = normalize (v);
  s = clamp (dot (p, v), 0., len);
  p -= s * v;
  s = s / len - md;
  return length (p) - r * (1. - rf * s * s);
}

float ObjDf (vec3 p)
{
  vec3 pp, q, v;
  float d, dMin, s, len, hGap, bf;
  if (multi) {
    hGap = 6.;
    bf = PrOBoxDf (p - vec3 (0., 4., 0.), vec3 (3. * hGap, 5., 3. * hGap));
    p.xz -= 2. * hGap * floor ((p.xz + hGap) / (2. * hGap));
  } else bf = -1.;
  dMin = dstFar;
  pp = p - vec3 (0., bdyHt, 0.);
  pp.yz = Rot2D (pp.yz, bdyEl);
  q = pp - vec3 (0., -0.15, 0.2);
  d = max (bf, PrEllipsDf (q, vec3 (0.7, 0.5, 1.3), 0.6));
  if (d < dMin) { dMin = d;  idObj = idBdy;  qHit = q; }
  q = pp - vec3 (0., 0.1, 1.1);
  d = max (bf, PrEllipsDf (q, vec3 (0.2, 0.4, 0.5), 0.2));
  if (d < dMin) { dMin = d;  idObj = idHead;  qHit = q; }
  q = pp;
  q.x = abs (q.x);
  q -= vec3 (0.15, 0.25, 1.5);
  d = max (bf, PrSphDf (q, 0.1));
  if (d < dMin) { dMin = d;  idObj = idEye; }
  q -= vec3 (-0.05, 0.15, -0.3);
  d = max (bf, ShpCylDf (q, vec3 (0.3, 1.1, 0.4), 0., 0.05, 0.7));
  if (d < dMin) { dMin = d;  idObj = idAnt; }
  for (int j = 0; j < 8; j ++) {
    q = p - hipPos[j];
    d = max (bf, 0.6 * ShpCylDf (q, kneePos[j] - hipPos[j], 0., 0.15, 0.4));
    if (d < dMin) { dMin = d;  idObj = idLegU;  qHit = q; }
    q = p - kneePos[j];
    d = max (bf, 0.6 * ShpCylDf (q, footPos[j] - kneePos[j], 0.3, 0.1, 1.3));
    if (d < dMin) { dMin = d;  idObj = idLegD;  qHit = q; }
  }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.0002 || dHit > dstFar) break;
  }

  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.05;
  for (int j = 0; j < 20; j ++) {
    h = 1.5 * ObjDf (ro + rd * d);
    sh = min (sh, 30. * h / d);
    d += h + 0.07;
    if (h < 0.001) break;
  }
  return max (sh, 0.5);
}

vec4 ObjCol (vec3 ro, vec3 vn)
{
  vec4 col;
  if (idObj == idBdy) {
    col = mix (vec4 (0., 0.8, 0., 0.5), vec4 (0.8, 0., 0., 0.5),
       smoothstep (-0.7, 0.3, qHit.z));
  } else if (idObj == idHead) {
    col = vec4 (0.8, 0.8, 0., 0.5);
    if (qHit.z > 0.4) col = mix (vec4 (0.1, 0.03, 0.03, 0.1), col,
       smoothstep (0.02, 0.04, abs (qHit.x)));
  } else if (idObj == idEye) {
    if (vn.z > 0.6) col = vec4 (0., 0., 0., 0.3);
    else col = vec4 (0.6, 0.6, 0., 1.);
  } else if (idObj == idLegU || idObj == idLegD) {
    col = vec4 (0.6, 0.4, 0., 0.3) * (0.6 + 0.4 * cos (8. * length (qHit)));
  } else if (idObj == idAnt) {
    col = vec4 (0.2, 0.4, 0.7, 0.5);
  }
  return col;
}

void ConfigWalker ()
{
  vec3 v;
  float tCyc, tWait, tc, spd, a, az, fz, d, ll;
  for (int j = 0; j < 4; j ++) {
    a = 0.2 * (1. + float (j)) * pi;
    hipPos[j] = 0.5 * vec3 (- sin (a), 0., 1.5 * cos (a));
    hipPos[j + 4] = hipPos[j];  hipPos[j + 4].x *= -1.;
  }
  spd = 1.5;
  tCyc = 19.5;
  tWait = 4.;
  tCur += 4.;
  tc = mod (spd * tCur, tCyc);
  gDisp = spd * tCur - tc + ((tc < tWait) ? 0. :
     (tc - tWait) * tCyc / (tCyc - tWait));
  bdyHt = 1. + 1.2 * SmoothBump (tWait + 1.5, tCyc - 1.5, 1.5, mod (tc, tCyc));
  bdyEl = -10. * (1. + 1.2 * SmoothBump (tWait + 1.5, tCyc - 1.5, 1.5,
     mod (tc + 0.05, tCyc)) - bdyHt);
  legLenU = 2.2;
  legLenD = 3.;
  ll = legLenD * legLenD - legLenU * legLenU;
  for (int j = 0; j < 8; j ++) {
    fz = fract ((gDisp + 0.93 + ((j < 4) ? -1. : 1.) +
       mod (7. - float (j), 4.)) / 3.);
    az = smoothstep (0.7, 1., fz);
    footPos[j] = 5. * hipPos[j];
    footPos[j].x *= 1.7;
    footPos[j].y += 0.7 * sin (pi * clamp (1.4 * az - 0.4, 0., 1.));
    footPos[j].z += ((j < 3) ? 0.5 : 1.) - 3. * (fz - az);
    hipPos[j].yz = Rot2D (hipPos[j].yz, - bdyEl);
    hipPos[j] += vec3 (0., bdyHt - 0.3, 0.2);
    v = footPos[j] - hipPos[j];
    d = length (v);
    a = asin ((hipPos[j].y - footPos[j].y) / d);
    kneePos[j].y = footPos[j].y + legLenD *
       sin (acos ((d * d + ll) / (2. * d *  legLenD)) + a);
    kneePos[j].xz = hipPos[j].xz + legLenU * sin (acos ((d * d - ll) /
       (2. * d *  legLenU)) + 0.5 * pi - a) * normalize (v.xz);
  }
}

vec3 TrackPath (float t)
{
  vec3 p;
  vec2 tr;
  float ti[5], rPath, a, r, tC, tL, tWf, tWb;
  bool rotStep;
  rPath = 22.;
  tC = pi * rPath / 8.;
  tL = 2. * rPath / 5.;
  tWf = 15.;
  tWb = 1.;
  rotStep = false;
  ti[0] = 0.;
  ti[1] = ti[0] + tWf;
  ti[2] = ti[1] + tL;
  ti[3] = ti[2] + tWb;
  ti[4] = ti[3] + tC;
  p.y = 4. - 2. * cos (2. * pi * fract (t / (2. * ti[4])));
  t = mod (t, ti[4]);
  tr = vec2 (0.);
  if (t < ti[1]) {
    tr.y = rPath;
  } else if (t < ti[2]) {
    tr.y = rPath - 2. * rPath * (t - ti[1]) / (ti[2] - ti[1]);
  } else if (t < ti[3]) {
    tr.y = - rPath;
  } else {
    rotStep = true;
    a = 1.5 - (t - ti[3]) / (ti[4] - ti[3]);
    r = rPath;
  }
  if (rotStep) {
    a *= pi;
    p.xz = r * vec2 (cos (a), sin (a));
  } else {
    p.xz = tr;
  }
  p.x -= 5.;
  return p;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 col4;
  vec3 col, vn;
  float dstHit, sh;
  int idObjT;
  idObj = -1;
  sh = 1.;
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    col4 = ObjCol (ro, vn);
    sh = ObjSShadow (ro, sunDir);
  } else if (rd.y < 0.) {
    sh = ObjSShadow (ro - rd * ro.y / rd.y, sunDir);
  }
  if (dstHit < dstFar) {
    col = sh * col4.rgb * ((0.2 +
       0.2 * max (dot (vec3 (- sunDir.x, 0., - sunDir.z), vn), 0.) +
       0.8 * max (dot (vn, sunDir), 0.)) +
       col4.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 32.));
  } else col = sh * BgCol (ro, rd);
  return pow (clamp (col, 0., 1.), vec3 (0.8));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec2 canvas, uv, vf, cf, sf;
  vec3 ro, rd, vd, u;
  float f;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  multi = (mPtr.z <= 0.);
  ConfigWalker ();
  if (multi) {
    ro = TrackPath (0.8 * tCur);
    vd = normalize (vec3 (0., 2., 10.) - ro);
    u = - vd.y * vd;
    f = 1. / sqrt (1. - vd.y * vd.y);
    vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
    rd = vuMat * normalize (vec3 (uv, 2.));
    sunDir = normalize (vec3 (-1., 1.5, 1.));
  } else {
    vf = vec2 (clamp (0.7 - 1.5 * mPtr.y, 0.01, 1.4), pi + 6. * mPtr.x);
    cf = cos (vf);
    sf = sin (vf);
    vuMat = mat3 (1., 0., 0., 0., cf.x, - sf.x, 0., sf.x, cf.x) *
       mat3 (cf.y, 0., sf.y, 0., 1., 0., - sf.y, 0., cf.y);
    rd = normalize (vec3 (uv, 4.5)) * vuMat;
    ro = vec3 (0., 0., -20.) * vuMat;
    ro.y += 1.;
    sunDir = normalize (vec3 (-0.3, 1.5, 1.));
  }
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
