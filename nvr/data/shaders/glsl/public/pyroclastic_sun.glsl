// Shader downloaded from https://www.shadertoy.com/view/XtlXR2
// written by shadertoy user Duke
//
// Name: Pyroclastic sun
// Description: Noise was changed to this http://www.csee.umbc.edu/~olano/papers/index.html#mNoise one.
//    Upd.: Switched to iq's noise from here https://www.shadertoy.com/view/XslGRr 
//    Previous had some bugs on different browsers.
// based on this https://www.shadertoy.com/view/MtXSzS port
// iq's noise from here https://www.shadertoy.com/view/XslGRr
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

#define saturate(oo) clamp(oo, 0.0, 1.0)

// Quality Settings
#define MarchSteps 16
// Scene Settings
#define ExpPosition vec3(0.0)
#define Radius 1.8
#define Background vec4(0.1, 0.0, 0.0, 1.0)
// Noise Settings
#define NoiseSteps 4
#define NoiseAmplitude 0.06
#define NoiseFrequency 48.0
#define Animation vec3(0.0, -3.0, 0.5)
// Colour Gradient
#define Color1 vec4(1.0, 1.0, 1.0, 1.0)
#define Color2 vec4(1.0, 0.8, 0.2, 1.0)
#define Color3 vec4(1.0, 0.03, 0.0, 1.0)
#define Color4 vec4(0.5, 0.2, 0.2, 1.0)

/* noise from here http://webgl-fire.appspot.com/html/fire.html (based on this http://www.csee.umbc.edu/~olano/papers/index.html#mNoise work)
// Pregenerated noise texture.
  const float modulus = 80.0;  // Value used in pregenerated noise texture.

// Modified Blum Blum Shub pseudo-random number generator.
vec2 mBBS(vec2 val, float modulus) {
    val = mod(val, modulus); // For numerical consistancy.
    return mod(val * val, modulus);
  }

float mnoise(vec3 pos) {
    float intArg = floor(pos.z);
    float fracArg = fract(pos.z);
    vec2 hash = mBBS(intArg * 3.0 + vec2(0, 3), modulus);
    vec4 g = vec4(
        texture2D(iChannel0, vec2(pos.x, pos.y + hash.x) / modulus).xy,
        texture2D(iChannel0, vec2(pos.x, pos.y + hash.y) / modulus).xy) * 2.0 - 1.0;
    return mix(g.x + g.y * fracArg,
               g.z + g.w * (fracArg - 1.0),
               smoothstep(0.0, 1.0, fracArg));
  }
*/
float noise( in vec3 x )
{
    vec3 p = floor(x);
    vec3 f = fract(x);
	f = f*f*(3.0-2.0*f);
	vec2 uv = (p.xy+vec2(37.0,17.0)*p.z) + f.xy;
	vec2 rg = texture2D( iChannel0, (uv+ 0.5)/256.0, -100.0 ).yx;
	return -1.0+1.7*mix( rg.x, rg.y, f.z );
}
    
float Turbulence(vec3 position, float minFreq, float maxFreq, float qWidth)
{
 float value = 0.0;
 float cutoff = clamp(0.5/qWidth, 0.0, maxFreq);
 float fade;
 float fOut = minFreq;
 for(int i=NoiseSteps ; i>=0 ; i--)
 {
  if(fOut >= 0.5 * cutoff) break;
  fOut *= 2.0;
  value += abs(noise(position * fOut))/fOut;
 }
 fade = clamp(2.0 * (cutoff-fOut)/cutoff, 0.0, 1.0);
 value += fade * abs(noise(position * fOut))/fOut;
 return 1.0-value;
}

float SphereDist(vec3 position)
{
 return length(position - ExpPosition) - Radius;
}

vec4 Shade(float distance)
{
 float c1 = saturate(distance*5.0 + 0.5);
 float c2 = saturate(distance*5.0);
 float c3 = saturate(distance*3.4 - 0.5);
 vec4 a = mix(Color1,Color2, c1);
 vec4 b = mix(a,     Color3, c2);
 return   mix(b,     Color4, c3);
}

// Draws the scene
float RenderScene(vec3 position, out float distance)
{
 float noise = Turbulence(position * NoiseFrequency + Animation*iGlobalTime*0.24, 0.1, 1.5, 0.03) * NoiseAmplitude;
 noise = saturate(abs(noise));
 distance = SphereDist(position) - noise;
 return noise;
}

// Basic ray marching method.
vec4 March(vec3 rayOrigin, vec3 rayStep)
{
 vec3 position = rayOrigin;
 float distance;
 float displacement;
 for(int step = MarchSteps; step >=0  ; --step)
 {
  displacement = RenderScene(position, distance);
  if(distance < 0.05) break;
  position += rayStep * distance;
 }
 return mix(Shade(displacement), Background, float(distance >= 0.5));
}

bool IntersectSphere(vec3 ro, vec3 rd, vec3 pos, float radius, out vec3 intersectPoint)
{
 vec3 relDistance = (ro - pos);
 float b = dot(relDistance, rd);
 float c = dot(relDistance, relDistance) - radius*radius;
 float d = b*b - c;
 intersectPoint = ro + rd*(-b - sqrt(d));
 return d >= 0.0;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
 vec2 p = (gl_FragCoord.xy / iResolution.xy) * 2.0 - 1.0;
 p.x *= iResolution.x/iResolution.y;
 float rotx = iMouse.y * 0.01;
 float roty = -iMouse.x * 0.01+iGlobalTime*0.1;
 float zoom = 5.0;
 // camera
 vec3 ro = zoom * normalize(vec3(cos(roty), cos(rotx), sin(roty)));
 vec3 ww = normalize(vec3(0.0, 0.0, 0.0) - ro);
 vec3 uu = normalize(cross( vec3(0.0, 1.0, 0.0), ww));
 vec3 vv = normalize(cross(ww, uu));
 vec3 rd = normalize(p.x*uu + p.y*vv + 1.5*ww);
 vec4 col = Background;
 vec3 origin;
 if(IntersectSphere(ro, rd, ExpPosition, Radius + NoiseAmplitude*14.0, origin))
 {
  col = March(origin, rd);
 }
 fragColor = col;
}