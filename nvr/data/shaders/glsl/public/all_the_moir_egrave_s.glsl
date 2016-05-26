// Shader downloaded from https://www.shadertoy.com/view/lt23Rh
// written by shadertoy user scirvir
//
// Name: all the moir&egrave;s
// Description: Thinking about moires, 
/* Added ACCEL such that the zoom out speed is easier to customize
   Try 10. or Don't I'm not your dad.
*/
#define ACCEL 1.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float ar = iResolution.x / iResolution.y;
	vec2 uv = fragCoord.xy / iResolution.xy 
        - vec2( 0.5 , 0.5);
    uv.x = ar * uv.x;
    fragColor = vec4( sin (15. * (iGlobalTime * ACCEL) * dot( uv, uv)),
                      sin (25. * (iGlobalTime * ACCEL) * dot( uv, uv)),
                      sin (35. * (iGlobalTime * ACCEL) * dot( uv, uv)),
                      1.);
}