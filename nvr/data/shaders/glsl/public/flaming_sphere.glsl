// Shader downloaded from https://www.shadertoy.com/view/4ls3DH
// written by shadertoy user dr2
//
// Name: Flaming Sphere
// Description: Just a great ball of fire.
// "Flaming Sphere" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

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
  float i, f;
  i = floor (p);  f = fract (p);
  f = f * f * (3. - 2. * f);
  vec2 t = Hashv2f (i);
  return mix (t.x, t.y, f);
}

float Noisefv2 (vec2 p)
{
  vec2 i = floor (p);
  vec2 f = fract (p);
  f = f * f * (3. - 2. * f);
  vec4 t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

float Noisefv3a (vec3 p)
{
  vec3 i, f;
  i = floor (p);  f = fract (p);
  f *= f * (3. - 2. * f);
  vec4 t1 = Hashv4v3 (i);
  vec4 t2 = Hashv4v3 (i + vec3 (0., 0., 1.));
  return mix (mix (mix (t1.x, t1.y, f.x), mix (t1.z, t1.w, f.x), f.y),
              mix (mix (t2.x, t2.y, f.x), mix (t2.z, t2.w, f.x), f.y), f.z);
}

float Fbm3 (vec3 p)
{
  const mat3 mr = mat3 (0., 0.8, 0.6, -0.8, 0.36, -0.48, -0.6, -0.48, 0.64);
  float f, a, am, ap;
  f = 0.;  a = 0.5;
  am = 0.5;  ap = 4.;
  p *= 0.5;
  for (int i = 0; i < 6; i ++) {
    f += a * Noisefv3a (p);
    p *= mr * ap;  a *= am;
  }
  return f;
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

mat3 flMat;
vec3 qHit, qnHit, flPos, fBallPos, sunDir;
float tCur, fBallRad;
const float dstFar = 180.;

vec3 SkyBg (vec3 rd)
{
  const vec3 sbCol = vec3 (0.2, 0.3, 0.55);
  vec3 col;
  col = sbCol + 0.25 * pow (1. - max (rd.y, 0.), 8.);
  return col;
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  vec3 col;
  vec2 p;
  float sd, w, f;
  col = SkyBg (rd);
  sd = max (dot (rd, sunDir), 0.);
  rd.y = abs (rd.y);
  ro.x += 0.5 * tCur;
  p = 0.1 * (rd.xz * (50. - ro.y) / rd.y + ro.xz);
  w = 0.8;
  f = 0.;
  for (int j = 0; j < 4; j ++) {
    f += w * Noisefv2 (p);
    w *= 0.5;
    p *= 2.;
  }
  col += 0.35 * pow (sd, 6.) + 0.65 * min (pow (sd, 256.), 0.3);
  return mix (col, vec3 (0.85), clamp (0.8 * f * rd.y + 0.1, 0., 1.));
}

vec3 TrackPath (float t)
{
  return vec3 (30. * sin (0.35 * t) * sin (0.12 * t) * cos (0.1 * t) +
     26. * sin (0.032 * t), 1. + 3. * sin (0.21 * t) * sin (1. + 0.23 * t),
     10. * t);
}

float GrndHt (vec2 p)
{
  const mat2 qRot = mat2 (1.6, -1.2, 1.2, 1.6);
  vec2 q, t, ta, v;
  float wAmp, pRough, ht;
  wAmp = 2.;
  pRough = 1.;
  q = p * 0.1;
  ht = 0.;
  for (int j = 0; j < 3; j ++) {
    t = q + 2. * Noisefv2 (q) - 1.;
    ta = abs (sin (t));
    v = (1. - ta) * (ta + abs (cos (t)));
    v = pow (1. - v, vec2 (pRough));
    ht += (v.x + v.y) * wAmp;
    q *= 1.5 * qRot;
    wAmp *= 0.25;
    pRough = 0.6 * pRough + 0.2;
  }
  return ht;
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
    s += max (0.25, 0.4 * h) + 0.005 * s;
    if (s > dstFar) break;
  }
  if (h < 0.) {
    sHi = s;
    for (int j = 0; j < 8; j ++) {
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

float FBallHit (vec3 ro, vec3 rd, vec3 p, float s)
{
  vec3 v;
  float h, b, d;
  v = ro - p;
  b = dot (rd, v);
  d = b * b + s * s - dot (v, v);
  h = dstFar;
  if (d >= 0.) {
    h = - b - sqrt (d);
    qHit = ro + h * rd;
    qnHit = (qHit - p) / s;
  }
  return h;
}

float FBallLum (vec3 ro, vec3 rd, float dHit)
{
  vec3 p, q, dp;
  float g, s, fr, f;
  p = ro + dHit * rd - fBallPos;
  dp = (fBallRad / 30.) * rd;
  g = 0.;
  for (int i = 0; i < 30; i ++) {
    p += dp;
    q = 4. * p;   q.y -= 5. * tCur;
    f = Fbm3 (q);
    q = 7. * p;   q.y -= 9. * tCur;
    f += Fbm3 (q);
    s = length (p);
    fr = max (1. - 0.9 * s / fBallRad, 0.);
    g += max (0.15 * fr * (f - 0.55), 0.);
    if (s > fBallRad || g > 1.) break;
  }
  return g;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 flmCol, col, vn;
  float dstHit, dstGrnd, dstFbHit, fIntens, f;
  dstFbHit = FBallHit (ro, rd, fBallPos, fBallRad);
  fIntens = (dstFbHit < dstFar) ? FBallLum (ro, rd, dstFbHit) : 0.;
  dstHit = dstFar;
  dstGrnd = GrndRay (ro, rd);
  if (dstGrnd < dstFar) {
    ro += dstGrnd * rd;
    vn = VaryNf (1.2 * ro, GrndNf (ro, dstHit), 1.);
    col = (mix (vec3 (0.2, 0.4, 0.1), vec3 (0., 0.5, 0.),
       clamp (0.7 * Noisefv2 (ro.xz) - 0.3, 0., 1.))) *
       (0.1 + max (0., max (dot (vn, sunDir), 0.))) +
       0.1 * pow (max (0., dot (sunDir, reflect (rd, vn))), 100.);
    f = dstGrnd / dstFar;
    f *= f;
    col = mix (col, SkyBg (rd), clamp (f * f, 0., 1.));
  } else col = SkyCol (ro, rd);
  if (dstFbHit < dstFar) {
    ro += rd * dstFbHit;
    rd = reflect (rd, qnHit);
    col = 0.9 * col + 0.08 + 0.25 * max (dot (qnHit, sunDir), 0.) * (1. +
       4. * pow (max (0., dot (sunDir, rd)), 128.));
  }
  f = clamp (0.7 * fIntens, 0., 1.);
  f *= f;
  flmCol = 1.5 * (0.7 + 0.3 * Noiseff (20. * tCur)) *
     mix (vec3 (1., 0.1, 0.1), vec3 (1., 1., 0.5), f * f);
  col = mix (col, flmCol, min (1.2 * fIntens * fIntens, 1.));
  if (dstFbHit < dstFar) {
    dstGrnd = GrndRay (ro, rd);
    col = mix (col, ((dstGrnd < dstFar) ? vec3 (0.1, 0.3, 0.1) :
       SkyCol (ro, rd)), pow (1. - abs (dot (rd, qnHit)), 3.));
  }
  return sqrt (clamp (col, 0., 1.));
}

void FlyerPM (float t)
{
  vec3 fpF, fpB, vel, acc, va, ort, cr, sr;
  float vy, dt;
  dt = 2.;
  flPos = TrackPath (t);
  fpF = TrackPath (t + dt);
  fpB = TrackPath (t - dt);
  vel = (fpF - fpB) / (2. * dt);
  vy = vel.y;
  vel.y = 0.;
  acc = (fpF - 2. * flPos + fpB) / (dt * dt);
  acc.y = 0.;
  va = cross (acc, vel) / length (vel);
  vel.y = vy;
  ort = vec3 (0., atan (vel.z, vel.x) - 0.5 * pi, 0.2 * length (va) * sign (va.y));
  cr = cos (ort);
  sr = sin (ort);
  flMat = mat3 (cr.z, - sr.z, 0., sr.z, cr.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., cr.x, - sr.x, 0., sr.x, cr.x) *
     mat3 (cr.y, 0., - sr.y, 0., 1., 0., sr.y, 0., cr.y);
  flPos.y += 7.;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  vec3 ro, rd, col;
  fBallRad = 3.;
  sunDir = normalize (vec3 (1.));
  fBallPos = TrackPath (tCur + 5. + 4. * sin (0.5 * tCur));
  fBallPos.y += 9.;
  FlyerPM (tCur);
  ro = flPos;
  ro.y += 2.;
  rd = normalize (vec3 (uv, 3.)) * flMat;
  col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}

