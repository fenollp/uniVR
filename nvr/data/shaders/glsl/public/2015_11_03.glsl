// Shader downloaded from https://www.shadertoy.com/view/4ljXWK
// written by shadertoy user hughsk
//
// Name: 2015/11/03
// Description: SDFs

vec2 doModel(vec3 p, vec2 beats);

vec2 calcRayIntersection_2_0(vec3 rayOrigin, vec3 rayDir, float maxd, float precis, vec2 beats) {
  float latest = precis * 2.0;
  float dist   = +0.0;
  float type   = -1.0;
  vec2  res    = vec2(-1.0, -1.0);

  for (int i = 0; i < 50; i++) {
    if (latest < precis || dist > maxd) break;

    vec2 result = doModel(rayOrigin + rayDir * dist, beats);

    latest = result.x;
    type   = result.y;
    dist  += latest;
  }

  if (dist < maxd) {
    res = vec2(dist, type);
  }

  return res;
}

vec2 calcRayIntersection_2_0(vec3 rayOrigin, vec3 rayDir, vec2 beats) {
  return calcRayIntersection_2_0(rayOrigin, rayDir, 20.0, 0.001, beats);
}

vec3 calcNormal_3_1(vec3 pos, float eps, vec2 beats) {
  const vec3 v1 = vec3( 1.0,-1.0,-1.0);
  const vec3 v2 = vec3(-1.0,-1.0, 1.0);
  const vec3 v3 = vec3(-1.0, 1.0,-1.0);
  const vec3 v4 = vec3( 1.0, 1.0, 1.0);

  return normalize( v1 * doModel( pos + v1*eps, beats ).x +
                    v2 * doModel( pos + v2*eps, beats ).x +
                    v3 * doModel( pos + v3*eps, beats ).x +
                    v4 * doModel( pos + v4*eps, beats ).x );
}

vec3 calcNormal_3_1(vec3 pos, vec2 beats) {
  return calcNormal_3_1(pos, 0.002, beats);
}



float ao_1_2( in vec3 pos, in vec3 nor, vec2 beats )
{
	float occ = 0.0;
    float sca = 1.0;
    for( int i=0; i<5; i++ )
    {
        float hr = 0.01 + 0.12 * float( i ) / 4.0;
        vec3 aopos =  nor * hr + pos;
        float dd = doModel( aopos, beats ).x;
        occ += -(dd-hr)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 3.0*occ, 0.0, 1.0 );    
}


float orenNayarDiffuse_4_3(
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

vec2 squareFrame_9_4(vec2 screenSize, vec2 coord) {
  vec2 position = 2.0 * (coord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}



mat3 calcLookAtMatrix_11_5(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));

  return mat3(uu, vv, ww);
}




vec3 getRay_10_6(mat3 camMat, vec2 screenPos, float lensLength) {
  return normalize(camMat * vec3(screenPos, lensLength));
}

vec3 getRay_10_6(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
  mat3 camMat = calcLookAtMatrix_11_5(origin, target, 0.0);
  return getRay_10_6(camMat, screenPos, lensLength);
}




void orbitCamera_5_7(
  in float camAngle,
  in float camHeight,
  in float camDistance,
  in vec2 screenResolution,
  out vec3 rayOrigin,
  out vec3 rayDirection,
  in vec2 fragCoord
) {
  vec2 screenPos = squareFrame_9_4(screenResolution, fragCoord);
  vec3 rayTarget = vec3(0.0);

  rayOrigin = vec3(
    camDistance * sin(camAngle),
    camHeight,
    camDistance * cos(camAngle)
  );

  rayDirection = getRay_10_6(rayOrigin, rayTarget, screenPos, 2.0);
}



float gaussianSpecular_6_8(
  vec3 lightDirection,
  vec3 viewDirection,
  vec3 surfaceNormal,
  float shininess) {
  vec3 H = normalize(lightDirection + viewDirection);
  float theta = acos(dot(H, surfaceNormal));
  float w = theta / shininess;
  return exp(-w*w);
}


