// Shader downloaded from https://www.shadertoy.com/view/4sK3RR
// written by shadertoy user cornusammonis
//
// Name: Particle System Dynamics
// Description: A particle system implementing several different forces, and rule-based particle interactions. Use mouse controls to speed up particles locally.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 is = texture2D(iChannel1, uv);
    float l = length(is);    
    fragColor = ((0.5 + 0.5 * sin(20.0 * l))/l) *  vec4(is.xyz, 0.0) + 0.5 * vec4(is.w, is.w, 0.0, 0.0); 
}