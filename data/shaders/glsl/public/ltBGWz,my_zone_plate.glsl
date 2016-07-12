// Shader downloaded from https://www.shadertoy.com/view/ltBGWz
// written by shadertoy user ap
//
// Name: my zone plate
// Description: Just a zoneplate. Started at 433 characters until GregRostami's first comment.
void mainImage(out vec4 o, vec2 i)
{
  float f=length(i)/iResolution.y;
  o=vec4((1.+cos(1e3*mix(1.,sin(iGlobalTime),.3)*f*f))/2.);
}