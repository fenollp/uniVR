// Shader downloaded from https://www.shadertoy.com/view/XsVSW1
// written by shadertoy user tamasaur
//
// Name: Fisheye/Pinch
// Description: Simple webcam shader with toggleable pinch/bulge capabilities
#define TESTS 50.0
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 p = fragCoord.xy/iResolution.xy - 0.5;
  
  // cartesian to polar coordinates
  float r = length(p);
  float a = atan(p.y, p.x);
  
  // distort
  //r = sqrt(r)*0.3; // pinch
  r = r*r*3.0; // bulge
  
  // polar to cartesian coordinates
  p = r * vec2(cos(a)*0.5, sin(a)*0.5);
  
  // sample the iChannel0
  vec4 color = texture2D(iChannel0, p + 0.5);
  fragColor = color;
}

