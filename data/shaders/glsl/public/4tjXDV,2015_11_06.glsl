// Shader downloaded from https://www.shadertoy.com/view/4tjXDV
// written by shadertoy user hughsk
//
// Name: 2015/11/06
// Description: This one's a day late :) Playing with change over time and ray/sphere casting.
float t = iChannelTime[0];

vec2 noiseOffset = vec2(-t * 0.15, 0);

vec2 squareFrame_6_0(vec2 screenSize, vec2 coord) {
  vec2 position = 2.0 * (coord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}



mat3 calcLookAtMatrix_8_1(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));

  return mat3(uu, vv, ww);
}




vec3 getRay_7_2(mat3 camMat, vec2 screenPos, float lensLength) {
  return normalize(camMat * vec3(screenPos, lensLength));
}

vec3 getRay_7_2(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
  mat3 camMat = calcLookAtMatrix_8_1(origin, target, 0.0);
  return getRay_7_2(camMat, screenPos, lensLength);
}




void orbitCamera_2_3(
  in float camAngle,
  in float camHeight,
  in float camDistance,
  in vec2 screenResolution,
  out vec3 rayOrigin,
  out vec3 rayDirection,
  in vec2 fragCoord
) {
  vec2 screenPos = squareFrame_6_0(screenResolution, fragCoord);
  vec3 rayTarget = vec3(0.0);

  rayOrigin = vec3(
    camDistance * sin(camAngle),
    camHeight,
    camDistance * cos(camAngle)
  );

  rayDirection = getRay_7_2(rayOrigin, rayTarget, screenPos, 2.25);
}



//
// Description : Array and textureless GLSL 2D/3D/4D simplex
//               noise functions.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
//

