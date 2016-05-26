// Shader downloaded from https://www.shadertoy.com/view/Ms3SzH
// written by shadertoy user dr2
//
// Name: Pannini's Rotunda
// Description: Interactively explore the Pannini projection (see the source)
// "Pannini's Rotunda" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  Interactively explore the Pannini (or Panini) projection, a method for
  reducing distortion in wide-angle images.
  
  The left slider widget (activated by button-down inside its box) controls
  the focal length, starting from extreme wide angle. The right slider
  controls the Pannini factor, with a logarithmic scale and range 0-150
  (approx).

  The green/red button toggles automatic or manual motion and viewing; in
  manual mode the mouse controls view direction.

  Vertical lines remain vertical, but serious distortion occurs at wide
  angles!!

  The scene is based on the earlier "Flame Ascending".
  
  For the maths see: T.K. Sharpless et al (2010)
     (tksharpless.net/vedutismo/Pannini/panini.pdf)

  Relation to standard projections (the cylindrical versions):
  
   x - horizontal coordinate (y coordinate is rectilinear and unaffected)
   a - corresponding azimuth angle
   f - proportional to lens focal length
   p - Pannini factor 

   Pannini:       x = f*(p+1)*sin(a)/(p+cos(a)) 
   Rectlinear:    x = f*tan(a)         (p = 0)
   Stereographic: x = f*2*tan(a/2)     (p = 1)
   Orthographic:  x = f*sin(a)         (p large)
*/

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

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  p.z -= h * clamp (p.z / h, -1., 1.);
  return length (p) - r;
}

float PrCapsShDf (vec3 p, float rIn, float rEx, float h)
{
  float s;
  p.z -= h * clamp (p.z / h, -1., 1.);
  s = length (p);
  return max (s - rEx, rIn - s);
}

float PrFlatDiskDf (vec3 p, float w, float r)
{
  p.x -= w * clamp (p.x / w, -1., 1.);
  return length (p.xy) - r;
}

float PrFlatCylShDf (vec3 p, float w, float rIn, float rEx, float h)
{
  float s;
  p.x -= w * clamp (p.x / w, -1., 1.);
  s = length (p.xy);
  return max (max (s - rEx, rIn - s), abs (p.z) - h);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

const float txRow = 64.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

vec3 sunDir, fBallPos, qHit;
float dmRad, dmLen, dmUpRad, dmUpLen, psgLen, psgWid, psgHt, capRad, wThk, udBase,
   fBallRad, tCur, tCyc, capPos, ltFac, qLenH, qAngH, dstFar;
int idObj, runState;
const int idDm = 1, idDmUp = 2, idPsg = 3, idFlor = 4, idCol = 5, idHot = 6,
  idArch = 7;

vec3 GrndCol (vec3 ro, vec3 rd)
{
  vec3 vn, col;
  vec2 w;
  float f;
  w = 5. * ro.xz;
  f = Fbm2 (w);
  vn = normalize (vec3 (f - Fbm2 (w + vec2 (0.01, 0.)), 0.1,
     f - Fbm2 (w + vec2 (0., 0.01))));
  col = 0.4 * mix (vec3 (0.4, 0.3, 0.1), vec3 (0.4, 0.5, 0.2), f) *
       (1. - 0.1 * Noisefv2 (31. * w));
  col *= 0.1 + 0.9 * max (dot (vn, sunDir), 0.);
  col = mix (col, vec3 (0.05, 0.1, 0.25) + 0.25, pow (1. + rd.y, 32.));
  return col;
}

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col;
  float sd, f;
  if (rd.y > 0.) {
    ro.xz += 2. * tCur;
    sd = max (dot (rd, sunDir), 0.);
    col = vec3 (0.05, 0.1, 0.25) + 0.2 * pow (1. - max (rd.y, 0.), 8.) +
       0.2 * pow (sd, 6.) + 0.4 * min (pow (sd, 256.), 0.3);
    f = Fbm2 (0.05 * (ro.xz + rd.xz * (50. - ro.y) / rd.y));
    col = mix (col, vec3 (1.), clamp (0.1 + 0.8 * f * rd.y, 0., 1.));
  } else {
    sd = - ro.y / rd.y;
    ro += sd * rd;
    col = GrndCol (ro, rd);
  }
  return col;
}

