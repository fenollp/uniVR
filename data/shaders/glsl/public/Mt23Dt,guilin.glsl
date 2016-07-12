// Shader downloaded from https://www.shadertoy.com/view/Mt23Dt
// written by shadertoy user dr2
//
// Name: Guilin
// Description: An idealized version of an amazing landscape.
// "Guilin" by dr2 - 2015
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

vec2 Hashv2v2 (vec2 p)
{
  const vec2 cHashVA2 = vec2 (37.1, 61.7);
  const vec2 e = vec2 (1., 0.);
  return fract (sin (vec2 (dot (p + e.yy, cHashVA2),
     dot (p + e.xy, cHashVA2))) * cHashM);
}

float Noisefv2 (vec2 p)
{
  vec2 i, f;
  i = floor (p);  f = fract (p);
  f = f * f * (3. - 2. * f);
  vec4 t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

float Fbm2 (vec2 p)
{
  float s = 0.;
  float a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * Noisefv2 (p);
    a *= 0.5;
    p *= 2.;
  }
  return s;
}

float Fbmn (vec3 p, vec3 n)
{
  vec3 s = vec3 (0.);
  float a = 1.;
  for (int i = 0; i < 5; i ++) {
    s += a * vec3 (Noisefv2 (p.yz), Noisefv2 (p.zx), Noisefv2 (p.xy));
    a *= 0.5;
    p *= 2.;
  }
  return dot (s, abs (n));
}

vec3 VaryNf (vec3 p, vec3 n, float f)
{
  vec3 e = vec3 (0.2, 0., 0.);
  float s = Fbmn (p, n);
  vec3 g = vec3 (Fbmn (p + e.xyy, n) - s,
     Fbmn (p + e.yxy, n) - s, Fbmn (p + e.yyx, n) - s);
  return normalize (n + f * (g - n * dot (n, g)));
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

mat3 flMat;
vec3 flPos, qHit, noiseDisp;
float tCur;
int idObj;
const float dstFar = 100.;

vec3 TrackPath (float t)
{
  return vec3 (20. * sin (0.2 * t) * sin (0.11 * t) * cos (0.07 * t) +
     19. * sin (0.02 * t), 1.3, 0.6 * t);
}

float GrndHt (vec2 p)
{
  return 0.1 + 0.05 * smoothstep (0.6, 1.3, Fbm2 (2. * p));
}

float GrndRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, h, s, sLo, sHi;
  s = 0.;
  sLo = 0.;
  dHit = dstFar;
  for (int j = 0; j < 150; j ++) {
    p = ro + s * rd;
    h = p.y - GrndHt (p.xz);
    if (h < 0.) break;
    sLo = s;
    s += max (0.3, 0.4 * h) + 0.01 * s;
    if (s > dstFar) break;
  }
  if (h < 0.) {
    sHi = s;
    for (int j = 0; j < 4; j ++) {
      s = 0.5 * (sLo + sHi);
      p = ro + s * rd;
      h = step (0., p.y - GrndHt (p.xz));
      sLo += h * (s - sLo);
      sHi += (1. - h) * (s - sHi);
    }
    dHit = sHi;
  }
  return dHit;
}

vec3 GrndNf (vec3 p, float d)
{
  float ht = GrndHt (p.xz);
  vec2 e = vec2 (max (0.01, 0.00001 * d * d), 0.);
  return normalize (vec3 (ht - GrndHt (p.xz + e.xy), e.x,
     ht - GrndHt (p.xz + e.yx)));
}

float ObjDf (vec3 p)
{
  vec3 g, q;
  float dMin, d, r, ht, rad, a, aa;
  dMin = dstFar;
  g.xz = floor ((p.xz + 2.) / 4.);
  q = p;
  q.xz -= g.xz * 4.;
  q.xz += 1.6 * (Hashv2v2 (21. * g.zx) - 0.5);
  q.xz = Rot2D (q.xz, 2. * pi * Hashfv2 (13.55 * g.xz));
  aa = 0.15 * Hashfv2 (12.4 * g.xz);
  q.xy = Rot2D (q.xy, aa);
  a = atan (q.z, q.x) / (2. * pi) + 0.5;
  ht = 0.2 + 0.5 * Hashfv2 (11.2 * g.xz);
  rad = 0.3 + 0.2 * Hashfv2 (11.7 * g.xz);
  r = max (0., (ht + rad - q.y) / (ht + rad));
  d = PrCapsDf (q.xzy, (1. + 0.3 * r * r) * rad *
     (1. + 0.15 * clamp (0.7 * r, 0., 1.) * abs (sin (30. * pi * a))), ht);
  d = min (d, p.y + 0.1);
  if (d < dMin) { dMin = d;  idObj = 1;  qHit = q; }
  if (ht > 0.5) {
    q.y -= ht + rad - 0.02;
    q.xy = Rot2D (q.xy, - aa);
    d = max (PrCylDf (q.xzy, 0.3 * rad, 0.04),
       - PrCylDf (q.xzy, 0.25 * rad, 0.05));
    if (d < dMin) { dMin = d;  idObj = 2;  qHit = q; }
    d = PrCapsDf (q.xzy, 0.02, 0.11);
    if (d < dMin) { dMin = d;  idObj = 3;  qHit = q; }
  }
  return dMin;
}

