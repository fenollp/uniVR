// Shader downloaded from https://www.shadertoy.com/view/4dK3zD
// written by shadertoy user hunter
//
// Name: Musical Heart
// Description: Heart that beats to the music.
// Based on: https://www.shadertoy.com/view/4scGDs
//
// formula SRC: http://mathworld.wolfram.com/HeartCurve.html

float heartRadius(float theta)
{
    return 2. - 2.*sin(theta) + sqrt(abs(cos(theta)))*sin(theta)/(1.4 + sin(theta));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    vec2 uv = fragCoord.xy / iResolution.xy;
    float v  = texture2D( iChannel0, vec2(1/510,0.25) ).x;
    
    float red  = texture2D( iChannel0, vec2(1/510,0.25) ).x;
    float grn  = texture2D( iChannel0, vec2(0.5,0.5) ).x;
    float blu  = texture2D( iChannel0, vec2(0.75,0.5) ).x;
    
    vec4 heartColor = vec4(red,grn,blu,1.0);
    vec4 bgColor = vec4(0.0,0.0,0.0,1.0);
    vec2 originalPos = (2.0 * fragCoord - iResolution.xy)/iResolution.yy;
    vec2 pos = originalPos;
    pos.y -= 0.5;        	
    
    float theta = atan(pos.y, pos.x);
    float r = heartRadius(theta);

    fragColor = mix(bgColor, heartColor,
                    smoothstep(0.0, length(pos) * 0.5, r * v * 0.25 ));
    
}