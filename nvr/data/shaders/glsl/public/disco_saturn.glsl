// Shader downloaded from https://www.shadertoy.com/view/MddSRs
// written by shadertoy user substack
//
// Name: disco saturn
// Description: saturn with some warping and color blending
//glsl-noise:
vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v)
  {
  const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
  const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

// First corner
  vec3 i  = floor(v + dot(v, C.yyy) );
  vec3 x0 =   v - i + dot(i, C.xxx) ;

// Other corners
  vec3 g = step(x0.yzx, x0.xyz);
  vec3 l = 1.0 - g;
  vec3 i1 = min( g.xyz, l.zxy );
  vec3 i2 = max( g.xyz, l.zxy );

  //   x0 = x0 - 0.0 + 0.0 * C.xxx;
  //   x1 = x0 - i1  + 1.0 * C.xxx;
  //   x2 = x0 - i2  + 2.0 * C.xxx;
  //   x3 = x0 - 1.0 + 3.0 * C.xxx;
  vec3 x1 = x0 - i1 + C.xxx;
  vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
  vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

// Permutations
  i = mod289(i);
  vec4 p = permute( permute( permute(
             i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
           + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
           + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

// Gradients: 7x7 points over a square, mapped onto an octahedron.
// The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
  float n_ = 0.142857142857; // 1.0/7.0
  vec3  ns = n_ * D.wyz - D.xzx;

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
  vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

  vec3 p0 = vec3(a0.xy,h.x);
  vec3 p1 = vec3(a0.zw,h.y);
  vec3 p2 = vec3(a1.xy,h.z);
  vec3 p3 = vec3(a1.zw,h.w);

//Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;

// Mix final noise value
  vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
  m = m * m;
  return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
                                dot(p2,x2), dot(p3,x3) ) );
}

float torus (vec3 p, vec2 t) {
  vec2 q = vec2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
}
float sphere(vec3 p, float r) {
  return length(p)-r;
}
mat4 scale (float x, float y, float z) {
  return mat4(x,0,0,0,0,y,0,0,0,0,z,0,0,0,0,1);
}
mat4 invert(mat4 m) {
  float
      a00 = m[0][0], a01 = m[0][1], a02 = m[0][2], a03 = m[0][3],
      a10 = m[1][0], a11 = m[1][1], a12 = m[1][2], a13 = m[1][3],
      a20 = m[2][0], a21 = m[2][1], a22 = m[2][2], a23 = m[2][3],
      a30 = m[3][0], a31 = m[3][1], a32 = m[3][2], a33 = m[3][3],

      b00 = a00 * a11 - a01 * a10,
      b01 = a00 * a12 - a02 * a10,
      b02 = a00 * a13 - a03 * a10,
      b03 = a01 * a12 - a02 * a11,
      b04 = a01 * a13 - a03 * a11,
      b05 = a02 * a13 - a03 * a12,
      b06 = a20 * a31 - a21 * a30,
      b07 = a20 * a32 - a22 * a30,
      b08 = a20 * a33 - a23 * a30,
      b09 = a21 * a32 - a22 * a31,
      b10 = a21 * a33 - a23 * a31,
      b11 = a22 * a33 - a23 * a32,

      det = b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;

  return mat4(
      a11 * b11 - a12 * b10 + a13 * b09,
      a02 * b10 - a01 * b11 - a03 * b09,
      a31 * b05 - a32 * b04 + a33 * b03,
      a22 * b04 - a21 * b05 - a23 * b03,
      a12 * b08 - a10 * b11 - a13 * b07,
      a00 * b11 - a02 * b08 + a03 * b07,
      a32 * b02 - a30 * b05 - a33 * b01,
      a20 * b05 - a22 * b02 + a23 * b01,
      a10 * b10 - a11 * b08 + a13 * b06,
      a01 * b08 - a00 * b10 - a03 * b06,
      a30 * b04 - a31 * b02 + a33 * b00,
      a21 * b02 - a20 * b04 - a23 * b00,
      a11 * b07 - a10 * b09 - a12 * b06,
      a00 * b09 - a01 * b07 + a02 * b06,
      a31 * b01 - a30 * b03 - a32 * b00,
      a20 * b03 - a21 * b01 + a22 * b00) / det;
}

vec3 sunpos = vec3(20,10,20);
vec2 model(vec3 p) {
  mat4 m = invert(scale(1.8,0.3,1.8));
  float ring = torus(vec3(m*vec4(p,1)),vec2(4.5,0.5))
    + snoise(p*8.0)*0.05;
  float planet = sphere(p,4.0);
  float sun = sphere(p-sunpos,2.0);
  return vec2(min(ring,min(planet,sun)));
}

vec3 calcNormal(vec3 pos) {
  const float eps = 0.002;

  const vec3 v1 = vec3( 1.0,-1.0,-1.0);
  const vec3 v2 = vec3(-1.0,-1.0, 1.0);
  const vec3 v3 = vec3(-1.0, 1.0,-1.0);
  const vec3 v4 = vec3( 1.0, 1.0, 1.0);

  return normalize(v1*model(pos + v1*eps).x
    + v2*model(pos + v2*eps).x
    + v3*model(pos + v3*eps).x
    + v4*model(pos + v4*eps).x);
}

const int steps = 25;

vec2 calcRayIntersection(vec3 rayOrigin, vec3 rayDir, float maxd, float precis) {
  float latest = precis * 2.0;
  float dist   = +0.0;
  float type   = -1.0;
  vec2  res    = vec2(-1.0, -1.0);
  for (int i = 0; i < steps; i++) {
    if (latest < precis || dist > maxd) break;
    vec2 result = model(rayOrigin + rayDir * dist);
    latest = result.x;
    type = result.y;
    dist += latest;
  }
  if (dist < maxd) res = vec2(dist, type);
  return res;
}

vec2 raytrace(vec3 rayOrigin, vec3 rayDir) {
  return calcRayIntersection(rayOrigin, rayDir, 50.0, 0.001);
}

vec2 square(vec2 screenSize) {
  vec2 position = 2.0 * (gl_FragCoord.xy / screenSize.xy) - 1.0;
  position.x *= screenSize.x / screenSize.y;
  return position;
}

vec3 camera(mat3 camMat, vec2 screenPos, float lensLength) {
  return normalize(camMat * vec3(screenPos, lensLength));
}

mat3 lookAt(vec3 origin, vec3 target, float roll) {
  vec3 rr = vec3(sin(roll), cos(roll), 0.0);
  vec3 ww = normalize(target - origin);
  vec3 uu = normalize(cross(ww, rr));
  vec3 vv = normalize(cross(uu, ww));
  return mat3(uu, vv, ww);
}

vec3 camera(vec3 origin, vec3 target, vec2 screenPos, float lensLength) {
  mat3 camMat = lookAt(origin, target, 0.0);
  return camera(camMat, screenPos, lensLength);
}

vec3 lighting (vec3 pos, vec3 nor, vec3 rd, float dis, vec3 mal) {
  vec3 lin = vec3(0.0);
  vec3  lig = normalize(vec3(1.0,0.7,0.9));
  float dif = max(dot(nor,lig),0.0);
  lin += dif*vec3(2);
  lin += vec3(0.05);
  return mal*lin;
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
  float t = iGlobalTime;
  vec2 uv = fragCoord.xy / iResolution.xy;
  float cameraAngle = 0.2 * t;
  vec3 rayOrigin = vec3(18.0 * sin(cameraAngle), 2.2, 18.0 * cos(cameraAngle));
  vec3 rayTarget = vec3(0, 0, 0);
  vec2 screenPos = square(iResolution.xy);
  float lensLength = 2.0;
  vec3 rayDirection = camera(rayOrigin, rayTarget, screenPos, lensLength);
  rayDirection.x += sin(4.0*t + uv.x*4.0) / 20.0;
  rayDirection.y += cos(8.0*t + uv.y*4.0) / 20.0;

  vec2 collision = raytrace(rayOrigin, rayDirection);
  if (collision.x > -0.5) {
    vec3 pos = rayOrigin + rayDirection * collision.x;
    if (length(pos) > 25.0 && length(pos-vec3(sunpos))<=5.0) { // sun
      fragColor = vec4(1,1,1,1);
    } else if (length(pos) <= 6.0) { // planet
      vec3 nor = calcNormal(pos);
      vec3 mat = (vec3(0.9,0.75,0.6+sin(pos.y*2.0+3.0)*0.05))*vec3(
        sin(pos.y*2.0*sin(pos.y*2.5)+sin(pos.y*2.0)+snoise(pos*3.0)*0.4)*0.05+0.6
      );
      vec3 col = lighting(pos, nor, rayDirection, collision.x, mat);
      col = pow(clamp(col,0.0,1.0), vec3(1.2));
      fragColor = vec4(col, 1.0);
    } else { // ring
      float edge = length(pos)+snoise(pos*8.0)*0.03;
      vec3 col = vec3(0.95,0.8,0.7)*vec3(
        sin(1.5+sqrt(length(pos)*4.0)*2.0+sqrt(sin(length(pos)*8.1))
          +snoise(pos*12.0)*0.3)*0.2+0.6)
        * (abs(edge-8.6)<0.1?0.2:1.0)
      ;
      if (length(pos)>=10.0) col = vec3(0,0,0);
      else if (abs(pos.y)>0.35) col = vec3(0,0,0);
      else {
        vec3 p = normalize(-sunpos)*7.5;
        col *= min(1.0,(length(pos-p)-4.0)/4.0);
      }
      fragColor = vec4(col, 1.0);
    }
  } else {
    fragColor = vec4(vec3(pow(snoise(rayDirection*128.0),4.0)),1);
  }
  fragColor.x *= sin(t*3.0+sin(t*4.0+uv.x*uv.x*2.0)+cos(t*4.0+uv.y*uv.y*8.0));
  fragColor.y *= sin(t*2.0+sin(t*2.0+uv.x*uv.x*8.0)+cos(t*1.0+uv.y*uv.y*8.0));
}