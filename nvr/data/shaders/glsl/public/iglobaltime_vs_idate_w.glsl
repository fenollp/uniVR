// Shader downloaded from https://www.shadertoy.com/view/Ms3XzM
// written by shadertoy user GregRostami
//
// Name: iGlobalTime vs iDate.w
// Description: This shader demonstrates the difference in the precision of iGlobalTime vs iDate.w
//    If you view this shader after midnight the top and bottom will be very similar!
// This shader demonstrates the difference in the precision of iGlobalTime vs iDate.w
// If you view this shader after midnight the top and bottom will be very similar!
void mainImage(out vec4 o,vec2 i)
{
i/=iResolution.xy;
o = vec4 ( i.y > .5
  ? .5+.5*sin(i.x - iGlobalTime *8.)    //iGlobalTime has greater precision
  : .5+.5*sin(i.x - iDate.w     *8.));  //iDate.w displays banding because of lower precision
}