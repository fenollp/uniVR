// Shader downloaded from https://www.shadertoy.com/view/4scGDs
// written by shadertoy user CCFSA
//
// Name: glow heart 
// Description: simple shader for glow
// heart function refer to https://www.shadertoy.com/view/MsSXzh
//
// formula SRC: http://mathworld.wolfram.com/HeartCurve.html

float heartRadius(float theta)
{
    return 2. - 2.*sin(theta) + sqrt(abs(cos(theta)))*sin(theta)/(1.4 + sin(theta));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 _BgColor = vec4(0,0,0,0);
    vec2 originalPos = (2.0 * fragCoord - iResolution.xy)/iResolution.yy;
    vec2 pos = originalPos;
    pos.y -= 0.5;        	

    pos.x /= (0.05*sin(iGlobalTime*5.0) + 0.8);
    pos.y /= (0.05*cos(iGlobalTime*11.0) + 0.8);
    //float a = pow(pos.x*pos.x + pos.y*pos.y - 1, 3);      	
    //float b = pos.x*pos.x*pos.y*pos.y*pos.y;

    float theta = atan(pos.y, pos.x);
    float r = heartRadius(theta);

    // 背景色
    fragColor = _BgColor;
    fragColor = mix(fragColor, vec4(0.5*sin(iGlobalTime*4.0),0.69*cos(iGlobalTime*2.0),0.94,1.0), 
                     smoothstep(0.0, length(pos), r/8.0));
}