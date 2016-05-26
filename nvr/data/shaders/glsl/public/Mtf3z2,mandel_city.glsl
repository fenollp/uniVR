// Shader downloaded from https://www.shadertoy.com/view/Mtf3z2
// written by shadertoy user dr2
//
// Name: Mandel City
// Description: On a faraway island where the architects are mathematicians...
// "Mandel City" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Branch-free swizzled DDA (Bresenham's algorithm in 3d) suggested
// by fb39ca4 and iq; architecture by BBM.

const vec4 cHashA4 = vec4 (0., 1., 57., 58.);
const vec3 cHashA3 = vec3 (1., 57., 113.);
const float cHashM = 43758.54;

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

float FbmS (vec2 p)
{
  float a = 1.;
  float v = 0.;
  for (int i = 0; i < 5; i ++) {
    v += a * (sin (6. * Noisefv2 (p)) + 1.);
    a *= 0.5;
    p *= 2.;
    p *= mat2 (0.8, -0.6, 0.6, 0.8);
  }
  return v;
}

float tCur;
vec3 fcHit, gCel, sunDir, waterDisp, cloudDisp;
const float dstFar = 200.;

vec3 SkyCol (vec3 ro, vec3 rd)
{
  vec3 col, skyCol, sunCol, p;
  float ds, fd, att, attSum, d, dDotS;
  p = ro + rd * (150. - ro.y) / rd.y;
  ds = 0.1 * sqrt (distance (ro, p));
  fd = 0.003 / (smoothstep (0., 10., ds) + 0.1);
  p.xz *= fd;
  p.xz += cloudDisp.xz;
  att = FbmS (p.xz);
  attSum = att;
  d = fd;
  ds *= fd;
  for (int i = 0; i < 4; i ++) {
    attSum += FbmS (p.xz + d * sunDir.xz);
    d += ds;
  }
  attSum *= 0.27;
  att *= 0.27;
  dDotS = clamp (dot (sunDir, rd), 0., 1.);
  skyCol = mix (vec3 (0.7, 1., 1.), vec3 (1., 0.4, 0.1), 0.25 + 0.75 * dDotS);
  sunCol = vec3 (1., 0.8, 0.7) * pow (dDotS, 1024.) +
     vec3 (1., 0.4, 0.2) * pow (dDotS, 256.);
  col = mix (vec3 (0.5, 0.75, 1.), skyCol, exp (-2. * (3. - dDotS) *
     max (rd.y - 0.1, 0.))) + sunCol;
  attSum = 1. - smoothstep (1., 9., attSum);
  col = mix (vec3 (0.4, 0., 0.2), mix (col, vec3 (0.2), att), attSum) +
     vec3 (1., 0.4, 0.) * pow (attSum * att, 3.) * (pow (dDotS, 10.) + 0.5);
  return col;
}

float WaterHt (vec3 p)
{
  p *= 0.05;
  p += waterDisp;
  float ht = 0.;
  const float wb = 1.414;
  float w = wb;
  for (int j = 0; j < 7; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x) + 20. * waterDisp;
    ht += w * abs (Noisefv3 (p) - 0.5);
  }
  return ht;
}

vec3 WaterNf (vec3 p, float d)
{
  vec2 e = vec2 (max (0.01, 0.001 * d * d), 0.);
  float ht = WaterHt (p);
  return normalize (vec3 (ht - WaterHt (p + e.xyy), e.x,
     ht - WaterHt (p + e.yyx)));
}

float HtMand (vec3 p)
{
  vec3 q;
  vec2 v, w;
  float h;
  h = 0.;
  p.xz *= 0.03;
  p.x -= 0.85;
  q = 0.01 * floor (100. * p);
  if (length (q.xz + vec2 (0.25, 0.)) > 0.45 &&
     length (q.xz + vec2 (1., 0.)) > 0.2 &&
     (q.x < 0. || abs (q.z) > 0.04)) {
    v = q.xz;
    h = 80.;
    for (int j = 0; j < 80; j ++) {
      w = v * v;
      if (w.x + w.y > 4.) {
        h = float (j + 1);
        break;
      } else v = q.xz + vec2 (w.x - w.y, 2. * v.x * v.y);
    }
  }
  return step (0.3 * h, q.y);
}

float ObjRay (vec3 ro, vec3 rd)
{
  vec3 gDir, gv, s, cp, rdi;
  float dHit;
  bool hit;
  gCel = floor (ro);
  gDir = sign (rd);
  gv = max (gDir, 0.) - ro;
  rdi = 1. / rd;
  for (int i = 0; i < 300; i ++) {
    s = (gCel + gv) * rdi;
    cp = step (s, s.yzx);
    fcHit = cp * (1. - cp.zxy);
    gCel += gDir * fcHit;
    hit = (HtMand (gCel) == 0.);
    if (hit) break;
  }
  dHit = hit ? dot ((gCel + gv - gDir) * rdi, fcHit) : dstFar;
  if (length ((ro + rd * dHit).xz - vec2 (8., 0.)) > 50.) dHit = dstFar;
  return dHit;
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 col, vn;
  vec2 fp;
  float dstHit, fcFac, dw;
  sunDir = normalize (vec3 (0., 0.05, 1.));
  cloudDisp = -0.05 * tCur * vec3 (1., 0., 1.);
  waterDisp = -0.005 * tCur * vec3 (-1., 0., 1.);
  dstHit = ObjRay (ro, rd);
  if (rd.y < 0. && dstHit >= dstFar) {
    dw = - (ro.y - 1.) / rd.y;
    ro += dw * rd;
    rd = reflect (rd, WaterNf (ro, dw));
    ro += 0.01 * rd;
    dstHit = ObjRay (ro, rd);
  }
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    vn = - fcHit * sign (rd);
    if (fcHit.y == 0. && gCel.y > 1.) {
      fp = fract ((fcHit.x != 0.) ? ro.yz : ro.yx);
      fcFac = 1. - pow (2. * max (abs (fp.x - 0.5), abs (fp.y - 0.5)), 4.);
      rd = reflect (rd, vn);
      if (Noisefv3 (2. * gCel + 1. + 
         cos (tCur * vec3 (0.71, 0.87, 1.01))) < 0.5)
         col = SkyCol (ro, rd);
      else col = 1.3 * vec3 (0.9, 0.6, 0.);
      col *= fcFac;
    } else {
      if (gCel.y == 0.) col = vec3 (0.05, 0.3, 0.) *
         (0.7 + 0.3 * Noisefv2 (5. * ro.xz));
      else if (fcHit.y == 0.) col = vec3 (0.3, 0.2, 0.);
      else col = vec3 (0.5, 0.4, 0.2) * clamp (0.2 * gCel.y, 0., 1.);
      col *= (0.3 + 0.7 * max (0., dot (sunDir, vn)));
    }
  } else col = SkyCol (ro, rd);
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  vec3 ro, rd;
  vec2 vEl, vAz;
  float az, el;
  az = -0.5 + 0.05 * tCur;
  el = 0.34;
  vEl = vec2 (cos (el), sin (el));
  vAz = vec2 (cos (az), sin (az));
  vuMat = mat3 (1., 0., 0., 0., vEl.x, - vEl.y, 0., vEl.y, vEl.x) *
     mat3 (vAz.x, 0., vAz.y, 0., 1., 0., - vAz.y, 0., vAz.x);
  rd = normalize (vec3 (uv, 3.)) * vuMat;
  ro = vec3 (0., 0., -120.) * vuMat;
  ro.xy += vec2 (8., 5.);
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
