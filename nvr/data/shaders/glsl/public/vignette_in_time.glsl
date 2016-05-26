// Shader downloaded from https://www.shadertoy.com/view/XdcXRH
// written by shadertoy user WojtaZam
//
// Name: Vignette in time
// Description: Simple vignette effect. Thanks to Dave_Hoskins.
const float vignetteStrength = 1.0;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float timeFactor = ( 1.0 + sin( iGlobalTime ) ) / 2.0;
    vec2 nCoord = fragCoord/iResolution.xy;
    vec4 color = texture2D( iChannel0, nCoord );
    vec2 centeredCoord = nCoord - 0.5;
    
    float distance = sqrt( dot( centeredCoord,centeredCoord ) );
    
    fragColor = mix( color, vec4(0), distance * vignetteStrength * timeFactor );
}