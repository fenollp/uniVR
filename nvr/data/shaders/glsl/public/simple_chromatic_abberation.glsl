// Shader downloaded from https://www.shadertoy.com/view/lsKSDz
// written by shadertoy user Knifa
//
// Name: Simple Chromatic Abberation
// Description: !
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
    vec2 d = abs((uv - 0.5) * 2.0);
    d = pow(d, vec2(2.0, 2.0));
        
    vec4 r = texture2D(iChannel0, uv - d * 0.015);
    vec4 g = texture2D(iChannel0, uv);
    vec4 b = texture2D(iChannel0, uv);
    
    fragColor = vec4(r.r, g.g, b.b, 1.0);
}