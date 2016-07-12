// Shader downloaded from https://www.shadertoy.com/view/lsdGDf
// written by shadertoy user ChazMeister
//
// Name: Warped Moving Image
// Description: I thought this looked quite cool
void mainImage(out vec4 fragColor, in vec2 fragCoord)
{    
    vec2 p = -0.1 + 10.0 * fragCoord.xy / iResolution.xy;
    vec2 uv;
   
    float a = atan(p.y, p.x);
    float r = sqrt(dot(p, p));

    uv.x = .75 * iGlobalTime+.1 / 1.0;
    uv.y = a / 3.1416;

    vec3 col = texture2D(iChannel0, uv).xyz;

    fragColor = vec4(col * r, 1.0);
}