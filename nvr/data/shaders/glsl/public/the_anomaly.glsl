// Shader downloaded from https://www.shadertoy.com/view/4dV3Ry
// written by shadertoy user DrLuke
//
// Name: The Anomaly
// Description: The warping effect is the result of only marching 0.1 times the distance returned from the distance function.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
	fragColor = texture2D(iChannel1, uv);
}