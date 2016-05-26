// Shader downloaded from https://www.shadertoy.com/view/lsVGz3
// written by shadertoy user FabriceNeyret2
//
// Name: chromatic aberration 2
// Description: how much chromatic aberration do you prefer ? tune with mouse x (0 to 10%)
void mainImage( out vec4 O,  vec2 U )
{
    vec2 R = iResolution.xy, m = iMouse.xy/R; 
	U/= R;
    float d = (length(m)<.02) ? .015 : m.x/10.;
  //float d = (length(m)<.02) ? .05-.05*cos(iDate.w) : m.x/10.;
 
	O = vec4( texture2D(iChannel0,U-d).x,
              texture2D(iChannel0,U  ).x,
              texture2D(iChannel0,U+d).x,
              1);
}