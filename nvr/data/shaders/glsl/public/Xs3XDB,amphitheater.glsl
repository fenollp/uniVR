// Shader downloaded from https://www.shadertoy.com/view/Xs3XDB
// written by shadertoy user dr2
//
// Name: Amphitheater
// Description: Somewhere in the Roman empire... Use the mouse to examine the architecture.
// "Amphitheater" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

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
  const vec3 e = vec3 (0.1, 0., 0.);
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s, Fbmn (p + e.yxy, n) - s,
     Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrOBoxDf (vec3 p, vec3 b)
{
  return length (max (abs (p) - b, 0.));
}

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrERCylDf (vec3 p, float r, float rt, float h)
{
  vec2 dc;
  float dxy, dz;
  dxy = length (p.xy) - r;
  dz = abs (p.z - 0.5 * h) - h;
  dc = vec2 (dxy, dz) + rt;
  return min (min (max (dc.x, dz), max (dc.y, dxy)), length (dc) - rt);
}

float PrCylAnDf (vec3 p, float r, float w, float h)
{
  return max (abs (length (p.xy) - r) - w, abs (p.z) - h);
}

float PrFlatCyl2Df (vec2 p, float rhi, float rlo)
{
  return length (p - vec2 (rhi * clamp (p.x / rhi, -1., 1.), 0.)) - rlo;
}

vec2 SSBump (float w, float s, float x)
{
  return vec2 (step (x + s, w) * step (- w, x + s),
     step (x - s, w) * step (- w, x - s));
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

vec2 Rot2Cs (vec2 q, vec2 cs)
{
  return vec2 (dot (q, vec2 (cs.x, - cs.y)), dot (q.yx, cs));
}

vec3 sunDir;
vec2 rAngHCs, rAngACs, rAngLCs, rAngTCs;
float dstFar, tCur;
int idObj;
bool walk;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col, skyCol, p;
  float ds, fd, att, attSum, d, sd;
  if (rd.y >= 0.) {
    p = rd * (200. - ro.y) / max (rd.y, 0.0001);
    ds = 0.1 * sqrt (length (p));
    p += ro;
    fd = 0.002 / (smoothstep (0., 10., ds) + 0.1);
    p.xz *= fd;  p.xz += 0.1 * tCur;
    att = Fbm2 (p.xz);  attSum = att;
    d = fd;
    ds *= fd;
    for (int j = 0; j < 4; j ++) {
      attSum += Fbm2 (p.xz + d * sunDir.xz);
      d += ds;
    }
    attSum *= 0.3;  att *= 0.3;
    sd = clamp (dot (sunDir, rd), 0., 1.);
    skyCol = mix (vec3 (0.7, 1., 1.), vec3 (1., 0.4, 0.1), 0.25 + 0.75 * sd);
    col = mix (vec3 (0.5, 0.75, 1.), skyCol, exp (-2. * (3. - sd) *
       max (rd.y - 0.1, 0.)));
    attSum = 1. - smoothstep (1., 9., attSum);
    col = mix (vec3 (0.4, 0., 0.2), mix (col, vec3 (0.3, 0.3, 0.3), att), attSum) +
       vec3 (1., 0.4, 0.) * pow (attSum * att, 3.) * (pow (sd, 10.) + 0.5);
  } else {
    p = ro - (ro.y / rd.y) * rd;
    col = 0.6 * mix (vec3 (0.4, 0.4, 0.1), vec3 (0.5, 0.5, 0.2),
       Fbm2 (9. * p.xz)) * (1. - 0.1 * Noisefv2 (150. * p.xz));
  }
  return col;
}

