// Shader downloaded from https://www.shadertoy.com/view/4sdSzH
// written by shadertoy user Lawliet
//
// Name: BackgroundGrid
// Description: Test the transparency
vec4 grid(vec2 fragCoord)
{
    vec2 index = ceil(fragCoord * 0.1);
   	
    return vec4(0.7 + 0.5*mod(index.x + index.y, 2.0));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    fragColor = grid(fragCoord);
}
