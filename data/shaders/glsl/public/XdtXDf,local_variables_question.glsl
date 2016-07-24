// Shader downloaded from https://www.shadertoy.com/view/XdtXDf
// written by shadertoy user vox
//
// Name: Local Variables Question
// Description: Does &quot;int counter = 0;&quot; really keep count of the number of pixels rendered? I realize this question makes no sense for an algorithm run on a parallel processor; it seems useful, though: http://www.geeks3d.com/20120309/opengl-4-2-atomic-counter-demo-re
#define PI 3.14159265359

int counter = 0;
#define saw(x) (acos(cos(x))/PI)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy*2.0-1.0;
    fragColor = vec4(saw(length(uv)+float(counter++)/PI));
}