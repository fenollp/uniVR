// Shader downloaded from https://www.shadertoy.com/view/llfGR4
// written by shadertoy user dr2
//
// Name: Seabird
// Description: Just a weird bird fishing.
// "Seabird" by dr2 - 2014
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

float Hashfv2 (vec2 p)
{
  return fract (sin (dot (p, cHashA3.xy)) * cHashM);
}

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

float Noisefv3 (vec3 p)
{
  vec3 i = floor (p);
  vec3 f = fract (p);
  f = f * f * (3. - 2. * f);
  float q = dot (i, cHashA3);
  vec4 t1 = Hashv4f (q);
  vec4 t2 = Hashv4f (q + cHashA3.z);
  return mix (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
     mix (mix (t2.x, t2.y, f.x), mix (t2.z, t2.w, f.x), f.y), f.z);
}

float SmoothMin (float a, float b, float r)
{
  float h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
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

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrFlatCylDf (vec3 p, float rhi, float rlo, float h)
{
  return max (length (p.xy - vec2 (rhi *
     clamp (p.x / rhi, -1., 1.), 0.)) - rlo, abs (p.z) - h);
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  return length (vec2 (length (p.xy) - rc, p.z)) - ri;
}

int idObj;
mat3 bdMat, birdMat;
vec3 bdPos, birdPos, fltBox, qHit, sunDir;
float tCur, birdVel, birdLen, legAng;
const float dstFar = 100.;
const int idWing = 21, idBdy = 22, idEye = 23, idBk = 24, idLeg = 25;

vec3 SkyBg (vec3 rd)
{
  const vec3 sbCol = vec3 (0.2, 0.25, 0.7);
  vec3 col;
  col = sbCol + 0.2 * pow (1. - max (rd.y, 0.), 5.);
  return col;
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  const float skyHt = 150.;
  vec3 col;
  float cloudFac;
  if (rd.y > 0.) {
    ro.x += 0.5 * tCur;
    vec2 p = 0.01 * (rd.xz * (skyHt - ro.y) / rd.y + ro.xz);
    float w = 0.65;
    float f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.3;
    }
    cloudFac = clamp (5. * (f - 0.5) * rd.y + 0.1, 0., 1.);
  } else cloudFac = 0.;
  float s = max (dot (rd, sunDir), 0.);
  col = SkyBg (rd) + (0.35 * pow (s, 6.) + 0.65 * min (pow (s, 256.), 0.3));
  col = mix (col, vec3 (0.75), cloudFac);
  return col;
}

float WaterHt (vec3 p)
{
  p *= 0.05;
  p += 0.005 * tCur * vec3 (0., 1., 1.);
  float ht = 0.;
  const float wb = 1.414;
  float w = wb;
  for (int j = 0; j < 7; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x) + 0.05 * tCur * vec3 (1., 0., 1.);
    ht += w * abs (Noisefv3 (p) - 0.5);
  }
  return ht;
}

vec3 WaterNf (vec3 p, float d)
{
  vec2 e = vec2 (max (0.01, 0.001 * d * d), 0.);
  float ht = WaterHt (p);
  return normalize (vec3 (ht - WaterHt (p + e.xyy), e.x, ht - WaterHt (p + e.yyx)));
}

float AngQnt (float a, float s1, float s2, float nr)
{
  return (s1 + floor (s2 + a * (nr / (2. * pi)))) * (2. * pi / nr);
}

