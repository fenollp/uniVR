// Shader downloaded from https://www.shadertoy.com/view/llsXW7
// written by shadertoy user brejep
//
// Name: Do not adjust your tv
// Description: Rgb splitting
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    vec4 tex = texture2D(iChannel0, uv);
    
    float val = 0.1 - mod(iChannelTime[0] / 10.0, 0.2);
    
    vec4 rTex = texture2D(iChannel0, uv - val);
    float red = rTex.r;
    
    vec4 gTex = texture2D(iChannel0, uv + val);
    float green = gTex.g;
    
    vec4 bTex = texture2D(iChannel0, uv - 0.2);
    float blue = bTex.b;
    
    vec2 uv2 = vec2(uv.x, mod(iGlobalTime, 1.175));
    vec4 tex2 = texture2D(iChannel0, uv2);
    
    float grey = dot(vec3(red, green, blue), vec3(0.3, 0.59, 0.11));
    
    vec4 tex3 = mix(tex, tex2, 0.1);
    
    fragColor = mix(tex3, vec4(grey, grey, grey, 1.0), 0.2);
    vec2 posMod = mod( fragCoord.xy, vec2( 4.0 ) );
    if(posMod.y < 2.0) { 
     fragColor.rgb -= 0.5;
    }
}
