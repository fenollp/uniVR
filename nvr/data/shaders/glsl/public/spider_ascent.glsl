// Shader downloaded from https://www.shadertoy.com/view/4sd3WX
// written by shadertoy user dr2
//
// Name: Spider Ascent
// Description: Who knows where they come from, or where they go?
// "Spider Ascent" by dr2 - 2016
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

float PrBox2Df (vec2 p, vec2 b)
{
  vec2 d = abs (p) - b;
  return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrEllipsDf (vec3 p, vec3 r, float dFac)
{
  return dFac * (length (p / r) - 1.);
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCylAnDf (vec3 p, float r, float w, float h)
{
  return max (abs (length (p.xy) - r) - w, abs (p.z) - h);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

float BrickPat (vec2 p)
{
  vec2 q, iq;
  q = p * vec2 (1., 4.);
  iq = floor (q);
  if (2. * floor (iq.y / 2.) != iq.y) q.x += 0.5;
  q = smoothstep (0.02, 0.05, abs (fract (q + 0.5) - 0.5));
  return (0.7 + 0.3 * q.x * q.y);
}

vec3 footPos[8], kneePos[8], hipPos[8], fBallPos, noiseDisp, qHit, sunDir, wkrPos;
float legLenU, legLenD, bdyHt, trRad, trGap, trWid, trThk, wkrAz, wkrEl, wkrSpd,
   trCoil, fBallRad, tCur, dstFar;
int idObj;
const int idPath = 1, idCol = 2, idWall = 3, idBdy = 11, idHead = 12, idEye = 13,
   idAnt = 14, idLegU = 15, idLegD = 16;

float FrAbsf (float p)
{
  return abs (fract (p) - 0.5);
}

vec3 FrAbsv3 (vec3 p)
{
  return abs (fract (p) - 0.5);
}

float TriNoise3d (vec3 p)
{
  const mat3 mr = mat3 (0., 0.8, 0.6, -0.8, 0.36, -0.48, -0.6, -0.48, 0.64);
  vec3 q;
  float a, f;
  a = 1.;
  f = 0.;
  p *= 0.005;
  q = p;
  for (int j = 0; j < 5; j ++) {
    p += FrAbsv3 (q + FrAbsv3 (q).yzx) + noiseDisp;
    p *= 1.2;
    f += a * (FrAbsf (p.x + FrAbsf (p.y + FrAbsf (p.z))));
    q *= 2. * mr;
    q += 0.21;
    a *= 0.9;
  }
  return 0.1 * clamp (2. * f - 1.3, 0., 1.);
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

vec3 GrndCol (vec3 ro, vec3 rd)
{
  vec3 vn, col;
  vec2 w;
  float f;
  vec2 e = vec2 (0.01, 0.);
  w = 0.1 * ro.xz;
  f = Fbm2 (w);
  vn = normalize (vec3 (f - Fbm2 (w + e.xy), 0.07, f - Fbm2 (w + e.yx)));
  col = mix (vec3 (0.4, 0.8, 0.2), vec3 (0.3, 0.25, 0.),
    1. + (f - 1.) * (1. - pow (1. + rd.y, 3.)));
  col *= 0.1 + 0.9 * max (dot (vn, sunDir), 0.);
  col = mix (col, vec3 (0.1, 0.2, 0.4) + 0.25, pow (1. + rd.y, 32.));
  return col;
}

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col;
  float sd, f;
  if (rd.y > 0.) {
    ro.xz += 2. * tCur;
    sd = max (dot (rd, sunDir), 0.);
    col = vec3 (0.1, 0.2, 0.4) + 0.2 * pow (1. - max (rd.y, 0.), 8.) +
       0.35 * pow (sd, 6.) + 0.65 * min (pow (sd, 256.), 0.3);
    f = Fbm2 (0.02 * (ro.xz + rd.xz * (300. - ro.y) / rd.y));
    col = mix (col, vec3 (1.), clamp (0.1 + 0.8 * f * rd.y, 0., 1.));
  } else {
    sd = - ro.y / rd.y;
    ro += sd * rd;
    col = GrndCol (ro, rd);
  }
  return col;
}

float FBallHit (vec3 ro, vec3 rd, vec3 p, float s)
{
  vec3 v;
  float h, b, d;
  v = ro - p;
  b = dot (rd, v);
  d = b * b + s * s - dot (v, v);
  h = dstFar;
  if (d >= 0.) h = - b - sqrt (d);
  return h;
}

float WkrDf (vec3 p, float dMin)
{
  vec3 q;
  float d, yLim, s, len;
  yLim = max (- p.y, p.y - trCoil * trGap);
  p.y = mod (p.y + 0.5 * trGap - (wkrPos.y + bdyHt), trGap) -
     (0.5 * trGap - (wkrPos.y + bdyHt));
  p -= wkrPos;
  p.xz = Rot2D (p.xz, - wkrAz);
  p.yz = Rot2D (p.yz, wkrEl);
  p.y -= bdyHt + trThk;
  d = max (PrCylDf (p.xzy, 4.5, 2.2), yLim);
  if (d < dMin) {
    q = p - vec3 (0., -0.15, 0.2);
    d = PrEllipsDf (q, vec3 (0.7, 0.5, 1.3), 0.6);
    if (d < dMin) { dMin = d;  idObj = idBdy;  qHit = q; }
    q = p - vec3 (0., 0.1, 1.1);
    d = PrEllipsDf (q, vec3 (0.2, 0.4, 0.5), 0.2);
    if (d < dMin) { dMin = d;  idObj = idHead;  qHit = q; }
    q = p;
    q.x = abs (q.x);
    q -= vec3 (0.15, 0.25, 1.5);
    d = PrSphDf (q, 0.13);
    if (d < dMin) { dMin = d;  idObj = idEye; }
    q -= vec3 (0., 0.15, -0.3);
    d = ShpCylDf (q, vec3 (0.3, 1.1, 0.4), 0., 0.1, 0.7);
    if (d < dMin) { dMin = d;  idObj = idAnt; }
    p.y += bdyHt;
    for (int j = 0; j < 8; j ++) {
      q = p - hipPos[j];
      d = 0.6 * ShpCylDf (q, kneePos[j] - hipPos[j], 0., 0.22, 0.4);
      if (d < dMin) { dMin = d;  idObj = idLegU;  qHit = q; }
      q = p - kneePos[j];
      d = 0.6 * ShpCylDf (q, footPos[j] - kneePos[j], 0.3, 0.15, 1.3);
      if (d < dMin) { dMin = d;  idObj = idLegD;  qHit = q; }
    }
  }
  return dMin;
}

float ObjDf (vec3 p)
{
  float dMin = dstFar;
  vec3 q;
  float dr, d;
  q = p;
  q.y = mod (q.y + trGap - 0.0001, trGap) - (trGap - 0.0001);
  q.y -= trGap * atan (q.z, q.x) / (2. * pi);
  dr = length (q.xz) - trRad;
  d = PrBox2Df (vec2 (dr, q.y), vec2 (trWid, trThk));
  q.y += trGap;
  d = min (d, PrBox2Df (vec2 (dr, q.y), vec2 (trWid, trThk)));
  d = max (d, p.y - trCoil * trGap);
  if (d < dMin) { dMin = d;  idObj = idPath;  qHit = q; }
  q = p;
  q.xz = abs (q.xz) - (trRad - trWid - 4. * trThk) / 1.414;
  d = PrCylDf (q.xzy, 3. * trThk, trCoil * trGap);
  if (d < dMin) { dMin = d;  idObj = idCol;  qHit = q; }
  q = p;
  q.y -= 0.1 * trGap;
  d = min (PrCylAnDf (q.xzy, trRad + 1.1 * trWid, 0.1 * trWid, trGap),
     PrCylAnDf (q.xzy, trRad - 1.1 * trWid, 0.1 * trWid, trGap));
  if (d < dMin) { dMin = d;  idObj = idWall;  qHit = q; }
  dMin = WkrDf (p, dMin);
  d = p.y;
  if (d < dMin) { dMin = d;  idObj = -1; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 100; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.0001, -0.0001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.05;
  for (int j = 0; j < 20; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 20. * h / d));
    d += 0.25 + 0.1 * d;
    if (h < 0.001) break;
  }
  return 0.5  + 0.5 * sh;
}

vec3 FBallCol (vec3 col, vec3 ro, vec3 rd, float dHit, float tRot)
{
  vec3 p;
  const vec3 cFog = vec3 (0.8, 0.8, 0.9);
  float diAx, d, b, f;
  ro -= fBallPos;
  ro.xz = Rot2D (ro.xz, tRot);
  rd.xz = Rot2D (rd.xz, tRot);
  diAx = 1. / max (0.001, length (ro - dot (rd, ro) * rd));
  b = 0.05 * fBallRad;
  d = 0.;
  for (int i = 0; i < 20; i ++) {
    d += b;
    f = smoothstep (1., 1.3, sqrt (d * (2. * fBallRad - d)) * diAx);
    p = ro + d * rd;
    f = clamp (TriNoise3d (p) * f * f, 0., 1.);
    col += f * (cFog - col);
    if (length (p) > fBallRad) break;
  }
  return col;
}

vec4 WkrCol (vec3 vn)
{
  vec4 col;
  if (idObj == idBdy) {
    col = vec4 (0.3, 0.3, 1., 0.5);
  } else if (idObj == idHead) {
    col = vec4 (0.3, 0.3, 1., 0.5);
    if (qHit.z > 0.4) col = mix (vec4 (0.2, 0.05, 0.05, 0.1), col,
       smoothstep (0.02, 0.04, abs (qHit.x)));
  } else if (idObj == idEye) {
    col = (vn.z > 0.6) ? vec4 (1., 0., 0., 0.3) : vec4 (1., 1., 0., 1.);
  } else if (idObj == idLegU || idObj == idLegD) {
    col = mix (vec4 (0.3, 0.3, 1., 0.5), vec4 (1., 0.2, 0.2, 0.5),
       SmoothBump (0.4, 1., 0.2, fract (0.7 * length (qHit))));
  } else if (idObj == idAnt) {
    col = vec4 (0., 1., 0., 0.5);
  }
  return col;
}

void Setup ()
{
  vec3 v;
  float gDisp, a, az, fz, d, ll, t;
  wkrSpd = 8.;
  trRad = 20.;
  trWid = 4.5;
  trThk = 0.2;
  trGap = 10.;
  trCoil = 15.;
  t = mod ((wkrSpd / (2. * pi * (trRad + 1.))) * tCur, 1.);
  wkrAz = 2. * pi * t;
  wkrEl = asin (trGap / (2. * pi * trRad));
  wkrPos.xz = trRad * vec2 (cos (wkrAz), sin (wkrAz));
  wkrPos.y = trGap * t;
  fBallRad = trRad + 4.2 * trWid;
  fBallPos = vec3 (0., trCoil * trGap, 0.);
  for (int j = 0; j < 4; j ++) {
    a = 0.2 * (1. + float (j)) * pi;
    hipPos[j] = 0.5 * vec3 (- sin (a), 0., 1.5 * cos (a));
    hipPos[j + 4] = hipPos[j];  hipPos[j + 4].x *= -1.;
  }
  gDisp = wkrSpd * tCur;
  bdyHt = 2.4;
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

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 vn, col, roo;
  float dstHit, dstBHit, spec, sh, f;
  int idObjT;
  col = vec3 (0.);
  noiseDisp = 0.07 * tCur * vec3 (-1., 0., 1.);
  dstBHit = FBallHit (ro, rd, fBallPos, fBallRad);
  roo = ro;
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj >= idBdy) {
      objCol = WkrCol (vn);
      col = objCol.rgb;
      spec = objCol.a;
    } else if (idObj == idPath) {
      vn = VaryNf (100. * ro, vn, 0.5);
      col = vec3 (0.45, 0.4, 0.4);
      spec = 0.2;
    } else if (idObj == idCol) {
      col = vec3 (0.3, 0.3, 0.35);
      spec = 0.5;
    } else if (idObj == idWall) {
      col = vec3 (0.8, 0.5, 0.) * BrickPat (mod (vec2 (50. *
         atan (qHit.z, - qHit.x) / (2. * pi), 0.2 * qHit.y), 1.));
      spec = 0.2;
    } else {
      col = vec3 (1., 1., 0.5);
    }
    sh = ObjSShadow (ro, sunDir);
    col = col * (0.2 + sh * 0.7 * max (dot (vn, sunDir), 0.)) +
       0.5 * sh * spec * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.);
    f = clamp (5. * ro.y / (trCoil * trGap) - 4., 0., 1.);
    col = mix (col, BgCol (roo, rd), f * f * f);
  } else {
    col = BgCol (ro, rd);
    if (rd.y < 0.) col *= ObjSShadow (ro - rd * ro.y / rd.y, sunDir);
  }
  if (dstBHit < min (dstHit, dstFar))
     col = FBallCol (col, roo + rd * dstBHit, rd, dstBHit, 0.1 * tCur);
  col = pow (clamp (col, 0., 1.), vec3 (0.7));
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec3 ro, rd;
  vec2 canvas, uv, vf, cf, sf;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  Setup ();
  vf = vec2 (0.02 * pi, pi - 0.05 * tCur);
  cf = cos (vf);
  sf = sin (vf);
  vuMat = mat3 (1., 0., 0., 0., cf.x, - sf.x, 0., sf.x, cf.x) *
     mat3 (cf.y, 0., sf.y, 0., 1., 0., - sf.y, 0., cf.y);
  rd = normalize (vec3 (uv, 6.)) * vuMat;
  dstFar = 300.;
  ro = vec3 (0., 0., -200.) * vuMat;
  ro.y = trCoil * trGap * (0.25 + 0.75 *
     SmoothBump (0.25, 0.75, 0.2, mod (0.02 * tCur, 1.)));
  sunDir = normalize (vec3 (0.5, 1., 0.5));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}