float BdWingDf (vec3 p, float dHit)
{
  vec3 q, qh;
  float d, dd, a, wr;
  float wngFreq = 4.;
  float wSegLen = 0.15 * birdLen;
  float wChord = 0.3 * birdLen;
  float wSpar = 0.03 * birdLen;
  float fTap = 8.;
  float tFac = (1. - 1. / fTap);
  q = p - vec3 (0., 0., 0.3 * birdLen);
  q.x = abs (q.x) - 0.1 * birdLen;
  float wf = 1.;
  a = -0.1 + 0.2 * sin (wngFreq * tCur);
  d = dHit;
  qh = q;
  for (int k = 0; k < 5; k ++) {
    q.xy = Rot2D (q.xy, a);
    q.x -= wSegLen;
    wr = wf * (1. - 0.5 * q.x / (fTap * wSegLen));
    dd = PrFlatCylDf (q.zyx, wr * wChord, wr * wSpar, wSegLen);
    if (k < 4) {
      q.x -= wSegLen;
      dd = min (dd, PrCapsDf (q, wr * wSpar, wr * wChord));
    } else {
      q.x += wSegLen;
      dd = max (dd, PrCylDf (q.xzy, wr * wChord, wSpar));
      dd = min (dd, max (PrTorusDf (q.xzy, 0.98 * wr * wSpar,
         wr * wChord), - q.x));
    }
    if (dd < d) { d = dd;  qh = q; }
    a *= 1.03;
    wf *= tFac;
  }
  if (d < dHit) { dHit = min (dHit, d);  idObj = idWing;  qHit = qh; }
  return dHit;
}

float BdBodyDf (vec3 p, float dHit)
{
  vec3 q;
  float d, a, wr;
  float bkLen = 0.15 * birdLen;
  q = p;
  wr = q.z / birdLen;
  float tr, u;
  if (wr > 0.5) {
    u = (wr - 0.5) / 0.5;
    tr = 0.17 - 0.11 * u * u;
  } else {
    u = clamp ((wr - 0.5) / 1.5, -1., 1.);
    u *= u;
    tr = 0.17 - u * (0.34 - 0.18 * u); 
  }
  d = PrCapsDf (q, tr * birdLen, birdLen);
  if (d < dHit) {
    dHit = d;  idObj = idBdy;  qHit = q;
  }
  q = p;
  q.x = abs (q.x);
  wr = (wr + 1.) * (wr + 1.);
  q -= birdLen * vec3 (0.3 * wr, 0.1 * wr, -1.2);
  d = PrCylDf (q, 0.009 * birdLen, 0.2 * birdLen);
  if (d < dHit) { dHit = min (dHit, d);  idObj = idBdy;  qHit = q; }
  q = p;
  q.x = abs (q.x);
  q -= birdLen * vec3 (0.08, 0.05, 0.9);
  d = PrSphDf (q, 0.04 * birdLen);
  if (d < dHit) { dHit = d;  idObj = idEye;  qHit = q; }
  q = p;  q -= birdLen * vec3 (0., -0.015, 1.15);
  wr = clamp (0.5 - 0.3 * q.z / bkLen, 0., 1.);
  d = PrFlatCylDf (q, 0.25 * wr * bkLen, 0.25 * wr * bkLen, bkLen);
  if (d < dHit) { dHit = d;  idObj = idBk;  qHit = q; }
  return dHit;
}

float BdFootDf (vec3 p, float dHit)
{
  vec3 q;
  float d;
  float lgLen = 0.1 * birdLen;
  float ftLen = 0.5 * lgLen;
  q = p;
  q.x = abs (q.x);
  q -= birdLen * vec3 (0.1, -0.12, 0.6);
  q.yz = Rot2D (q.yz, legAng);
  q.xz = Rot2D (q.xz, -0.05 * pi);
  q.z += lgLen;
  d = PrCylDf (q, 0.15 * lgLen, lgLen);
  if (d < dHit) { dHit = d;  idObj = idLeg;  qHit = q; }
  q.z += lgLen;
  q.xy = Rot2D (q.xy, 0.5 * pi);
  q.xy = Rot2D (q.xy, AngQnt (atan (q.y, - q.x), 0., 0.5, 3.));
  q.xz = Rot2D (q.xz, - pi + 0.4 * legAng);
  q.z -= ftLen;
  d = PrCapsDf (q, 0.2 * ftLen, ftLen);
  if (d < dHit) { dHit = d;  idObj = idLeg;  qHit = q; }
  return dHit;
}

