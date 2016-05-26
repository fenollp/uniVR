// Shader downloaded from https://www.shadertoy.com/view/lsK3Dm
// written by shadertoy user mahrizh
//
// Name: Sun sprite
// Description: Use pre-rotated texture channels to avoid multiple uvs. The blank line separates vert and frag parts.
/*
||  Attribution-NonCommercial (CC BY-NC v4)      \\
||  http://creativecommons.org/licenses/by-nc/4.0/  \\
||  made by mahrizh
*/
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 colA = vec4(1.0, 0.0, 0.0, 1.0);
    vec4 colB = vec4(2.0, 1.5, 0.8, 1.0);
	vec2 uv0 = ((fragCoord.xy - iResolution.xy * .5) / iResolution.y) * 2.0;
    float angle = 0.79;
    mat2 rot = mat2(
        sin(angle), -cos(angle),
        cos(angle), sin(angle)
    );
    vec2 uv1 = uv0 * rot;
    vec2 uv2 = rot * uv0;
    vec3 enlarge = 2. - fract(vec3(0., 0.333, 0.667) + iGlobalTime*0.5);
    
    float r = dot(uv0,uv0);
    float p = (pow(r, 3.) + 0.3);
    uv0 *= p;
    uv1 *= p;
    uv2 *= p;
    float fire = dot(vec3(
        texture2D(iChannel0, uv0 * enlarge.x).x,
        texture2D(iChannel0, uv1 * enlarge.y).y,
        texture2D(iChannel0, uv2 * enlarge.z).z
    ), smoothstep(vec3(0.5), vec3(0.0), abs(fract(enlarge)-0.5)));
    fragColor = mix(colA, colB, fire) - r*r * 1.75;
}