float BldgDf (vec3 p, float dMin)
{
  vec3 q, qq, qt;
  vec2 rh, drh;
  float d, a;
  qq = p;
  qq.xz = Rot2D (qq.xz, 2. * pi / 48.);
  a = atan (qq.z, - qq.x) / (2. * pi);
  q = qq;  q.y -= 0.57;
  d = PrCylAnDf (q.xzy, 2., 0.03, 0.57);
  q = qq;  q.xz = Rot2D (q.xz, 2. * pi * (floor (24. * a) + 0.5) / 24.);
  q.y -= 0.11;
  d = max (d, - max (PrFlatCyl2Df (q.yz, 0.2, 0.16), -0.1 - q.y));
  q = qq;  q.xz = Rot2D (q.xz, 2. * pi * (floor (48. * a) + 0.5) / 48.);
  qt = q;
  q.y -= 0.63;
  d = max (d, - max (PrFlatCyl2Df (q.yz, 0.13, 0.1), -0.05 - q.y));
  q = qq;  q.xz = Rot2D (q.xz, 2. * pi * (floor (96. * a) + 0.5) / 96.);
  q.y -= 0.96;
  d = max (d, - max (PrFlatCyl2Df (q.yz, 0.08, 0.05), -0.025 - q.y));
  q = qt;  q.xy -= vec2 (-1.9, 0.47);
  d = min (d, PrOBoxDf (q, vec3 (0.07, 0.01, 0.02)));
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = p;  q.y -= 0.25;
  rh = vec2 (1.8, 0.25);
  drh = vec2 (0.05, 0.0175);
  d = PrCylAnDf (q.xzy, rh.x, 0.5 * drh.x, rh.y);
  for (int k = 0; k < 13; k ++) {
    q.y -= - drh.y;  rh -= drh;
    d = min (d, PrCylAnDf (q.xzy, rh.x, 0.5 * drh.x, rh.y));
  }
  qq = p;
  a = atan (qq.z, - qq.x) / (2. * pi);
  qq.xz = Rot2D (qq.xz, 2. * pi * ((floor (6. * a) + 0.5) / 6.));
  q = qq;  q.y -= 0.07;
  d = max (d, - max (PrFlatCyl2Df (q.yz, 0.22, 0.1), -0.05 - q.y));
  if (d < dMin) { dMin = d;  idObj = 2; }
  q = p;  q.y = abs (q.y - 0.26) - 0.25;
  d = PrCylAnDf (q.xzy, 0.3, 0.01, 0.01);
  q = qq;  q.xy -= vec2 (-0.3, 0.26);
  d = min (d, PrCylDf (q.xzy, 0.01, 0.25));
  if (d < dMin) { dMin = d;  idObj = 3; }
  q = p;  q.y -= 0.03;
  d = PrCylDf (q.xzy, 0.2, 0.03);
  if (d < dMin) { dMin = d;  idObj = 4; }
  q = p;  q.y -= -0.003;
  d = PrCylDf (q.xzy, 2.5, 0.003);
  if (d < dMin) { dMin = d;  idObj = 5; }
  return dMin;
}

float RobDf (vec3 p, float dMin)
{
  vec3 q;
  vec2 s;
  float hGap, bf, d, szFac, spx;
  bool isMob;
  isMob = (length (p.xz) > 0.4);
  if (isMob) {
    p.xz = Rot2Cs (p.xz, rAngTCs);
    s = step (0., p.xz);
    p.xz = abs (p.xz) - 0.5;
    p.xz = Rot2D (p.xz, ((s.x == s.y) ? -0.75 :
       (0.75 - 2. * step (s.x, s.y))) * pi);
    szFac = 25.;
  } else {
    p.xz = vec2 (- p.z, p.x);  p.y -= 0.06;
    szFac = 10.;
  }
  p *= szFac;
  hGap = 2.;
  bf = isMob ? PrBoxDf (p, vec3 (3. * hGap, 6., 3. * hGap)) : 0.;
  dMin *= szFac;
  if (isMob) {
    p.xz = mod (p.xz + hGap, 2. * hGap) - hGap;
    if (s.x == s.y) p.xz = vec2 (- p.z, p.x);
    if (! walk) {
      p.xz = vec2 (- p.z, p.x);
      if (s.x == s.y) p.xz = - p.xz;
    }
  }
  spx = 2. * step (0., p.x) - 1.;
  q = p;  q.y -= 2.2;
  d = max (PrSphDf (q, 0.85), - q.y);
  q = p;  q.y -= 1.2;
  d = min (d, PrERCylDf (q.xzy, 0.9, 0.28, 0.7));
  q = p;  q.xz = Rot2Cs (q.xz, rAngHCs);
  q.x = abs (q.x) - 0.3;  q.y -= 3.;
  q.xy = Rot2D (q.xy, 0.2 * pi);
  d = min (d, PrERCylDf (q.xzy, 0.06, 0.04, 0.2));
  q = p;  q.x = abs (q.x) - 1.05;  q.y -= 2.1;
  if (isMob || ! walk) q.yz = Rot2Cs (q.yz, rAngACs *
     vec2 (1., (walk ? spx : 1.)));
  q.y -= -0.9;
  d = min (d, PrERCylDf (q.xzy, 0.2, 0.15, 0.6));
  q = p;  q.x = abs (q.x) - 0.4;  q.y -= 1.;
  if (isMob) q.yz = Rot2Cs (q.yz, rAngLCs * vec2 (1., spx));
  q.y -= -0.8;
  d = max (min (d, PrERCylDf (q.xzy, 0.25, 0.15, 0.55)), bf);
  if (d < dMin) { dMin = d;  idObj = 11; }
  q = p;  q.xz = Rot2Cs (q.xz, rAngHCs);
  q.x = abs (q.x) - 0.4;  q.yz -= vec2 (2.6, 0.7);
  d = max (PrSphDf (q, 0.15), bf);
  if (d < dMin) { dMin = d;  idObj = 12; }
  dMin /= szFac;
  return dMin;
}

