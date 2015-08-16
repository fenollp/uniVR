// Shader downloaded from https://www.shadertoy.com/view/4sXGzn
// written by shadertoy user iq
//
// Name: Deform - holes
// Description: A simple 2D plane deformation driven by the mouse (more info here: http://www.iquilezles.org/www/articles/deform/deform.htm)
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 p = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
  vec2 m = -1.0 + 2.0 * iMouse.xy / iResolution.xy;

  float a1 = atan(p.y-m.y,p.x-m.x);
  float r1 = sqrt(dot(p-m,p-m));
  float a2 = atan(p.y+m.y,p.x+m.x);
  float r2 = sqrt(dot(p+m,p+m));

  vec2 uv;
  uv.x = 0.2*iGlobalTime + (r1-r2)*0.25;
  uv.y = asin(sin(a1-a2))/3.1416;
	

  vec3 col = texture2D( iChannel0, 0.125*uv ).zyx;

  float w = exp(-15.0*r1*r1) + exp(-15.0*r2*r2);

  w += 0.25*smoothstep( 0.93,1.0,sin(128.0*uv.x));
  w += 0.25*smoothstep( 0.93,1.0,sin(128.0*uv.y));
	
  fragColor = vec4(col+w,1.0);
}