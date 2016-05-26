// Shader downloaded from https://www.shadertoy.com/view/XlfXWf
// written by shadertoy user jackdavenport
//
// Name: 2D Light Test
// Description: I decided to try making a 2D light effect. Move with the mouse, increase light size by decreasing LIGHT_RANGE.
//    
//    I started off trying to do a point light effect, but it bugged out and made a really cool spotlight, so I'm pretty happy :)
#define LIGHT_RANGE 90.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 light = vec2(.2,.2);
    
    if(iMouse.z > 0.) {
     
        light = iMouse.xy / iResolution.xy;
        
    } else {
     
        light = vec2(abs(sin(iGlobalTime)),.2);
        
    }
    
    vec3 finalColor = vec3(.8,.8,.8) * pow(max(dot(normalize(light),normalize(uv)),0.),LIGHT_RANGE);
    vec3 bg = texture2D(iChannel0, uv).xyz / 4.;
    
	fragColor = vec4(bg + finalColor.xyz,1.);
}