// Shader downloaded from https://www.shadertoy.com/view/MsVGRt
// written by shadertoy user gnalvesteffer
//
// Name: Wave Flames
// Description: Cool.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float drawScale = iResolution.x / 50.0;
    float speed = iGlobalTime * 5.0;
	float x = fragCoord.x;    
    float y = sin(x / drawScale + speed) * ((fragCoord.x / 5.0) + 100.0 * sin(fragCoord.y + x - speed));    
    fragColor = vec4(
        x / distance(vec2(fragCoord.x, fragCoord.y), vec2(x, y)) / iResolution.x * 20.0, //R
        0.02, //G
        0.3 * (y / iResolution.y), //B
        1.0);
}