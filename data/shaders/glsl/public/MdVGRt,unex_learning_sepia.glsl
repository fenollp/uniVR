// Shader downloaded from https://www.shadertoy.com/view/MdVGRt
// written by shadertoy user blfunex
//
// Name: Unex learning Sepia
// Description: basic sepia effect
void sepia( inout vec3 color, float adjust ) {
    color.r = min(1.0, (color.r * (1.0 - (0.607 * adjust))) + (color.g * (0.769 * adjust)) + (color.b * (0.189 * adjust)));
    color.g = min(1.0, (color.r * (0.349 * adjust)) + (color.g * (1.0 - (0.314 * adjust))) + (color.b * (0.168 * adjust)));    
    color.b = min(1.0, (color.r * (0.272 * adjust)) + (color.g * (0.534 * adjust)) + (color.b * (1.0 - (0.869 * adjust))));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = texture2D(iChannel0, uv).rgb;
    sepia(color, 0.75);
	fragColor = vec4(color, 1.0);
}