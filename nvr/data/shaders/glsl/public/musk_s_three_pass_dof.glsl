// Shader downloaded from https://www.shadertoy.com/view/MsG3Dz
// written by shadertoy user mu6k
//
// Name: musk's three pass dof
// Description: Use mouse to rotate! My attempt at writing a decent depth of field effect. Well all I can say is that I'm satisfied with it.
/*by musk License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
  email: muuuusk at gmail dot com

2016-02-02:

  My attempt at writing a decent depth of field effect.
  Well all I can say is that I'm satisfied with it.

  My attempt was to get a hexagonal bokeh. Well it's sort of like that.
  But maybe using it on a scene with a lot of reflection wasnt the best idea...

  So you might ask how come this is three pass when four buffers are used?
  Well only the depth of field effect uses 3 passes. 
  The rest of the passes handle rendering and post processing.
  
  This part here is the post processing.
*/

#define DISPLAY_GAMMA 1.8
#define USE_CHROMATIC_ABBERATION

vec2 uvsToUv(vec2 uvs){
    return (uvs)*vec2(iResolution.y/iResolution.x,1.0)+vec2(.5,.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 uvs = (fragCoord.xy-iResolution.xy*.5)/iResolution.yy;
    
    //chromatic abberation
    #ifdef USE_CHROMATIC_ABBERATION
    vec3 color = vec3(0,0,0);
    color.x += texture2D(iChannel0, uvsToUv(uvs)).x*.66;
    color.xy += texture2D(iChannel0, uvsToUv(uvs*.995)).xy*.33;
    color.y += texture2D(iChannel0, uvsToUv(uvs*.990)).y*.33;
    color.yz += texture2D(iChannel0, uvsToUv(uvs*.985)).yz*.33;
    color.z += texture2D(iChannel0, uvsToUv(uvs*.980)).z*.66;
    #else
    vec3 color = texture2D(iChannel0, uvsToUv(uvs)).xyz;
    #endif
    
    //tone mapping
    color = vec3(1.7,1.8,1.9)*color/(1.0+color);
    
    //inverse gamma correction
	fragColor = vec4(pow(color,vec3((1.0)/(DISPLAY_GAMMA))),1.0);
}