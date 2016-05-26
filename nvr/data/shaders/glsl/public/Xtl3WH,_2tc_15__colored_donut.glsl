// Shader downloaded from https://www.shadertoy.com/view/Xtl3WH
// written by shadertoy user aiekick
//
// Name: [2TC 15] Colored Donut
// Description: [2TC 15] Colored Donut
void mainImage( out vec4 f, in vec2 w )
{
    vec2 s = iResolution.xy, k = 1.3*(2.*w-s)/s.y; 
    
    float r = dot(k.xyx, k.xxy), t = iDate.w * 1.8, c;
    
    k *= 3.5 * mat2(cos(t),-sin(t),sin(t),cos(t));
    
    c = length(k);
    
    f.rgb = mix(vec3(r, dot(r, k.x), dot(r, k.y))+c, vec3(1), c);
}