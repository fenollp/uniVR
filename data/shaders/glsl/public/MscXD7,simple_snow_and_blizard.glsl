// Shader downloaded from https://www.shadertoy.com/view/MscXD7
// written by shadertoy user bleedingtiger2
//
// Name: Simple snow and blizard
// Description: Simple snow particles with blizard option !
#define _SnowflakeAmount 200	// Number of snowflakes
#define _BlizardFactor 0.2		// Fury of the storm !

vec2 uv;

float rnd(float x)
{
    return fract(sin(dot(vec2(x+47.49,38.2467/(x+2.3)), vec2(12.9898, 78.233)))* (43758.5453));
}

float drawCircle(vec2 center, float radius)
{
    return 1.0 - smoothstep(0.0, radius, length(uv - center));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    uv = fragCoord.xy / iResolution.x;
    
    fragColor = vec4(0.808, 0.89, 0.918, 1.0);
    float j;
    
    for(int i=0; i<_SnowflakeAmount; i++)
    {
        j = float(i);
        float speed = 0.3+rnd(cos(j))*(0.7+0.5*cos(j/(float(_SnowflakeAmount)*0.25)));
        vec2 center = vec2((0.25-uv.y)*_BlizardFactor+rnd(j)+0.1*cos(iGlobalTime+sin(j)), mod(sin(j)-speed*(iGlobalTime*1.5*(0.1+_BlizardFactor)), 0.65));
        fragColor += vec4(0.09*drawCircle(center, 0.001+speed*0.012));
    }
}