float BirdDf (vec3 p, float dHit)
{
  dHit = BdWingDf (p, dHit);
  dHit = BdBodyDf (p, dHit);
  dHit = BdFootDf (p, dHit);
  return 0.9 * dHit;
}

vec4 BirdCol (vec3 n)
{
  vec3 col;
  float spec = 1.;
  if (idObj == idWing) {
    float gw = 0.15 * birdLen;
    float w = mod (qHit.x, gw);
    w = SmoothBump (0.15 * gw, 0.65 * gw, 0.1 * gw, w);
    col = mix (vec3 (0.05), vec3 (1.), w);
  } else if (idObj == idEye) {
    col = vec3 (0., 0.6, 0.);
    spec = 5.;
  } else if (idObj == idBdy) {
    vec3 nn = birdMat * n;
    col = mix (mix (vec3 (1.), vec3 (0.1), smoothstep (0.5, 1., nn.y)), vec3 (1.),
       1. - smoothstep (-1., -0.7, nn.y));
  } else if (idObj == idBk) {
    col = vec3 (1., 1., 0.);
  } else if (idObj == idLeg) {
    col = (0.5 + 0.4 * sin (100. * qHit.z)) * vec3 (0.6, 0.4, 0.);
  }
  return vec4 (col, spec);
}

