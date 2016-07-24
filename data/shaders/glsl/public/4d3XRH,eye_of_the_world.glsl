// Shader downloaded from https://www.shadertoy.com/view/4d3XRH
// written by shadertoy user Mr_E
//
// Name: Eye of the world
// Description: A random adaption from https://www.shadertoy.com/view/MlfSWX which was written by dr2.
//    
// A random adaption from https://www.shadertoy.com/view/MlfSWX which was written by dr2.

float PrCapsDf (vec3 p, float r, float h)
{
  return length (p - vec3 (0., 0., h * clamp (p.z / h, -1., 1.))) - r;
}



float tCur, qStep;
vec3 vuPos;
const float mScale = 2.8;
const float dstFar = 30.;

float MBoxDf (vec3 p)
{
  vec4 q, q0;
  const int nIter = 30;
  q0 = vec4 (p, 1.);
  q = q0;
  for (int n = 0; n < nIter; n ++) {
    q.xyz = clamp (q.xyz, -1., 1.) * 2. - q.xyz;
    q *= mScale / clamp (dot (q.xyz, q.xyz), 0.5, 1.);
    q += q0;
  }
  return length (q.xyz) / abs (q.w);
}

float ObjDf (vec3 p)
{
  return max (MBoxDf (p), - PrCapsDf (p - vuPos, 0.2, 0.5));
}

float ObjRay (vec3 ro, vec3 rd)
{
  const int nStep = 50;
  float d, h, s;
  d = 0.;
  s = 0.;
  for (int j = 0; j < nStep; j ++) {
    h = ObjDf (ro + d * rd);
    d += h;
    ++ s;
    if (h < 0.08 || d > dstFar) break;
  }
  qStep = s / float (nStep);
  return d;
}

vec3 ObjNf (vec3 p)
{
  const vec3 e = vec3 (0.001, -0.001, 0.);
  vec4 v = vec4 (ObjDf (p + e.xxx), ObjDf (p + e.xyy),
     ObjDf (p + e.yxy), ObjDf (p + e.yyx));
  return normalize (vec3 (v.x - v.y - v.z - v.w) + 2. * v.yzw);
}

vec3 ShowScene (vec3 ro, vec3 rd)
{
  vec3 ltDir, col, vn;
  float dstHit;
  dstHit = ObjRay (ro, rd);
  ltDir = normalize (vec3 (0.2, 1., -0.2));
  col = vec3 (clamp (0.5 + 1.5 * rd.y, 0., 1.));
  if (dstHit < dstFar) {
    ro += dstHit * rd;
    vn = ObjNf (ro);
    col = vec3(1, 1, 1);
    col = col * (0.3 +
       0.7 * max (dot (vn, ltDir), 0.)) +
       0.3 * pow (max (0., dot (ltDir, reflect (rd, vn))), 16.);
    col = clamp (col, 0., 1.);
  }
  return col;
}

void mainImage (out vec4 fragColor, in vec2 fragCoord)
{
  vec2 uv = 2. * fragCoord.xy / iResolution.xy - 1.;
  uv.x *= iResolution.x / iResolution.y;
  tCur = iGlobalTime;
  vuPos = vec3 (0., 0., -5.5 + mod (.05 * tCur + .3, 9.));
  fragColor = vec4 (ShowScene (vuPos, normalize (vec3 (uv, 5.))), -2.1);
}
