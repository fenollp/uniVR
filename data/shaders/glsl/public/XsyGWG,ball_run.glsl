// Shader downloaded from https://www.shadertoy.com/view/XsyGWG
// written by shadertoy user dr2
//
// Name: Ball Run
// Description: Lots of balls...
// "Ball Run" by dr2 - 2016
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

float PrCapsDf (vec3 p, float r, float h)
{
  p.z -= h * clamp (p.z / h, -1., 1.);
  return length (p) - r;
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
  float fi = float (idVar);
  return texture2D (txBuf, (vec2 (mod (fi, txRow), floor (fi / txRow)) + 0.5) /
     txSize);
}

mat3 QToRMat (vec4 q) 
{
  mat3 m;
  float a1, a2, s;
  s = q.w * q.w - 0.5;
  m[0][0] = q.x * q.x + s;  m[1][1] = q.y * q.y + s;  m[2][2] = q.z * q.z + s;
  a1 = q.x * q.y;  a2 = q.z * q.w;  m[0][1] = a1 + a2;  m[1][0] = a1 - a2;
  a1 = q.x * q.z;  a2 = q.y * q.w;  m[2][0] = a1 + a2;  m[0][2] = a1 - a2;
  a1 = q.y * q.z;  a2 = q.x * q.w;  m[1][2] = a1 + a2;  m[2][1] = a1 - a2;
  return 2. * m;
}

const int nBall = 70;
vec3 vnBall, ltDir;
float dstFar;
int idBall, idObj;
const vec2 wallSpc = vec2 (8., 4.);
const vec2 obsSpc = vec2 (3., 5.);

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d;
  dMin = dstFar;
  d = min (wallSpc.x - abs (p.x), wallSpc.y - abs (p.y));
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = p;
  q.x = mod (q.x, 2. * obsSpc.x) - obsSpc.x;
  q.y -= - wallSpc.y;
  q.z = mod (q.z + obsSpc.y, 2. * obsSpc.y) - obsSpc.y;
  d = PrCapsDf (q.xzy, 0.5, 0.5);
  if (d < dMin) { dMin = d;  idObj = 2; }
  q = p;
  q.x = abs (q.x) - wallSpc.x - 0.1;
  q.y -= 0.5 * wallSpc.y;
  q.z = mod (q.z, 2. * obsSpc.y) - obsSpc.y;
  d = PrCapsDf (q.xzy, 0.3, 0.4);
  if (d < dMin) { dMin = d;  idObj = 3; }
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

float BallRay (vec3 ro, vec3 rd)
{
  vec3 u;
  vec2 p;
  float b, d, w, dMin, rad;
  dMin = dstFar;
  rad = 0.48;
  for (int n = 0; n < nBall; n ++) {
    p = Loadv4 (4 + 2 * n).xy;
    u = ro - vec3 (p.x, - wallSpc.y + 0.5, p.y);
    b = dot (rd, u);
    w = b * b + rad * rad - dot (u, u);
    if (w >= 0.) {
      d = - b - sqrt (w);
      if (d > 0. && d < dMin) {
        dMin = d;
        vnBall = (u + d * rd) / rad;
        idBall = n;
      }
    }
  }
  return dMin;
}

float BallChqr (int idBall, vec3 vnBall)
{
  vec3 u;
  u = QToRMat (Loadv4 (4 + 2 * idBall + 1)) * vnBall;
  return 0.6 + 0.4 * step (0., sign (u.y) * sign (u.z) * atan (u.x, u.y));
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn, roo;
  float dstObj, dstBall, c, spec, reflAtn;
  int idObjT;
  roo = ro;
  reflAtn = 1.;
  for (int nr = 0; nr < 4; nr ++) {
    dstBall = BallRay (ro, rd);
    dstObj = ObjRay (ro, rd);
    if (min (dstBall, dstObj) < dstFar) {
      if (dstObj < dstBall) {
        ro += rd * dstObj;
        vn = ObjNf (ro);
        if (idObj == 1 && abs (mod (ro.z + obsSpc.y, 2. * obsSpc.y) - obsSpc.y) <
           obsSpc.y - 1. && (vn.y < -0.99 && abs (ro.x) < wallSpc.x - 0.5 ||
           abs (vn.x) > 0.99 && abs (ro.y) < wallSpc.y - 0.5) || idObj == 2 &&
           ro.y > - wallSpc.y + 0.1) {
          rd = reflect (rd, vn);
          ro += 0.01 * rd;
          reflAtn *= 0.85 * reflAtn;
        } else break;
      } else break;
    } else break;
  }
  if (min (dstBall, dstObj) < dstFar) {
    if (dstObj < dstBall) {
      idObjT = idObj;
      vn = ObjNf (ro);
      idObj = idObjT;
      if (idObj == 1) {
        if (vn.y > 0.99) {
          col = mix (vec3 (0.8, 0.4, 0.2), vec3 (0.5, 0.25, 0.1),
             Fbm2 (vec2 (5., 0.5) * ro.xz)) *
             (0.5 + 0.5 * smoothstep (0.05, 0.1, mod (ro.x, 1.)));
          for (int n = 0; n < nBall; n ++) {
            c = length (ro.xz - Loadv4 (4 + 2 * n).xy);
            if (c < 0.5) {
              col *= 0.8 + 0.2 * smoothstep (0.3, 0.45, c);
              break;
            }
          }
        } else {
          col = 1.3 * mix (vec3 (0.8, 0.4, 0.2), vec3 (0.5, 0.25, 0.1),
             Fbm2 (vec2 (2., 0.2) * ro.zy));
        }
        spec = 0.1;
      } else if (idObj == 2) {
        col = vec3 (0.2, 0.1, 0.);
        spec = 0.4;
      } else if (idObj == 3) {
        col = vec3 (1., 1., 0.5) * (0.1 + 0.9 * abs (vn.x));
      }
    } else {
      idObj = -1;
      ro += rd * dstBall;
      vn = vnBall;
      c = 33. * float (idBall) / float (nBall);
      col = HsvToRgb (vec3 (mod (c, 1.), 1. - 0.1 * mod (c, 8.),
         1. - 0.05 * mod (c, 13.))) * BallChqr (idBall, vn);
      spec = 0.4;
    }
    if (idObj != 3) col = col * (0.3 + 0.7 * max (dot (vn, ltDir), 0.)) +
       spec * pow (max (0., dot (ltDir, reflect (rd, vn))), 32.);
    col = mix (col * reflAtn, vec3 (0.05, 0.05, 0.),
       smoothstep (0.6, 1., length (ro - roo) / dstFar));
  } else col = vec3 (0.05, 0.05, 0.);
  return pow (clamp (col, 0., 1.), vec3 (0.9));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 p;
  vec3 rd, ro, u, vd;
  vec2 canvas, uv, rLead, rCent;
  float tCur, f;
  canvas = iResolution.xy;
  uv = 2. * fragCoord / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  dstFar = 300.;
  p = Loadv4 (1);
  rCent = p.xy;
  rLead = p.zw;
  ro = vec3 (rCent.x + 0.5 * sin (0.5 * tCur), -0.5, 22. + rCent.y);
  vd = normalize (vec3 (rLead.x, 0., rLead.y) - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 ((1./0.15) * sin (0.15 * uv), 2.5));
  ltDir = normalize (vec3 (0.25, 1., 0.5));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
