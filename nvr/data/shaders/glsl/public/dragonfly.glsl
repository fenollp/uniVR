// Shader downloaded from https://www.shadertoy.com/view/MsBSW3
// written by shadertoy user dr2
//
// Name: Dragonfly
// Description: A hungry dragonfly.
//    
// "Dragonfly" by dr2 - 2014
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

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

float Length6 (vec2 p)
{
  p *= p * p;
  p *= p;
  return pow (p.x + p.y, 1. / 6.);
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

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

float Fbmn (vec3 p, vec3 n)
{
  vec3 s = vec3 (0.);
  float a = 1.;
  for (int i = 0; i < 3; i ++) {
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

float PrSphDf (vec3 p, float s)
{
  return length (p) - s;
}

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}

int idObj;
mat3 bugMat;
vec3 bugPos, qHit, sunDir, sunCol;
float tCur, szFac;
const float dstFar = 150.;
const float pi = 3.14159;

float WaterHt (vec3 p)
{
  p *= 0.5;
  float ht = 0.;
  const float wb = 1.414;
  float w = 0.2 * wb;
  for (int j = 0; j < 7; j ++) {
    w *= 0.5;
    p = wb * vec3 (p.y + p.z, p.z - p.y, 2. * p.x);
    ht += w * abs (Noisefv3 (p) - 0.5);
  }
  return 0.3 * ht;
}

vec3 WaterNf (vec3 p, float d)
{
  float ht = WaterHt (p);
  vec2 e = vec2 (max (0.01, 0.001 * d * d), 0.);
  return normalize (vec3 (ht - WaterHt (p + e.xyy), e.x, ht - WaterHt (p + e.yyx)));
}

vec3 SkyBg (vec3 rd)
{
  const vec3 sbCol = vec3 (0.2, 0.25, 0.7);
  vec3 col;
  col = sbCol + 0.2 * sunCol * pow (1. - max (rd.y, 0.), 5.);
  return col;
}

vec3 SkyCol (vec3 ro, vec3 rd)
{
  const float skyHt = 50.;
  vec3 col;
  float cloudFac;
  if (rd.y > 0.) {
    ro.x += 10. * tCur;
    vec2 p = 0.01 * (rd.xz * (skyHt - ro.y) / rd.y + ro.xz);
    float w = 0.65;
    float f = 0.;
    for (int j = 0; j < 4; j ++) {
      f += w * Noisefv2 (p);
      w *= 0.5;
      p *= 2.3;
    }
    cloudFac = clamp (5. * (f - 0.5) * rd.y - 0.1, 0., 1.);
  } else cloudFac = 0.;
  float s = max (dot (rd, sunDir), 0.);
  col = SkyBg (rd) + sunCol * (0.35 * pow (s, 6.) +
     0.65 * min (pow (s, 256.), 0.3));
  col = mix (col, vec3 (0.75), cloudFac);
  return col;
}

float StoneRingDf (vec3 p, float r, float w, float n)
{
  vec2 q = vec2 (length (p.xz) - r, p.y);
  float a = atan (p.x, p.z);
  a = 0.2 * pow (abs (sin (a * n)), 0.25) + 0.8;
  return Length6 (q) - w * a;
}

struct WingParm
{
  float span, sRad, trans, thck, tapr;
};

float WingDf (vec3 p, WingParm wg)
{
  float s = abs (p.x - wg.trans);
  float dz = s / wg.span;
  return max (length (abs (p.yz) + vec2 (wg.sRad + wg.tapr * dz * dz * dz, 0.))
     - wg.thck, s - wg.span);
}

float BugDf (vec3 p, float dHit)
{
  vec3 q;
  WingParm wg;
  float d, wr, ws;
  float wSpan = 3.;
  float bdyLen = 2.;
  float wFreq = 21.3;
  float wAngF = cos (wFreq * tCur);
  float wAngB = cos (wFreq * tCur + 0.3 * pi);
  dHit /= szFac;
  p /= szFac;
  ws = 0.11 * (wAngF + 0.3) * max (0., abs (p.x) - 0.12 * bdyLen) / (wSpan * szFac);
  q = p - vec3 (0., 14. * ws, 3. * ws);
  wg = WingParm (0.9 * wSpan, 2.14, 0., 2.17, 0.04);
  d = WingDf (q, wg);
  if (d < dHit) {
    dHit = min (dHit, d);  idObj = 21;  qHit = q;
  }
  ws = 0.13 * (wAngB + 0.3) * max (0., abs (p.x) - 0.12 * bdyLen) / (wSpan * szFac);
  q = p - vec3 (0., 14. * ws, 3. * ws);
  q.z -= 0.38 * bdyLen;
  wg.span *= 1.1;
  d = WingDf (q, wg);
  if (d < dHit) {
    dHit = min (dHit, d);  idObj = 21;  qHit = q;
  }
  q = p;
  q.x = abs (q.x);
  q -= bdyLen * vec3 (0.085, 0.035, 1.);
  d = PrSphDf (q, 0.072 * bdyLen);
  if (d < dHit) {
    dHit = d;  idObj = 22;  qHit = q;
  }
  q = p;
  wr = q.z / bdyLen;
  float tr, u;
  if (wr > 0.5) {
    u = (wr - 0.5) / 0.5;
    tr = 0.17 - 0.11 * u * u;
  } else {
    u = clamp ((wr - 0.5) / 1.5, -1., 1.);
    u *= u;
    tr = 0.17 - u * (0.34 - 0.18 * u); 
  }
  d = PrCapsDf (q, tr * bdyLen, bdyLen);
  if (d < dHit + 0.02) {
    dHit = SmoothMin (dHit, d, 0.02);  idObj = 23;  qHit = q;
  }
  q -= bdyLen * vec3 (0., 0.1 * (wr + 1.) * (wr + 1.), -1.8);
  d = PrCylDf (q, 0.009 * bdyLen, 0.8 * bdyLen);
  if (d < dHit) {
    dHit = min (dHit, d);  idObj = 23;  qHit = q;
  }
  q = p;
  q -= bdyLen * vec3 (0., -0.03, 1.03);
  d = PrSphDf (q, 0.03 * bdyLen);
  if (d < dHit) {
    dHit = d;  idObj = 24;  qHit = q;
  }
  q = p;
  wr = q.y / bdyLen;
  q.x = abs (q.x) - 0.03 * bdyLen;
  q.xz -= 2.4 * wr * wr;
  q -= bdyLen * vec3 (0., 0.17, 0.9);
  d = PrCylDf (q.xzy, 0.01 * bdyLen - 0.2 * wr * wr, 0.1 * bdyLen);
  if (d < dHit) {
    dHit = d;  idObj = 25;  qHit = q;
  }
  return 0.8 * dHit * szFac;
}

vec3 BugCol (vec3 n)
{
  const vec3 wCol = vec3 (1., 1., 0.7), bCol = vec3 (0., 0.1, 0.6),
     mCol = vec3 (0.9, 0.3, 0.), gCol = vec3 (0.8, 0.8, 0.1),
     eCol = vec3 (0.7, 0., 0.1);
  const vec4 g1 = vec4 (-1.2, -0.5, -0.18, -0.05),
     g2 = vec4 (1.65, 0.725, 0.225, 0.1),
     g3 = 1. / vec4 (0.1, 0.075, 0.075, 0.075);
  float cFac = 1.;
  vec3 col;
  qHit *= 5. * szFac;
  if (idObj == 21) {
    col = wCol;
    vec4 b = (g1 * abs (qHit.x) + max (qHit.z, - qHit.z) + g2) * g3;
    vec2 bb = b.xz + step (abs (b.yw), abs (b.xz)) * (b.yw - b.xz);
    float ds = bb.x + step (abs (bb.y), abs (bb.x)) * (bb.y - bb.x);
    ds = sqrt (max (0., 1. - ds * ds)) * sign (ds);
    if (ds != 0.) {
      col *= (1. - 0.2 * abs (ds));
      if (dot (n, sunDir) > 0.) {
	    vec3 nn = bugMat * n;
	    nn.yz = clamp (nn.yz - vec2 (sqrt (1. - ds * ds), ds), -1., 1.);
	    nn = normalize (nn) * bugMat;
	    col *= (1. + 1.5 * max (dot (nn, sunDir), 0.));
      }
    }
  } else if (idObj == 22) {
    col = bCol;
    if (qHit.z > 0.3) {
      col = eCol;
      idObj = 29;
    }
  } else if (idObj == 23) {
    vec3 nn = bugMat * n;
    col = mix (mix (bCol, mCol, smoothstep (0.5, 1.5, nn.y)), wCol,
       1. - smoothstep (-1.3, -0.7, nn.y));
    if (qHit.y < 0.) col *= (1. - 0.3 * SmoothBump (-0.07, 0.07, 0.03, qHit.x));
  } else if (idObj == 24) {
    col = mCol;
  } else if (idObj == 25) {
    col = gCol;
  }
  return col * cFac;
}

struct FlwParm
{
  float spRad, spWid, nRot, bAng, wgThk, wgOff;
};

float FlwDf (vec3 q, float yp, float aa, FlwParm f, float dHit, int id)
{
  q.y -= yp;
  vec3 qq = q;
  float d = max (PrSphDf (qq, f.spRad),
     - PrSphDf (qq - vec3 (0., 0.5 * f.spWid, 0.), f.spRad * (1. - f.spWid)));
  float s = f.nRot / (2. * pi);
  float a = (floor (aa * s) + 0.5) / s;
  qq.xz = cos (a) * qq.xz + sin (a) * qq.zx * vec2 (-1., 1.);
  qq.xy = cos (f.bAng) * qq.xy + sin (f.bAng) * qq.yx * vec2 (1., -1.);
  qq.x += f.wgOff * f.spRad;
  float wgRad = 3. * f.spRad;
  qq.xz /= wgRad;
  d = max (d, wgRad * (sqrt (dot (qq.xz, qq.xz) + 2. * abs (qq.z) + 1.) -
     (1. + f.wgThk)));
  if (d < dHit) {
    dHit = d;  idObj = id;  qHit = q;
  }
  d = PrCylDf (q.xzy + vec3 (0., 0., 0.98 * f.spRad),
     0.05 * f.spRad, 0.04 * f.spRad);
  if (d < dHit) {
    dHit = d;  idObj = 13;  qHit = q;
  }
  return dHit;
}

vec3 FlwCol (vec3 n)
{
  vec3 col;
  float h;
  if (idObj == 11 || idObj == 12) {
    h = 0.6 * abs (asin (qHit.y / length (qHit))) / pi;
  }
  if (idObj == 11) {
    col = HsvToRgb (vec3 (h, 1., 1.));
  } else if (idObj == 12) {
    col = HsvToRgb (vec3 (0.3, 1. - 2. * h, 1. - 2. * h));
  } else if (idObj == 13) {
    col = vec3 (0.3, 0.5, 0.3) * (1. -
       0.5 * SmoothBump (0.3, 0.5, 0.1, mod (20. * qHit.y, 1.)));
  } else if (idObj == 15) {
    col = 0.9 * vec3 (0.6, 0.4, 0.2);
  }
  return col * col;
}

float ObjDf (vec3 p)
{
  float dHit = dstFar;
  float flFac = 1.2;
  vec3 q;
  float vOff = 1.;
  float d;
  float s = 3.3 * (flFac - 1.);
  float aa = atan (p.z, - p.x);
  dHit = FlwDf (p, vOff + s + 0.3 * flFac, aa,
     FlwParm (1. * flFac, 0.02, 21., 0.8, 0.02, 0.9), dHit, 11);
  dHit = FlwDf (p, vOff + s, aa,
     FlwParm (3.3 * flFac, 0.015, 42., 1.5, 0.01, 0.8), dHit, 12);
  d = PrCylDf (p.xzy + vec3 (0.03 * sin (6. * p.y), 0.03 * cos (6. * p.y),
     - (vOff + s) + 1.9 * flFac), 0.03 * flFac, 1.3 * flFac);
  if (d < dHit) {
    dHit = d;  idObj = 13;  qHit = p;
  }
  d = PrCylDf (p.xzy - vec3 (0., 0., vOff - 3.3), 6. * flFac, 0.01);
  if (d < dHit) {
    dHit = d;  idObj = 14;  qHit = p;
  }
  d = StoneRingDf (p - vec3 (0., vOff - 3.1, 0.), 6. * flFac, 0.3 * flFac, 10.);
  if (d < dHit) {
    dHit = d;  idObj = 15;  qHit = p;
  }
  dHit = BugDf (bugMat * (p - bugPos), dHit);
  return dHit;
}

float ObjRay (vec3 ro, vec3 rd)
{
  const float dTol = 0.001;
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
  const vec3 e = vec3 (0.001, -0.001, 0.);
  float v0 = ObjDf (p + e.xxx);
  float v1 = ObjDf (p + e.xyy);
  float v2 = ObjDf (p + e.yxy);
  float v3 = ObjDf (p + e.yyx);
  return normalize (vec3 (v0 - v1 - v2 - v3) + 2. * vec3 (v1, v2, v3));
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float sh = 1.;
  float d = 0.04;
  for (int i = 0; i < 100; i++) {
    float h = ObjDf (ro + rd * d);
    sh = min (sh, 20. * h / d);
    d += 0.04;
    if (h < 0.001) break;
  }
  return clamp (sh, 0., 1.);
}

void BugPM (float t)
{
  float aimHt = 2.;
  float fa = 0.3 * t + pi * (0.3 * sin (0.4 * t) + 0.22 * sin (0.44 * t));
  float fe = pi * (0.35 + 0.1 * sin (0.3 * t) + 0.05 * sin (0.33 * t));
  float fd = 5. + 0.6 * sin (2.5 * t) + 0.3 * sin (2.61 * t);
  bugPos = fd * vec3 (cos (fa) * sin (fe), cos (fe), sin (fa) * sin (fe));
  bugPos.y += aimHt;
  vec3 vo = vec3 (0., aimHt, 0.);
  vec3 vd = normalize (bugPos - vo);
  float azF = 0.5 * pi + atan (vd.z, vd.x);
  float elF = asin (vd.y);
  float rlF = pi * (0.2 * sin (3.2 * t) + 0.15 * sin (3.51 * t));
  vec3 ori = vec3 (elF, azF, rlF);
  vec3 ca = cos (ori);
  vec3 sa = sin (ori);
  bugMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 vn, objCol;
  float dstHit;
  vec3 col = vec3 (0.);
  float spec = 0.5;
  float specEx = 128.;
  dstHit = ObjRay (ro, rd);
  float refFac = 1.;
  if (dstHit < dstFar && idObj == 14) {
    ro += rd * dstHit;
    rd = reflect (rd, WaterNf (qHit, dstHit));
    ro += 0.01 * rd;
    idObj = -1;
    dstHit = ObjRay (ro, rd);
    refFac = 0.8;
  }
  int idObjT = idObj;
  if (idObj < 0) dstHit = dstFar;
  if (dstHit >= dstFar) {
    if (refFac == 1.) col = vec3 (0.);
    else col = refFac * SkyCol (ro, rd);
  } else {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    idObj = idObjT;
    spec = 0.5;
    if (idObj < 20) {
      if (idObj == 15) {
        vn = VaryNf (5. * qHit, vn, 1.);
        spec = 0.1;
      } else if (idObj != 14) vn = VaryNf (100. * qHit, vn, 0.2);
      objCol = FlwCol (vn);
    } else {
      vec3 vno = vn;
      if (idObj != 25) vn = VaryNf (100. * qHit, bugMat * vn, 0.3) * bugMat;
      idObj = idObjT;
      objCol = BugCol (vn);
      spec = 2.;
      if (idObj == 29) {
	    spec = 0.5;
	    specEx = 8.;
      }
    }
    float dif = max (dot (vn, sunDir), 0.);
    col = refFac * (0.2 * objCol * (1. +
       max (dot (vn, - normalize (vec3 (sunDir.x, 0., sunDir.z))), 0.)) +
       max (0., dif) * ObjSShadow (ro, sunDir) *
       (objCol * dif + spec * pow (max (0., dot (sunDir, reflect (rd, vn))), specEx)));
  }
  col = sqrt (clamp (col, 0., 1.));
  return col;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  float zmFac = 3.;
  tCur = iGlobalTime;
  szFac = 1.;
  sunDir = normalize (vec3 (0.5, 1., -0.4));
  sunCol = vec3 (1.);
  float dist = 25.;
  vec3 rd = normalize (vec3 (uv, zmFac));
  float el = 0.9;
  float az = pi * cos (0.01 * tCur) + pi;
  float cEl = cos (el);
  float sEl = sin (el);
  rd = vec3 (rd.x, rd.y * cEl - rd.z * sEl, rd.z * cEl + rd.y * sEl);
  float cAz = cos (az);
  float sAz = sin (az);
  rd = vec3 (rd.x * cAz + rd.z * sAz, rd.y, rd.z * cAz - rd.x * sAz); 
  vec3 ro = - dist * vec3 (cEl * sAz, - sEl, cEl * cAz);
  BugPM (tCur);
  vec3 col = ShowScene (ro, rd);
  fragColor = vec4 (col, 1.);
}
