// Shader downloaded from https://www.shadertoy.com/view/Mt2XRD
// written by shadertoy user mrdoob
//
// Name: Van Damme Trails
// Description: Just curious...
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 tex = texture2D(iChannel0,uv);
    float distance = tex.g - max( tex.r, tex.b );
    if (distance > 0.05) discard;
	fragColor = tex;
}