float ObjDf (vec3 p)
{
  float dMin;
  dMin = dstFar;
  dMin = BldgDf (p, dMin);
  dMin = RobDf (p, dMin);
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
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy), ObjDf (p + e.yxy),
     ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
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
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col, q;
  vec2 ss;
  float dstObj, spec, sn, a, f, sh;
  int idObjT;
  bool isRuf;
  dstObj = ObjRay (ro, rd);
  if (dstObj < dstFar) {
    ro += rd * dstObj;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    isRuf = true;
    spec = 0.1;
    if (idObj == 1 || idObj == 2) a = atan (ro.z, - ro.x) / (2. * pi);
    if (idObj == 1) {
      q = ro;
      col = vec3 (0.8, 0.6, 0.3);
      ss = vec2 (0.);
      if (abs (q.y - 0.53) < 0.021) {
        ss = SSBump (0.008, 0.013, q.y - 0.53);
        sn = 0.3;
      } else if (abs (q.y - 0.9) < 0.013) {
        ss = SSBump (0.005, 0.008, q.y - 0.9);
        sn = 0.2;
      } else if (abs (q.y - 1.125) < 0.008) {
        ss = SSBump (0.003, 0.005, q.y - 1.125);
        sn = 0.15;
      }
      if (ss.x + ss.y != 0.) {
        vn.y += sn * (ss.y - ss.x);
        vn = normalize (vn);
        col *= 0.8 * ss.x + 1.1 * ss.y;
        isRuf = false;
      } else if (length (q.xz) > 2. && q.y < 0.505) {
        q.xz = Rot2D (q.xz, 2. * pi * (floor (24. * a) + 0.5) / 24.);
        if (abs (q.z) < 0.032) {
          ss = SSBump (0.013, -0.015, q.z);
          if (ss.x + ss.y != 0.) {
            vn.xz += 0.3 * (ss.y - ss.x) * vn.zx * vec2 (-1., 1.);
            col *= 0.8 * ss.x + 1.1 * ss.y;
          }
        }
      }
      if (length (q.xz) > 2. && abs (q.y - 0.84) < 0.03) {
        q.xz = Rot2D (q.xz, 2. * pi * (floor (6. * a) + 0.5) / 6.);
        q.y -= 0.84;
        if (length (q.yz) < 0.03) {
          col = mix (vec3 (1., 0.7, 0.), vec3 (0., 0., 1.),
             step (0., sin (500. * length (q.yz))));
          isRuf = false;
          spec = -1.;
        }
      }
    } else if (idObj == 2) {
      if (length (ro.xz) > 1.82) {
        f = SmoothBump (0.7, 1.1, 0.1, Fbm2 (40. * vec2 (10. * a, ro.y)));
        col = vec3 (0.6, 0.6, 0.8) * mix (1., 0.9, f);
      } else {
        col = vec3 (0.6, 0.6, 0.7) * mix (1., 0.9, Noisefv3a (200. * ro));
      }
    } else if (idObj == 3) {
      col = vec3 (0.8, 0.8, 0.2);
      spec = 1.;
    } else if (idObj == 4) {
      col = vec3 (0.1, 0.2, 0.6);
    } else if (idObj == 5) {
      if (length (ro.xz) > 2.) col = vec3 (0.4, 0.4, 0.3) * (1. -
         0.1 * SmoothBump (0.1, 0.3, 0.05, mod (30. *
         (length (ro.xz) - 2.), 1.)));
      else col = vec3 (0.5, 0.5, 0.45) * mix (1., 0.7, Noisefv2 (400. * ro.xz));
    } else if (idObj == 11) {
      col = (length (ro.xz) > 0.4) ? vec3 (0.2, 0.8, 0.2) : vec3 (0.8, 0.2, 0.8);
      spec = 0.5;
    } else if (idObj == 12) {
      col = (length (ro.xz) > 0.4) ? vec3 (0.8, 0.3, 0.) : vec3 (1., 0., 0.);
      spec = 1.;
    }
    if (spec >= 0.) {
      if (idObj == 1 && isRuf || idObj == 5) vn = VaryNf (100. * ro, vn, 0.5);
      sh = ObjSShadow (ro, sunDir);
      col = col * (0.2 +
         sh * (0.1 * max (vn.y, 0.) + 0.8 * max (dot (vn, sunDir), 0.)) +
         sh * spec * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.));
    }
  } else {
    sh = (rd.y < 0.) ? ObjSShadow (ro - (ro.y / rd.y) * rd, sunDir) : 1.;
    col = sh * BgCol (ro, rd);
  }
  return pow (clamp (col, 0., 1.), vec3 (0.8));
}

