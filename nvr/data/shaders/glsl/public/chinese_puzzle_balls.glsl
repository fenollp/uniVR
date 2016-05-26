// Shader downloaded from https://www.shadertoy.com/view/XlsXRr
// written by shadertoy user dr2
//
// Name: Chinese Puzzle Balls
// Description: Chinese Puzzle Balls (no ivory and no decorations).
// "Chinese Puzzle Balls" by dr2 - 2015
// License: Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License

// Octavio Good's "Protophore" got me thinking about this.

const float pi = 3.14159;

float PrCylDf (vec3 p, float r, float h)
{
  return max (length (p.xy) - r, abs (p.z) - h);
}

float PrTorusDf (vec3 p, float ri, float rc)
{
  vec2 q = vec2 (length (p.xy) - rc, p.z);
  return length (q) - ri;
}

vec2 Rot2D (vec2 q, float a)
{
  return q * cos (a) * vec2 (1., 1.) + q.yx * sin (a) * vec2 (-1., 1.);
}

float SmoothMin (float a, float b, float k)
{
  float h = clamp (0.5 + 0.5 * (b - a) / k, 0., 1.);
  return mix (b, a, h) - k * h * (1. - h);
}

vec3 HsvToRgb (vec3 c)
{
  vec3 p = abs (fract (c.xxx + vec3 (1., 2./3., 1./3.)) * 6. - 3.);
  return c.z * mix (vec3 (1.), clamp (p - 1., 0., 1.), c.y);
}

float aSpin, sHole, redFac, tCur;
int idObj;
const float dstFar = 100.;

float ObjDf (vec3 p)
{
  vec3 q;
  float cLen, rad, smVal, dMin, d, aRot, r;
  dMin = dstFar;
  rad = 1.;
  smVal = 0.02;
  q = p;
  d = PrTorusDf (q.xzy, 0.03 * rad, 1.02 * rad);
  if (d < dMin) { dMin = d;  idObj = 11; }
  q.xz = abs (q.xz) - 0.707 * 1.02 * rad;
  cLen = 0.7;
  q.y -= - cLen;
  d = PrCylDf (q.xzy, 0.03, cLen);
  if (d < dMin) { dMin = d;  idObj = 11; }
  aRot = 1.5 * aSpin;
  q = p;
  for (int j = 0; j < 10; j ++) {
    r = length (q);
    d = max (r - rad, - (r - 1.03 * redFac * rad));
    d = - SmoothMin (- d, length (abs (q) - 0.5 * rad) - rad * sHole, smVal);
    if (d < dMin) { dMin = d;  idObj = j; }
    q = q.yzx;
    q.xz = Rot2D (q.xz, aRot);
    rad *= redFac;
    smVal *= redFac;
    aRot *= 1.23;
  }
  return dMin;
}

vec3 ObjNf (vec3 p)
{
  vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * vec3 (v.y, v.z, v.w));
}

float ObjAO (vec3 ro, vec3 rd)
{
  float ao = 0.;
  for (int j = 0; j < 8; j ++) {
    float d = 0.3 * float (j + 1) / 8.;
    ao += max (0., d - 3. * ObjDf (ro + d * rd));
  }
  return clamp (1. - 0.6 * ao, 0., 1.);
}

float ObjRay (vec3 ro, vec3 rd)
{
  float d, h;
  d = 0.;
  for (int j = 0; j < 100; j ++) {
    h = ObjDf (ro + d * rd);
    d += h;
    if (h < 0.001 || d > dstFar) break;
  }
  return d;
}

float ObjSShadow (vec3 ro, vec3 rd)
{
  float d, h, sh;
  sh = 1.;
  d = 0.05;
  for (int j = 0; j < 50; j ++) {
    h = ObjDf (ro + d * rd);
    sh = min (sh, 20. * h / d);
    d *= 1.04;
    if (h < 0.0001) break;
  }
  return clamp (sh, 0., 1.);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 ltDir, col, bgCol, vn;
  float dstHit, ts, amb, bAmb, fi, c, sh, bk;
  int idObjT;
  ts = fract (tCur * 0.333 + 0.125) - 0.25;
  aSpin = 0.1 * (tCur + max (0., ts) - 3. * min (0., ts));
  sHole = clamp (1.1 + sin (tCur * 0.4), 0.17, 0.51);
  redFac = 0.87;
  dstHit = dstFar;
  dstHit = ObjRay (ro, rd);
  ltDir = normalize (vec3 (0.2, 1., -0.1));
  col = vec3 (0.);
  bAmb = 1.;
  idObjT = idObj;
  if (dstHit < dstFar) {
    ro += rd * dstHit;
    vn = ObjNf (ro);
    amb = ObjAO (ro, vn);
    rd = reflect (rd, vn);
    if (idObjT <= 10) {
      fi = 0.1 * float (idObjT);
      col = HsvToRgb (vec3 (fi, 1., 1.));
    } else {
      col = vec3 (0.5, 0.5, 0.);
    }
    bk = max (dot (vn, - normalize (vec3 (ltDir.x, 0., ltDir.z))), 0.);
    sh = ObjSShadow (ro, ltDir);
    col = col * (0.2 + 0.2 * bk +
       sh * 0.8 * max (dot (vn, ltDir), 0.)) +
       sh * 0.5 * pow (max (0., dot (ltDir, reflect (rd, vn))), 64.);
    bAmb = 0.2 * amb;
  }
  c = (rd.y > max (abs (rd.x), abs (rd.z * 0.25))) ? min (2. * rd.y, 1.) :
     0.05 * (1. + dot (rd, ltDir));
  if (rd.y > 0.) c += 0.5 * pow (clamp (1.05 - 0.5 *
     length (max (abs (rd.xz / rd.y) - vec2 (1., 4.), 0.)), 0., 1.), 6.);
  bgCol = vec3 (0.5, 0.5, 1.) * c + 2. * vec3 (1., 0.8, 0.9) *
     (clamp (0.0002 / (1. - abs (rd.x)), 0., 1.) +
      clamp (0.0002 / (1. - abs (rd.z)), 0., 1.));
  col += bAmb * bgCol;
  return sqrt (clamp (col, 0., 1.));
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  mat3 vuMat;
  vec3 ro, rd, ca, sa;
  float el, az;
  az = 0.25 * pi - 0.1 * tCur;
  el = 0.4 + 0.1 * sin (0.3 * tCur);
  ca = cos (vec3 (el, az, 0.));
  sa = sin (vec3 (el, az, 0.));
  vuMat = mat3 (ca.z, - sa.z, 0., sa.z, ca.z, 0., 0., 0., 1.) *
     mat3 (1., 0., 0., 0., ca.x, - sa.x, 0., sa.x, ca.x) *
     mat3 (ca.y, 0., - sa.y, 0., 1., 0., sa.y, 0., ca.y);
  rd = normalize (vec3 (uv, 4.)) * vuMat;
  ro = vec3 (0., 0., -5.) * vuMat;
  fragColor = vec4 (ShowScene (ro, rd), 1.);
}
