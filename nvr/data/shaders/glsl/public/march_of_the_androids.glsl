// Shader downloaded from https://www.shadertoy.com/view/XlSSRd
// written by shadertoy user dr2
//
// Name: March of the Androids
// Description: Beware!
// "March of the Androids" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// With ideas from simesgreen (4dfGz8) and iapafoto (MsB3zK)

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
vec3 sunDir, qHit;
float tCur, rAngH, rAngL, rAngA, gDisp;
int idObj;
bool walk;
float dstFar = 150.;

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

float PrERCylDf (vec3 p, float r, float rt, float h)
{
  vec2 dc;
  float dxy, dz;
  dxy = length (p.xy) - r;
  dz = abs (p.z - 0.5 * h) - h;
  dc = vec2 (dxy, dz) + rt;
  return min (min (max (dc.x, dz), max (dc.y, dxy)), length (dc) - rt);
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
    f = Fbm2 (0.05 * (ro.xz + rd.xz * (50. - ro.y) / rd.y));
    col = mix (col, vec3 (1.), clamp (0.1 + 0.8 * f * rd.y, 0., 1.));
  } else {
    sd = - ro.y / rd.y;
    col = mix (vec3 (0.6, 0.5, 0.3),
       0.9 * (vec3 (0.1, 0.2, 0.4) + 0.2) + 0.1, pow (1. + rd.y, 5.));
  }
  return col;
}

