// Shader downloaded from https://www.shadertoy.com/view/XstGWf
// written by shadertoy user DrLuke
//
// Name: drl005 (VHS filter)
// Description: VHS test
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    
    
    vec4 moviecol;
    
    vec2 uvOffset = texture2D(iChannel1, vec2(iGlobalTime*5.0)).rg;
    uvOffset.x *= 0.001;
    uvOffset.y *= 0.003;
    
    moviecol.r = texture2D(iChannel0, uv + uvOffset ).r;;
    moviecol.g = vec4(texture2D(iChannel0, uv + uvOffset)).g;
    moviecol.b = texture2D(iChannel0, uv + uvOffset + vec2(-0.01*texture2D(iChannel1, vec2(uv.x/100.0,uv.y + iGlobalTime*5.0)).r, 0) ).b;
    
    
    moviecol.rgb = mix(moviecol.rgb, vec3(dot(moviecol.rgb, vec3(.33))), 0.6);
    
	fragColor = vec4(moviecol);
    
    
    
}