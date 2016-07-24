// Shader downloaded from https://www.shadertoy.com/view/4tS3Rm
// written by shadertoy user andrewmac
//
// Name: GRID FOR TRON
// Description: Grid example
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 pixel = uv * vec2(8, 8);
    vec2 dif = pixel - floor(pixel);
    vec2 grid = floor(dif + vec2(0.02, 0.02));
    
    vec4 texture = texture2D( iChannel0, uv );
    float val = floor(grid.x + grid.y);
	fragColor = vec4(texture.rgb - val,1.0);
}