// Shader downloaded from https://www.shadertoy.com/view/XddSRX
// written by shadertoy user cornusammonis
//
// Name: Suture Fluid
// Description: Fake fluid dynamical system that creates viscous-fingering-like flow patterns, and suturing patterns along boundaries. Try letting it evolve for a while in fullscreen. Use the mouse to paint, spacebar resets the system (useful in fullscreen).
// Visualization of the system in Buffer A

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 texel = 1. / iResolution.xy;
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 c = texture2D(iChannel0, uv).xyz;
    vec3 norm = normalize(c);
    
    vec3 div = vec3(0.1) * norm.z;    
    vec3 rbcol = 0.5 + 0.6 * cross(norm.xyz, vec3(0.5, -0.4, 0.5));
    
    fragColor = vec4(rbcol + div, 0.0);
}