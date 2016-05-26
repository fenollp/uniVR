// Shader downloaded from https://www.shadertoy.com/view/llBSDK
// written by shadertoy user dr2
//
// Name: Magic Tree
// Description: A tree with its own temple (mouse enabled).
// "Magic tree" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Tree includes ideas from eiffie (4s23Rh) and iapafoto (XsS3Dm).

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

float SmoothMin (float a, float b, float r)
{
  float h;
  h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
  return mix (b, a, h) - r * h * (1. - h);
}

vec2 Rot2D (vec2 q, float a)
{
  const vec2 e = vec2 (1., -1.);
  return q * cos (a) * e.xx + q.yx * sin (a) * e.yx;
}

mat3 RMat3D (vec3 a)
{
  vec3 cr, sr;
  cr = cos (a);
  sr = sin (a);
  return mat3 (cr.z, - sr.z, 0., sr.z, cr.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., cr.x, - sr.x, 0., sr.x, cr.x) *
     mat3 (cr.y, 0., - sr.y, 0., 1., 0., sr.y, 0., cr.y);
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p;
  p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
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

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCylAnDf (vec3 p, float r, float w, float h)
{
  return max (abs (length (p.xy) - r) - w, abs (p.z) - h);
}

float PrECapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., clamp (p.z, 0., h))) - r;
}

mat3 bRot;
vec3 qHit, sunDir;
float tCur, trAge, trBloom, szTree, nCyc, flRad, brLen, brRad, brRadMax;
int idObj;
const float sScale = 0.726;
const float dstFar = 100.;
const int brMax = 14;
const int idBase = 1, idCol = 2, idRing = 3, idTop = 4, idWat = 5, idIWall = 6,
   idLatt = 7, idOWall = 8, idBrnch = 101, idFlwr = 120;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col;
  float sd, f;
  if (rd.y > 0.) {
    ro.xz += 2. * tCur;
    sd = max (dot (rd, sunDir), 0.);
    col = vec3 (0.1, 0.2, 0.4) + 0.2 * pow (1. - max (rd.y, 0.), 8.) +
       0.35 * pow (sd, 6.) + 0.65 * min (pow (sd, 256.), 0.3);
    f = Fbm2 (0.1 * (ro.xz + rd.xz * (50. - ro.y) / rd.y));
    col = mix (col, vec3 (1.), clamp (0.1 + 0.8 * f * rd.y, 0., 1.));
  } else {
    f = Noisefv2 ((ro.xz - rd.xz * ro.y / rd.y) * 17.1);
    col = mix (mix (vec3 (0.2, 0.4, 0.2), vec3 (0.3, 0.6, 0.3), f),
       0.9 * (vec3 (0.1, 0.2, 0.4) + 0.2) + 0.1, pow (1. + rd.y, 5.));
  }
  return col;
}

float TreeDf (vec3 p, float dMin)
{
  vec3 q;
  float rFac, d, fr;
  q = p / szTree;
  q.xz = Rot2D (q.xz, 1.3 * nCyc);
  q *= RMat3D (vec3 (0.2, 0.5, -0.2));
  rFac = 1.;
  for (int j = 0; j < brMax - 4; j ++) {
    rFac *= sScale;
    brRad = max (brRadMax - 0.02 * q.y, 0.02);
    d = PrECapsDf (q.xzy, brRad, brLen) * rFac;
    if (d < dMin) {
      dMin = SmoothMin (dMin, d, 0.1 * brRad * rFac);
      idObj = idBrnch + j;
      qHit = q;
    }
    q.x = abs (q.x);
    q.y -= brLen;
    q *= bRot;
  }
  fr = 0.8 * flRad;
  for (int j = 0; j < 4; j ++) {
    rFac *= sScale;
    d = PrCylDf (q + vec3 (brRad, brLen, 0.), fr, 0.03 * brLen) * rFac;
    if (d < dMin) {
      dMin = d;
      idObj = idFlwr + j;
      qHit = q;
    }
    q.x = abs (q.x);
    q.y -= brLen;
    q *= bRot;
    fr += 0.05 * flRad;
  }
  return dMin;
}