float ObjDf (vec3 p)
{
  vec3 q, pp;
  vec2 ip;
  float dMin, d, bf, hGap, bFac, ah;
  hGap = 2.5;
  bf = PrBoxDf (p, vec3 (7. * hGap, 6., 7. * hGap));
  pp = p;
  ip = floor ((pp.xz + hGap) / (2. * hGap));
  pp.xz = pp.xz - 2. * hGap * ip;
  bFac = (ip.x == 0. && ip.y == 0.) ? 1.6 : 1.;
  ah = rAngH * (walk ? sign (1.1 - bFac) : - step (1.1, bFac));
  dMin = dstFar;
  q = pp;
  q.y -= 1.2;
  d = max (PrSphDf (q, 0.85), - q.y); // head
  q = pp;
  q.y -= 0.2;
  d = min (d, PrERCylDf (q.xzy, 0.9, 0.28, 0.7)); // trunk
  q = pp;
  q.xz = Rot2D (q.xz, ah);
  q.x = abs (q.x) - 0.4;
  q.y -= 1.9;
  q.xy = Rot2D (q.xy, 0.2 * pi);
  d = min (d, PrERCylDf (q.xzy, 0.06, 0.04, 0.4 * (2. * bFac - 1.))); // ant
  q = pp;
  q.x = abs (q.x) - 1.05;
  q.y -= 1.1;
  q.yz = Rot2D (q.yz, rAngA * (walk ? sign (pp.x) : 1.));
  q.y -= -0.9;
  d = min (d, PrERCylDf (q.xzy, 0.2, 0.15, 0.6)); // arm
  q = pp;
  q.x = abs (q.x) - 0.4;
  q.yz = Rot2D (q.yz, - rAngL * sign (pp.x));
  q.y -= -0.8;
  d = min (d, PrERCylDf (q.xzy, 0.25, 0.15, 0.55)); // leg
  d = max (d, bf);
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = pp;
  q.xz = Rot2D (q.xz, ah);
  q.x = abs (q.x) - 0.4;
  q -= vec3 (0., 1.6 + 0.3 * (bFac - 1.), 0.7 - 0.3 * (bFac - 1.));
  d = PrSphDf (q, 0.15 * bFac);
  d = max (d, bf);
  if (d < dMin) { dMin = d;  idObj = 2; }  // eye
  d = p.y + 1.;
  if (d < dMin) { dMin = d;  idObj = 0;  qHit = p; }  // ground
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
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float ChqPat (vec3 p, float dHit)
{
  vec2 q, iq;
  float f, s;
  p.z += gDisp;
  q = p.xz + vec2 (0.5, 0.25);
  iq = floor (q);
  s = 0.5 + 0.5 * Noisefv2 (q * 107.);
  if (2. * floor (iq.x / 2.) != iq.x) q.y += 0.5;
  q = smoothstep (0., 0.02, abs (fract (q + 0.5) - 0.5));
  f = dHit / dstFar;
  return s * (1. - 0.9 * exp (-2. * f * f) * (1. - q.x * q.y));
}

vec3 ObjCol (vec3 rd, vec3 vn, float dHit)
{
  vec3 col;
  if (idObj == 1) col = vec3 (0.65, 0.8, 0.2);
  else if (idObj == 2) col = vec3 (0.8, 0.8, 0.);
  else col = mix (vec3 (0.4, 0.3, 0.2), vec3 (0.6, 0.5, 0.4),
     (0.5 + 0.5 * ChqPat (qHit / 5., dHit)));
  return col * (0.3 + 0.7 * max (dot (vn, sunDir), 0.)) +
     0.3 * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.);
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.05;
  for (int j = 0; j < 15; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 10. * h / d);
    d += 0.2;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 TrackPath (float t)
{
  vec3 p;
  vec2 tr;
  float ti[5], rPath, a, r, tC, tL, tWf, tWb;
  bool rotStep;
  rPath = 28.;
  tC = pi * rPath / 8.;
  tL = 2. * rPath / 5.;
  tWf = 4.;
  tWb = 2.;
  rotStep = false;
  ti[0] = 0.;
  ti[1] = ti[0] + tWf;
  ti[2] = ti[1] + tL;
  ti[3] = ti[2] + tWb;
  ti[4] = ti[3] + tC;
  p.y = 1.;
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
    a = 1.5 + (t - ti[3]) / (ti[4] - ti[3]);
    r = rPath;
  }
  if (rotStep) {
    a *= pi;
    p.xz = r * vec2 (cos (a), sin (a));
  } else {
    p.xz = tr;
  }
  p.xz -= 2.5;
  return p;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col, c;
  float dstHit, tCyc, refl, spd;
  int idObjT;
  spd = 0.7;
  tCyc = mod (spd * tCur, 7.);
  if (tCyc < 4.) {
    walk = true;
    tCyc = mod (tCyc, 1.);
    gDisp = mod (spd * tCur, 1.);
    rAngH = -0.7 * sin (2. * pi * tCyc);
    rAngA = 1.1 * sin (2. * pi * tCyc);
    rAngL = 0.6 * sin (2. * pi * tCyc);
  } else {
    walk = false;
    tCyc = mod (tCyc, 1.);
    gDisp = 0.;
    rAngH = 0.4 * sin (2. * pi * tCyc);
    rAngA = 2. * pi * (0.5 - abs (tCyc - 0.5)); 
    rAngL = 0.;
  }
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    col = ObjCol (rd, vn, dstHit);
    idObj = idObjT;
    if (idObj > 0) {
      rd = reflect (rd, vn);
      ro += 0.01 * rd;
      refl = 0.2 + 0.3 * pow (1. - dot (vn, rd), 4.);
      dstHit = ObjRay (ro, rd);
      if (dstHit < dstFar) {
        ro += rd * dstHit;
	c = ObjCol (rd, ObjNf (ro), dstHit);
      } else {
        c = BgCol (ro, rd);
      }
      col = mix (col, c, refl);
    }
    col *= (0.8 + 0.2 * ObjSShadow (ro, sunDir));
  } else {
    col = BgCol (ro, rd);
  }
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec2 canvas, uv;
  vec3 ro, rd, vd, u;
  float f;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  ro = TrackPath (tCur);
  vd = normalize (vec3 (0., 2., 0.) - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (uv, 2.));
  sunDir = normalize (vec3 (1., 2., 1.));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}

