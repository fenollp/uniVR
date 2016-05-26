// Shader downloaded from https://www.shadertoy.com/view/4tlGDs
// written by shadertoy user Craxic
//
// Name: Raymarching Attempt 1
// Description: My first attempt at a very basic ray marcher. I haven't even used a projection matrix :P 
//    Not sure where to start optimizing though, this shader is SLOW.
#define INNER_RADIUS 0.75
#define OUTER_RADIUS 0.9
#define SHEET_THICKNESS 0.012
#define NOISINESS 2.0

#define INNER_COLOR vec4(0.0, 30.0, 30.0, 1.0)
#define OUTER_COLOR vec4(20.0, 20.0, 30.0, 1.0)

#define NUM_STEPS 128

// THE FOLLOWING CODE (FROM HERE UNTIL THE END MARKER) WAS BLATANTLY LIFTED FROM 
// https://github.com/ashima/webgl-noise/blob/master/src/noise4D.glsl
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

vec4 mod289(vec4 x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

float mod289(float x) {
  return x - floor(x * (1.0 / 289.0)) * 289.0; }

vec4 permute(vec4 x) {
     return mod289(((x*34.0)+1.0)*x);
}

float permute(float x) {
     return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

float taylorInvSqrt(float r)
{
  return 1.79284291400159 - 0.85373472095314 * r;
}

vec4 grad4(float j, vec4 ip)
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

float snoise(vec4 v)
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
  i = mod289(i); 
  float j0 = permute( permute( permute( permute(i.w) + i.z) + i.y) + i.x);
  vec4 j1 = permute( permute( permute( permute (
             i.w + vec4(i1.w, i2.w, i3.w, 1.0 ))
           + i.z + vec4(i1.z, i2.z, i3.z, 1.0 ))
           + i.y + vec4(i1.y, i2.y, i3.y, 1.0 ))
           + i.x + vec4(i1.x, i2.x, i3.x, 1.0 ));

// Gradients: 7x7x6 points over a cube, mapped onto a 4-cross polytope
// 7*7*6 = 294, which is close to the ring size 17*17 = 289.
  vec4 ip = vec4(1.0/294.0, 1.0/49.0, 1.0/7.0, 0.0) ;

  vec4 p0 = grad4(j0,   ip);
  vec4 p1 = grad4(j1.x, ip);
  vec4 p2 = grad4(j1.y, ip);
  vec4 p3 = grad4(j1.z, ip);
  vec4 p4 = grad4(j1.w, ip);

// Normalise gradients
  vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
  p0 *= norm.x;
  p1 *= norm.y;
  p2 *= norm.z;
  p3 *= norm.w;
  p4 *= taylorInvSqrt(dot(p4,p4));

// Mix contributions from the five corners
  vec3 m0 = max(0.6 - vec3(dot(x0,x0), dot(x1,x1), dot(x2,x2)), 0.0);
  vec2 m1 = max(0.6 - vec2(dot(x3,x3), dot(x4,x4)            ), 0.0);
  m0 = m0 * m0;
  m1 = m1 * m1;
  return 49.0 * ( dot(m0*m0, vec3( dot( p0, x0 ), dot( p1, x1 ), dot( p2, x2 )))
               + dot(m1*m1, vec2( dot( p3, x3 ), dot( p4, x4 ) ) ) ) ;

  }

/// THE END MARKER!
/// All the next code was written by yours truly!

vec4 merge_colours(vec4 apply_this, vec4 on_top_of_this)
{
    return on_top_of_this * (1.0 - apply_this.a) + apply_this * apply_this.a;
}

vec4 getdensity(vec3 pos)
{
    vec3 samplePos = normalize(pos);
    float sample = (snoise(vec4(samplePos * NOISINESS, iGlobalTime)) + 1.0) / 2.0;
    sample = clamp(sample, 0.0, 1.0);
    float innerIncBorder = INNER_RADIUS + SHEET_THICKNESS;
    float outerIncBorder = OUTER_RADIUS - SHEET_THICKNESS;
    
    float radius = innerIncBorder + (outerIncBorder - innerIncBorder) * sample;
    float dist = distance(pos, vec3(0.0, 0.0, 0.0));
    if (dist > radius && dist < radius + SHEET_THICKNESS) {
        return INNER_COLOR + (OUTER_COLOR - INNER_COLOR) * (radius - innerIncBorder) / (outerIncBorder - innerIncBorder);
    } else {
        return vec4(0.0, 0.0, 0.0, 0.0);
    }
}

vec4 raymarch(vec3 start, vec3 end)
{
    vec4 retn = vec4(0.0, 0.0, 0.0, 0.0);
	vec3 delta = end - start;
    float stepDistance = length(delta) / float(NUM_STEPS);
    
    vec4 densityPrevious = getdensity(start);
    for (int i = 1; i < NUM_STEPS; i++) 
    {
        vec3 samplePos = start + delta * float(i) / float(NUM_STEPS);
        vec4 density = getdensity(samplePos);
        // Integrate the density using linear interpolation
        // The colours will be the average of the two weighted by their alpha
        vec4 densityIntegrated = (density + densityPrevious) / 2.0;
        // Optimised out to return. densityIntegrated *= stepDistance
        retn += densityIntegrated;
        
        densityPrevious = density;
    }
    
    return retn * stepDistance;
}

vec4 raymarch_ball(vec2 coord)
{
	// Now we're going to intersect a ray from the 
    // position onto two spheres, one inside the 
    // other (same origin). getdensity is only > 0 
    // between these volumes.
    float d = distance(coord, vec2(0.0, 0.0));
    if (d > OUTER_RADIUS) {
        // No intersection on the spheres.
		return vec4(0.0, 0.0, 0.0, 0.0);
    }
    float dOuterNormalized = d / OUTER_RADIUS;
    float outerStartZ = -sqrt(1.0 - dOuterNormalized*dOuterNormalized) * OUTER_RADIUS; // sqrt(1-x*x) = function of a circle :)
    float outerEndZ = -outerStartZ;
    if (d > INNER_RADIUS) {
        // The ray only intersects the larger sphere, 
        // so we need to cast from the front to the back
        return raymarch(vec3(coord, outerStartZ), vec3(coord, outerEndZ));
    }
    
    float dInnerNormalized = d / INNER_RADIUS;
    float innerStartZ = -sqrt(1.0 - dInnerNormalized*dInnerNormalized) * INNER_RADIUS; // sqrt(1-x*x) = function of a circle :)
    float innerEndZ = -innerStartZ;
    // The ray intersects both spheres.
    vec4 frontPart = raymarch(vec3(coord, outerStartZ), vec3(coord, innerStartZ));
    vec4 backPart = raymarch(vec3(coord, innerEndZ), vec3(coord, outerEndZ));
    //vec4 mr = merge_colours(frontPart, backPart);
    vec4 final = frontPart + backPart;
    return final;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / min(iResolution.x, iResolution.y)) * 2.0 - vec2(iResolution.x / iResolution.y, 1.0);
    fragColor = merge_colours(raymarch_ball(uv), vec4(0.0, 0.0, 0.0, 1.0));
}