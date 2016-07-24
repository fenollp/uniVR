// Shader downloaded from https://www.shadertoy.com/view/ldtXD8
// written by shadertoy user dr2
//
// Name: Thomas X3
// Description: Three little steam locomotives
// "Thomas X3" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Thomas is a popular toy engine (many design changes have been made).

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

float PrBoxDf (vec3 p, vec3 b)
{
  vec3 d;
  d = abs (p) - b;
  return min (max (d.x, max (d.y, d.z)), 0.) + length (max (d, 0.));
}

float PrOBoxDf (vec3 p, vec3 b)
{
  return length (max (abs (p) - b, 0.));
}

float PrBox2Df (vec2 p, vec2 b)
{
  vec2 d;
  d = abs (p) - b;
  return min (max (d.x, d.y), 0.) + length (max (d, 0.));
}

float PrOBox2Df (vec2 p, vec2 b)
{
  return length (max (abs (p) - b, 0.));
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

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

vec4 pCar[3];
vec3 qHit, ltDir;
vec2 rlSize;
float ti[13], dstFar, tCur, szFac, trSpd, rgHSize, trkWid, tCyc;
int idObj, idObjGrp;

const int idEng = 1, idCabin = 2, idCoal = 3, idBase = 4, idBand = 4, idAxle = 4,
   idRoof = 6, idWheel = 7, idSpoke = 7, idCrod = 8, idFunl = 9, idFunt = 10,
   idStripe = 10, idLamp = 11, idCpl = 12, idGrnd = 21, idTflr = 22, idRail = 23;
const int dirNS = 0, dirEW = 1, dirSW = 2, dirNW = 3, dirSE = 4, dirNE = 5,
   dirX = 6;

float TrackDf (vec3 p)
{
  vec3 q, qq;
  vec2 ip;
  float dMin, d, db, dc, sqWid;
  int indx, isq;
  dMin = dstFar;
  sqWid = 0.4999;
  ip = floor (p.xz);
  db = PrOBox2Df (p.xz, vec2 (2. * sqWid * rgHSize));
  q = p;
  q.xz = fract (q.xz) - vec2 (0.5);
  indx = -1;
  isq = int (2. * rgHSize * mod (ip.y + rgHSize, 2. * rgHSize) +
     mod (ip.x + rgHSize, 2. * rgHSize));
  if (isq == 6 || isq == 8 || isq == 20 || isq == 23 || isq == 26 ||
     isq == 29) indx = dirNS;
  else if (isq == 1 || isq == 13 || isq == 15 || isq == 16 || isq == 33 ||
     isq == 34) indx = dirEW;
  else if (isq == 35) indx = dirSW;
  else if (isq == 2 || isq == 17) indx = dirNW;
  else if (isq == 12 || isq == 32) indx = dirSE;
  else if (isq == 0) indx = dirNE;
  else if (isq == 14) indx = dirX;
  d = dstFar;
  if (indx >= 0 && indx <= dirX) {
    q.y -= 0.5 * rlSize.y;
    dc = max (db, PrBox2Df (q.xz, vec2 (sqWid)));
    if (indx < dirX) {
      if (indx == dirEW) q.xz = q.zx;
      else if (indx == dirNW) q.z *= -1.;
      else if (indx == dirSE) q.x *= -1.;
      else if (indx == dirNE) q.xz *= -1.;
      if (indx <= dirEW) {
        q.z += 0.5;  q.x = abs (q.x);
      } else {
        q.xz += 0.5;  q.x = abs (length (q.xz) - 0.5);
      }
      d = max (PrOBox2Df (q.xy, vec2 (2. * trkWid, 0.5 * rlSize.y)), dc);
      if (d < dMin) { dMin = d;  idObj = idTflr;  qHit = q; }
      q.xy -= vec2 (trkWid, rlSize.y);
      d = max (PrOBox2Df (q.xy, rlSize), dc);
      if (d < dMin) { dMin = d;  idObj = idRail;  qHit = q; }
    } else {
      qq = q;  q.x = abs (q.x);  q.z += 0.5;
      d = PrOBox2Df (q.xy, vec2 (2. * trkWid, 0.5 * rlSize.y));
      q = qq;  q.xz = q.zx;   q.x = abs (q.x);  q.z += 0.5;
      d = max (min (d, PrOBox2Df (q.xy, vec2 (2. * trkWid, 0.5 * rlSize.y))), dc);
      if (d < dMin) { dMin = d;  idObj = idTflr;  qHit = q; }
      q = qq;  q.y -= rlSize.y;  qq = q;
      q.x = abs (q.x) - trkWid;  q.z += 0.5;
      d = PrOBox2Df (q.xy, rlSize);
      q = qq;  q.xz = q.zx;  q.x = abs (q.x) - trkWid;  q.z += 0.5;
      d = min (d, PrOBox2Df (q.xy, rlSize));
      q = qq;  q.xz = abs (q.xz) - trkWid + 1.75 * rlSize.x;
      d = max (max (d, - min (PrBox2Df (q.xz, vec2 (trkWid, 0.75 * rlSize.x)),
         PrBox2Df (q.xz, vec2 (0.75 * rlSize.x, trkWid)))), dc);
      if (d < dMin) { dMin = d;  idObj = idRail;  qHit = q; }
    }
  }
  return dMin;
}

float TrackRay (vec3 ro, vec3 rd)
{
  vec3 p;
  vec2 srd, dda, h;
  float dHit, d;
  srd = - sign (rd.xz);
  dda = - srd / (rd.xz + 0.0001);
  dHit = max (0., PrBox2Df (ro.xz, vec2 (rgHSize)));
  for (int j = 0; j < 200; j ++) {
    p = ro + dHit * rd;
    h = fract (dda * fract (srd * p.xz));
    d = TrackDf (p);
    dHit += min (d, 0.001 + max (0., min (h.x, h.y)));
    if (d < 0.0001 || dHit > dstFar || p.y < 0.) break;
  }
  if (d > 0.0001) dHit = dstFar;
  return dHit;
}

float EngDf (vec3 p, float dMin)
{
  vec3 q;
  float d, aw, a, sx, wRad, tw;
  wRad = 0.8;
  tw = 214. * szFac * trkWid;
  q = p;
  q -= vec3 (0., -0.2, 0.5);
  d = max (PrCapsDf (q, 1., 2.), - (q.z + 1.7));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idEng; }
  q = p;  q.z = abs (q.z - 0.85);  q -= vec3 (0., -0.2, 1.8);
  d = PrCylDf (q, 1.05, 0.05);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idBand; }
  q = p;  q -= vec3 (0., -1.3, -0.25);
  d = PrBoxDf (q, vec3 (1., 0.1, 3.2));
  q = p;  q -= vec3 (0., -1.4, 3.);
  d = min (d, PrBoxDf (q, vec3 (1.1, 0.2, 0.07)));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idBase; }
  q.x = abs (q.x);  q -= vec3 (0.6, 0., 0.1);
  d = PrCylDf (q, 0.2, 0.1);
  q = p;  q -= vec3 (0., -2.4, -1.75);
  d = min (d, max (PrCylDf (q, 4., 0.65), - (q.y - 3.75)));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idRoof; }
  q = p;  q -= vec3 (0., 0.01, -1.75);
  d = max (max (PrBoxDf (q, vec3 (1., 1.4, 0.6)),
     - PrBoxDf (q - vec3 (0., 0., -0.2), vec3 (0.95, 1.3, 0.65))),
     - PrBoxDf (q - vec3 (0., 0.7, 0.), vec3 (1.1, 0.4, 0.5)));
  q.x = abs (q.x);  q -= vec3 (0.4, 1., 0.4);
  d = max (d, - PrBoxDf (q, vec3 (0.35, 0.15, 0.3)));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idCabin;  qHit = q; }
  q = p;  q -= vec3 (0., -0.5, -3.15);
  d = PrBoxDf (q, vec3 (1., 0.7, 0.3));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idCoal;  qHit = q; }
  q = p;  q -= vec3 (0., -1.4, -3.5);
  d = PrCylDf (q.xzy, 0.4, 0.03);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idCpl; }
  q = p;  q.xz = abs (q.xz);  q -= vec3 (tw - 0.12, -1.4, 1.1);
  d = PrCylDf (q.zyx, wRad, 0.1);
  aw = - trSpd * tCur / (szFac * wRad);
  if (d < dMin) {
    d = min (max (min (d, PrCylDf (q.zyx - vec3 (0.,0., -0.07), wRad + 0.05, 0.03)),
       - PrCylDf (q.zyx, wRad - 0.1, 0.12)), PrCylDf (q.zyx, 0.15, 0.10));
    if (d < dMin) { dMin = d;  idObj = idObjGrp + idWheel; }
    q = p;  q.x = abs (q.x);  q -= vec3 (tw - 0.17, -1.4, 1.1 * sign (q.z));
    q.yz = q.yz * cos (aw) + q.zy * sin (aw) * vec2 (-1., 1.);  
    a = floor ((atan (q.y, q.z) + pi) * 8. / (2. * pi) + 0.5) / 8.;
    q.yz = q.yz * cos (2. * pi * a) + q.zy * sin (2. * pi * a) * vec2 (-1., 1.);
    q.z += 0.5 * wRad;
    d = PrCylDf (q, 0.05, 0.5 * wRad);
    if (d < dMin) { dMin = d;  idObj = idObjGrp + idSpoke; }
  }
  q = p;  sx = sign (q.x);  q.x = abs (q.x);
  q -= vec3 (tw + 0.08, -1.4, 0.);
  aw -= 0.5 * pi * sx; 
  q.yz -= 0.3 * vec2 (cos (aw), - sin (aw));
  d = PrCylDf (q, 0.04, 1.2);
  q.z = abs (q.z);  q -= vec3 (-0.1, 0., 1.1);
  d = min (d, PrCylDf (q.zyx, 0.06, 0.15));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idCrod; }
  q = p;  q.z = abs (q.z);  q -= vec3 (0., -1.4, 1.1);
  d = PrCylDf (q.zyx, 0.1, tw - 0.1);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idAxle; }
  q = p;  q -= vec3 (0., 1.1, 2.15);  d = PrCylDf (q.xzy, 0.3, 0.5);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idFunl; }
  q = p;  q -= vec3 (0., 1.5, 2.15);
  d = max (PrCylDf (q.xzy, 0.4, 0.15), - PrCylDf (q.xzy, 0.3, 0.2));
  q = p;  q -= vec3 (0., 0.8, 0.55);
  d = min (d, PrCapsDf (q.xzy, 0.3, 0.2));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idFunt; }
  q = p;  q.x = abs (q.x);  q -= vec3 (1., -0.2, 0.85);
  d = PrBoxDf (q, vec3 (0.05, 0.1, 1.8));
  q = p;  q.x = abs (q.x);  q -= vec3 (1., -0.2, -1.75);
  d = min (d, PrBoxDf (q, vec3 (0.05, 0.1, 0.6)));
  q = p;  q.x = abs (q.x);  q -= vec3 (1., -0.2, -3.15);
  d = min (d, PrBoxDf (q, vec3 (0.05, 0.1, 0.3)));
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idStripe; }
  q = p;  q -= vec3 (0., -0.2, 3.5);
  d = PrCylDf (q, 0.2, 0.1);
  if (d < dMin) { dMin = d;  idObj = idObjGrp + idLamp; }
  return dMin;
}

