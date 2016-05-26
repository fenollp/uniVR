// Shader downloaded from https://www.shadertoy.com/view/XsyGWK
// written by shadertoy user worldedit
//
// Name: A simple blackhole
// Description: a simple blackhole
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    vec2 center = vec2(0.5, 0.5);
    vec2 tc = uv - center;
    float d = distance(uv, center);
    float r = abs(sin(iGlobalTime / 10.)) * 0.5;//clamp(iGlobalTime / 10., 0.0, 1.0);
    
    float percent = clamp((r - d) / r, 0.0, 1.0);
    float T = sin(iGlobalTime / 10.);
    float theta = percent * percent * T * 12.;
    
    float s = sin(theta);
    float c = cos(theta);
    
    tc = vec2(dot(tc, vec2(c, -s)), dot(tc, vec2(s, c)));
    tc += center;
    
	fragColor = vec4(texture2D(iChannel0,tc).rgb,1.0);
    
    fragColor.rgb *= pow(1. - percent, 3.);
}