float ObjRay (vec3 ro, vec3 rd)
{
  float dHit, d;
  dHit = 0.;
  for (int j = 0; j < 150; j ++) {
    d = ObjDf (ro + dHit * rd);
    dHit += d;
    if (d < 0.001 || dHit > dstFar) break;
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

float FrAbsf (float p)
{
  return abs (fract (p) - 0.5);
}

vec3 FrAbsv3 (vec3 p)
{
  return abs (fract (p) - 0.5);
}

float TriNoise3d (vec3 p)
{
  vec3 q;
  float a, f;
  a = 2.;
  f = 0.;
  q = p;
  for (int j = 0; j < 4; j ++) {
    p += FrAbsv3 (q + FrAbsv3 (q).yzx) + noiseDisp;
    p *= 1.2;
    f += a * (FrAbsf (p.x + FrAbsf (p.y + FrAbsf (p.z))));
    q = 2. * q + 0.2;
    a *= 0.7;
  }
  return f;
}

float FogAmp (vec3 p, float d)
{
  vec3 q;
  q = p + noiseDisp;
  q.x += 0.3 * sin (tCur * 1.5);
  q.z += sin (0.5 * q.x);
  q.y *= 2.;
  q.y += 0.2 * sin (0.3 * q.x) + 0.1 * sin (tCur * 0.6);
  return 0.2 * TriNoise3d (1.5 * q / (d + 30.)) *
     (1. - smoothstep (1., 7., p.y)) * (2. - smoothstep (0., 0.2, p.y));
}

vec3 FogCol (vec3 col, vec3 ro, vec3 rd, float dHit)
{
  vec3 q;
  float d, dq, fFac, f, fa;
  d = 2.5;
  dq = 0.2;
  fFac = 1.;
  for (int i = 0; i < 6; i ++) {
    q = ro + rd * d;
    f = FogAmp (q, d);
    fa = 1. - clamp (f - FogAmp (q + dq, d), 0., 1.);
    col = mix (col, vec3 (0.95, 0.95, 0.9) * fa,
       clamp (fFac * f * smoothstep (0.9 * d, 2.3 * d, dHit), 0., 1.));
    d *= 1.6;
    dq *= 0.8;
    fFac *= 1.1;
    if (d > dHit) break;
  }
  return col;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn, roo, ltDir;
  float dstHit, dstGrnd, dstObj;
  ltDir = normalize (vec3 (-1., 1., -1.));
  noiseDisp = 0.05 * tCur * vec3 (-1., 0., 1.);
  dstHit = dstFar;
  roo = ro;
  dstGrnd = GrndRay (ro, rd);
  idObj = -1;
  dstObj = ObjRay (ro, rd);
  if (idObj < 0) dstObj = dstFar;
  vec3 skyCol = vec3 (0.5, 0.6, 0.9) - rd.y * 0.2 * vec3 (1., 0.5, 1.) +
     0.2 * vec3 (1., 0.6, 0.1) * pow (clamp (dot (ltDir, rd), 0., 1.), 8.);
  dstHit = min (dstObj, dstGrnd);
  if (dstHit >= dstFar) col = skyCol;
  else {
    if (dstHit < dstGrnd) {
      ro += rd * dstHit;
      vn = ObjNf (ro);
      if (idObj == 1) {
	vn = VaryNf (20. * qHit, vn, 2.);
	col = mix (vec3 (0.3, 0.5, 0.1), vec3 (0.55, 0.5, 0.45),
	   clamp (1.4 * ro.y, 0., 1.));
      } else if (idObj == 2) {
        vn = VaryNf (10. * qHit, vn, 1.);
        col = vec3 (0.6, 0.4, 0.3);
      } else if (idObj == 3) {
        col = vec3 (1., 1., 0.) * (0.8 - 0.2 * dot (vn, rd));
      }
      if (idObj != 3) col = col * (0.55 + 0.45 * max (dot (vn, ltDir), 0.)) ;
    } else {
      ro += rd * dstHit;
      vn = GrndNf (ro, dstHit);
      vn = VaryNf (10. * ro, vn, 0.3);
      col = mix (vec3 (0.6, 0.3, 0.2), vec3 (0.4, 0.7, 0.3),
	 clamp (5. * ro.y, 0., 1.));
      col = col * (0.6 + 0.4 * max (dot (vn, ltDir), 0.)) ;
    }
    col = mix (vec3 (0.5, 0.6, 0.9), col,
       exp (- 2. * clamp (5. * (dstHit / dstFar - 0.8), 0., 1.)));
  }
  col = FogCol (col, roo, rd, min (dstGrnd, dstObj));
  return col;
}

void FlyerPM (float t)
{
  vec3 fpF, fpB, vel, acc, va, ort, cr, sr;
  float dt;
  dt = 2.;
  flPos = TrackPath (t);
  fpF = TrackPath (t + dt);
  fpB = TrackPath (t - dt);
  vel = (fpF - fpB) / (2. * dt);
  vel.y = 0.;
  acc = (fpF - 2. * flPos + fpB) / (dt * dt);
  acc.y = 0.;
  va = cross (acc, vel) / length (vel);
  ort = vec3 (0.2, atan (vel.z, vel.x) - 0.5 * pi, 0.2 * length (va) * sign (va.y));
  cr = cos (ort);
  sr = sin (ort);
  flMat = mat3 (cr.z, - sr.z, 0., sr.z, cr.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., cr.x, - sr.x, 0., sr.x, cr.x) *
     mat3 (cr.y, 0., - sr.y, 0., 1., 0., sr.y, 0., cr.y);
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  vec3 rd, ro;
  FlyerPM (tCur);
  ro = flPos;
  rd = normalize (vec3 (uv, 2.)) * flMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
