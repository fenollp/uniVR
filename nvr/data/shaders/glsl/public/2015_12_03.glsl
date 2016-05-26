// Shader downloaded from https://www.shadertoy.com/view/lst3Dr
// written by shadertoy user hughsk
//
// Name: 2015/12/03
// Description: Going overboard with (likely incorrect) reflections here :)
#define GLSLIFY 1

vec2 doModel(vec3 p);

vec2 calcRayIntersection_1_3(vec3 rayOrigin, vec3 rayDir, float maxd, float precis) {
  float latest = precis * 2.0;
  float dist   = +0.0;
  float type   = -1.0;
  vec2  res    = vec2(-1.0, -1.0);

  for (int i = 0; i < 30; i++) {
    if (latest < precis || dist > maxd) break;

    vec2 result = doModel(rayOrigin + rayDir * dist);

    latest = result.x;
    type   = result.y;
    dist  += latest;
  }

  if (dist < maxd) {
    res = vec2(dist, type);
  }

  return res;
}

vec2 calcRayIntersection_1_3(vec3 rayOrigin, vec3 rayDir) {
  return calcRayIntersection_1_3(rayOrigin, rayDir, 20.0, 0.001);
}

vec3 calcNormal_2_4(vec3 pos, float eps) {
  const vec3 v1 = vec3( 1.0,-1.0,-1.0);
  const vec3 v2 = vec3(-1.0,-1.0, 1.0);
  const vec3 v3 = vec3(-1.0, 1.0,-1.0);
  const vec3 v4 = vec3( 1.0, 1.0, 1.0);

  return normalize( v1 * doModel( pos + v1*eps ).x +
                    v2 * doModel( pos + v2*eps ).x +
                    v3 * doModel( pos + v3*eps ).x +
                    v4 * doModel( pos + v4*eps ).x );
}

vec3 calcNormal_2_4(vec3 pos) {
  return calcNormal_2_4(pos, 0.002);
}

vec2 squareFrame_4_1(vec2 screenSize, vec2 coord) {
  vec2 position = 2.0 * (coord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}

mat3 calcLookAtMatrix_5_0(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));

  return mat3(uu, vv, ww);
}

vec3 getRay_6_2(mat3 camMat, vec2 screenPos, float lensLength) {
  return normalize(camMat * vec3(screenPos, lensLength));
}

vec3 getRay_6_2(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
  mat3 camMat = calcLookAtMatrix_5_0(origin, target, 0.0);
  return getRay_6_2(camMat, screenPos, lensLength);
}

void orbitCamera_7_5(
  in float camAngle,
  in float camHeight,
  in float camDistance,
  in vec2 screenResolution,
  out vec3 rayOrigin,
  out vec3 rayDirection,
  in vec2 coord
) {
  vec2 screenPos = squareFrame_4_1(screenResolution, coord);
  vec3 rayTarget = vec3(0.0);

  rayOrigin = vec3(
    camDistance * sin(camAngle),
    camHeight,
    camDistance * cos(camAngle)
  );

  rayDirection = getRay_6_2(rayOrigin, rayTarget, screenPos, 2.0);
}

// Description : Array and textureless GLSL 2D/3D/4D simplex
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//

