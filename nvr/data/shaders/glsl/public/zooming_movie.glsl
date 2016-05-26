// Shader downloaded from https://www.shadertoy.com/view/MlBGRh
// written by shadertoy user donmilham
//
// Name: Zooming Movie
// Description: - zoom in and out of texture over time
//    - tweaking colors over time
//    - static effect
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    float scale = .5 + .5 * (1.0 + sin(iGlobalTime * .5));
    vec4 c = texture2D(iChannel0, (.5 + -.5 * scale +  uv * scale), 1.0);
    c.r = c.r * .5 + c.r * 1.2 * sin(iGlobalTime * 2.0);
    c.g = c.g * .5 + c.g * 1.2 * sin(iGlobalTime * 1.5);
    c.b = c.b * .5 + c.b * 1.2 * sin(iGlobalTime * 1.25);
    fragColor = c;
    
    vec2 offset = texture2D(iChannel1, vec2(fract(iGlobalTime * 2.0), fract(iGlobalTime)), 1.0).xy;
    
    fragColor += texture2D(iChannel1, offset + uv, .1);
}