float ObjDf (vec3 p)
{
  vec3 q;
  const vec3 bIw = vec3 (7., 0., 9.);
  const vec3 bOw = vec3 (8.9, 0., 10.9);
  const float tIw = 0.3, hIw = 0.6;
  const float tOw = 0.15, cLen = 2.4, hb = 0.05, hTop = 0.4;
  float dMin, d, da, db, wr;
  dMin = dstFar;
  q = p;
  db = max (PrBox2Df (q.xz, bIw.xz + tIw), - PrBox2Df (q.xz, bIw.xz - tIw));
  q.y -= hb;
  d = PrBoxDf (q, vec3 (bOw.x + 0.5, hb, bOw.z + 0.5));
  if (d < dMin) { dMin = d;  idObj = idBase;  qHit = q; }
  q = p;
  q.y -= 2. * hb + cLen + hIw + 1.1 * hTop;
  d = max (max (PrBox2Df (q.xz, bOw.xz + tOw),
     - PrBox2Df (q.xz, bOw.xz - tOw)), abs (q.y) - (cLen + hIw + 1.1 * hTop));
  d = max (d, - min (PrBox2Df (q.xy, vec2 (bOw.x - 0.5, 3.)),
     PrBox2Df (q.zy, vec2 (bOw.z - 0.5, 3.))));
  d = max (d, min (- q.y, 0.7 - min (abs (q.x), abs (q.z))));
  if (d < dMin) { dMin = d;  idObj = idOWall;  qHit = q; }
  q = p;
  q.y -= hIw + 2. * hb;
  d = min (d, max (max (PrBoxDf (q, vec3 (bIw.x + tIw, hIw, bIw.z + tIw)),
     0.7 - min (abs (q.x), abs (q.z))), db));
  if (d < dMin) { dMin = d;  idObj = idIWall;  qHit = q; }
  q = p;
  q.y -= 2. * cLen + hTop + 2. * hIw + 2. * hb;
  d = max (PrBoxDf (q, vec3 (bIw.x + tIw, hTop, bIw.z + tIw)), db);
  q.xz = mod (q.xz + 1., 2.) - 1.;
  q.y -= -0.6;
  d = max (d, - min (PrCylDf (q, 0.7, bIw.z + 1.),
     PrCylDf (q.zyx, 0.7, bIw.x + 1.)));
  if (d < dMin) { dMin = d;  idObj = idTop;  qHit = q; }
  q = p;
  q.y -= 2. * cLen + 2. * hTop + 2. * hIw;
  d = max (PrBoxDf (q, vec3 (bOw.x, hb, bOw.z)),
     - PrBox2Df (q.xz, bIw.xz - 0.15));
  q.xz = mod (q.xz + 1., 2.) - 1.;
  d = max (d, - PrBox2Df (q.xz, vec2 (0.8)));    
  if (d < dMin) { dMin = d;  idObj = idLatt;  qHit = q; }
  q = p;
  q.xz = mod (q.xz, 2.) - 1.;
  q.y -= cLen + 2. * hIw + 2. * hb;
  wr = q.y / cLen;
  d = max (PrCylDf (q.xzy, tIw * (0.8 - 0.05 * wr * wr), cLen), db);
  if (d < dMin) { dMin = d;  idObj = idCol;  qHit = q; }
  q = p;
  q.y -= 0.2;
  d = PrCylAnDf (q.xzy, 4.4, 0.1, 0.15);
  if (d < dMin) { dMin = d;  idObj = idRing;  qHit = q; }
  q = p;
  q.y -= 0.2;
  d = PrCylDf (q.xzy, 4.5, 0.02);
  if (d < dMin) { dMin = d;  idObj = idWat;  qHit = q; }
  dMin = TreeDf (q, dMin);
  return dMin;
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
  d = 0.1;
  for (int j = 0; j < 10; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, 5. * h / d);
    d *= 1.7;
    if (h < 0.001) break;
  }
  return max (sh, 0.);
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
  return 1. - 0.6 * exp (-10. * f * f) * (1. - q.x * q.y);
}

