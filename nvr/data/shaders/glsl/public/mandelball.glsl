// Shader downloaded from https://www.shadertoy.com/view/llBXRD
// written by shadertoy user dr2
//
// Name: Mandelball
// Description: Testing the buoyancy of a fractal.
// "Mandelball" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

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
  vec2 i = floor (p);
  vec2 f = fract (p);
  f = f * f * (3. - 2. * f);
  vec4 t = Hashv4f (dot (i, cHashA3.xy));
  return mix (mix (t.x, t.y, f.x), mix (t.z, t.w, f.x), f.y);
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

mat3 ballMat;
vec3 ballPos, sunDir, cloudDisp, waterDisp;
float tCur, qStep;
const float dstFar = 100.;

vec3 SkyCol (vec3 ro, vec3 rd)
{
  vec3 col;
  vec2 p;
  float sd, w, f;
  col = vec3 (0.15, 0.25, 0.5) + 0.2 * pow (1. - max (rd.y, 0.), 8.);
  sd = max (dot (rd, sunDir), 0.);
  rd.y = abs (rd.y);
  ro += cloudDisp;
  p = 0.2 * (rd.xz * (20. - ro.y) / rd.y + ro.xz);
  w = 1.;
  f = 0.;
  for (int j = 0; j < 4; j ++) {
    f += w * Noisefv2 (p);
    w *= 0.5;
    p *= 2.;
  }
  col += 0.35 * pow (sd, 6.) + 0.65 * min (pow (sd, 256.), 0.3);
  return mix (col, vec3 (1.), clamp (0.8 * f * rd.y + 0.1, 0., 1.));
}

float WaveHt (vec3 p)
{
  const mat2 qRot = mat2 (1.6, -1.2, 1.2, 1.6);
  vec4 t4, ta4, v4;
  vec2 q2, t2, v2;
  float wFreq, wAmp, pRough, ht;
  wFreq = 0.3;  wAmp = 0.3;  pRough = 5.;
  q2 = p.xz + waterDisp.xz;
  ht = 0.;
  for (int j = 0; j < 4; j ++) {
    t2 = tCur * vec2 (1., -1.);
    t4 = vec4 (q2 + t2.xx, q2 + t2.yy) * wFreq;
    t2 = vec2 (Noisefv2 (t4.xy), Noisefv2 (t4.zw));
    t4 += 2. * vec4 (t2.xx, t2.yy) - 1.;
    ta4 = abs (sin (t4));
    v4 = (1. - ta4) * (ta4 + abs (cos (t4)));
    v2 = pow (1. - sqrt (v4.xz * v4.yw), vec2 (pRough));
    ht += (v2.x + v2.y) * wAmp;
    q2 *= qRot;  wFreq *= 2.;  wAmp *= 0.25;
    pRough = 0.8 * pRough + 0.2;
  }
  return ht;
}

float WaveRay (vec3 ro, vec3 rd)
{
  vec3 p;
  float dHit, h, s, sLo, sHi;
  dHit = dstFar;
  if (rd.y < 0.) {
    s = 0.;
    sLo = 0.;
    for (int j = 0; j < 80; j ++) {
      p = ro + s * rd;
      h = p.y - WaveHt (p);
      if (h < 0.) break;
      sLo = s;
      s += max (0.3, h) + 0.005 * s;
      if (s > dstFar) break;
    }
    if (h < 0.) {
      sHi = s;
      for (int j = 0; j < 4; j ++) {
        s = 0.5 * (sLo + sHi);
        p = ro + s * rd;
        h = step (0., p.y - WaveHt (p));
        sLo += h * (s - sLo);
        sHi += (1. - h) * (s - sHi);
      }
      dHit = sHi;
    }
  }
  return dHit;
}

vec3 WaveNf (vec3 p, float d)
{
  vec2 e = vec2 (max (0.1, 0.01 * d), 0.);
  float h = WaveHt (p);
  return normalize (vec3 (h - WaveHt (p + e.xyy), e.x, h - WaveHt (p + e.yyx)));
}

