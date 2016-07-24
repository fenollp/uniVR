// Shader downloaded from https://www.shadertoy.com/view/ldtSDs
// written by shadertoy user BeRo
//
// Name: two lines hue rotation
// Description: two lines hue rotation
vec3 rgb2hsv(vec3 c){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c){
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}


vec3 hueRotation(vec3 c, float hueRotationAngle){ // <= this is the two lines hue rotation routine  
    // By Benjamin 'BeRo' Rosseaux, CC0 licensed 
    vec3 hueRotationValues = vec3(0.57735, sin(vec2(radians(hueRotationAngle)) + vec2(0.0, 1.57079632679)));
    return mix(hueRotationValues.xxx * dot(hueRotationValues.xxx, c), c, hueRotationValues.z) + (cross(hueRotationValues.xxx, c) * hueRotationValues.y);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ){
  vec2 uv = fragCoord.xy / iResolution.xy;
  vec3 c = texture2D(iChannel0, uv).xyz;
   
   
  float hueRotationAngle = iGlobalTime * 180.0;
      
  c = (abs(fragCoord.x - (iResolution.x * 0.5)) < 1.0) ?
        vec3(1.0) :
        ((fragCoord.x < (iResolution.x * 0.5)) ?
           hsv2rgb(rgb2hsv(c.xyz) + vec3(hueRotationAngle / 360.0, 0.0, 0.0)) : 
           hueRotation(c, hueRotationAngle));
    
  fragColor = vec4(c, 1.0);
}