float ObjDf (vec3 p)
{
  vec3 q, qq;
  float dMin, d, dc, dm, dr;
  dMin = dstFar;
  q = p;
  qLenH = length (q.xz);
  qAngH = atan (q.z, - q.x) / (2. * pi);
  dr = (q.y > dmLen) ? abs (fract (18. * (atan (q.y - dmLen, qLenH) /
     (2. * pi) - 0.25)) - 0.5) : 2. * abs (abs (q.y / dmLen - 0.5) - 0.5);
  dr = wThk * clamp (4. * min (dr, abs (fract (8. * qAngH) - 0.5)) - 0.1, 0., 0.25);
  dm = max (PrCapsShDf (q.xzy, dmRad - wThk + dr, dmRad - dr, dmLen),
     max (0.14 * dmRad - length (p.xz), - q.y));
  q.xz = Rot2D (q.xz, 2. * pi * (floor (4. * qAngH) + 0.5) / 4.);
  qq = q;
  q.x -= wThk - dmRad;
  d = max (PrFlatCylShDf (q.yzx, psgHt, psgWid - 1.3 * wThk,
     psgWid - 0.9 * wThk, wThk), - q.y); 
  if (d < dMin) { dMin = d;  idObj = idArch;  qHit = q; }
  q.x -= - psgLen;
  dc = PrFlatDiskDf (q.yzx, psgHt, psgWid - wThk);
  dr = wThk * clamp (min (4. * abs (fract ((q.x - 0.5 * psgLen) /
     (0.95 * psgLen)) - 0.5),
     8. * abs (fract ((q.y + psgHt) / (1.95 * psgHt)) - 0.5)) - 0.2, 0., 0.25);
  d = max (max (PrFlatCylShDf (q.yzx, psgHt, psgWid - wThk, psgWid - dr, psgLen),
     dmRad - 0.5 * wThk - qLenH), - q.y);
  if (d < dMin) { dMin = d;  idObj = idPsg;  qHit = q; }
  q = p;
  d = max (dm, - dc);
  if (d < dMin) { dMin = d;  idObj = idDm;  qHit = q; }
  q.y -= udBase;
  d = max (max (PrCapsShDf (q.xzy, dmUpRad - wThk, dmUpRad, dmUpLen), - q.y),
     0.05 * dmRad - qLenH);
  if (d < dMin) { dMin = d;  idObj = idDmUp;  qHit = q; }
  q = p;
  d = PrCylDf (q.xzy, 6. * dmRad, 0.01 * dmLen);
  d = max (d, capRad - qLenH);
  q.y -= capPos;
  d = min (d, PrCylDf (q.xzy, capRad, 0.05 * dmLen));
  if (d < dMin) { dMin = d;  idObj = idFlor;  qHit = qq; }
  q = p;
  q.y -= -0.2 * dmLen;
  d = max (PrCylDf (q.xzy, capRad, 0.2 * dmLen), 0.99 * capRad - qLenH);
  if (d < dMin) { dMin = d;  idObj = idHot; }
  q = p;
  q.y -= dmLen;
  q.xz = Rot2D (q.xz, 2. * pi * (floor (8. * qAngH) + 0.5) / 8.);
  q.xy -= vec2 (2. * wThk, -0.5 * dmLen);
  d = PrCapsDf (q.xzy, 0.035 * dmRad, 0.5 * dmLen);
  if (d < dMin) { dMin = d;  idObj = idCol;  qHit = q; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 120; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.0005 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  const vec3 e = vec3 (0.0001, -0.0001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float FBallHit (vec3 ro, vec3 rd, vec3 p, float s)
{
  vec3 v;
  float b, d;
  v = ro - p;
  b = dot (rd, v);
  d = b * b + s * s - dot (v, v);
  return (d >= 0.) ? - b - sqrt (d) : dstFar;
}

float FBallLum (vec3 ro, vec3 rd, float dHit)
{
  vec3 p, q, dp;
  float g, s, f, ri, t;
  p = ro + dHit * rd - fBallPos;
  dp = 0.033 * fBallRad * rd;
  ri = 0.9 / fBallRad;
  t = 3. * tCur;
  g = 0.;
  for (int i = 0; i < 30; i ++) {
    p += dp;
    q = 20. * p;
    q.y -= t;
    f = Fbm3 (q);
    q = 35. * p;
    q.y -= 1.9 * t;
    f += Fbm3 (q);
    s = length (p);
    g += max (0.075 * max (1. - s * ri, 0.) * (f - 1.1), 0.);
    if (s > fBallRad || g > 1.) break;
  }
  return g;
}

float ObjAO (vec3 ro, vec3 rd)
{
  float ao, d;
  ao = 0.;
  for (int j = 0; j < 8; j ++) {
    d = 0.1 + float (j) / 8.;
    ao += max (0., d - 3. * ObjDf (ro + rd * d));
  }
  return 0.3 + 0.7 * clamp (1. - 0.1 * ao, 0., 1.);
}

void SetConfig ()
{
  float tIn, tm;
  dmRad = 1.2;
  dmLen = 1.3;
  dmUpRad = 0.17 * dmRad;
  dmUpLen = 0.08 * dmLen;
  psgLen = 0.4 * dmRad;
  psgHt = 0.55 * dmLen;
  psgWid = 0.22 * dmLen;
  capRad = 0.3 * dmRad;
  wThk = 0.06;
  udBase = dmLen + sqrt (dmRad * dmRad - dmUpRad * dmUpRad) - wThk;
  fBallRad = 0.3;
  tCyc = 15.;
  tIn = mod (tCur / tCyc, 1.);
  capPos = -0.04 * dmLen - 0.3 * dmLen * SmoothBump (0.05, 0.15, 0.05, tIn);
  ltFac = SmoothBump (0.1, 0.95, 0.05, tIn);
  fBallPos = vec3 (0.);
  tm = 0.07;
  fBallPos.y = fBallRad + capPos + (dmLen + dmRad - fBallRad) *
     ((tIn > tm) ? (tIn - tm) / (1. - tm) : (tm - tIn) / tm);
}

vec3 TrackPath (float t)
{
  vec3 p;
  float ti[6], a, rHi, rLo, trkCyc;
  ti[0] = 0.;
  ti[1] = ti[0] + 0.05;
  ti[2] = ti[1] + 0.2;
  ti[3] = ti[2] + 0.5;
  ti[4] = ti[3] + 0.2;
  ti[5] = ti[4] + 0.05;
  trkCyc = 4. * tCyc;
  a = floor (t / trkCyc);
  t = fract (t / trkCyc);
  if      (t < ti[1]) a += 0.25 * (t - ti[0]) / (ti[1] - ti[0]);
  else if (t < ti[2]) a += 0.25;
  else if (t < ti[3]) a += 0.25 + 0.5 * (t - ti[2]) / (ti[3] - ti[2]);
  else if (t < ti[4]) a += 0.75;
  else if (t < ti[5]) a += 0.75 + 0.25 * (t - ti[4]) / (ti[5] - ti[4]);
  rHi = 3.5 * dmRad;
  rLo = 0.8 * dmRad;
  p = vec3 (0., 0.8 * psgHt, - rHi + (rHi - rLo) * SmoothBump (0.15, 0.85, 0.1, t));
  p.xz = Rot2D (p.xz, pi * a);
  return p;
}

bool ChkInside ()
{
  vec3 q;
  bool isIn;
  isIn = false;
  if (idObj == idDm) {
    q = qHit;
    q.y -= dmLen;
    isIn = (((q.y < 0.) ? qLenH : length (q)) < dmRad - 0.3 * wThk);
  } else if (idObj == idDmUp) {
    q = qHit;
    q.y -= dmUpLen;
    isIn = (((q.y < 0.) ? qLenH : length (q)) < dmUpRad - 0.01 * wThk);
  } else if (idObj == idPsg) {
    q = qHit;
    q.y -= psgHt;
    isIn = (((q.y < 0.) ? abs (qHit.z) : length (q.yz)) < psgWid - 0.9 * wThk);
  } else if (idObj == idFlor) {
    isIn = (abs (qHit.z) < psgWid &&
       abs (qHit.x) < dmRad + 2. * psgLen - wThk || qLenH < dmRad);
  } else if (idObj == idCol || idObj == idHot || idObj == idArch) isIn = true;
  return isIn;
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, float zmVar, float pnVar)
{
  vec4 wgBx[3];
  vec2 ust;
  float asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (0.41 * asp, 0.1, 0.012 * asp, 0.15);
  wgBx[1] = vec4 (0.47 * asp, 0.1, 0.012 * asp, 0.15);
  wgBx[2] = vec4 (0.44 * asp, -0.15, 0.025, 0.);
  ust = abs (0.5 * uv - wgBx[0].xy) - wgBx[0].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.8);
  ust = 0.5 * uv - wgBx[0].xy;
  ust.y -= (zmVar - 0.5) * 2. * wgBx[0].w;
  ust = abs (ust) - 0.6 * wgBx[0].zz;
  if (abs (max (ust.x, ust.y)) * canvas.y < 2.) col = vec3 (1., 0.3, 1.);
  ust = abs (0.5 * uv - wgBx[1].xy) - wgBx[1].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.8);
  ust = 0.5 * uv - wgBx[1].xy;
  ust.y -= (pnVar - 0.5) * 2. * wgBx[1].w;
  ust = abs (ust) - 0.6 * wgBx[1].zz;
  if (abs (max (ust.x, ust.y)) * canvas.y < 2.) col =
     (pnVar > 0.3) ? vec3 (1., 0., 0.1) : ((pnVar > 0.1) ?
     vec3 (1., 1., 0.1) : vec3 (0.1, 1., 0.1));
  if (length (0.5 * uv - wgBx[2].xy) < wgBx[2].z)
     col = (runState > 0) ? vec3 (0.2, 0.7, 0.2) : vec3 (0.7, 0.2, 0.2);
  return col;
}

vec4 ObjCol (vec3 ro, bool inside)
{
  vec4 objCol;
  vec2 u;
  float f;
  if (inside) {
    if (idObj == idDm || idObj == idDmUp) objCol = vec4 (0.4, 0.1, 0.1, 0.3);
    if (idObj == idDm) {
      if (((qHit.y < dmLen) ? qLenH : length (qHit - vec3 (0., dmLen, 0.))) >
         dmRad - 0.77 * wThk) {
        if (qHit.y < dmLen) {
          u = vec2 (1.5 * (fract (4. * qAngH + 0.5) - 0.5), qHit.y / dmLen - 0.6);
          u *= u;
          objCol.rgb = mix (objCol.rgb, vec3 (0.3, 0.3, 1.),
             SmoothBump (0.01, 0.025, 0.005,
             abs (80. * dot (u, u) - 0.14) - 0.005));
        }
      } else objCol = vec4 (0.5, 0.5, 0.8, 0.3);
    } else if (idObj == idFlor) {
      f = SmoothBump (0.7, 1.1, 0.1, Fbm2 (17. * ro.xz));
      objCol = vec4 (mix (vec3 (0.3, 0.8, 0.4), vec3 (0.2, 0.6, 0.3), f),
         1. - 0.95 * f);
    } else if (idObj == idCol) {
      objCol = vec4 (0.7, 0.7, 0., 0.3) * (0.7 +
         0.3 * sin (pi * mod (20. * (atan (qHit.x, qHit.z) / (2. * pi) + 0.5 +
           qHit.y / dmLen), 1.)));
    } else if (idObj == idHot) objCol = vec4 (1., 0., 0., 0.) *
       (0.3 + 0.7 * Noiseff (50. * tCur));
    else if (idObj == idPsg) objCol = vec4 (0.3, 0.3, 1., 0.3);
    else if (idObj == idArch) objCol = vec4 (0.3, 0.3, 1., 0.3);
  } else {
    if (idObj == idDm || idObj == idPsg) objCol = vec4 (0.85, 0.8, 0.8, 0.7);
  }
  return objCol;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 roo, col, vn, flmCol, ltDir, ltVec;
  float dstHit, dstFbHit, fIntens, ltDist, f;
  int idObjT;
  bool isIn, isBg;
  dstFbHit = FBallHit (ro, rd, fBallPos, fBallRad);
  roo = ro;
  dstHit = ObjRay (ro, rd);
  isBg = false;
  if (dstHit < dstFar) {
    idObjT = idObj;
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    isIn = ChkInside ();
    objCol = ObjCol (ro, isIn);
    if (isIn) {
      if (idObj == idFlor) {
        f = fract (5. * qLenH / dmRad) - 0.15;
        if (abs (f) < 0.04) {
          vn.xz -= 20. * f * ro.xz / qLenH;
          vn = normalize (vn);
        }
      }
      ltVec = fBallPos - ro;
      ltDist = length (ltVec);
      ltDir = (fBallPos - ro) / ltDist;
      f = max (dot (vn, ltDir), 0.);
      col = objCol.rgb * (0.1 + vec3 (1., 0.8, 0.8) * f * (0.1 + 0.9 * f) +
         vec3 (1., 0., 0.7) * objCol.a *
         pow (max (0., dot (ltDir, reflect (rd, vn))), 64.));
      if (idObj != idHot) col *= (0.2 + 0.8 * ltFac) /
         (1. + 0.5 * pow (ltDist, 4.));
    } else {
      if (idObj == idDmUp || idObj == idDm && qHit.y > dmLen &&
         length (qHit - vec3 (0., dmLen, 0.)) - dmRad < -0.23 * wThk) {
        rd = reflect (rd, vn);
        isBg = true;
      } else if (idObj == idFlor) col = GrndCol (ro, rd);
      else col = objCol.rgb * (0.3 +
         0.2 * max (dot (vn, sunDir * vec3 (-1., 1., -1.)), 0.) +
         0.7 * max (0., max (dot (vn, sunDir), 0.)) +
         objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 32.));
    }
  } else isBg = true;
  if (isBg) col = BgCol (ro, rd);
  col *= ObjAO (ro, vn);
  if (dstFbHit < min (dstHit, dstFar)) {
    fIntens = (dstFbHit < dstFar) ? FBallLum (roo, rd, dstFbHit) : 0.;
    f = clamp (0.7 * fIntens, 0., 1.);
    f *= f;
    flmCol = 1.5 * (0.7 + 0.3 * Noiseff (20. * tCur)) *
       mix (vec3 (1., 0.1, 0.1), vec3 (1., 1., 0.5), f * f);
    col = mix (col, flmCol, ltFac * min (fIntens * fIntens, 1.));
  }
  col = pow (clamp (col, 0., 1.), vec3 (0.7));
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 stDat, wgBx[2];
  mat3 vuMat;
  vec3 ro, rd, vd, u, col;
  vec2 canvas, uv, ori, ca, sa;
  float el, az, f, a, asp, zmVar, pnVar, zmFac, pnFac, tRun;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  SetConfig ();
  stDat = Loadv4 (0);
  zmVar = stDat.x;
  pnVar = stDat.y;
  el = stDat.z;
  az = stDat.w;
  stDat = Loadv4 (1);
  runState = int (stDat.y);
  tRun = stDat.z;
  asp = canvas.x / canvas.y;
  ro = TrackPath (tRun);
  if (runState > 0) {
    vd = mix (vec3 (- ro.x, 0.3 * dmLen, - ro.z), fBallPos - ro, 
      smoothstep (-0.5, 0., 1. - length (ro.xz) / dmRad));
    vd = normalize (vd);
    u = - vd.y * vd;
    f = 1. / sqrt (1. - vd.y * vd.y);
    vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  } else {
    ori = vec2 (el, az - atan (ro.x, - ro.z));
    ca = cos (ori);
    sa = sin (ori);
    vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
       mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  }
  dstFar = 20.;
  zmFac = 0.2 + 2.8 * zmVar;
  pnFac = exp (5. * pnVar) - 1.;  
  a = atan (uv.x / (asp * zmFac));
  rd = vuMat * normalize (vec3 (((1. + pnFac) * sin (a) / (pnFac + cos (a))) * asp,
     uv.y / zmFac, 1.));
  a = 0.022 * pi * tCur;
  sunDir = normalize (vec3 (cos (a), 3. + cos (0.55 * a), sin (a)));
  col = ShowScene (ro, rd);
  col = ShowWg (uv, canvas, col, zmVar, pnVar);
  fragColor = vec4 (col, 1.);
}
