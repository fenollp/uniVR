// Shader downloaded from https://www.shadertoy.com/view/4d3GW7
// written by shadertoy user hughsk
//
// Name: 2015/12/12
// Description: Experimenting with refraction &mdash; still some room for improving accuracy/aesthetics but happy with it so far :)
#define GLSLIFY 1

vec2 mapRefract(vec3 p);
vec2 mapSolid(vec3 p);

vec2 calcRayIntersection_3975550108(vec3 rayOrigin, vec3 rayDir, float maxd, float precis) {
  float latest = precis * 2.0;
  float dist   = +0.0;
  float type   = -1.0;
  vec2  res    = vec2(-1.0, -1.0);

  for (int i = 0; i < 50; i++) {
    if (latest < precis || dist > maxd) break;

    vec2 result = mapRefract(rayOrigin + rayDir * dist);

    latest = result.x;
    type   = result.y;
    dist  += latest;
  }

  if (dist < maxd) {
    res = vec2(dist, type);
  }

  return res;
}

vec2 calcRayIntersection_3975550108(vec3 rayOrigin, vec3 rayDir) {
  return calcRayIntersection_3975550108(rayOrigin, rayDir, 20.0, 0.001);
}

vec2 calcRayIntersection_766934105(vec3 rayOrigin, vec3 rayDir, float maxd, float precis) {
  float latest = precis * 2.0;
  float dist   = +0.0;
  float type   = -1.0;
  vec2  res    = vec2(-1.0, -1.0);

  for (int i = 0; i < 60; i++) {
    if (latest < precis || dist > maxd) break;

    vec2 result = mapSolid(rayOrigin + rayDir * dist);

    latest = result.x;
    type   = result.y;
    dist  += latest;
  }

  if (dist < maxd) {
    res = vec2(dist, type);
  }

  return res;
}

vec2 calcRayIntersection_766934105(vec3 rayOrigin, vec3 rayDir) {
  return calcRayIntersection_766934105(rayOrigin, rayDir, 20.0, 0.001);
}

vec3 calcNormal_3606979787(vec3 pos, float eps) {
  const vec3 v1 = vec3( 1.0,-1.0,-1.0);
  const vec3 v2 = vec3(-1.0,-1.0, 1.0);
  const vec3 v3 = vec3(-1.0, 1.0,-1.0);
  const vec3 v4 = vec3( 1.0, 1.0, 1.0);

  return normalize( v1 * mapRefract( pos + v1*eps ).x +
                    v2 * mapRefract( pos + v2*eps ).x +
                    v3 * mapRefract( pos + v3*eps ).x +
                    v4 * mapRefract( pos + v4*eps ).x );
}

vec3 calcNormal_3606979787(vec3 pos) {
  return calcNormal_3606979787(pos, 0.002);
}

vec3 calcNormal_1245821463(vec3 pos, float eps) {
  const vec3 v1 = vec3( 1.0,-1.0,-1.0);
  const vec3 v2 = vec3(-1.0,-1.0, 1.0);
  const vec3 v3 = vec3(-1.0, 1.0,-1.0);
  const vec3 v4 = vec3( 1.0, 1.0, 1.0);

  return normalize( v1 * mapSolid( pos + v1*eps ).x +
                    v2 * mapSolid( pos + v2*eps ).x +
                    v3 * mapSolid( pos + v3*eps ).x +
                    v4 * mapSolid( pos + v4*eps ).x );
}

vec3 calcNormal_1245821463(vec3 pos) {
  return calcNormal_1245821463(pos, 0.002);
}

float beckmannDistribution_2315452051(float x, float roughness) {
  float NdotH = max(x, 0.0001);
  float cos2Alpha = NdotH * NdotH;
  float tan2Alpha = (cos2Alpha - 1.0) / cos2Alpha;
  float roughness2 = roughness * roughness;
  float denom = 3.141592653589793 * roughness2 * cos2Alpha * cos2Alpha;
  return exp(tan2Alpha / roughness2) / denom;
}

