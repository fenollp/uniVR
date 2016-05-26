// Shader downloaded from https://www.shadertoy.com/view/4sKGDV
// written by shadertoy user piotrekli
//
// Name: Test 2.
// Description: test...
vec4 light(sampler2D channel, vec2 fragCoord)
{
    vec4 s = vec4(0.0);
    s += 1.0*texture2D(channel, (fragCoord+vec2(0.0, 0.0))/iResolution.xy);
    s -= 0.5*texture2D(channel, (fragCoord+vec2(1.0, 0.0))/iResolution.xy);
    s -= 0.5*texture2D(channel, (fragCoord+vec2(0.0, 1.0))/iResolution.xy);
    return s;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec3 color = 1.0-texture2D(iChannel0, uv).xyz;
    color *= color;
    //color *= color*color*color;
    color = 1.0-color;
    color += dot(vec3(1.0), light(iChannel0, fragCoord).xyz)*2.0;
	fragColor = vec4(color, 1.0);
}