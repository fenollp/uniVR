// Shader downloaded from https://www.shadertoy.com/view/4s3XD2
// written by shadertoy user dr2
//
// Name: This Is Not A Pipe
// Description:   This is clearly not Magritte's masterpiece. But is the 3D form less
//      'not a pipe' than the original?
//    
// "This Is Not A Pipe" by dr2 - 2016
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

float Fbm1 (float p);
float Fbm2 (vec2 p);
float Fbm3 (vec3 p);
vec3 VaryNf (vec3 p, vec3 n, float f);
float SmoothMin (float a, float b, float r);
float SmoothMax (float a, float b, float r);
float SmoothBump (float lo, float hi, float w, float x);
vec2 Rot2D (vec2 q, float a);

const float pi = 3.14159;

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrEllCylDf (vec3 p, vec2 r, float h)
{
  return max ((length (p.xy / r) - 1.) * min (r.x, r.y), abs (p.z) - h);
}

float PrCapsShDf (vec3 p, float r, float w, float h)
{
  p.z -= h * clamp (p.z / h, -1., 1.);
  return abs (length (p) - r) - w;
}

vec3 ltDir;
float dstFar, tCur;
int idObj;

float ObjDf (vec3 p)
{
  vec3 q;
  vec2 rp;
  float dMin, d;
  dMin = dstFar;
  p.x += 1.;
  q = p;
  d = SmoothMax (PrCapsShDf (q.xzy, 0.5, 0.09, 0.3), -0.5 + q.y, 0.05);
  q.y -= smoothstep (0.5, 2.5, q.x) - 0.5;
  q.x -= 1.3;
  rp = vec2 (0.1, 0.17) - vec2 (0.05, 0.06) * (q.x / 0.6 - 1.);
  d = 0.5 * SmoothMin (d, max (SmoothMin (PrEllCylDf (q.yzx, rp, 1.2),
     PrEllCylDf (q.yzx - vec3 (0., 0., 1.2), rp + 0.007, 0.007), 0.05),
     0.03 - length (q.yz * vec2 (1.1, 0.35))), 0.12);
  if (d < dMin) { dMin = d;  idObj = 1; }
  q = p;
  q.y -= 0.3 + 0.03 * Fbm2 (40. * q.xz);
  d = 0.5 * PrCylDf (q.xzy, 0.5, 0.01);
  if (d < dMin) { dMin = d;  idObj = 2; }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 200; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.0005 || dHit > dstFar) break;
  }
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  vec4 v;
  vec3 vn;
  const vec3 e = vec3 (0.001, -0.001, 0.);
  int idObjT;
  idObjT = idObj;
  v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  vn = normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
  idObj = idObjT;
  return vn;
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh, d, h;
  sh = 1.;
  d = 0.02;
  for (int j = 0; j < 30; j ++) {
    h = ObjDf (ro + rd * d);
    sh = min (sh, smoothstep (0., 0.07 * d, h));
    d += max (0.04, 0.08 * d);
    if (sh < 0.05) break;
  }
  return 0.6 + 0.4 * sh;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, col, q;
  float dstObj, sh;
  dstObj = ObjRay (ro, rd);
  if (dstObj < dstFar) {
    ro += rd * dstObj;
    vn = ObjNf (ro);
    if (idObj == 1) {
      q = ro;
      q.xy -= vec2 (0.4);
      q.xy = Rot2D (q.xy, -0.2 * pi);
      if (q.x < -0.03) vn = VaryNf (10. * q, vn, 0.1);
      col = mix ((q.x < 0.) ? mix (vec3 (0.6, 0.3, 0.), vec3 (0.3, 0.1, 0.),
         0.5 * Fbm3 (2. * ro)) : vec3 (0.1), vec3 (0.7, 0.6, 0.),
         SmoothBump (-0.03, 0.03, 0.01, q.x));
      sh = ObjSShadow (ro, ltDir);
      col = col * (0.2 + sh * (0.1 * max (vn.y, 0.) +
         0.8 * max (dot (vn, ltDir), 0.))) +
         0.5 * sh * pow (max (0., dot (ltDir, reflect (rd, vn))), 8.);
    } else if (idObj == 2) {
      col = mix (vec3 (0.7, 0., 0.) * smoothstep (0.1, 1.5, Fbm1 (0.5 * tCur)),
         vec3 (0.1, 0.01, 0.01), clamp (Fbm2 (30. * ro.xz) - 0.3, 0., 1.));
    }
  } else col = vec3 (0.9, 0.8, 0.6);
  return pow (clamp (col, 0., 1.), vec3 (0.7));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  mat3 vuMat;
  vec4 mPtr;
  vec3 ro, rd, col;
  vec2 canvas, uv, uvs, ori, ca, sa;
  float el, az, zmFac;
  canvas = iResolution.xy;
  uv = 2. * fragCoord.xy / canvas - 1.;
  uvs = uv;
  uv.x *= canvas.x / canvas.y;
  tCur = iGlobalTime;
  mPtr = iMouse;
  mPtr.xy = mPtr.xy / canvas - 0.5;
  dstFar = 25.;
  zmFac = 12.;
  az = 0.;
  el = 0.;
  if (mPtr.z > 0.) {
    az += 2. * pi * mPtr.x;
    el += 2. * pi * mPtr.y;
  } else {
    az = 2. * pi * sin (0.05 * tCur);
    el = -0.3 * pi * cos (0.2 * tCur);
  }
  el = clamp (el, - 0.5 * pi, 0.5 * pi);
  ori = vec2 (el, az);
  ca = cos (ori);
  sa = sin (ori);
  vuMat = mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
          mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  rd = vuMat * normalize (vec3 (uv, zmFac));
  ro = vuMat * vec3 (0., 0., -15.);
  ltDir = vuMat * normalize (vec3 (-1., 0.5, -0.5));
  col = ShowScene (ro, rd);
  uvs *= uvs * uvs;
  col *= mix (0.8, 1., pow (1. - 0.5 * length (uvs * uvs), 4.));
  fragColor = vec4 (col, 1.);
}

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

float Fbm1 (float p)
{
  float f, a;
  f = 0.;
  a = 1.;
  for (int i = 0; i < 5; i ++) {
    f += a * Noiseff (p);
    a *= 0.5;
    p *= 2.;
  }
  return f;
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
  for (int i = 0; i < 5; i ++) {
    f += a * Noisefv3a (p);
    a *= 0.5;
    p *= 4. * mr;
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
  g = vec3 (Fbmn (p + e.xyy, n) - s, Fbmn (p + e.yxy, n) - s,
     Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) + q.yx * sin (a) * vec2 (-1., 1.);
}

float SmoothMin (float a, float b, float r)
{
  float h;
  h = clamp (0.5 + 0.5 * (b - a) / r, 0., 1.);
  return mix (b, a, h) - r * h * (1. - h);
}

float SmoothMax (float a, float b, float r)
{
  return - SmoothMin (- a, - b, r);
}

float SmoothBump (float lo, float hi, float w, float x)
{
  return (1. - smoothstep (hi - w, hi + w, x)) * smoothstep (lo - w, lo + w, x);
}
