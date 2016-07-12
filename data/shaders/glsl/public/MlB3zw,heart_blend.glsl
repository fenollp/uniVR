// Shader downloaded from https://www.shadertoy.com/view/MlB3zw
// written by shadertoy user hunter
//
// Name: Heart Blend
// Description: orginal by:  macbooktall ( https://www.shadertoy.com/view/llSGzw )
// orginal by:  macbooktall ( https://www.shadertoy.com/view/llSGzw )

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
     
    uv.x = (abs(uv.x*2.0-1.0));
    uv.y = (abs(uv.y*2.0-1.0));
    
    vec2 left  = vec2(uv.x - sin(uv.x*uv.y), uv.x);
    vec2 right = vec2(uv.x + sin(uv.x*uv.y), uv.y);
     
    vec4 color = texture2D(iChannel0, left) * texture2D(iChannel0, right);
    fragColor = color;
}