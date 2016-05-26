// Shader downloaded from https://www.shadertoy.com/view/ltfGzf
// written by shadertoy user aiekick
//
// Name: Transitions : DoorWay
// Description: From https://glsl.io/
// from https://glsl.io/

#define from iChannel0
#define to iChannel1
float progress = sin(iGlobalTime*0.5)*.5+.5;
vec2 resolution = iResolution.xy;
 
float reflection = .4;
float perspective = .4;
float depth = 3.;
 
const vec4 black = vec4(0.0, 0.0, 0.0, 1.0);
const vec2 boundMin = vec2(0.0, 0.0);
const vec2 boundMax = vec2(1.0, 1.0);
 
bool inBounds (vec2 p) {
  return all(lessThan(boundMin, p)) && all(lessThan(p, boundMax));
}
 
vec2 project (vec2 p) {
  return p * vec2(1.0, -1.2) + vec2(0.0, -0.02);
}
 
vec4 bgColor (vec2 p, vec2 pto) {
  vec4 c = black;
  pto = project(pto);
  if (inBounds(pto)) {
    c += mix(black, texture2D(to, pto), reflection * mix(1.0, 0.0, pto.y));
  }
  return c;
}
 
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 p = fragCoord.xy / resolution.xy;
 if ( iMouse.z>0.) progress = iMouse.x/iResolution.x;

  vec2 pfr = vec2(-1.), pto = vec2(-1.);
 
  float middleSlit = 2.0 * abs(p.x-0.5) - progress;
  if (middleSlit > 0.0) {
    pfr = p + (p.x > 0.5 ? -1.0 : 1.0) * vec2(0.5*progress, 0.0);
    float d = 1.0/(1.0+perspective*progress*(1.0-middleSlit));
    pfr.y -= d/2.;
    pfr.y *= d;
    pfr.y += d/2.;
  }
 
  float size = mix(1.0, depth, 1.-progress);
  pto = (p + vec2(-0.5, -0.5)) * vec2(size, size) + vec2(0.5, 0.5);
 
  if (inBounds(pfr)) {
    fragColor = texture2D(from, pfr);
  }
  else if (inBounds(pto)) {
    fragColor = texture2D(to, pto);
  }
  else {
    fragColor = bgColor(p, pto);
  }
}