float ObjDf (vec3 p)
{
  float mScale = 2.;
  vec4 q, q0;
  const int nIter = 12;
  p *= ballMat;
  p -= ballPos;
  q0 = vec4 (p, 1.);
  q = q0;
  for (int n = 0; n < nIter; n ++) {
    q.xyz = clamp (q.xyz, -1., 1.) * 2. - q.xyz;
    q = q * mScale / clamp (dot (q.xyz, q.xyz), 0.5, 1.) + q0;
  }
  return max (length (q.xyz) / abs (q.w), length (p) - 6.);
}

float ObjRay (vec3 ro, vec3 rd)
{
  const int nStep = 100;
  float dHit, h, s;
  dHit = 0.;
  s = 0.;
  for (int j = 0; j < nStep; j ++) {
    h = ObjDf (ro + dHit * rd);
    dHit += h;
    ++ s;
    if (h < 0.001 || dHit > dstFar) break;
  }
  if (h >= 0.001) dHit = dstFar;
  qStep = s / float (nStep);
  return dHit;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.01, -0.01, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 c1 = vec3 (1.5, 0.2, 0.), c2 = vec3 (0.1, 0.55, 0.5);
  vec3 col, vn;
  float dstObj, dstWat;
  col = vec3 (1.);
  dstObj = ObjRay (ro, rd);
  dstWat = WaveRay (ro, rd);
  if (dstObj < min (dstWat, dstFar)) {
    ro += rd * dstObj;
    vn = ObjNf (ro);
    rd = reflect (rd, vn);
    col = mix (c1, col, max (0., 1. - 1.3 * qStep));
    dstWat = WaveRay (ro, rd);
    if (dstWat < dstFar) {
      ro += rd * dstWat;
      vn = WaveNf (ro, dstWat);
      rd = reflect (rd, vn);
      col = mix (c2, col, pow (1. - abs (dot (rd, vn)), 5.));
    }
  } else if (dstWat < min (dstObj, dstFar)) {
    ro += rd * dstWat;
    vn = WaveNf (ro, dstWat);
    rd = reflect (rd, vn);
    col = mix (c2, col, pow (1. - abs (dot (rd, vn)), 5.));
    dstObj = ObjRay (ro, rd);
    if (dstObj < dstFar) {
      ro += rd * dstObj;
      vn = ObjNf (ro);
      rd = reflect (rd, vn);
      col = mix (c1, col, max (0., 1. - 1.3 * qStep));
    }
  }
  col *= SkyCol (ro, rd);
  return clamp (col, 0., 1.);
}

void BallPM ()
{
  const vec3 e = vec3 (4., 0., 0.);
  float h[5], b, a, c, s;
  ballPos = vec3 (0.);
  h[0] = WaveHt (ballPos);
  h[1] = WaveHt (ballPos + e.yyx);  h[2] = WaveHt (ballPos - e.yyx);
  h[3] = WaveHt (ballPos + e);  h[4] = WaveHt (ballPos - e);
  ballPos.y = 0.5 + (2. * h[0] + h[1] + h[2] + h[3] + h[4]) / 6.;
  b = (h[1] - h[2]) / (2. * e.x);
  ballMat[2] = normalize (vec3 (0., b, 0.5));
  b = (h[3] - h[4]) / (2. * e.x);
  ballMat[1] = normalize (cross (ballMat[2], vec3 (0.5, b, 0.)));
  ballMat[0] = cross (ballMat[1], ballMat[2]);
  a = 0.4 * sin (0.03 * tCur);
  c = cos (a);
  s = sin (a);
  ballMat *= mat3 (c, 0., s, 0., 1., 0., - s, 0., c);
  ballPos.y += 4. * sin (0.1 * tCur) - 1.;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  vec3 ro, rd;
  sunDir = normalize (vec3 (1., 1., -1.));
  cloudDisp = tCur * vec3 (0., 0., 1.);
  waterDisp = 0.2 * tCur * vec3 (-1., 0., 1.);
  rd = normalize (vec3 (uv, 2.));
  ro = vec3 (0., 3., -20.);
  rd.xz = Rot2D (rd.xz, - pi / 4.);
  ro.xz = Rot2D (ro.xz, - pi / 4.);
  BallPM ();
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
