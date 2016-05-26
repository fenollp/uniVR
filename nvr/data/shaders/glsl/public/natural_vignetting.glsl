// Shader downloaded from https://www.shadertoy.com/view/4lSXDm
// written by shadertoy user ApoorvaJ
//
// Name: Natural vignetting
// Description: Based on Keijiro Takahashi's Kino Vignette
//    https://github.com/keijiro/KinoVignette
float Falloff = 0.25;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec2 coord = (uv - 0.5) * (iResolution.x/iResolution.y) * 2.0;
    float rf = sqrt(dot(coord, coord)) * Falloff;
    float rf2_1 = rf * rf + 1.0;
    float e = 1.0 / (rf2_1 * rf2_1);
    
    vec4 src = vec4(1.0,1.0,1.0,1.0);
	fragColor = vec4(src.rgb * e, 1.0);
}