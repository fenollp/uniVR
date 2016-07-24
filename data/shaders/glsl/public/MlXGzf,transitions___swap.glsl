// Shader downloaded from https://www.shadertoy.com/view/MlXGzf
// written by shadertoy user aiekick
//
// Name: Transitions : Swap
// Description: Im not the author of this code. I have just adapted it to ShaderToy.
//    Code from here : [url=https://glsl.io/]Glsl.io[/url]
#define from iChannel0
#define to iChannel1
float progress = sin(iGlobalTime*.5)*.5+.5;
vec2 resolution = iResolution.xy;

float reflection = .4;
float perspective = .2;
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
 
vec4 bgColor (vec2 p, vec2 pfr, vec2 pto) {
  vec4 c = black;
  pfr = project(pfr);
  if (inBounds(pfr)) {
    c += mix(black, texture2D(from, pfr), reflection * mix(1.0, 0.0, pfr.y));
  }
  pto = project(pto);
  if (inBounds(pto)) {
    c += mix(black, texture2D(to, pto), reflection * mix(1.0, 0.0, pto.y));
  }
  return c;
}
 
void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
  vec2 p = fragCoord.xy / resolution.xy;
  if (iMouse.z>0.) progress = iMouse.x/iResolution.x;

  vec2 pfr, pto = vec2(-1.);
 
  float size = mix(1.0, depth, progress);
  float persp = perspective * progress;
  pfr = (p + vec2(-0.0, -0.5)) * vec2(size/(1.0-perspective*progress), size/(1.0-size*persp*p.x)) + vec2(0.0, 0.5);
 
  size = mix(1.0, depth, 1.-progress);
  persp = perspective * (1.-progress);
  pto = (p + vec2(-1.0, -0.5)) * vec2(size/(1.0-perspective*(1.0-progress)), size/(1.0-size*persp*(0.5-p.x))) + vec2(1.0, 0.5);
 
  bool fromOver = progress < 0.5;
 
  if (fromOver) {
    if (inBounds(pfr)) {
      fragColor = texture2D(from, pfr);
    }
    else if (inBounds(pto)) {
      fragColor = texture2D(to, pto);
    }
    else {
      fragColor = bgColor(p, pfr, pto);
    }
  }
  else {
    if (inBounds(pto)) {
      fragColor = texture2D(to, pto);
    }
    else if (inBounds(pfr)) {
      fragColor = texture2D(from, pfr);
    }
    else {
      fragColor = bgColor(p, pfr, pto);
    }
  }
}