vec4 mod289_0_6(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

float mod289_0_6(float x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute_0_7(vec4 x) {
     return mod289_0_6(((x*34.0)+1.0)*x);
}

float permute_0_7(float x) {
     return mod289_0_6(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt_0_8(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float taylorInvSqrt_0_8(float r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4_0_9(float j, vec4 ip)
  {
  const vec4 ones = vec4(1.0, 1.0, 1.0, -1.0);
  vec4 p,s;

  p.xyz = floor( fract (vec3(j) * ip.xyz) * 7.0) * ip.z - 1.0;
  p.w = 1.5 - dot(abs(p.xyz), ones.xyz);
  s = vec4(lessThan(p, vec4(0.0)));
  p.xyz = p.xyz + (s.xyz*2.0 - 1.0) * s.www;

  return p;
  }

// (sqrt(5) - 1)/4 = F4, used once below
#define F4 0.309016994374947451

float snoise_0_10(vec4 v)
  {
  const vec4  C = vec4( 0.138196601125011,  // (5 - sqrt(5))/20  G4
                        0.276393202250021,  // 2 * G4
                        0.414589803375032,  // 3 * G4
                       -0.447213595499958); // -1 + 4 * G4

// First corner
  vec4 i  = floor(v + dot(v, vec4(F4)) );
  vec4 x0 = v -   i + dot(i, C.xxxx);

// Other corners

// Rank sorting originally contributed by Bill Licea-Kane, AMD (formerly ATI)
  vec4 i0;
  vec3 isX = step( x0.yzw, x0.xxx );
  vec3 isYZ = step( x0.zww, x0.yyz );
//  i0.x = dot( isX, vec3( 1.0 ) );
  i0.x = isX.x + isX.y + isX.z;
  i0.yzw = 1.0 - isX;
//  i0.y += dot( isYZ.xy, vec2( 1.0 ) );
  i0.y += isYZ.x + isYZ.y;
  i0.zw += 1.0 - isYZ.xy;
  i0.z += isYZ.z;
  i0.w += 1.0 - isYZ.z;

  // i0 now contains the unique values 0,1,2,3 in each channel
  vec4 i3 = clamp( i0, 0.0, 1.0 );
  vec4 i2 = clamp( i0-1.0, 0.0, 1.0 );
  vec4 i1 = clamp( i0-2.0, 0.0, 1.0 );

  //  x0 = x0 - 0.0 + 0.0 * C.xxxx
  //  x1 = x0 - i1  + 1.0 * C.xxxx
  //  x2 = x0 - i2  + 2.0 * C.xxxx
  //  x3 = x0 - i3  + 3.0 * C.xxxx
  //  x4 = x0 - 1.0 + 4.0 * C.xxxx
  vec4 x1 = x0 - i1 + C.xxxx;
  vec4 x2 = x0 - i2 + C.yyyy;
  vec4 x3 = x0 - i3 + C.zzzz;
  vec4 x4 = x0 + C.wwww;

// Permutations
  i = mod289_0_6(i);
  float j0 = permute_0_7( permute_0_7( permute_0_7( permute_0_7(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute_0_7( permute_0_7( permute_0_7( permute_0_7 (
             i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));

// Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  vec4 p0_0_11 = grad4_0_9(j0,   ip);
  vec4 p1 = grad4_0_9(j1.x, ip);
  vec4 p2 = grad4_0_9(j1.y, ip);
  vec4 p3 = grad4_0_9(j1.z, ip);
  vec4 p4 = grad4_0_9(j1.w, ip);

// Normalise gradients
  vec4 norm = taylorInvSqrt_0_8(vec4(dot(p0_0_11,p0_0_11), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0_0_11 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt_0_8(dot(p4,p4));

// Mix contributions from the five corners
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0_0_11, x0 ), dot( p1, x1 ), dot( p2, x2 )))
               + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

  }

float smin_3_12(float a, float b, float k) {
  float h = clamp(0.5 + 0.5 * (b - a) / k, 0.0, 1.0);
  return mix(b, a, h) - k * h * (1.0 - h);
}

vec2 doModel(vec3 p) {
  vec3 P = p;
  
  p.z += iGlobalTime * 2.0;
  p.xzy = mod(p.xzy + 3.0, 6.0) - 3.0;
  
  float r  = 0.75;
  float d  = length(p) - r;
  float id = 0.0;
  
  d = smin_3_12(d, 10.0 - length(P), 3.95);

  return vec2(d, id);
}

bool bounce(vec3 ro, vec3 rd, out vec3 pos, out vec3 nor, out vec3 col) {
  vec2 t = calcRayIntersection_1_3(ro, rd);
  bool hits = t.x > -0.5;
  
  if (hits) {
    pos = ro + rd * t.x;
    nor = calcNormal_2_4(pos);
    col = vec3(0.75, 0.9, 1.25) * max(0.0, dot(nor, normalize(vec3(0, 1, 0))));
  }
  
  return hits;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec3 color = vec3(0.0);
  vec3 ro, rd;

  float rotation = iMouse.z > 0.0 ? 5.0 * (1.0 - iMouse.x / iResolution.x) : iGlobalTime * 0.4;
  float height   = iMouse.z > 0.0 ? 8.0 * (1.0 - iMouse.y / iResolution.y - 0.5) : sin(iGlobalTime * 0.5) * 2.0;
  float dist     = 4.0;
  orbitCamera_7_5(rotation, height, dist, iResolution.xy, ro, rd, fragCoord);
  
  vec3 pos, nor, col;

  for (int i = 0; i < 3; i++) {
    if (!bounce(ro, rd, pos, nor, col)) break;
    color += max(vec3(0.0), col) * pow(0.325, float(i));
    ro = pos + nor * 0.01;
    rd = reflect(rd, nor);
  }

  color = pow(color, vec3(0.4545));
  color.r = smoothstep(-0.05, 1., color.r);
  color.b = smoothstep(0., 0.9, color.b);
  color.g = smoothstep(0., 0.925, color.g);
  color = mix(color, color * length(color), 0.25);
  color -= 0.1;
  
  fragColor.rgb = color;
  fragColor.a   = 1.0;
}