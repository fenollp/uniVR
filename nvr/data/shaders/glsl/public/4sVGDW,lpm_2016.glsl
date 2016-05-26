// Shader downloaded from https://www.shadertoy.com/view/4sVGDW
// written by shadertoy user Reymenta
//
// Name: LPM 2016
// Description: from the code of the LPM 2016 
#define t iGlobalTime

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float a = texture2D(iChannel0, uv).y;
	vec2 uv2 = 2.  * uv + a;
    float col = texture2D(iChannel0, uv).x * .3;
    uv2.x += sin(t * a *10. );
    col += abs(.5/uv2.x * col );
	fragColor = vec4(vec3(col),1.0);
}