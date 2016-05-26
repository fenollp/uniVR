// Shader downloaded from https://www.shadertoy.com/view/XdVXRh
// written by shadertoy user ChronosDragon
//
// Name: Messing with dithering
// Description: I recalled reading that the 8x8 noise texture here is actually a Bayer dithering matrix, so wanted to investigate. Might reuse this shader for more dithering experiments in the future.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 color = texture2D(iChannel0, uv);
    
    vec3 value = color.rgb;
    vec3 oldcolor = value + (value * texture2D(iChannel1, (mod(fragCoord, 8.0) / 8.0)).rgb);
    vec3 newcolor = floor(oldcolor);
    if (fragCoord.x > iMouse.x) {
		fragColor = vec4(newcolor, 1.0);
    }
    else {
        fragColor = vec4(value, 1.0);
    }
}