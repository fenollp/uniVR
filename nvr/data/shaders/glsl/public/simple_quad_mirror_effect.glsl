// Shader downloaded from https://www.shadertoy.com/view/XdG3zw
// written by shadertoy user hunter
//
// Name: Simple Quad Mirror Effect
// Description: still learning
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 c[4];
    c[0] = texture2D(iChannel0, uv);
    c[1] = texture2D(iChannel0, vec2(1.0-uv.x, uv.y));
    c[2] = texture2D(iChannel0, vec2(uv.x, 1.0-uv.y));
    c[3] = texture2D(iChannel0, vec2(1.0-uv.x, 1.0-uv.y));
    
    vec4 color = (uv.y >= 0.5 && uv.x >= 0.5) ? c[0] :
                 (uv.y >= 0.5 && uv.x < 0.5) ? c[1] :
                 (uv.y < 0.5 && uv.x >= 0.5) ? c[2] : c[3];
    
    vec4 d = max(c[0], c[1]);
    d = max(d, c[2]);
    d = max(d, c[3]);
    
    
    vec3 s = mix(color.rgb, d.rgb, (color.rgb + d.rgb) * 0.5); 
    fragColor = vec4(s.rgb, 1.0);
}