// Shader downloaded from https://www.shadertoy.com/view/4ljSW1
// written by shadertoy user arhad
//
// Name: Chessboard without IFs
// Description: Uniformly scaled chessboard material, created with no conditional branches.
#define SCALE 3.0

// Generates a chessboard pattern.
//
// It is made of vertical stripes that are shifted by oscillating xOffset along with vertical axis.
// Stripes and oscillation are made by a square wave.
float chessboard(vec2 uv)
{
    float xOffset = step(fract(uv.y), 0.5) * 0.5;
    return step(fract(uv.x + xOffset), 0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xx * SCALE;
    vec3 color = vec3(chessboard(uv));
    
	fragColor = vec4(color, 1.0);
}