void SetState ()
{
  float tCyc, wkSpd, rAngH, rAngA, rAngL, rAngT;
  wkSpd = 2. * pi * 0.55 / 7.;
  tCyc = mod (wkSpd * tCur, 7.);
  rAngT = - 0.07 * (4. * floor (wkSpd * tCur / 7.) + min (tCyc, 4.)) / wkSpd;
  rAngTCs = vec2 (cos (rAngT), sin (rAngT));
  if (tCyc < 4.) {
    walk = true;
    tCyc = mod (tCyc, 1.);
    rAngH = -0.7 * sin (2. * pi * tCyc);
    rAngA = 1.1 * sin (2. * pi * tCyc);
    rAngL = -0.6 * sin (2. * pi * tCyc);
  } else {
    walk = false;
    tCyc = mod (tCyc, 1.);
    rAngH = 0.;
    rAngA = 2. * pi * (0.5 - abs (tCyc - 0.5)); 
    rAngL = 0.;
  }
  rAngHCs = vec2 (cos (rAngH), sin (rAngH));
  rAngACs = vec2 (cos (rAngA), sin (rAngA));
  rAngLCs = vec2 (cos (rAngL), sin (rAngL));
}

vec3 TrackPath (float t)
{
  vec3 p, w;
  float ti[7], rI, rO, hI, hO, hC, s;
  ti[0] = 0.;  ti[1] = ti[0] + 0.3;  ti[2] = ti[1] + 0.1;  ti[3] = ti[2] + 0.4;
  ti[4] = ti[3] + 0.1;  ti[5] = ti[4] + 0.3;  ti[6] = ti[5] + 0.3;
  t = mod (0.02 * t, ti[6]);
  rI = 1.6;  rO = 5.5;  hI = 0.7;  hO = 0.5;  hC = 0.2;
  if (t < ti[1]) {
    s = (t - ti[0]) / (ti[1] - ti[0]);
    w = vec3 (rO - s * (rO - rI), hO + s * (hC - hO), -0.5 * pi);
  } else if (t < ti[2]) {
    s = (t - ti[1]) / (ti[2] - ti[1]);
    w = vec3 (rI, hC + s * (hI - hC), -0.5 * pi);
  } else if (t < ti[3]) {
    s = (t - ti[2]) / (ti[3] - ti[2]);
    w = vec3 (rI, hI, - 0.5 * pi + s * 1.333 * pi);
  } else if (t < ti[4]) {
    s = (t - ti[3]) / (ti[4] - ti[3]);
    w = vec3 (rI, hI - s * (hI - hC), 0.833 * pi);
  } else if (t < ti[5]) {
    s = (t - ti[4]) / (ti[5] - ti[4]);
    w = vec3 (rI + s * (rO - rI), hC + s * (hO - hC), 0.833 * pi);
  } else {
    s = (t - ti[5]) / (ti[6] - ti[5]);
    w = vec3 (rO, hO, 0.833 * pi + s * 0.667 * pi);
  }
  p.xz = w.x * vec2 (cos (w.z), sin (w.z));  p.y = w.y;
  return p;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd, vd, col;
  vec2 canvas, uv, ori, ca, sa;
  float el, az, zmFac, vuMode;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  dstFar = 12.;
  sunDir = normalize (vec3 (1., 1., -1.));
  vuMode = 1.;
  az = 0.;
  el = (vuMode == 1.) ? 0.05 : -0.3;
  if (mPtr.z > 0.) {
    az += 3. * pi * mPtr.x;
    el += pi * mPtr.y;
  }
  if (vuMode == 1.) {
    ro = TrackPath (tCur);
    vd = normalize (vec3 (0., 0.1, 0.) - ro);
    az = clamp (az, -0.7 * pi, 0.7 * pi);
    el = clamp (el, -0.2 * pi, 0.2 * pi);
    az += 0.5 * pi + atan (- vd.z, vd.x);
    el += asin (vd.y);
    zmFac = 1.4 + 0.45 * length (ro.xz);
  } else {
    el = min (el, 0.);
    zmFac = 3.6;
  }
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
          mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  rd = vuMat * normalize (vec3 (uv, zmFac));
  if (vuMode == 0.) ro = vuMat * vec3 (0., 0.3, -6.);
  SetState ();
  col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