// Originally sourced from:
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

float sdBox_7_9(vec3 position, vec3 dimensions) {
  vec3 d = abs(position) - dimensions;

  return min(max(d.x, max(d.y,d.z)), 0.0) + length(max(d, 0.0));
}



float fogFactorExp2_8_10(
  const float dist,
  const float density
) {
  const float LOG2 = -1.442695;
  float d = density * dist;
  return 1.0 - clamp(exp2(d * d * LOG2), 0.0, 1.0);
}



  
#define rs(a) (a * 0.5 + 0.5)

mat4 rotationMatrix(vec3 axis, float angle) {
  axis = normalize(axis);
  float s = sin(angle);
  float c = cos(angle);
  float oc = 1.0 - c;

  return mat4(oc * axis.x * axis.x + c,           oc * axis.x * axis.y - axis.z * s,  oc * axis.z * axis.x + axis.y * s,  0.0,
              oc * axis.x * axis.y + axis.z * s,  oc * axis.y * axis.y + c,           oc * axis.y * axis.z - axis.x * s,  0.0,
              oc * axis.z * axis.x - axis.y * s,  oc * axis.y * axis.z + axis.x * s,  oc * axis.z * axis.z + c,           0.0,
              0.0,                                0.0,                                0.0,                                1.0);
}
  
float boxTiles(vec3 p, float r) {
  float l = 0.3;
  mat4 rot = rotationMatrix(normalize(vec3(1, 0, 1)), sin(iGlobalTime * 0.15) * 5.);
  p = (rot * vec4(p, 1)).xyz;
  p = mod(p + l, l * 2.) - l;
  
  return sdBox_7_9(p, vec3(r));
}
  
vec2 doModel(vec3 p, vec2 beats) {
  float d  = mix(length(p) - 2.0, sdBox_7_9(p, vec3(1.)), 0.5 + sin(iGlobalTime * 0.215) * 0.35);
  float id = 0.0;
  
  d = max(d, -boxTiles(p, 0.15 + 0.125 * rs(sin(iGlobalTime))));
  d = max(d, 1.35 - length(p));

  return vec2(d, id);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec3 color = vec3(0.0);
  vec3 ro, rd;

  float rotation = sin(iGlobalTime * 0.25) * 0.5 + 1.5 + iMouse.x / iResolution.x * 6.;
  float height   = 2.0 - (iMouse.y / iResolution.y - 0.25) * 10.;
  float dist     = 4.0;
  orbitCamera_5_7(rotation, height, dist, iResolution.xy, ro, rd, fragCoord);
    
  vec2 beats = vec2(0);
  
  color = mix(clamp(abs(rd * 2.), 0., 1.), vec3(1.0), 0.75);

  vec2 t = calcRayIntersection_2_0(ro, rd, 10., 0.0001, beats);
  if (t.x > -0.5) {
    vec3 pos = ro + rd * t.x;
    vec3 nor = calcNormal_3_1(pos, beats);
    vec3 mat = nor * 0.5 + 0.5;
    vec3 dir = normalize(vec3(-0.5, 1, -0.15));
    vec3 lcl = vec3(1.9, 1.75, 1.7);
    vec3 col;
    
    float spec = gaussianSpecular_6_8(dir, -rd, nor, 0.3) * 0.33;
    float diff = orenNayarDiffuse_4_3(dir, -rd, nor, 1.5, 1.1);
    
    col = mix(mat, lcl * (spec + diff * mat), 0.55);
    col *= mix(0.75, 1.0, ao_1_2(pos, nor, beats));
    
    color = mix(col, color, fogFactorExp2_8_10(t.x, 0.15));
  }
  
  color = pow(color, vec3(0.6545));

  fragColor.rgb = color;
  fragColor.a   = 1.0;
}