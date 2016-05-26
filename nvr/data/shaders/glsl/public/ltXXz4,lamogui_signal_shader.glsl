// Shader downloaded from https://www.shadertoy.com/view/ltXXz4
// written by shadertoy user lamogui
//
// Name: lamogui signal shader
// Description: Official lamogui signal shader more info: http://lamogui.github.io
//Made for my audio tool : lamogui
//Not quite exact because the number of sample is different
//CC BY-NC-SA 3.0 FR ID: 1GMgzH4jmMaZrgTDZuMy1gCw7qssyyWFqH
//More info https://lamogui.github.io
//View the shader here: https://www.shadertoy.com/view/ltXXz4

const vec4 color=vec4(1.,1.,1.,1.);
const float thickness=2./100.;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
  vec2 v = fragCoord.xy / iResolution.xy;
  //iChannel0 = texture that contains audia samples scaled from .0 to 1.
  float vs=texture2D(iChannel0, vec2(v.x,.75)).x;
  float eps=vs-v.y;
  float thick=thickness*0.5;
  float a=color.a*(1.0-pow(abs(eps/thick),1.5));
  if (eps > -thick && eps < thick)
  	fragColor = vec4(a*color.rgb, 1.);
  else 
    fragColor = vec4(0.16,0.16,0.16,1.);
}