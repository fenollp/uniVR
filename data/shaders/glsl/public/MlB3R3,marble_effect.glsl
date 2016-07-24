// Shader downloaded from https://www.shadertoy.com/view/MlB3R3
// written by shadertoy user jonobr1
//
// Name: Marble Effect
// Description: A shader to create an animated marble effect.
const float PI = 3.14;
const int resolution = 16;
vec2 period = vec2( 5.0, 10.0 );
float power = 8.0;
float size = 64.0;

//
// Description : Array and textureless GLSL 2D simplex noise function.
//      Author : Ian McEwan, Ashima Arts.
//  Maintainer : ijm
//     Lastmod : 20110822 (ijm)
//     License : Copyright (C) 2011 Ashima Arts. All rights reserved.
//               Distributed under the MIT License. See LICENSE file.
//               https://github.com/ashima/webgl-noise
// 

vec3 mod289(vec3 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec2 mod289(vec2 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec3 permute(vec3 x) {
  return mod289(((x*34.0)+1.0)*x);
}

float snoise(vec2 v)
  {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0
// First corner
  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

// Other corners
  vec2 i1;
  //i1.x = step( x0.y, x0.x ); // x0.x > x0.y ? 1.0 : 0.0
  //i1.y = 1.0 - i1.x;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  // x0 = x0 - 0.0 + 0.0 * C.xx ;
  // x1 = x0 - i1 + 1.0 * C.xx ;
  // x2 = x0 - 1.0 + 2.0 * C.xx ;
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

// Permutations
  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

// Gradients: 41 points uniformly over a line, mapped onto a diamond.
// The ring size 17*17 = 289 is close to a multiple of 41 (41*7 = 287)

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

// Normalise gradients implicitly by scaling m
// Approximation of: m *= inversesqrt( a0*a0 + h*h );
  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

// Compute final noise value at P
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}

float smoothNoise(float x, float y) {

   //get fractional part of x and y
   float fractX = x - floor(x);
   float fractY = y - floor(y);
   
   //wrap around
   float x1 = mod((floor(x) + iResolution.x), iResolution.x);
   float y1 = mod((floor(y) + iResolution.y), iResolution.y);
   
   //neighbor values
   float x2 = mod((x1 + iResolution.x - 1.0), iResolution.x);
   float y2 = mod((y1 + iResolution.y - 1.0), iResolution.y);

   //smooth the noise with bilinear interpolation
   float value = 0.0;
   value += fractX       * fractY       * snoise(vec2(x1, y1));
   value += fractX       * (1.0 - fractY) * snoise(vec2(x1, y2));
   value += (1.0 - fractX) * fractY       * snoise(vec2(x2, y1));
   value += (1.0 - fractX) * (1.0 - fractY) * snoise(vec2(x2, y2));

   return value;
}

float turbulence( vec2 pos, in float size ) {

    float value = 0.0, initialSize = size;
    float x = pos.x;
    float y = pos.y;
    
    for ( int i = 0; i < resolution; i++ ) {
    	value += smoothNoise( x / size, y / size ) * size;
        size /= 2.0;
    }
    
    return( 128.0 * value / initialSize );
}

float marble( in vec2 p ) {

  	float x = p.x;
    float y = p.y;

    float xy = x / iResolution.y * period.x;
    xy += y * period.y / iResolution.x;
    xy += power * turbulence( p, size ) / 256.0;

    return sin( 256.0 * xy * PI );
    
}

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {

	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 pos = uv.xy;

    period.x += 10.0 * cos( iGlobalTime );
    period.y += 10.0 * sin( iGlobalTime );
    
	float n = marble( pos );
    
	fragColor = vec4(vec3(1.0 - n), 1.0);

}