float SceneDf (vec3 p)
{
  vec3 q;
  float dMin, d, db;
  dMin = dstFar;
  db = PrOBox2Df (p.xz, vec2 (0.999 * rgHSize));
  d = abs (p.y + 0.001) - 0.001;
  d = max (d, db);
  if (d < dMin) { dMin = d;  idObj = idGrnd;  qHit = p; }
  dMin /= szFac;
  for (int k = 0; k < 3; k ++) {
    q = p;
    q -= pCar[k].xyz;
    q /= szFac;
    d = PrCylDf (q.xzy, 4., 2.2);
    if (d < dMin) {
      q.xz = Rot2D (q.xz, pCar[k].w);
      idObjGrp = (k + 1) * 256;
      dMin = EngDf (q, dMin);
    }
 }
  dMin *= szFac;
  return dMin;
}

float SceneRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = SceneDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.0001 || dHit > dstFar) break;
  }
  return dHit;
}

float ObjDf (vec3 p)
{
  float dMin;
  dMin = dstFar;
  dMin = min (dMin, TrackDf (p));
  dMin = min (dMin, SceneDf (p));
  return dMin;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = 0.0001 * vec3 (1., -1., 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

vec4 ObjCol (vec3 ro, vec3 rd, vec3 n)
{
  vec4 objCol;
  int ig, id;
  const vec4 cR = vec4 (1., 0., 0., 1.), cY = vec4 (1., 1., 0., 1.),
     cG = vec4 (0., 1., 0., 1.), cB = vec4 (0., 0., 1., 1.),
     cBlk = vec4 (0.03, 0.03, 0.03, 0.1), cLB = vec4 (0.4, 0.4, 1., 1.);
  objCol = vec4 (0.);
  if (idObj <= idRail) {
    if (idObj == idGrnd) objCol = vec4 (mix (vec3 (0.4, 0.25, 0.1),
        vec3 (0.3, 0.6, 0.3), smoothstep (0.8, 1.1, Fbm2 (5. * ro.xz))) *
        (1. - 0.1 * Noisefv2 (30. * ro.xz)), 0.05);
    else if (idObj == idTflr) objCol = vec4 (0.4, 0.5, 0.4, 0.1) *
       (1. - 0.3 * Fbm2 (90. * ro.xz));
    else if (idObj == idRail) objCol = vec4 (0.7, 0.7, 0.7, 0.5);
  } else {
    ig = idObj / 256;
    id = idObj - 256 * ig;
    if (id == idEng) objCol = (ig == 1) ? cG : ((ig == 2) ? cY : cR);
    else if (id == idCabin) objCol = (qHit.y > -1.3) ? cLB : cB;
    else if (id == idCoal)
       objCol = (qHit.y > 0.3) ? ((n.y > 0.9) ? cBlk : cLB) : cB;
    else if (id == idBase || id == idBand || id == idAxle)
       objCol = vec4 (0.3, 0.2, 0.2, 0.3);
    else if (id == idRoof || id == idCpl || id == idFunl && n.y <= 0.9)
       objCol = (ig == 3) ? cG : ((ig == 1) ? cY : cR);
    else if (id == idFunl && n.y > 0.9) objCol = cBlk;
    else if (id == idWheel || id == idSpoke) objCol = vec4 (0.6, 0.7, 0.7, 0.5);
    else if (id == idCrod) objCol = cY;
    else if (id == idStripe || id == idFunt) objCol = (ig == 2) ? cG :
       ((ig == 3) ? cY : cR);
    else if (id == idLamp) objCol = (mod (tCur + 0.667 * float (ig), 2.) < 1.) ?
       vec4 (1., 1., 1., -1.) : vec4 (0.6, 0.6, 0.6, -1.);
  }
  return objCol;
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.02;
  for (int j = 0; j < 20; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 20. * h / d));
    d += min (0.05, 3. * h);
    if (h < 0.001) break;
  }
  return 0.5 + 0.5 * sh;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 qHitT, col, vn;
  float dstHit, d, sh;
  int idObjT;
  dstHit = dstFar;
  d = TrackRay (ro, rd);
  if (d < dstHit) dstHit = d;
  idObjT = idObj;
  qHitT = qHit;
  d = SceneRay (ro, rd);
  if (d < dstHit) dstHit = d;
  else {
    idObj = idObjT;
    qHit = qHitT;
  }
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    if (idObj == idTflr) vn = VaryNf (100. * ro, vn, 2.);
    else if (idObj == idGrnd) vn = VaryNf (5. * ro, vn, 0.5);
    objCol = ObjCol (ro, rd, vn);
    col = objCol.rgb;
    if (objCol.a >= 0.) {
      sh = ObjSShadow (ro, ltDir);
      col = col * (0.3 + 0.7 * sh * max (dot (vn, ltDir), 0.)) +
         objCol.a * sh * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
    }
  } else col = vec3 (0.1, 0.1, 0.2);
  return clamp (col, 0., 1.);
}