float cookTorranceSpecular_1460171947(
  vec3 lightDirection,
  vec3 viewDirection,
  vec3 surfaceNormal,
  float roughness,
  float fresnel) {

  float VdotN = max(dot(viewDirection, surfaceNormal), 0.0);
  float LdotN = max(dot(lightDirection, surfaceNormal), 0.0);

  //Half angle vector
  vec3 H = normalize(lightDirection + viewDirection);

  //Geometric term
  float NdotH = max(dot(surfaceNormal, H), 0.0);
  float VdotH = max(dot(viewDirection, H), 0.000001);
  float LdotH = max(dot(lightDirection, H), 0.000001);
  float G1 = (2.0 * NdotH * VdotN) / VdotH;
  float G2 = (2.0 * NdotH * LdotN) / LdotH;
  float G = min(1.0, min(G1, G2));

  //Distribution term
  float D = beckmannDistribution_2315452051(NdotH, roughness);

  //Fresnel term
  float F = pow(1.0 - VdotN, fresnel);

  //Multiply terms and done
  return  G * F * D / max(3.14159265 * VdotN, 0.000001);
}

vec2 squareFrame_1062606552(vec2 screenSize) {
  vec2 position = 2.0 * (gl_FragCoord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}

vec2 squareFrame_1062606552(vec2 screenSize, vec2 coord) {
  vec2 position = 2.0 * (coord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}

mat3 calcLookAtMatrix_1535977339(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));

  return mat3(uu, vv, ww);
}

vec3 getRay_870892966(mat3 camMat, vec2 screenPos, float lensLength) {
  return normalize(camMat * vec3(screenPos, lensLength));
}

vec3 getRay_870892966(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
  mat3 camMat = calcLookAtMatrix_1535977339(origin, target, 0.0);
  return getRay_870892966(camMat, screenPos, lensLength);
}

void orbitCamera_421267681(
  in float camAngle,
  in float camHeight,
  in float camDistance,
  in vec2 screenResolution,
  out vec3 rayOrigin,
  out vec3 rayDirection,
  in vec2 coord
) {
  vec2 screenPos = squareFrame_1062606552(screenResolution, coord);
  vec3 rayTarget = vec3(0.0);

  rayOrigin = vec3(
    camDistance * sin(camAngle),
    camHeight,
    camDistance * cos(camAngle)
  );

  rayDirection = getRay_870892966(rayOrigin, rayTarget, screenPos, 2.0);
}

// Originally sourced from:
// http://iquilezles.org/www/articles/distfunctions/distfunctions.htm

float sdBox_1117569599(vec3 position, vec3 dimensions) {
  vec3 d = abs(position) - dimensions;

  return min(max(d.x, max(d.y,d.z)), 0.0) + length(max(d, 0.0));
}

highp float random_2281831123(vec2 co)
{
    highp float a = 12.9898;
    highp float b = 78.233;
    highp float c = 43758.5453;
    highp float dt= dot(co.xy ,vec2(a,b));
    highp float sn= mod(dt,3.14);
    return fract(sin(sn) * c);
}

float fogFactorExp2_529295689(
  const float dist,
  const float density
) {
  const float LOG2 = -1.442695;
  float d = density * dist;
  return 1.0 - clamp(exp2(d * d * LOG2), 0.0, 1.0);
}

float intersectPlane(vec3 ro, vec3 rd, vec3 nor, float dist) {
  float denom = dot(rd, nor);
  float t = -(dot(ro, nor) + dist) / denom;

  return t;
}

vec3 n4 = vec3(0.577,0.577,0.577);
vec3 n5 = vec3(-0.577,0.577,0.577);
vec3 n6 = vec3(0.577,-0.577,0.577);
vec3 n7 = vec3(0.577,0.577,-0.577);
vec3 n8 = vec3(0.000,0.357,0.934);
vec3 n9 = vec3(0.000,-0.357,0.934);
vec3 n10 = vec3(0.934,0.000,0.357);
vec3 n11 = vec3(-0.934,0.000,0.357);
vec3 n12 = vec3(0.357,0.934,0.000);
vec3 n13 = vec3(-0.357,0.934,0.000);

float icosahedral(vec3 p, float r) {
  float s = abs(dot(p,n4));
  s = max(s, abs(dot(p,n5)));
  s = max(s, abs(dot(p,n6)));
  s = max(s, abs(dot(p,n7)));
  s = max(s, abs(dot(p,n8)));
  s = max(s, abs(dot(p,n9)));
  s = max(s, abs(dot(p,n10)));
  s = max(s, abs(dot(p,n11)));
  s = max(s, abs(dot(p,n12)));
  s = max(s, abs(dot(p,n13)));
  return s - r;
}

vec2 rotate2D(vec2 p, float a) {
  return p * mat2(cos(a), -sin(a), sin(a),  cos(a));
}

