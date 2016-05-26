// Shader downloaded from https://www.shadertoy.com/view/XsdXDj
// written by shadertoy user Danich
//
// Name: Sun and Moon Dynamic
// Description: Two dynamic circles
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 sunXY;
    vec2 moonXY;
    
    sunXY.x = iResolution.x * 0.5 + iResolution.x * sin(2.0 * 3.14 / 24.0 * iGlobalTime) * 0.4 * (iResolution.y / iResolution.x);
    sunXY.y = iResolution.y * 0.5 + iResolution.y * cos(2.0 * 3.14 / 24.0 * iGlobalTime) * 0.4;
    
    moonXY.x = iResolution.x - sunXY.x;
    moonXY.y = iResolution.y - sunXY.y;

    vec4 sunColor = vec4(0.0, 0.0, 0.0, 1.0);
    vec4 moonColor = vec4(0.0, 0.0, 0.0, 1.0);
//    vec4 skyColor = vec4(0.0, 0.0, 0.1, 1.0);
    
//    skyColor.r = cos(iGlobalTime);
//    skyColor.b = sin(iGlobalTime);
    
    
    float dSun = sin(3.14 / (distance(sunXY, fragCoord.xy) + 1.0)) * 10.0;
    float dMoon = sin(2.00 / (distance(moonXY, fragCoord.xy) + 1.0)) * 8.0;
    
    
    sunColor.r = dSun;
    sunColor.g = dSun * 0.7;
    
    moonColor.r = dMoon * 0.7;
    moonColor.g = dMoon * 0.7;
    moonColor.b = dMoon;
    
    
    
    fragColor = sunColor + moonColor;
    
}