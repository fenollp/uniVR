// Shader downloaded from https://www.shadertoy.com/view/4sdGD8
// written by shadertoy user Makio64
//
// Name: Optimized Ashima SimplexNoise2D
// Description: I already optimized it a bit but I'm looking to a way to optimize it more, anyone have idea ?
//    
//    cheers!
// original shader Ashima Simplex noise2D
// https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl


// v3
// base on FabriceNeyret2 comment
// return a value between 0 & 1
// +inline directly the number XYZW
//*

vec3 permute(vec3 x) { return mod( x*x*34.+x, 289.); }
float snoise(vec2 v) {
  vec2 i = floor(v + (v.x+v.y)*.36602540378443),
      x0 = v -   i + (i.x+i.y)*.211324865405187,
       j = step(x0.yx, x0),
      x1 = x0-j+.211324865405187, 
      x3 = x0-.577350269189626; 

  i = mod(i,289.);
  vec3 p = permute( permute( i.y + vec3(0, j.y, 1 ))
                           + i.x + vec3(0, j.x, 1 )   ),
       m = max( .5 - vec3(dot(x0,x0), dot(x1,x1), dot(x3,x3)), 0.),
       x = 2. * fract(p * .024390243902439) - 1.,
       h = abs(x) - .5,
      a0 = x - floor(x + .5),
       g = a0 * vec3(x0.x,x1.x,x3.x) 
          + h * vec3(x0.y,x1.y,x3.y);

  m = m*m*m*m* ( 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h ) );  
  return .5 + 65. * dot(m, g);
}


void mainImage( out vec4 o,  vec2 u )
{
 	o = vec4( snoise( 5.*u/iResolution.xy + iGlobalTime) );
}



//*/
// v2 inspired by this thread
// http://forum.unity3d.com/threads/2d-3d-4d-optimised-perlin-noise-cg-hlsl-library-cginc.218372/
/*


vec3 permute(vec3 x) { return mod( x*x*34.+x, 289.); }
float snoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187,0.366025403784439,-0.577350269189626,0.024390243902439);
  vec2 i = floor(v + dot(v, C.yy) );
  vec2 x0 = v - i + dot(i, C.xx);
  vec2 i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;
  i = mod(i,289.);
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 )) + i.x + vec3(0.0, i1.x, 1.0 ));
  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  vec3 x = 2. * fract(p * C.www) - 1.;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;
  m = m*m*m*m*(1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h ));
  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130. * dot(m, g);
}


void mainImage( out vec4 o,  vec2 u )
{
 	o = vec4( .5+.5*snoise( 5.*u/iResolution.xy + iGlobalTime) );
}


//*/
// v1
// https://github.com/ashima/webgl-noise/blob/master/src/noise2D.glsl
/*


vec2 mod289(vec2 x) { return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec3 mod289(vec3 x) { return x - floor(x * (1.0 / 289.0)) * 289.0;}
vec3 permute(vec3 x) { return mod289(((x*34.0)+1.0)*x); }
float snoise(vec2 v) {
  const vec4 C = vec4(0.211324865405187,  // (3.0-sqrt(3.0))/6.0
                      0.366025403784439,  // 0.5*(sqrt(3.0)-1.0)
                     -0.577350269189626,  // -1.0 + 2.0 * C.x
                      0.024390243902439); // 1.0 / 41.0

  vec2 i  = floor(v + dot(v, C.yy) );
  vec2 x0 = v -   i + dot(i, C.xx);

  vec2 i1;
  i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
  vec4 x12 = x0.xyxy + C.xxzz;
  x12.xy -= i1;

  i = mod289(i); // Avoid truncation effects in permutation
  vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
		+ i.x + vec3(0.0, i1.x, 1.0 ));

  vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy), dot(x12.zw,x12.zw)), 0.0);
  m = m*m ;
  m = m*m ;

  vec3 x = 2.0 * fract(p * C.www) - 1.0;
  vec3 h = abs(x) - 0.5;
  vec3 ox = floor(x + 0.5);
  vec3 a0 = x - ox;

  m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );

  vec3 g;
  g.x  = a0.x  * x0.x  + h.x  * x0.y;
  g.yz = a0.yz * x12.xz + h.yz * x12.yw;
  return 130.0 * dot(m, g);
}



void mainImage( out vec4 o,  vec2 u )
{
 	o = vec4( .5+.5*snoise( 5.*u/iResolution.xy + iGlobalTime) );
}
//*/