vec2 mapRefract(vec3 p) {
  float d  = icosahedral(p, 1.0);
  float id = 0.0;

  return vec2(d, id);
}

vec2 mapSolid(vec3 p) {
  p.xz = rotate2D(p.xz, iGlobalTime * 1.25);
  p.yx = rotate2D(p.yx, iGlobalTime * 1.85);
  p.y += sin(iGlobalTime) * 0.25;
  p.x += cos(iGlobalTime) * 0.25;

  float d = length(p) - 0.25;
  float id = 1.0;
  float pulse = pow(sin(iGlobalTime * 2.) * 0.5 + 0.5, 9.0) * 2.;

  d = mix(d, sdBox_1117569599(p, vec3(0.175)), pulse);

  return vec2(d, id);
}

// Source: http://www.iquilezles.org/www/articles/palettes/palettes.htm
vec3 palette( in float t, in vec3 a, in vec3 b, in vec3 c, in vec3 d ) {
    return a + b*cos( 6.28318*(c*t+d) );
}

vec3 bg(vec3 ro, vec3 rd) {
  vec3 col = 0.1 + (
    palette(clamp((random_2281831123(rd.xz + sin(iGlobalTime * 0.1)) * 0.5 + 0.5) * 0.035 - rd.y * 0.5 + 0.35, -1.0, 1.0)
      , vec3(0.5, 0.45, 0.55)
      , vec3(0.5, 0.5, 0.5)
      , vec3(1.05, 1.0, 1.0)
      , vec3(0.275, 0.2, 0.19)
    )
  );

  float t = intersectPlane(ro, rd, vec3(0, 1, 0), 4.);

  if (t > 0.0) {
    vec3 p = ro + rd * t;
    float g = (1.0 - pow(abs(sin(p.x) * cos(p.z)), 0.25));

    col += (1.0 - fogFactorExp2_529295689(t, 0.04)) * g * vec3(5, 4, 2) * 0.075;
  }

  return col;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec3 ro, rd;

  vec2  uv       = squareFrame_1062606552(iResolution.xy, fragCoord);
  float dist     = 4.5;
  float rotation = iMouse.z > 0.0
    ? 6. * iMouse.x / iResolution.x
    : iGlobalTime * 0.45;
  float height = iMouse.z > 0.0
    ? 5. * (iMouse.y / iResolution.y * 2.0 - 1.0)
    : -0.2;
    
  orbitCamera_421267681(rotation, height, dist, iResolution.xy, ro, rd, fragCoord);

  vec3 color = bg(ro, rd);
  vec2 t = calcRayIntersection_3975550108(ro, rd);
  if (t.x > -0.5) {
    vec3 pos = ro + rd * t.x;
    vec3 nor = calcNormal_3606979787(pos);
    vec3 ldir1 = normalize(vec3(0.8, 1, 0));
    vec3 ldir2 = normalize(vec3(-0.4, -1.3, 0));
    vec3 lcol1 = vec3(0.6, 0.5, 1.1);
    vec3 lcol2 = vec3(1.4, 0.9, 0.8) * 0.7;

    vec3 ref = refract(rd, nor, 0.97);
    vec2 u = calcRayIntersection_766934105(ro + ref * 0.1, ref);
    if (u.x > -0.5) {
      vec3 pos2 = ro + ref * u.x;
      vec3 nor2 = calcNormal_1245821463(pos2);
      float spec = cookTorranceSpecular_1460171947(ldir1, -ref, nor2, 0.6, 0.95) * 2.;
      float diff1 = 0.05 + max(0., dot(ldir1, nor2));
      float diff2 = max(0., dot(ldir2, nor2));

      color = spec + (diff1 * lcol1 + diff2 * lcol2);
    } else {
      color = bg(ro + ref * 0.1, ref) * 1.1;
    }

    color += color * cookTorranceSpecular_1460171947(ldir1, -rd, nor, 0.2, 0.9) * 2.;
    color += 0.05;
  }

  float vignette = 1.0 - max(0.0, dot(uv * 0.155, uv));

  color.r = smoothstep(0.05, 0.995, color.r);
  color.b = smoothstep(-0.05, 0.95, color.b);
  color.g = smoothstep(-0.1, 0.95, color.g);
  color.b *= vignette;

  fragColor.rgb = color;
  fragColor.a   = 1.0;
}
