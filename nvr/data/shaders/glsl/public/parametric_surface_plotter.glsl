// Shader downloaded from https://www.shadertoy.com/view/4dG3WW
// written by shadertoy user elias
//
// Name: Parametric Surface Plotter
// Description: Couldn't find one through the search so I thought I'd give it a go.
//    You can input your own equation in Buf A and tweak some parameters.
/*

    BufA = Rendering & Equation definition
    BufB = Evaluation Cache
    BufC = Font Display

*/

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iFrame < 2 || texture2D(iChannel3,vec2(32.5/256.,0.)).x > 0.0)
    {
		fragColor = texture2D(iChannel1, fragCoord.xy/iResolution.xy);
    }
    else
    {
        float res = texture2D(iChannel0, vec2(0.5)/iResolution.xy).x;
        fragColor = texture2D(iChannel0, fragCoord.xy/iResolution.xy*res);
	}
}