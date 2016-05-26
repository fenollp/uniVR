// Shader downloaded from https://www.shadertoy.com/view/MlSXWm
// written by shadertoy user brejep
//
// Name: Cartoon starburst
// Description: Cartoon starburst shader
vec3 backgroundColor = vec3(0.318, 0.753, 0.961);
vec3 yellowColor = vec3(0.961, 0.753, 0.196);
vec3 orangeColor = vec3(0.953, 0.482, 0.318);

// Cartoony starburst
// Very influenced by https://www.shadertoy.com/view/4dlGRM (by Tomek Augustyn)

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = (2.0*fragCoord.xy-iResolution.xy) / iResolution.y;
   	
    float period = 10.0;
    float rotation = iGlobalTime * 4.0;
    float rotation1 = rotation + 2.8;
    
    vec2 center = vec2(0.0);
    
    vec3 bg = backgroundColor;
    vec3 fg1 = yellowColor;
    vec3 fg2 = orangeColor;
    
    vec2 shift = uv - center;
    float shiftLen = length(shift);
    float shiftAtan = atan(shift.x, shift.y);
    
    float pct1 = smoothstep(0.75, 1.0, shiftLen);
    float pct2 = smoothstep(0.5 + 0.4*(cos(iGlobalTime)), 1.0, shiftLen);
    
    vec3 fade1 = mix(fg1, bg, pct1);
    vec3 fade2 = mix(fg2, bg, pct2);
    
    float offset = rotation + shiftLen / 10.0;
    float x = sin(offset + shiftAtan * period);
    float val = smoothstep(0.4, 0.6, x);
 	
    vec3 color = mix(bg, fade1, val);
    
    offset = rotation1 + shiftLen / 10.0;
    x = sin(offset + shiftAtan * period);
    val = smoothstep(0.4, 0.6, x);
    
    color = mix(color, fade2, val);
	
    fragColor = vec4(color, 1.0);
}