vec3 ChqNorm (vec3 p, vec3 n)
{
  vec2 q, iq;
  q = p.xz;
  iq = floor (q);
  if (2. * floor (iq.x / 2.) != iq.x) q.y += 0.5;
  q = 2. * fract (q) - 1.;
  n.xz += 0.5 * q * q * sign (q);
  return normalize (n);
}

void SetupTree ()
{
  float t;
  nCyc = floor (tCur / 60.);
  trAge = tCur / 60. - nCyc;
  trBloom = mod (5. * trAge, 1.);
  szTree = 2.3 - 2.2 * smoothstep (0.93, 0.98, trAge);
  t = min (trAge, 0.8);
  brLen = min (0.95, 0.03 + 1.3 * sqrt (t));
  brRadMax = 0.01 + 0.12 * sqrt (t);
  flRad = (0.2 + 6. * t) * (0.05 +
     0.8 * clamp (6. * trBloom * (1. - trBloom) - 0.1, 0., 1.));
  bRot = RMat3D (vec3 (-0.5 + 0.3 * t, -1.5, 0.7 + 0.2 * t) +
     0.05 * sin (0.5 * nCyc)) / sScale;
}
  
vec3 TrackPath (float t)
{
  vec3 p;
  vec2 tr;
  float ti[5], chRingO, chRingI, vuVel, a, r, tO, tI, tR, rGap;
  bool rotStep;
  chRingO = 21.;
  chRingI = 6.;
  vuVel = 2.;
  tO = 0.5 * pi * chRingO / vuVel;
  tI = 0.5 * pi * chRingI / vuVel;
  rGap = chRingO - chRingI;
  tR = rGap / vuVel;
  rotStep = false;
  ti[0] = 0.;
  ti[1] = ti[0] + tO;  ti[2] = ti[1] + tR;
  ti[3] = ti[2] + tI;  ti[4] = ti[3] + tR;
  p.y = 4.;
  t = mod (t, ti[4]);
  tr = vec2 (0.);
  if (t < ti[1]) {
    rotStep = true;
    a = (t - ti[0]) / (ti[1] - ti[0]);
    r = chRingO;
  } else if (t < ti[2]) {
    tr.y = chRingO - rGap * (t - ti[1]) / (ti[2] - ti[1]);
  } else if (t < ti[3]) {
    rotStep = true;
    a = 1. - (t - ti[2]) / (ti[3] - ti[2]);
    r = chRingI;
  } else {
    tr.x = chRingI + rGap * (t - ti[3]) / (ti[4] - ti[3]);
  }
  if (rotStep) {
    a *= 0.5 * pi;
    p.xz = r * vec2 (cos (a), sin (a));
  } else {
    p.xz = tr;
  }
  return p;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 objCol, col, roo, vn, vnw;
  float dstHit, refl, sh, a, f;
  int idObjT;
  refl = 1.;
  idObj = -1;
  roo = ro;
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar && idObj == idWat) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    vec2 u = ro.xz;
    float s = length (u);
    u /= s;
    u *= cos (20. * s - 5. * tCur) * (1. - s / 5.);
    vn = normalize (vec3 (u.x, 50., u.y));
    rd = reflect (rd, vn);
    ro += 0.01 * rd;
    refl *= 0.9;
    idObj = -1;
    dstHit = ObjRay (ro, rd);
  }
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == idCol) {
      a = 0.5 - mod (20. * (atan (qHit.x, qHit.z) / (2. * pi) + 0.5), 1.);
      vn.xz = Rot2D (vn.xz, -0.15 * pi * sin (pi * a));
    }
    if (idObj == idBase) {
      objCol = vec3 (0.6, 0.6, 0.5);
      if (vn.y > 0.99) {
        if (abs (abs (qHit.x) - 3.7) < 3. && abs (abs (qHit.z) - 4.7) < 4.) {
	  objCol = mix (vec3 (0.2, 0.5, 0.2), vec3 (0.3, 0.8, 0.2),
             Noisefv2 (qHit.xz * 41.)) * (0.5 + 0.5 * Noisefv2 (qHit.zx * 57.));
	} else {
          objCol *= ChqPat (qHit * vec3 (3., 1., 3.), dstHit);
          vn = ChqNorm (qHit * vec3 (3., 1., 3.), vn);
          vn = VaryNf (10. * qHit, vn, 2.);
	}
      } else {
        vn = VaryNf (20. * qHit, vn, 5.);
      }
    } else if (idObj == idTop || idObj == idIWall) {
      objCol = vec3 (0.6, 0.6, 0.5);
      vn = VaryNf (20. * qHit, vn, 2.);
    } else if (idObj == idOWall) {
      objCol = vec3 (0.6, 0.57, 0.6);
      vn = VaryNf (20. * qHit, vn, 5.);
    } else if (idObj == idLatt) {
      objCol = vec3 (0.6, 0.6, 0.5);
      vn = VaryNf (5. * qHit, vn, 1.);
    } else if (idObj == idRing) {
      objCol = vec3 (0.9, 0.7, 0.4);
      vn = VaryNf (20. * qHit, vn, 1.);
    } else if (idObj == idCol) {
      objCol = vec3 (0.9, 0.7, 0.6);
      vn = VaryNf (20. * qHit, vn, 1.);
    } else if (idObj >= idBrnch && idObj < idFlwr + 4) {
      if (idObj < idFlwr) {
	objCol = mix (vec3 (0.3, 0.7, 0.3), vec3 (0.5, 0.3, 0.1),
           smoothstep (0.02, 0.05, trAge));
	objCol *= (0.7 + 0.3 * clamp (0.7 + 0.6 * cos (11. * qHit.y), 0., 1.));
	a = mod (20. * (atan (qHit.z, qHit.x) / (2. * pi) + 0.5), 1.);
	vn.xz = Rot2D (vn.xz, 0.5 * sin (pi * a));
	vn = VaryNf (50. * ro, vn, 5. * smoothstep (0.03, 0.08, trAge));
      } else {
	objCol = HsvToRgb (vec3 (0.35 * max (0.05 * float (idObj - idFlwr) +
           1. - 1.2 * trBloom, 0.),
	   0.05 + 0.95 * smoothstep (0.15, 0.2, trBloom), 1.)); 
	if (idObj == idFlwr + 3) objCol = mix (vec3 (1., 0., 0.), objCol,
	   smoothstep (0.05, 0.2, trBloom));
	objCol = mix (objCol, vec3 (0.5, 0.3, 0.1), smoothstep (0.9, 1., trBloom));
      }
      objCol = mix (objCol, vec3 (0.8), smoothstep (0.93, 0.98, trAge));
    }
    sh = ObjSShadow (ro, sunDir);
  } else {
    if (rd.y < 0.) {
      sh = 0.7 + 0.3 * ObjSShadow (ro - rd * ro.y / rd.y, sunDir);
    } else sh = 1.;
  }
  if (dstHit < dstFar) {
    col = refl * objCol * (0.3 +
       0.7 * max (dot (vn, sunDir), 0.) * (0.5 + 0.5 * sh) +
       0.3 * pow (max (0., dot (sunDir, reflect (rd, vn))), 64.));
  } else col = sh * BgCol (ro, rd);
  return clamp (col, 0., 1.);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 canvas = iResolution.xy;
  vec2 uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  vec4 mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  mat3 vuMat;
  vec3 ro, rd, vd, u;
  float f, tPath;
  tPath = tCur;
  if (mPtr.z > 0.) tPath = 50. + 50. * mPtr.y;
  SetupTree ();
  ro = 0.5 * (TrackPath (tPath + 0.2) + TrackPath (tPath - 0.2));
  vd = normalize (vec3 (0., 0.5 + 2.5 * min (trAge, 0.8) * szTree, 0.) - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (uv, 1. + 0.03 * length (ro)));
  sunDir = normalize (vec3 (1., 3., 1.));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
