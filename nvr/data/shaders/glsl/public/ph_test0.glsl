// Shader downloaded from https://www.shadertoy.com/view/4sVGWt
// written by shadertoy user wuhao
//
// Name: ph_Test0
// Description: learning test 0

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

    vec2 dir = fragCoord.xy - iResolution.xy/2.0;

    vec2 uv0 = normalize(dir);
    float xx = iGlobalTime * .4;
    float C = cos(xx);
    float S = sin(xx);
    mat2 m=mat2(C,S,-S,C);
    vec2 uv1 = m*uv0;
    vec4 c0 = texture2D(iChannel3, uv1);
    
    fragColor = vec4(c0.rgb, 1.0);
}