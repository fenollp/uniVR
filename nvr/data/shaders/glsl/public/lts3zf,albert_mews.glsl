// Shader downloaded from https://www.shadertoy.com/view/lts3zf
// written by shadertoy user dr2
//
// Name: Albert Mews
// Description: Travel relativistically down a narrow lane (where Albert may have
//    resided); mouse controls speed.
//    
// "Albert Mews" by dr2 - 2015
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
  vec2 i = floor (p);
  vec2 f = fract (p);
  f = f * f * (3. - 2. * f);
  vec4 t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

float Noisefv3a (vec3 p)
{
  vec3 i, f;
  i = floor (p);  f = fract (p);
  f *= f * (3. - 2. * f);
  vec4 t1 = Hashv4v3 (i);
  vec4 t2 = Hashv4v3 (i + vec3 (0., 0., 1.));
  return mix (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
              mix (mix (t2.x, t2.y, f.x), mix (t2.z, t2.w, f.x), f.y), f.z);
}

int idObj;
vec3 qHit, ltDir;
float tCur;
const float dstFar = 150.;
const int idRoad = 11, idCol = 12, idBeam = 13, idBrg = 14, idWall = 15,
   idGrs = 16, idLumW = 17, idLumT = 18, idLamp = 19;

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrBox2Df (vec3 p, vec2 b)
{
  vec2 d = abs (p.xy) - b;
  return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

float ChqPat (vec3 p, float dHit)
{
  vec2 q, iq;
  float f;
  q = p.xz;
  iq = floor (q);
  if (2. * floor (iq.x / 2.) != iq.x) q.y += 0.5;
  q = smoothstep (0., 0.1, abs (fract (q + 0.5) - 0.5));
  f = dHit / dstFar;
  return 1. - 0.4 * exp (-10. * f * f) * (1. - q.x * q.y);
}

vec3 ChqNorm (vec3 p, vec3 n)
{
  vec2 q, iq;
  q = p.xz;
  iq = floor (q);
  if (2. * floor (iq.x / 2.) != iq.x) q.y += 0.5;
  q = 2. * fract (q) - 1.;
  n.xz += 0.3 * q * q * sign (q);
  return normalize (n);
}

float ObjDf (vec3 p)
{
  vec3 q, qq;
  float d, db, dHit, s;
  dHit = dstFar;
  d = dHit;
  q = p;
  s = sign (q.x);
  qq = q;
  q.x = abs (q.x) - 3.;  q.z = mod (q.z + 2., 4.) - 2.;
  d = PrCylDf (q.xzy, 0.25, 2.);
  q.x *= s;
  if (d < dHit) { dHit = d;  idObj = idCol;  qHit = q; }
  q = p;  q.y -= -2.;  q.z = mod (q.z, 4.) - 2.;
  d = PrCylDf (q.xzy, 0.5, 0.2);
  q.y -= 0.3;
  d = max (d, - PrCylDf (q.xzy, 0.45, 0.3));
  if (d < dHit) { dHit = d;  idObj = idCol;  qHit = q; }
  q.y -= -0.3;
  d = PrCylDf (q.xzy, 0.45, 0.1);
  if (d < dHit) { dHit = d;  idObj = idGrs;  qHit = q; }
  q = p;  q.x = abs (q.x) - 3.5;
  d = PrBox2Df (q, vec2 (0.1, 2.));
  qq = q;
  q.y -= 0.5;  q.z = abs (mod (q.z + 2., 4.) - 2.) - 0.75;
  d = max (d, - PrBoxDf (q, vec3 (1., 0.5, 0.4)));
  q.y -= 0.5;
  db = PrBoxDf (q, vec3 (0.12, 0.03, 0.4));
  q = qq;  q.y -= -0.45;  q.z = mod (q.z, 4.) - 2.;
  d = max (d, - PrBoxDf (q, vec3 (1., 1.45, 0.4)));
  q.y = abs (q.y) - 1.45;
  db = min (db, PrBoxDf (q, vec3 (0.12, 0.03, 0.4)));
  if (d < dHit) { dHit = d;  idObj = idWall;  qHit = q; }
  if (db < dHit) { dHit = db;  idObj = idBeam;  qHit = q; }
  q = p;  q.xy = abs (q.xy) - vec2 (3.5, 2.1);
  d = PrBox2Df (q, vec2 (0.8, 0.05));
  if (d < dHit) { dHit = d;  idObj = idBeam;  qHit = q; }
  q = p;  q.y -= 2.25;  q.z = mod (q.z + 2., 4.) - 2.;
  d = PrBoxDf (q, vec3 (3.25, 0.2, 0.25));
  if (d < dHit) { dHit = d;  idObj = idBrg;  qHit = q; }
  q = p;  q.y -= -2.3;
  d = PrBox2Df (q, vec2 (3.5, 0.1));
  if (d < dHit) { dHit = d;  idObj = idRoad;  qHit = q; }
  q = p;
  q.x = abs (q.x) - 3.35;  q.y -= 1.1;  q.z = mod (q.z, 4.) - 2.;
  d = PrCapsDf (q, 0.03, 0.2);
  if (d < dHit) { dHit = d;  idObj = idLamp;  qHit = q; }
  q = p;  q.x = abs (q.x) - 3.6;
  d = PrBox2Df (q, vec2 (0.1, 2.));
  if (d < dHit) { dHit = d;  idObj = idLumW;  qHit = q; }
  q = p;  q.y -= 2.5;
  d = PrBox2Df (q, vec2 (3.5, 0.1));
  if (d < dHit) { dHit = d;  idObj = idLumT;  qHit = q; }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec3 e = 1e-5 * vec3 (1., -1., 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 200; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjCol (vec3 n, float dHit)
{
  vec3 col;
  float sn = Noisefv3a (210. * qHit);
  if (idObj == idCol) col = vec3 (0.7, 0.6, 0.5);
  else if (idObj == idBeam) col = vec3 (0.6, 0.7, 0.5);
  else if (idObj == idBrg) col = vec3 (0.7, 0.8, 0.6);
  else if (idObj == idRoad)
     col = ChqPat (qHit * vec3 (3., 1., 3.), dHit) * vec3 (0.7, 0.7, 0.5);
  else if (idObj == idWall)
     col = ChqPat (qHit.yxz * vec3 (8., 1., 4.), dHit) * vec3 (0.8, 0.2, 0.2);
  else if (idObj == idGrs) col = vec3 (0.1, 0.7, 0.2);
  col *= 0.7 + 0.3 * sn;
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, bgCol, vn;
  float dstHit, da, a;
  int idObjT;
  bgCol = 0.9 * vec3 (0.5, 0.6, 0.8);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (idObj < 0) dstHit = dstFar;
  if (dstHit >= dstFar) col = bgCol;
  else if (idObj == idLumW) col = vec3 (0.7, 0.6, 0.1) *
       (1. - 0.5 * SmoothBump (0.1, 0.13, 0.01, mod (qHit.z + 0.125, 0.25))) *
       (1. - 0.5 * SmoothBump (0.1, 0.13, 0.01, mod (qHit.y + 0.125, 0.25)));
  else if (idObj == idLumT) col = vec3 (0.5, 0.6, 0.8);
  else if (idObj == idLamp) col = vec3 (0.4, 0.9, 0.4);
  else {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == idCol) {
      a = 0.5 - mod (12. * (atan (qHit.x, qHit.z) / (2. * pi) + 0.5), 1.);
      vn.xz = Rot2D (vn.xz, -0.15 * pi * sin (pi * a));
    } else if (idObj == idRoad) {
      vn = ChqNorm (qHit * vec3 (3., 1., 3.), vn);
    } else if (idObj == idWall) {
      vn = ChqNorm (qHit.yxz * vec3 (8., 1., 4.), vn.yxz);
    }
    col = ObjCol (vn, dstHit);
    col = col * (0.5 + 0.5 * max (dot (vn, ltDir), 0.)) +
       0.2 * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
  }
  da = min (dstHit / dstFar, 1.);
  col = mix (bgCol, col, exp (- 2. * da * da));
  return clamp (col, 0., 1.);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 canvas = iResolution.xy;
  vec2 uv = 2. * fragCoord.xy / canvas - 1.;
  vec2 uvs = uv;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  vec4 mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  float beta, cPhi, w, cLen;
  vec3 ro, rd, col;
  ltDir = normalize (vec3 (1., 1., -1.));
  w = (mPtr.z > 0.) ? clamp (0.5 + mPtr.y, 0.07, 1.) : 0.8;
  beta = clamp (pow (w, 0.25), 0.1, 0.999);
  ro = vec3 (0.);
  ro.z += (0.3 + 1.7 * beta) * tCur;
  uv += 0.5 * (Noisefv2 (2000. * uv) - 0.5) / canvas;
  rd = normalize (vec3 (uv, 4.));
  cPhi = (rd.z - beta) / (1. - rd.z * beta);
  rd = vec3 (0., 0., cPhi) +
     sqrt (1. - cPhi * cPhi) * normalize (rd - vec3 (0., 0., rd.z));
  col = ShowScene (ro, rd);
  cLen = 0.2;
  uvs.y = abs (uvs.y - 0.96);
  if (uvs.y < 0.02 && abs (uvs.x) < cLen) {
    col = 0.3 * col + 0.5;
    uvs.x += cLen - 0.01;
    if (uvs.y < 0.015 && uvs.x > 0. && uvs.x < (2. * cLen - 0.02) *
       (2. * beta - 1.)) col = vec3 (1., 0.9, 0.5);
  }
  fragColor = vec4 (col, 1.);
}
