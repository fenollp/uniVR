// Shader downloaded from https://www.shadertoy.com/view/4s3XzN
// written by shadertoy user dr2
//
// Name: Pannini Flies Gotham
// Description: Another flight through Gotham, now with user control and adjustable perspective.
// "Pannini Flies Gotham" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

/*
  See "Pannini's Rotunda" for background info.
  Vertical slider controls flight speed.
  Horizontal sliders control zoom and Pannini factor.
  Look around using the mouse.
  Scenery based on earlier "Gotham" (daytime flythrough mode only).
*/

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

const float pi = 3.14159;
const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

float Hashff (float p)
{
  return fract (sin (p) * cHashM);
}

float Hashfv2 (vec2 p)
{
  return fract (sin (dot (p, cHashA3.xy)) * cHashM);
}

vec2 Hashv2f (float p)
{
  return fract (sin (p + cHashA4.xy) * cHashM);
}

vec4 Hashv4f (float p)
{
  return fract (sin (p + cHashA4) * cHashM);
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

float IFbm1 (float p)
{
  float s, a;
  p *= 5.;
  s = 0.;
  a = 10.;
  for (int j = 0; j < 4; j ++) {
    s += floor (a * Noiseff (p));
    a *= 0.5;
    p *= 2.;
  }
  return 0.1 * s;
}

float Fbmn (vec3 p, vec3 n)
{
  vec3 s;
  float a;
  s = vec3 (0.);
  a = 1.;
  for (int j = 0; j < 5; j ++) {
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

float PrOBoxDf (vec3 p, vec3 b)
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

float SmoothMin (float a, float b, float r)
{
  float h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
  return mix (b, a, h) - r * h * (1. - h);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

const float txRow = 64.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

mat3 vuMat;
vec3 vuPos, qHit, sunDir;
vec2 iqBlk, cTimeV;
float dstFar, tCur, qcCar, cDir, flrHt;
int idObj;
const int idBldgF = 1, idBldgC = 2, idRoad = 3, idSWalk = 4, idCarWhl = 5,
   idCarBdy = 6, idTrLight = 7, idTwr = 8, idTwrTop = 9;

vec3 BgCol (vec3 ro, vec3 rd)
{
  vec3 col;
  float sd, f;
  if (rd.y >= 0.) {
    ro.xz += 2. * tCur;
    sd = max (dot (rd, sunDir), 0.);
    col = vec3 (0., 0., 0.6) + 0.3 * pow (1. - rd.y, 8.) +
       0.35 * pow (sd, 6.) + 0.65 * min (pow (sd, 256.), 0.3);
    f = Fbm2 (0.05 * (ro.xz + rd.xz * (100. - ro.y) / max (rd.y, 0.001)));
    col = mix (col, vec3 (1.), clamp (0.1 + 0.8 * f * rd.y, 0., 1.));
  } else {
    col = mix (vec3 (0.4, 0.5, 0.2), 0.95 * vec3 (0.4, 0.4, 0.9),
       pow (1. + rd.y, 8.));
  }
  return col;
}

float BldgDf (vec3 p, float dMin)
{
  vec3 q, qq;
  vec2 ip;
  float d, bWid, bWidU, bHt, bHtU, bShape, tWid, hiMid, twHt;
  bool bTall;
  ip = floor (p.xz);
  hiMid = dot (ip, ip);
  bTall = (hiMid == 0.);
  hiMid = 0.75 * clamp (4. / max (sqrt (hiMid), 1.), 0., 1.);
  d = p.y;
  if (d < dMin) { dMin = d;  idObj = idRoad;  qHit = p;  iqBlk = ip; }
  q = p;
  q.xz = fract (q.xz) - vec2 (0.5);
  bWid = floor ((0.2 + Hashfv2 (11. * ip) * 0.1) / flrHt + 0.5) * flrHt;
  bWidU = floor (bWid * (0.5 + 0.3 * Hashfv2 (12. * ip)) / flrHt + 0.5) * flrHt;
  bHt = (0.5 * Hashfv2 (13. * ip) + 0.05) * hiMid *
     (1.5 + (bWid - 0.15) / flrHt) + 0.1;
  bHtU = 0.25 * bHt + 0.75 * max (0., Hashfv2 (15. * ip) - 0.5) * hiMid + 0.05;
  bHt = (floor (bHt / flrHt) + 0.2) * flrHt;
  bHtU = floor (bHtU / flrHt) * flrHt;
  if (bHtU > 0.) bHtU += 0.2 * flrHt;
  if (bTall) {
    bHt = max (bHt, 40.2 * flrHt);
    bHtU = max (bHtU, 20.2 * flrHt);
  }
  tWid = ((bHtU > 0.) ? bWidU : bWid) - 0.0125;
  bShape = Hashfv2 (17. * ip);
  q.y -= 0.0015;
  d = PrOBoxDf (q, vec3 (0.35, 0.0015, 0.35));
  if (d < dMin) { dMin = d;  idObj = idSWalk;  qHit = p; }
  q.y -= 0.0015;
  qq = q;
  qq.y -= bHt - 0.2 * flrHt - 0.001;
  if (bShape > 0.25) {
    d = PrOBoxDf (qq, vec3 (bWid, bHt, bWid));
    if (d < dMin) { dMin = d;  idObj = idBldgF;  qHit = qq;  iqBlk = ip; }
  } else {
    d = PrCylDf (qq.xzy, bWid, bHt);
    if (d < dMin) { dMin = d;  idObj = idBldgC;  qHit = qq;  iqBlk = ip; }
  }
  qq.y -= bHt + bHtU - 0.2 * flrHt - 0.001;
  if (bHtU > 0.) {
    if (bShape > 0.5) {
      d = max (PrOBoxDf (qq, vec3 (bWidU, bHtU, bWidU)),
         - PrOBoxDf (qq - vec3 (0., bHtU, 0.),
         vec3 (tWid, 0.1 * flrHt, tWid)));
      if (d < dMin) { dMin = d;  idObj = idBldgF;  qHit = qq;  iqBlk = ip; }
    } else {
      d = max (PrCylDf (qq.xzy, bWidU, bHtU),
         - PrCylDf ((qq - vec3 (0., bHtU, 0.)).xzy, tWid, 0.1 * flrHt));
      if (d < dMin) { dMin = d;  idObj = idBldgC;  qHit = qq;  iqBlk = ip; }
    }
  }
  qq.y -= bHtU - 0.2 * flrHt - 0.001;
  if (bShape < 0.1) {
    d = PrCapsDf (qq.xzy, 0.4 * bWidU, 1.25 * flrHt);
    if (d < dMin) { dMin = d;  idObj = idBldgC;  qHit = qq;  iqBlk = ip; }
  } else if (bShape > 0.7) {
    d = PrOBoxDf (qq, vec3 (0.25 * bWidU, 1.25 * flrHt, 0.25 * bWidU));
    if (d < dMin) { dMin = d;  idObj = idBldgF;  qHit = qq;  iqBlk = ip; }
  }
  if (bHt + bHtU > 30. * flrHt) {
    twHt = 0.1 * (bHt + bHtU);
    qq.y -= twHt;
    d = PrCapsDf (qq.xzy, 0.3 * flrHt, twHt);
    if (d < dMin) {
      dMin = d;  qHit = qq;  iqBlk = ip;
      idObj = (qq.y > 0.9 * twHt) ? idTwrTop : idTwr;  
    }
  }
  if (bTall) {
    qq = q;
    qq.y -= 2. * (bHt + bHtU) + 0.2 * flrHt;
    d = PrCylDf (qq.xzy, 0.3, 1.2 * flrHt);
    if (d < dMin) { dMin = d;  idObj = idBldgC;  qHit = qq;  iqBlk = ip; }
  }
  return dMin;
}

float TrLightDf (vec3 p, float dMin)
{
  vec3 q;
  float d;
  q = p;
  q.xz = abs (fract (q.xz) - vec2 (0.5)) - vec2 (0.345);
  q.y -= 0.023;
  d = PrCylDf (q.xzy, 0.002, 0.02);
  if (d < dMin) { dMin = d;  idObj = idTrLight;  qHit = q; }
  return dMin;
}

vec4 CarPos (vec3 p)
{
  vec3 q;
  float vDir, cCar;
  if (cDir == 0. && abs (fract (p.z) - 0.5) > 0.35 ||
     cDir == 1. && abs (fract (p.x) - 0.5) < 0.35) {
    p.xz = vec2 (- p.z, p.x);
    vDir = 0.;
  } else {
    vDir = 1.;
  }
  q = p;
  q.y -= -0.003;
  q.z += 3. * floor (q.x);
  q.x = fract (q.x) - 0.5;
  q.z *= 2. * step (0., q.x) - 1.;
  q.z -= cTimeV.x + ((cDir == vDir) ? vDir + cTimeV.y : 1.);
  cCar = floor (20. * q.z);
  q.z = fract (q.z) - 0.5;
  q.x = abs (q.x) - 0.395 - 0.06 * step (0.7, Hashff (11. * cCar)) -
     0.03 * Hashff (13. * cCar);
  return vec4 (q, cCar);
}

float CarDf (vec3 p, float dMin)
{
  vec4 q4;
  vec3 q;
  float d, bf;
  q4 = CarPos (p);
  q = q4.xyz;
  bf = PrOBoxDf (q + vec3 (0., 0., -0.1), vec3 (0.015, 0.05, 0.2));
  q.z = mod (q.z, 0.05) - 0.025;
  d = SmoothMin (PrOBoxDf (q + vec3 (0., -0.008, 0.), vec3 (0.007, 0.002, 0.015)),
     PrOBoxDf (q + vec3 (0., -0.015, 0.003), vec3 (0.0035, 0.0003, 0.005)), 0.02);
  d = max (d, bf);
  if (d < dMin) { dMin = d;  idObj = idCarBdy;  qHit = q;  qcCar = q4.w; }
  q.xz = abs (q.xz) - vec2 (0.0085, 0.01);
  q.y -= 0.006;
  d = max (PrCylDf (q.yzx, 0.003, 0.0012), bf);
  if (d < dMin) { dMin = d;  idObj = idCarWhl;  qHit = q; }
  return 0.7 * dMin;
}

float ObjDf (vec3 p)
{
  float dMin;
  dMin = dstFar;
  dMin = BldgDf (p, dMin);
  dMin = TrLightDf (p, dMin);
  dMin = CarDf (p, dMin);
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  vec3 p;
  vec2 srd, dda, h;
  float dHit, d;
  srd = 1. - 2. * step (0., rd.xz);
  dda = - srd / (rd.xz + 0.0001);
  dHit = 0.;
  for (int j = 0; j < 240; j ++) {
    p = ro + dHit * rd;
    h = fract (dda * fract (srd * p.xz));
    d = ObjDf (p);
    dHit += min (d, 0.2 + max (0., min (h.x, h.y)));
    if (d < 0.0002 || dHit > dstFar) break;
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

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.02;
  for (int j = 0; j < 40; j ++) {
    h = BldgDf (ro + rd * d, dstFar);
    sh = min (sh, smoothstep (0., 1., 20. * h / d));
    d += min (0.05, 3. * h);
    if (h < 0.001) break;
  }
  return max (sh, 0.);
}

vec4 ObjCol (vec3 ro, vec3 rd, vec3 vn)
{
  vec3 col;
  vec2 g, b;
  float wFac, f, ff, spec;
  wFac = 1.;
  col = vec3 (0.);
  spec = 0.;
  if (idObj == idBldgF || idObj == idBldgC) {
    col = HsvToRgb (vec3 (0.7 * Hashfv2 (19. * iqBlk), 0.2,
       0.4 + 0.2 * Hashfv2 (21. * iqBlk)));
    if (abs (vn.y) < 0.05) {
      f = mod (qHit.y / flrHt - 0.2, 1.) - 0.5;
      wFac = 1. - (step (0., f) - 0.5) * step (abs (abs (f) - 0.24), 0.02) -
         0.801 * step (abs (f), 0.22);
      if (wFac < 0.2) {
        f = (idObj == idBldgF) ? 1.5 * dot (qHit.xz, normalize (vn.zx)) :
           length (qHit.xz) * (atan (qHit.z, qHit.x) + 0.5 * pi);
        wFac = min (0.2 + 0.8 * floor (fract (f / flrHt + 0.25) *
           (1. + Hashfv2 (51. * iqBlk))), 1.);
      }
      col *= wFac;
      spec = 0.3;
    } else if (vn.y > 0.95) {
      g = step (0.05, fract (qHit.xz * 70.));
      col *= mix (0.8, 1., g.x * g.y);
    }
    if (vn.y < 0.95 && wFac > 0.5)
       col *= (0.8 + 0.2 * Noisefv2 (512. * vec2 (qHit.x + qHit.z, qHit.y)));
  } else if (idObj == idTwr) {
    col = vec3 (0.3);
    spec = 0.3;
  } else if (idObj == idTwrTop) {
     col = vec3 (1., 0., 0.);
     spec = -1.;
  } else if (idObj == idSWalk) {
    g = step (0.05, fract (qHit.xz * 35.));
    col = vec3 (0.2) * mix (0.7, 1., g.x * g.y);
  } else if (idObj == idTrLight) {
    f = 2. * (atan (qHit.z, qHit.x) / pi + 1.) + 0.5;
    ff = floor (f);
    if (abs (qHit.y - 0.014) < 0.004 && abs (f - ff) > 0.3) {
      col = mix (vec3 (0., 1., 0.), vec3 (1., 0., 0.),
         (mod (ff, 2.) == 0.) ? cDir : 1. - cDir);
      spec = -2.;
    } else {
      col = vec3 (0.4, 0.2, 0.1);
      spec = 0.5;
    }
  } else if (idObj == idCarBdy) {
    col = HsvToRgb (vec3 (Hashff (qcCar * 37.), 0.9,
       0.4 + 0.6 * vec3 (Hashff (qcCar * 47.))));
    f = abs (qHit.z + 0.003);
    wFac = max (max (step (0.001, f - 0.005) * step (0.001, abs (qHit.x) - 0.0055),
       step (f, 0.001)), step (0.0015, abs (qHit.y - 0.0145)));
    col *= wFac;
    spec = 0.5;
    if (abs (qHit.z) > 0.015) {
      g = vec2 (qHit.x, 3. * (qHit.y - 0.008));
      if (qHit.z > 0. && dot (g, g) < 3.6e-5) col *= 0.3;
      g = vec2 (abs (qHit.x) - 0.005, qHit.y - 0.008);
      f = dot (g, g);
      if (qHit.z > 0. && f < 2.2e-6) {
        col = vec3 (1., 1., 0.3);
        spec = -2.;
      } else if (qHit.z < 0. && f < 1.1e-6) {
        col = vec3 (1., 0., 0.);
        spec = -2.;
      }
    }
  } else if (idObj == idCarWhl) {
    if (length (qHit.yz) < 0.0015) {
      col = vec3 (0.7);
      spec = 0.8;
    } else {
      col = vec3 (0.03);
    } 
  } else if (idObj == idRoad) {
    g = abs (fract (qHit.xz) - 0.5);
    if (g.x < g.y) g = g.yx;
    col = mix (vec3 (0.05), vec3 (0.08), step (g.x, 0.355));
    f = ((step (abs (g.x - 0.495), 0.002) + step (abs (g.x - 0.365), 0.002)) +
       step (abs (g.x - 0.44), 0.0015) * step (fract (g.y * 18. + 0.25), 0.7)) *
       step (g.y, 0.29);
    col = mix (col, vec3 (0.5, 0.4, 0.1), f);
    f = step (0.6, fract (g.x * 30. + 0.25)) * step (0.36, g.x) *
       step (abs (g.y - 0.32), 0.02);
    col = mix (col, vec3 (0.6), f);
    b = CarPos (ro).xz;
    g = abs (b + vec2 (0., -0.1)) - vec2 (0.015, 0.2);
    b.y = mod (b.y, 0.05) - 0.025;
    b = abs (b) * vec2 (1.55, 1.);
    if (max (g.x, g.y) < 0. && max (b.x, b.y) < 0.016) col *= 0.6;
  }
  if (wFac < 0.5) {
    rd = reflect (rd, vn);
    g = Rot2D (rd.xz, 5.1 * atan (20. + iqBlk.y, 20. + iqBlk.x));
    col = 0.8 * (0.2 + 0.8 * (step (1., 0.5 * ro.y + 3. * rd.y -
       0.2 * floor (5. * IFbm1 (0.3 * atan (g.y, g.x) + pi) + 0.05)))) *
       BgCol (ro, rd);
    spec = -1.;
  }
  return vec4 (col, spec);
}

vec3 ShowWg (vec2 uv, vec2 canvas, vec3 col, float zmVar, float pnVar, float fvVar)
{
  vec4 wgBx[3];
  vec2 ust;
  float asp;
  asp = canvas.x / canvas.y;
  wgBx[0] = vec4 (0.47 * asp, -0.2, 0.012 * asp, 0.15);
  wgBx[1] = vec4 (0.13 * asp, -0.46, 0.1 * asp, 0.022);
  wgBx[2] = vec4 (0.37 * asp, -0.46, 0.1 * asp, 0.022);
  ust = abs (0.5 * uv - wgBx[0].xy) - wgBx[0].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.8);
  ust = 0.5 * uv - wgBx[0].xy;
  ust.y -= (fvVar - 0.5) * 2. * wgBx[0].w;
  if (abs (length (ust) - 0.8 * wgBx[0].z) * canvas.y < 2.)
     col = (fvVar * canvas.y > 15.) ? vec3 (0.1, 1., 0.1) : vec3 (1., 0.1, 0.1);
  ust = abs (0.5 * uv - wgBx[1].xy) - wgBx[1].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.8);
  ust = 0.5 * uv - wgBx[1].xy;
  ust.x -= (zmVar - 0.5) * 2. * wgBx[1].z;
  ust = abs (ust) - 0.6 * wgBx[1].ww;
  if (abs (max (ust.x, ust.y)) * canvas.y < 2.) col = vec3 (1., 0.3, 1.);
  ust = abs (0.5 * uv - wgBx[2].xy) - wgBx[2].zw;
  if (abs (max (ust.x, ust.y)) * canvas.y < 1.) col = vec3 (0.8);
  ust = 0.5 * uv - wgBx[2].xy;
  ust.x -= (pnVar - 0.5) * 2. * wgBx[2].z;
  ust = abs (ust) - 0.6 * wgBx[2].ww;
  if (abs (max (ust.x, ust.y)) * canvas.y < 2.) col =
     (pnVar > 0.3) ? vec3 (1., 0., 0.1) : ((pnVar > 0.1) ?
     vec3 (1., 1., 0.1) : vec3 (0.1, 1., 0.1));
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, bgCol, vn;
  float dstHit, sh;
  int idObjT;
  bgCol = BgCol (ro, rd);
  dstHit = ObjRay (ro, rd);
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    idObjT = idObj;
    vn = ObjNf (ro);
    idObj = idObjT;
    objCol = ObjCol (ro, rd, vn);
    col = objCol.rgb;
    if (objCol.a >= 0.) {
      if (idObj == idRoad) vn = VaryNf (500. * qHit, vn, 2.);
      else if (idObj == idBldgF || idObj == idBldgC)
         vn = VaryNf (500. * qHit, vn, 0.5);
      sh = 0.2 + 0.8 * ObjSShadow (ro, sunDir);
      col = col * (0.2 + 0.1 * max (dot (vn, sunDir * vec3 (-1., 1., -1.)), 0.) +
         0.8 * sh * max (dot (vn, sunDir), 0.) +
         sh * objCol.a * pow (max (0., dot (sunDir, reflect (rd, vn))), 128.));
    } else if (objCol.a == -1.) {
      if (idObj == idBldgF || idObj == idBldgC || idObj == idTwrTop) col *= 0.2;
    }
    col = mix (col, bgCol, smoothstep (0.4, 1., dstHit / dstFar));
  } else col = bgCol;
  return pow (clamp (col, 0., 1.), vec3 (0.6));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec4 stDat;
  vec3 ro, rd, col;
  vec2 canvas, uv, ori, ca, sa;
  float el, az, cTime, tRep, sunAz, sunEl, asp, zmVar, pnVar, fvVar, zmFac,
     pnFac, a, t;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  stDat = Loadv4 (0);
  zmVar = stDat.x;
  pnVar = stDat.y;
  el = stDat.z;
  az = stDat.w;
  stDat = Loadv4 (1);
  fvVar = stDat.y;
  tRep = 80.;
  dstFar = 40.;
  flrHt = 0.05;
  sunAz = pi * sin (0.006 * 2. * pi * tCur);
  sunEl = pi * (0.3 + 0.15 * sin (0.44 * sunAz));
  sunDir = vec3 (cos (sunAz) * cos (sunEl), sin (sunEl), sin (sunAz) * cos (sunEl));
  cTime = 0.15 * mod (tCur, tRep);
  cDir = mod (floor (cTime), 2.);
  cTimeV = vec2 (floor (0.5 * floor (cTime)), mod (cTime, 1.));
  stDat = Loadv4 (3);
  ro = stDat.xyz;
  ori = vec2 (el, az + stDat.w);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x);
  asp = canvas.x / canvas.y;
  zmFac = 0.2 + 3.8 * zmVar;
  pnFac = exp (5. * pnVar) - 1.;  
  a = atan (uv.x / (asp * zmFac));
  rd = vuMat * normalize (vec3 (((1. + pnFac) * sin (a) / (pnFac + cos (a))) * asp,
     uv.y / zmFac, 1.));
  col = (abs (uv.y) < 0.85) ? ShowScene (ro, rd) : vec3 (0.1, 0.1, 0.2);
  t = step (50. * abs (mod (tCur / tRep + 0.5, 1.) - 0.5),
     max (abs (uv.x), abs (uv.y) * asp / 0.85) / max (1., asp));
  col = mix (col, vec3 (0.1, 0.1, 0.2), t);
  col = ShowWg (uv, canvas, col, zmVar, pnVar, fvVar);
  fragColor = vec4 (col, 1.);
}
