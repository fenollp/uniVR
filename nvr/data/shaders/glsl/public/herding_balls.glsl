// Shader downloaded from https://www.shadertoy.com/view/4dKGRt
// written by shadertoy user dr2
//
// Name: Herding Balls
// Description: Herding balls is easier than herding cats
//    
// "Herding Balls" by dr2 - 2016
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

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
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

const int nBall = 64;
vec3 vnBall, sunDir;
float dstFar;
int idBall, idObj;

float ObjDf (vec3 p)
{
  vec3 q;
  float dMin, d;
  dMin = dstFar;
  d = p.y;
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = p;
  q.xz = mod (q.xz + 3., 6.) - 3.;
  q.y -= 0.3;
  d = PrCylDf (q.xzy, 0.48, 0.3);
  if (d < dMin) { dMin = d;  idObj = 2; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 100; j ++) {
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
  float b, d, w, dMin, rad, radSq;
  dMin = dstFar;
  rad = 0.48;
  radSq = rad * rad;
  for (int n = 0; n < nBall; n ++) {
    p = Loadv4 (4 + 2 * n).xy;
    u = ro - vec3 (p.x, 0.5, p.y);
    b = dot (rd, u);
    w = b * b + radSq - dot (u, u);
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

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.01;
  for (int j = 0; j < 15; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 1., 10. * h / d));
    d += min (0.1, 3. * h);
    if (h < 0.001) break;
  }
  return 0.75 + 0.25 * sh;
}

vec3 WoodCol (vec3 p, vec3 n)
{
  float f;
  p *= 20.;
  f = dot (vec3 (Fbm2 (p.zy * vec2 (1., 0.1)),
     Fbm2 (p.xz), Fbm2 (p.xy * vec2 (1., 0.1))), abs (n));
  return mix (vec3 (0.8, 0.4, 0.2), 1.1 * vec3 (0.45, 0.25, 0.1), f);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  float dstObj, dstBall, c, f, sh, spec;
  int idObjT;
  const vec2 e = vec2 (0.01, 0.);
  dstBall = BallRay (ro, rd);
  dstObj = ObjRay (ro, rd);
  sh = 1.;
  if (min (dstBall, dstObj) < dstFar) {
    if (dstObj < dstBall) {
      ro += rd * dstObj;
      idObjT = idObj;
      vn = ObjNf (ro);
      idObj = idObjT;
      if (idObj == 1) {
	    f = Fbm2 (ro.xz);
	    vn = normalize (vec3 (f - Fbm2 (ro.xz + e.xy), 0.05,
	       f - Fbm2 (ro.xz + e.yx)));
	    col = mix (vec3 (0.4, 0.3, 0.1), vec3 (0.4, 0.5, 0.2), f) *
           (1. - 0.1 * Noisefv2 (ro.xz));
        for (int n = 0; n < nBall; n ++) {
          c = length (ro.xz + 0.3 * sunDir.xz - Loadv4 (4 + 2 * n).xy);
          if (c < 0.55) {
            col *= 0.8 + 0.2 * smoothstep (0.4, 0.55, c);
            break;
          }
        }
	    sh = ObjSShadow (ro, sunDir);
	    spec = 0.05;
      } else if (idObj == 2) {
        col = WoodCol (ro, vn);
	    spec = 0.1;
      }
    } else {
      vn = vnBall;
      c = 37. * float (idBall) / float (nBall);
      col = (HsvToRgb (vec3 (mod (c, 1.), 1. - 0.2 * mod (c, 4.),
         1. - 0.07 * mod (c, 7.)))) * BallChqr (idBall, vn);
      spec = 0.4;
    }
    col = col * (0.2 + sh * 0.8 * max (dot (vn, sunDir), 0.)) +
       sh * spec * pow (max (0., dot (sunDir, reflect (rd, vn))), 32.);
  } else col = vec3 (0.);
  return clamp (col, 0., 1.);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 p;
  vec3 rd, ro, u, vd;
  vec2 canvas, uv, rLead, rCent;
  float tCur, az, el, f;
  canvas = iResolution.xy;
  uv = 2. * fragCoord / canvas - 1.;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  dstFar = 100.;
  p = Loadv4 (1);
  rCent = p.xy;
  rLead = p.zw;
  az = pi * (1. + 0.5 * sin (0.01 * pi * tCur));
  el = 0.2 * pi;
  ro = vec3 (rCent.x, 0., rCent.y)  +
     40. * vec3 (cos (el) * sin (az), sin (el), cos (el) * cos (az));
  vd = normalize (vec3 (rLead.x, 0., rLead.y) - ro);
  u = - vd.y * vd;
  f = 1. / sqrt (1. - vd.y * vd.y);
  vuMat = mat3 (f * vec3 (vd.z, 0., - vd.x), f * vec3 (u.x, 1. + u.y, u.z), vd);
  rd = vuMat * normalize (vec3 (uv, 5.5));
  sunDir = normalize (vec3 (0., 1., -1.));
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
