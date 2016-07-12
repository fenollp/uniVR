// Shader downloaded from https://www.shadertoy.com/view/MsdXWn
// written by shadertoy user dr2
//
// Name: Faberge Balls
// Description:   Another lost egg (mouse enabled); the &amp;amp;quot;surprise&amp;amp;quot; in this one is a gravitational wave detector.
//    
// "Faberge Balls" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

#define txBuf iChannel0
#define txSize iChannelResolution[0].xy

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
  const vec3 e = vec3 (0.1, 0., 0.);
  s = Fbmn (p, n);
  g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

mat3 QtToRMat (vec4 q) 
{
  mat3 m;
  float a1, a2, s;
  q = normalize (q);
  s = q.w * q.w - 0.5;
  m[0][0] = q.x * q.x + s;  m[1][1] = q.y * q.y + s;  m[2][2] = q.z * q.z + s;
  a1 = q.x * q.y;  a2 = q.z * q.w;  m[0][1] = a1 + a2;  m[1][0] = a1 - a2;
  a1 = q.x * q.z;  a2 = q.y * q.w;  m[2][0] = a1 + a2;  m[0][2] = a1 - a2;
  a1 = q.y * q.z;  a2 = q.x * q.w;  m[1][2] = a1 + a2;  m[2][1] = a1 - a2;
  return 2. * m;
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p;
  p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

const float txRow = 128.;

vec4 Loadv4 (int idVar)
{
  float fi;
  fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

float PrEllips2ShDf (vec3 p, vec2 r, float w)
{
  vec3 ra;
  float s;
  s = min (r.x, r.y);
  ra = r.xyx;
  return max ((s + w) * (length (p / (ra + w)) - 1.), -
     (s - w) * (length (p / (ra - w)) - 1.));
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}

const int nBall = 216;
vec3 qHit, vnBall, ltDir, qnSph;
vec2 sOpen;
float dstFar, tCur, egLen, egRad, egOpen, wThk, spRad;
int idObj, idBall;

float ObjDf (vec3 p)
{
  vec3 q, qq;
  float dMin, d, db, dr, i2;
  i2 = 1. / sqrt (2.);
  dMin = dstFar;
  q = p;
  q.y -= -1.15 * egLen;
  q.xz = abs (q.xz);
  q.xz = vec2 (q.x - q.z, q.z + q.x) * i2;
  q.yz = q.yz * sOpen.x + q.zy * sOpen.y * vec2 (1., -1.);
  q.y -= 1.15 * egLen;
  dr = wThk * (1. - (1. - SmoothBump (0.47, 0.53, 0.03,
     fract (1.75 * abs (q.y) / egLen + 0.5))) * (1. - SmoothBump (0.45, 0.55, 0.03,
     fract (4. * (atan (q.z, - q.x) / pi + 1.)))));
  d = PrEllips2ShDf (q, vec2 (egRad + dr, egLen + dr), wThk);
  q.xz = vec2 (q.x + q.z, q.z - q.x) * i2;
  db = (sOpen.y != 0.) ? - min (q.x, q.z) : - dstFar;
  d = max (d, db);
  if (d < dMin) { dMin = d;  idObj = 1;  qHit = q; }
  qq = q;
  qq.y = abs (qq.y) - (egLen - 0.3 * egRad);
  d = max (PrCapsDf (qq.xzy, 0.4 * egRad, 0.005 * egRad), 0.25 * egRad - qq.y);
  d = max (d, db);
  if (d < dMin) { dMin = d;  idObj = 2;  qHit = q; }
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
  int idObjT;
  idObjT = idObj;
  const vec3 e = vec3 (0.0001, -0.0001, 0.);
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  idObj = idObjT;
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

float BallHit (vec3 ro, vec3 rd)
{
  vec4 p;
  vec3 v;
  float b, d, w, dMin, sz;
  dMin = dstFar;
  for (int n = 0; n < nBall; n ++) {
    p = Loadv4 (4 + 2 * n);
    v = ro - p.xyz;
    sz = 0.45 * p.w;
    b = dot (rd, v);
    w = b * b + sz * sz - dot (v, v);
    if (w >= 0.) {
      d = - b - sqrt (w);
      if (d > 0. && d < dMin) {
        dMin = d;
        vnBall = (v + d * rd) / sz;
        idBall = n;
      }
    }
  }
  return dMin;
}

float SphHit (vec3 ro, vec3 rd, float sz)
{
  float b, d, w;
  b = dot (rd, ro);
  w = b * b + sz * sz - dot (ro, ro);
  d = dstFar;
  if (w >= 0.) {
    d = - b - sqrt (w);
    qnSph = (ro + d * rd) / sz;
  }
  return d;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec4 objCol;
  vec3 col, vn, qh;
  float dstBall, dstSph, dstObj, a, s, t, c;
  const vec4 colEg1 = vec4 (0.3, 0.1, 0., 0.2),
     colEg2 = vec4 (0.6, 0.6, 0.2, 0.5), colEg3 = vec4 (0., 0., 0.6, 0.1);
  dstObj = ObjRay (ro, rd);
  dstBall = BallHit (ro, rd);
  dstSph = SphHit (ro, rd, spRad);
  if (dstBall < min (dstObj, dstFar)) {
    c = 33. * float (idBall) / float (nBall);
    col = HsvToRgb (vec3 (mod (c, 1.), 1. - 0.07 * mod (c, 8.),
       1. - 0.06 * mod (c, 13.)));
    col = col * (0.4 + 0.6 * max (dot (vnBall, ltDir), 0.)) +
       0.5 * pow (max (0., dot (ltDir, reflect (rd, vnBall))), 64.);
  } else if (dstObj < dstFar) {
    ro += rd * dstObj;
    vn = ObjNf (ro);
    qh.xz = qHit.xz / egRad;
    qh.y = qHit.y / egLen;
    a = 0.5 * (atan (qHit.z, - qHit.x) / pi + 1.);
    s = dot (qh, qh) - (wThk + 0.84);
    if (idObj == 1) {
      if (s > 0.01) {
        vn = VaryNf (100. * qh.xzy, vn, 0.3);
        t = 1.1 * abs (qh.y);
        objCol = mix (colEg1, colEg2, step (t, SmoothBump (0.49, 0.51, 0.005,
           fract (8. * a + 0.015 * cos (30. * t)))));
      } else {
        if (s > 0.) objCol = mix (colEg2, colEg3,
           clamp (10. * Fbm2 (vec2 (33. * pi * a, 17. * asin (qh.y))) - 9.,
           0., 1.));
        else idObj = 3;
      }
    } else if (idObj == 2) {
      if (s > 0.) {
        vn = VaryNf (200. * qh.xzy, vn, 0.1);
        t = length (qh.xz) - 0.12;
        t = 50. * t * t;
        objCol = mix (colEg1, colEg2, step (t, SmoothBump (0.45, 0.55, 0.015,
           fract (8. * a))));
      } else idObj = 3;
    }
    if (idObj == 3) {
      vn = VaryNf (100. * qh.xzy, vn, 0.1);
      objCol = colEg2;
    }
    col = objCol.rgb * (0.2 +
       0.8 * max (0., max (dot (vn, ltDir), 0.))) +
       objCol.a * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
  }  else col = vec3 (0., 0.03, 0.) * clamp (1. + 0.7 * rd.y, 0., 1.);
  if (dstSph < min (dstObj, dstFar)) {
    col = mix (col, vec3 (0.07), pow (1. - abs (dot (rd, qnSph)), 4.));
    col += 0.005 + 0.05 * max (dot (qnSph, ltDir), 0.) +
       0.1 * pow (max (0., dot (ltDir, reflect (rd, qnSph))), 32.);
  }
  return pow (clamp (col, 0., 1.), vec3 (0.7));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 qtVu;
  vec3 rd, ro;
  vec2 canvas, uv, w;
  float tCur;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  dstFar = 100.;
  egRad = 9.5;
  egLen = 8.5;
  wThk = 0.2;
  egOpen = SmoothBump (0.15, 0.8, 0.1, mod (tCur / 31. + 0.9, 1.));
  sOpen = vec2 (cos (1.1 * egOpen), sin (1.1 * egOpen));
  spRad = Loadv4 (0).y;
  qtVu = Loadv4 (1);
  vuMat = QtToRMat (qtVu);
  w = vec2 (cos (0.05 * tCur), sin (0.05 * tCur));
  vuMat *= mat3 (w.x, 0., - w.y, 0., 1., 0., w.y, 0., w.x);
  rd = normalize (vec3 (uv, 2.6)) * vuMat;
  ro = vec3 (0., - 3. * egOpen, -4. * spRad) * vuMat;
  ltDir = normalize (vec3 (-1., 2., -1.)) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