float ObjDf (vec3 p)
{
  float dHit = dstFar;
  dHit = BirdDf (birdMat * (p - birdPos), dHit);
  return dHit;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dTol = 0.001;
  float d;
  float dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < dTol || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh = 1.;
  float d = 0.01;
  for (int i = 0; i < 50; i++) {
    float h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.01;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn;
  vec4 objCol;
  float dstHit;
  float htWat = -1.5;
  float reflFac = 1.;
  vec3 col = vec3 (0.);
  idObj = -1;
  dstHit = ObjRay (ro, rd);
  if (rd.y < 0. && dstHit >= dstFar) {
    float dw = - (ro.y - htWat) / rd.y;
    ro += dw * rd;
    rd = reflect (rd, WaterNf (ro, dw));
    ro += 0.01 * rd;
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    reflFac *= 0.7;
  }
  int idObjT = idObj;
  if (idObj < 0) dstHit = dstFar;
  float spec = 0.5;
  if (dstHit >= dstFar) col = reflFac * SkyCol (ro, rd);
  else {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = BirdCol (vn);
    float dif = max (dot (vn, sunDir), 0.);
    col = reflFac * objCol.xyz * (0.2 + max (0., dif) * ObjSShadow (ro, sunDir) *
       (dif + objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 128.)));
  }
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

vec3 BirdTrack (float t)
{
  vec3 bp;
  float rdTurn = 0.45 * min (fltBox.x, fltBox.z);
  float tC = 0.5 * pi * rdTurn / birdVel;
  vec3 tt = vec3 (fltBox.x - rdTurn, length (fltBox.xy), fltBox.z - rdTurn) *
     2. / birdVel;
  float tCyc = 2. * (2. * tt.z + tt.x  + 4. * tC + tt.y);
  float tSeq = mod (t, tCyc);
  float ti[9];  ti[0] = 0.;  ti[1] = ti[0] + tt.z;  ti[2] = ti[1] + tC;
  ti[3] = ti[2] + tt.x;  ti[4] = ti[3] + tC;  ti[5] = ti[4] + tt.z;
  ti[6] = ti[5] + tC;  ti[7] = ti[6] + tt.y;  ti[8] = ti[7] + tC;
  float a, h, hd, tf;
  h = - fltBox.y;
  hd = 1.;
  if (tSeq > 0.5 * tCyc) { tSeq -= 0.5 * tCyc;  h = - h;  hd = - hd; }
  float rSeg = -1.;
  vec3 fbR = vec3 (1.);
  fbR.xz -= vec2 (rdTurn) / fltBox.xz;
  bp.xz = fltBox.xz;
  bp.y = h;
  if (tSeq < ti[4]) {
    if (tSeq < ti[1]) {
      tf = (tSeq - ti[0]) / (ti[1] - ti[0]);
      bp.xz *= vec2 (1., fbR.z * (2. * tf - 1.));
    } else if (tSeq < ti[2]) {
      tf = (tSeq - ti[1]) / (ti[2] - ti[1]);  rSeg = 0.;
      bp.xz *= fbR.xz;
    } else if (tSeq < ti[3]) {
      tf = (tSeq - ti[2]) / (ti[3] - ti[2]);
      bp.xz *= vec2 (fbR.x * (1. - 2. * tf), 1.);
    } else {
      tf = (tSeq - ti[3]) / (ti[4] - ti[3]);  rSeg = 1.;
      bp.xz *= fbR.xz * vec2 (-1., 1.);
    }
  } else {
    if (tSeq < ti[5]) {
      tf = (tSeq - ti[4]) / (ti[5] - ti[4]);
      bp.xz *= vec2 (- 1., fbR.z * (1. - 2. * tf));
    } else if (tSeq < ti[6]) {
      tf = (tSeq - ti[5]) / (ti[6] - ti[5]);  rSeg = 2.;
      bp.xz *= - fbR.xz;
    } else if (tSeq < ti[7]) {
      tf = (tSeq - ti[6]) / (ti[7] - ti[6]);
      bp.xz *= vec2 (fbR.x * (2. * tf - 1.), - 1.);
      bp.y = h + 2. * fltBox.y * hd * tf;
    } else {
      tf = (tSeq - ti[7]) / (ti[8] - ti[7]);  rSeg = 3.;
      bp.xz *= fbR.xz * vec2 (1., -1.);
      bp.y = - h;
    }
  }
  if (rSeg >= 0.) {
    a = 0.5 * pi * (rSeg + tf);
    bp += rdTurn * vec3 (cos (a), 0., sin (a));
  }
  bp.y -= - 1.1 * fltBox.y;
  return bp;
}

void BirdPM (float t)
{
  float dt = 1.;
  bdPos = BirdTrack (t);
  vec3 bpF = BirdTrack (t + dt);
  vec3 bpB = BirdTrack (t - dt);
  vec3 vel = (bpF - bpB) / (2. * dt);
  float vy = vel.y;
  vel.y = 0.;
  vec3 acc = (bpF - 2. * bdPos + bpB) / (dt * dt);
  acc.y = 0.;
  vec3 va = cross (acc, vel) / length (vel);
  vel.y = vy;
  float el = - 0.9 * asin (vel.y / length (vel));
  vec3 ort = vec3 (el, atan (vel.z, vel.x) - 0.5 * pi, 0.2 * length (va) * sign (va.y));
  vec3 cr = cos (ort);
  vec3 sr = sin (ort);
  bdMat = mat3 (cr.z, - sr.z, 0., sr.z, cr.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., cr.x, - sr.x, 0., sr.x, cr.x) *
     mat3 (cr.y, 0., - sr.y, 0., 1., 0., sr.y, 0., cr.y);
  legAng = pi * clamp (0.4 + 1.5 * el, 0.12, 0.8);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  vec3 ro, rd, vd;
  sunDir = normalize (vec3 (0.5, 0.4, -0.4));
  birdLen = 0.9;
  birdVel = 7.;
  fltBox = vec3 (10., 3., 10.);
  BirdPM (tCur);
  birdMat = bdMat;
  birdPos = bdPos;
  ro = vec3 (-0.45 * fltBox.x, 1.5 * fltBox.y, - 2. * fltBox.z);
  vd = normalize (birdPos - ro);
  vec3 vdd = - vd.y * vd;
  float f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (vdd.x, 1. + vdd.y, vdd.z), vd);
  rd = vuMat * normalize (vec3 (uv, 8.));
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