#define SLIN(k,d) ti[k + 1] = ti[k] + d
#define SCRV(k) ti[k + 1] = ti[k] + tc

void TrSetup ()
{
  float tc;
  tc = 0.25 * pi;
  ti[0] = 0.;
  SCRV(0);   SLIN(1, 1.);  SCRV(2);  SLIN(3, 4.);  SCRV(4);  SLIN(5, 2.);
  SCRV(6);  SLIN(7, 2.);  SCRV(8);  SLIN(9, 4.);  SCRV(10);  SLIN(11, 1.);
  tCyc = ti[12];
}

vec2 TrackPath (float t)
{
  vec2 r, dr;
  float tc, a;
  tc = 0.25 * pi;
  t = mod (t, tCyc);
  dr = vec2 (0.);
  a = 99.;
  if (t < ti[1]) {
    r = vec2 (0., 0.);  dr.xy = vec2 (1.);  a = 0.5 * tc + 0.25 * (t - ti[0]);
  } else if (t < ti[2]) {
    r = vec2 (1., 0.5);  dr.x = (t - ti[1]);
  } else if (t < ti[3]) {
    r = vec2 (2., 0.);  dr.y = 1.;  a = 0.75 * tc + 0.25 * (t - ti[2]);
  } else if (t < ti[4]) {
    r = vec2 (2.5, 1.);  dr.y = (t - ti[3]);
  } else if (t < ti[5]) {
    r = vec2 (2., 5.);  dr.x = 1.;  a = 0.5 * tc - 0.25 * (t - ti[4]);
  } else if (t < ti[6]) {
    r = vec2 (3., 5.5);  dr.x = (t - ti[5]);
  } else if (t < ti[7]) {
    r = vec2 (5., 5.);  a = 0.25 * tc - 0.25 * (t - ti[6]);
  } else if (t < ti[8]) {
    r = vec2 (5.5, 5.);  dr.y = - (t - ti[7]);
  } else if (t < ti[9]) {
    r = vec2 (5., 2.);  dr.y = 1.;  a = 0. * tc - 0.25 * (t - ti[8]);
  } else if (t < ti[10]) {
    r = vec2 (5., 2.5);  dr.x = - (t - ti[9]);
  } else if (t < ti[11]) {
    r = vec2 (0., 2.);  dr.x = 1.;  a = 0.25 * tc + 0.25 * (t - ti[10]);
  } else if (t < ti[12]) {
    r = vec2 (0.5, 2.);  dr.y = - (t - ti[11]);
  }
  if (a != 99.) {
    a *= 2. * pi / tc;
    r += 0.5 * vec2 (cos (a), sin (a));
  }
  r += dr - rgHSize;
  return r;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr, pc;
  vec3 ro, rd, col, u, vd;
  vec2 canvas, uv, uvs, ori, ca, sa, vo;
  float el, az, zmFac, t, f;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uvs = uv;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  dstFar = 40.;
  ltDir = normalize (vec3 (1., 2., -1.));
  rgHSize = 3.;
  szFac = 0.07;
  rlSize = vec2 (0.005, 0.01);
  trkWid = 0.095;
  trSpd = 0.8;
  TrSetup ();
  for (int k = 0; k < 3; k ++) {
    t = trSpd * tCur - float (k) * tCyc / 3.;
    pCar[k].xz = TrackPath (t);
    pCar[k].y = 3. * rlSize.y + 0.15;
    vo = TrackPath (t + 0.01) - pCar[k].xz;
    pCar[k].w = atan (vo.x, vo.y);
  }
  if (length (uvs) < 1.5 * SmoothBump (0.2, 0.7, 0.04, mod (0.05 * tCur, 1.))) {
    az = 0.01;
    el = 0.1 * pi;
    if (mPtr.z > 0.) {
      az -= 2. * pi * mPtr.x;
      el = clamp (el - pi * mPtr.y, 0.02 * pi, 0.45 * pi);
    }
    ori = vec2 (el, az);
    ca = cos (ori);
    sa = sin (ori);
    vuMat = mat3 (ca.y, 0., sa.y, 0., 1., 0., - sa.y, 0., ca.y) *
            mat3 (1., 0., 0., 0., ca.x, sa.x, 0., - sa.x, ca.x);
    ro = vuMat * vec3 (0., 0., -15.);
    zmFac = 8.;
  } else {
    t = mod (0.1 * tCur, 3.);
    pc = (t < 1.) ? pCar[0] : ((t < 2.) ? pCar[1] : pCar[2]);
    ro = vec3 (0., 1., -5.);
    vd = normalize (pc.xyz - ro);
    u = - vd.y * vd;
    f = 1. / sqrt (1. - vd.y * vd.y);
    vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
    zmFac = 6.;
  }
  rd = vuMat * normalize (vec3 (uv, zmFac));
  col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}


