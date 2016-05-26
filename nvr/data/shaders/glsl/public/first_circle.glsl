// Shader downloaded from https://www.shadertoy.com/view/XljXzz
// written by shadertoy user wangyue66
//
// Name: first_circle
// Description: just a circle
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / min(iResolution.x,iResolution.y);
    uv = uv*2.0-1.0;
    uv.x -= 0.7;
    float l = length(uv);
    if(l < 1.0)
        l = 1.0;
    else
        l = 0.0;
    vec3 col = vec3(1.0,0.0,1.0);
	fragColor = vec4(col*l,1.0);
}