// Shader downloaded from https://www.shadertoy.com/view/llXXWS
// written by shadertoy user racarate
//
// Name: steranko eyeball
// Description: patterns from http://www.gdcvault.com/play/1015493/Technical-Artist-Boot (p. 314)
//    snoise from github
//    fbm from iq
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


float t = iGlobalTime;
//mat2 m = mat2( 0.8+0.1*t, 0.6-t, -0.6+0.010*t, 0.8+0.4*t );
mat2 m = mat2( 0.8, 0.6, -0.6, 0.8 );

float fbm( vec2 p )
{
	float f = 0.0;
    f += 0.5000*snoise( p ); p*=m*2.02;
    f += 0.2500*snoise( p ); p*=m*2.05;
    f += 0.1250*snoise( p ); p*=m*2.03;
    f += 0.0625*snoise( p ); p*=m*2.01;
    f /= 0.9375;
    return f;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{         
	const float PI = 3.14159265;
    
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0*q;

    // background gradient colors
	vec3 start = vec3(0.7, 0.7, 0.4);
    vec3 end = vec3(0.0);
    
    // fix apsect ratio or something
    p.x *= iResolution.x / iResolution.y;
    
    // pixel distance from center of screen
    float dist = dot(p, p);    
   	float r = sqrt( dist );

    // used for falloff in pow(X)
    float falloff = 1.0;
    
	// domain distortion???
    p *= vec2(t,2.0*t);
    
    // radial gradient
    float blend = (PI + atan(p.y, p.x)) / (2.0*PI);
    blend = pow(blend, falloff);
    
    float freq1 = 10.0 *2.0*PI;
    float freq2 = 20.0 *2.0*PI;
    
    // sine-pulsed radial
    float wave = (sin(freq1*(blend - 0.05*t)) + 1.0) * 0.5;
	wave      += (sin(freq2*(blend + 0.1*t)) + 1.0) * 0.5; 
    
	p /= vec2(t,2.0*t);
    
	// domain distortion???
    p *= 0.2*abs(sin(0.1*t))*fbm(p);
    
    // break up radial shafts with sine-pulsed sphere gradient
    blend = dot(p,p);
    wave += 0.1*(sin(freq1*(blend + t)) + 1.0) * 0.5;
    
    // throw in some sine-pulsed fbm
    blend = fbm(0.05*p);
    wave += (sin(freq2*(blend + 0.1*t)) + 1.0) * 0.5;    
    vec3 col = mix(start, end, wave);
    
    // domain distortion
    
    r -= fbm(vec2(r,0.1*t));
    r += sin(p.x+0.1*t);
    r -= sin(p.y+0.1*t);
	r += dot(r,wave);
	r -= dot(wave, 0.01*r);
	r -= fbm(vec2(r,0.09*t));
    r *= p.y*t;
	r *= 10.0*sin(p.x+0.9*t);
	
    
    // a circle made of fbm 
    if ( r<10.0*(sin(t)*0.5) )
    {
     	col = vec3(1.0, 0.6, 0.3);   
        col += 0.9 * fbm( p + 0.05*t);
        col = pow(col, 1.0 - 0.5*vec3(sin(0.01*t)));
    }
	
    col = pow(col, vec3(2.2));
    
	fragColor = vec4(col, 1.0);
}