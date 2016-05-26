// Shader downloaded from https://www.shadertoy.com/view/4dVGRW
// written by shadertoy user hughsk
//
// Name: Post-Processing: Toon Shading
// Description: Toon shading &mdash; outlines achieved using edge detection on normals/depth in post. The raymarching buffer stores normals in RGB, and depth in A.
mat3 calcLookAtMatrix(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));

  return mat3(uu, vv, ww);
}

vec3 getRay(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
  mat3 camMat = calcLookAtMatrix(origin, target, 0.0);
  return normalize(camMat * vec3(screenPos, lensLength));
}

vec2 squareFrame(vec2 screenSize, vec2 coord) {
  vec2 position = 2.0 * (coord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}

vec2 getDeltas(sampler2D buffer, vec2 uv) {
  vec2 pixel = vec2(1. / iResolution.xy);
  vec3 pole = vec3(-1, 0, +1);
  float dpos = 0.0;
  float dnor = 0.0;
    
  vec4 s0 = texture2D(iChannel0, uv + pixel.xy * pole.xx); // x1, y1
  vec4 s1 = texture2D(iChannel0, uv + pixel.xy * pole.yx); // x2, y1
  vec4 s2 = texture2D(iChannel0, uv + pixel.xy * pole.zx); // x3, y1
  vec4 s3 = texture2D(iChannel0, uv + pixel.xy * pole.xy); // x1, y2
  vec4 s4 = texture2D(iChannel0, uv + pixel.xy * pole.yy); // x2, y2
  vec4 s5 = texture2D(iChannel0, uv + pixel.xy * pole.zy); // x3, y2
  vec4 s6 = texture2D(iChannel0, uv + pixel.xy * pole.xz); // x1, y3
  vec4 s7 = texture2D(iChannel0, uv + pixel.xy * pole.yz); // x2, y3
  vec4 s8 = texture2D(iChannel0, uv + pixel.xy * pole.zz); // x3, y3

  dpos = (
    abs(s1.a - s7.a) +
    abs(s5.a - s3.a) +
    abs(s0.a - s8.a) +
    abs(s2.a - s6.a)
  ) * 0.5;
  dpos += (
    max(0.0, 1.0 - dot(s1.rgb, s7.rgb)) +
    max(0.0, 1.0 - dot(s5.rgb, s3.rgb)) +
    max(0.0, 1.0 - dot(s0.rgb, s8.rgb)) +
    max(0.0, 1.0 - dot(s2.rgb, s6.rgb))
  );
  
  dpos = pow(max(dpos - 0.5, 0.0), 5.0);
    
  return vec2(dpos, dnor);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  vec3 ro = vec3(sin(iGlobalTime * 0.2), 1.5, cos(iGlobalTime * 0.2)) * 5.;
  vec3 ta = vec3(0, 0, 0);
  vec3 rd = getRay(ro, ta, squareFrame(iResolution.xy, fragCoord.xy), 2.0);
  vec2 uv = fragCoord.xy / iResolution.xy;
    
  vec4 buf = texture2D(iChannel0, fragCoord.xy / iResolution.xy);
  float t = buf.a;
  vec3 nor = buf.rgb;
  vec3 pos = ro + rd * t;
    
  vec3 col = vec3(0.5, 0.8, 1);
  vec2 deltas = getDeltas(iChannel0, uv);
  if (t > -0.5) {
    col = vec3(1.0);
    col *= max(0.3, 0.3 + dot(nor, normalize(vec3(0, 1, 0.5))));
    col *= vec3(1, 0.8, 0.35);
  }
  col.r = smoothstep(0.1, 1.0, col.r);
  col.g = smoothstep(0.1, 1.1, col.g);
  col.b = smoothstep(-0.1, 1.0, col.b);
  col = pow(col, vec3(1.1));
  col -= deltas.x - deltas.y;
  
    
  fragColor = vec4(col, 1);
}