vec3 mod289_1_4(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289_1_4(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute_1_5(vec4 x) {
     return mod289_1_4(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt_1_6(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise_1_7(vec3 v)
  {
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D_1_8 = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g_1_9 = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g_1_9;
  vec3 i1 = min( g_1_9.xyz, l.zxy );
  vec3 i2 = max( g_1_9.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D_1_8.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289_1_4(i);
  vec4 p = permute_1_5( permute_1_5( permute_1_5(
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D_1_8.wyz - D_1_8.xzx;

  vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

  vec4 x_ = floor(j * ns.z);
  vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

  vec4 x = x_ *ns.x + ns.yyyy;
  vec4 y = y_ *ns.x + ns.yyyy;
  vec4 h = 1.0 - abs(x) - abs(y);

  vec4 b0 = vec4( x.xy, y.xy );
  vec4 b1 = vec4( x.zw, y.zw );

  //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
  //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
  vec4 s0 = floor(b0)*2.0 + 1.0;
  vec4 s1 = floor(b1)*2.0 + 1.0;
  vec4 sh = -step(h, vec4(0.0));

  vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
  vec4 a1_1_10 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0_1_11 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1_1_10.xy,h.z);
  vec3 p3 = vec3(a1_1_10.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt_1_6(vec4(dot(p0_1_11,p0_1_11), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0_1_11 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0_1_11,x0), dot(p1,x1),
                                dot(p2,x2), dot(p3,x3) ) );
  }



float orenNayarDiffuse_5_12(
  vec3 lightDirection,
  vec3 viewDirection,
  vec3 surfaceNormal,
  float roughness,
  float albedo) {
  
  float LdotV = dot(lightDirection, viewDirection);
  float NdotL = dot(lightDirection, surfaceNormal);
  float NdotV = dot(surfaceNormal, viewDirection);

  float s = LdotV - NdotL * NdotV;
  float t = mix(1.0, max(NdotL, NdotV), step(0.0, s));

  float sigma2 = roughness * roughness;
  float A = 1.0 + sigma2 * (albedo / (sigma2 + 0.13) + 0.5 / (sigma2 + 0.33));
  float B = 0.45 * sigma2 / (sigma2 + 0.09);

  return albedo * max(0.0, NdotL) * (A + B * s / t) / 3.14159265;
}


float gaussianSpecular_3_13(
  vec3 lightDirection,
  vec3 viewDirection,
  vec3 surfaceNormal,
  float shininess) {
  vec3 H = normalize(lightDirection + viewDirection);
  float theta = acos(dot(H, surfaceNormal));
  float w = theta / shininess;
  return exp(-w*w);
}


float fogFactorExp2_4_14(
  const float dist,
  const float density
) {
  const float LOG2 = -1.442695;
  float d = density * dist;
  return 1.0 - clamp(exp2(d * d * LOG2), 0.0, 1.0);
}



  
float voxelModel(vec3 p, vec3 ro, vec2 beats) {
  float d = snoise_1_7(p.xyz * 0.08 + vec3(0, noiseOffset.x, 0));
  d -= max(0.0, p.y + 6.) * 0.05;
  return d > 0.0 ? 1.0 : 0.0;
}
  
vec2 raymarchVoxel(vec3 ro, vec3 rd, out vec3 nor, vec2 beats) {
  vec3 pos = floor(ro);
  vec3 ri = 1.0 / rd;
  vec3 rs = sign(rd);
  vec3 dis = (pos - ro + 0.5 + rs * 0.5) * ri;
  
  float res = -1.0;
  vec3 mm = vec3(0.0);
  
  for (int i = 0; i < 38; i++) {
    float k = voxelModel(pos, ro, beats);
    if (k > 0.5) {
      res = k;
      break;
    }
     
    mm = step(dis.xyz, dis.yxy) * step(dis.xyz, dis.zzx);
		dis += mm * rs * ri;
    pos += mm * rs;
  }
  
  if (res < -0.5) {
    return vec2(-1.0);
  }
  
  nor = -mm * rs;
  
  vec3 vpos = pos;
  vec3 mini = (pos-ro + 0.5 - 0.5*vec3(rs))*ri;
  float t = max(mini.x, max(mini.y, mini.z));
  
  return vec2(t, 0.0);
}

float attenuate(float d) {
  return pow(clamp(1.0 - d / 20.0, 0.0, 1.0), 2.95);
}

float intersectRaySphere(vec3 ray, vec3 dir, vec3 center, float radius)
{
	vec3 rc = ray-center;
	float c = dot(rc, rc) - (radius*radius);
	float b = dot(dir, rc);
	float d = b*b - c;
	float t = -b - sqrt(abs(d));
	float st = step(0.0, min(t,d));
	return mix(-1.0, t, st);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
  vec3 color = vec3(0, 0, 0);
  vec3 ro, rd;
  float fadeIn = clamp(t, 0., 1.);
  float fadeOut = clamp(73. - t, 0., 1.);
  float appear1 = clamp(t - 17., 0., 1.0);
  float appear2 = clamp(t - 1., 0., 1.);
  float pulse = clamp(t - 51., 0., 0.5) * 2.;

  float rotation = t * 0.134;// sin(t * 0.124) * 0.3 + iMouse.x / iResolution.x * 3.14;
  float height   = 9.0;// + (sin(t)) * 3.5;
  float dist     = 7.1;
  orbitCamera_2_3(rotation, height, dist, iResolution.xy, ro, rd, fragCoord);
  
  ro.z -= t * 5.;
  ro.y += 12.;
    
  vec2 beats = vec2(
    max(0., texture2D(iChannel0, vec2(0.02)).r),
    max(0., texture2D(iChannel0, vec2(0.3)).r) * 3.
  ) * 2.;
    
  vec3 lorigin = vec3(ro.x, 19, ro.z) - vec3(sin(rotation), 0, cos(rotation)) * 1.75;
  vec3 lrotation = (
      vec3(sin(t), 0, cos(t)) +
      vec3(sin(t * 0.3), 0, cos(t * 0.3))
  ) * 0.5;
  vec3 lpos1 = lorigin + lrotation - vec3(0, 1.5, 0);
  vec3 lpos2 = lorigin - lrotation;
  vec3 lcol1 = vec3(4.5, 1.5, 0.4);
  vec3 lcol2 = vec3(0.4, 3.5, 8.5);

  vec3 nor;
  vec2 t = raymarchVoxel(ro, rd, nor, beats);
  float s1 = intersectRaySphere(ro, rd, lpos1, 0.0550 * beats.y * appear1);
  float s2 = intersectRaySphere(ro, rd, lpos2, 0.0275 * beats.x * appear2);
  bool si1 = s1 > 0.0 && (s1 < t.x || t.x <= -0.5);
  bool si2 = s2 > 0.0 && (s2 < t.x || t.x <= -0.5);
    
  lcol1 *= beats.x;
  lcol2 *= beats.y;
    
  if (si1 || si2) {
    color = s1 < s2 ? lcol1 : lcol2;
  } else
  if (t.x > -0.5) {
    vec3 pos = ro + rd * t.x;
    vec3 mat = abs(fract(pos + 0.5));
    
    mat = fract(smoothstep(-0.3, 0.15, mat - 0.5) + 0.5);
    mat = pow(1.0 - (mat) * 4., vec3(0.8));
    mat = 1.0 - clamp(vec3(mat.x * mat.y + mat.y * mat.z + mat.x * mat.z), 0.2, 0.35);
      
    mat += pulse * (
        (1.0 - max(0.0, dot(nor, vec3(0, 1, 0)))) *
        max(0.0, sin(pos.y * 15. + beats.x * 10.)) * vec3(0, 9, 10)
    );
      
    mat = mix(mat, mat * 2., clamp(dot(nor, vec3(0, 1, 0)), 0., 1.));
      
    vec3 ldir1 = normalize(lpos1 - pos);
    float att1 = attenuate(length(lpos1 - pos)) * appear2;
    float dif1 = orenNayarDiffuse_5_12(ldir1, -rd, nor, 0.3, 3.0);
    vec3 ldir2 = normalize(lpos2 - pos);
    float att2 = attenuate(length(lpos2 - pos)) * appear1;
    float dif2 = orenNayarDiffuse_5_12(ldir2, -rd, nor, 0.3, 3.0);
    
    color = mix(color,
      att1 * lcol1 * dif1 * mat +
      att2 * lcol2 * dif2 * mat ,
      1.0 - fogFactorExp2_4_14(t.x, 0.028 - pos.y * 0.001)
    );
  }

  color *= fadeIn * fadeOut;
  color.b += 0.045;
  color.g += 0.012;
  color.r += 0.028;
  color = pow(color, vec3(0.55));
  color.rg *= 1.0 - dot(uv, uv) * 0.215;
  fragColor.rgb = color;
  fragColor.a   = 1.0;
}