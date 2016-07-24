// Shader downloaded from https://www.shadertoy.com/view/lsdXWr
// written by shadertoy user qleonetti
//
// Name: Space Jam
// Description: Was playing with Grapher app and wanted to turn some math into a shader
#define RATIO_DEFORMATION 0.5
#define SCREEN_TRANSLATE 0.5
#define SCALE 100000000.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (fragCoord.xy / iResolution.xy) - SCREEN_TRANSLATE;
    uv.y *= RATIO_DEFORMATION;
    float c = ceil(
        cos(uv.x*uv.y * SCALE )-
   		cos(uv.x/uv.y + iGlobalTime)
    );
	fragColor = vec4(c);
}