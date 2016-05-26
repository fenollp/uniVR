// Shader downloaded from https://www.shadertoy.com/view/XtfSW7
// written by shadertoy user LeftarCode
//
// Name: Alone oceanic planet
// Description: This is oceanic planet with very strange core.
//    CZEMU TU NIE DZIAŁA ALPHA?
//    
float circleRadius = 0.4;
vec4 circleColor1 = vec4( 1.0, 0.0, 0.0, 0.0 );
vec4 circleColor2 = vec4( 0.0, 0.5, 1.0, 0.0 );

vec4 atmosphereColor = vec4( 0.0, 0.5, 1.0, 0.0 );

float atmosphereRadiusOuter = 0.5;
float atmosphereRadiusInner = 0.45;

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    
    fragColor = vec4( 0, 0, 0, 1 );
    
    float ratio = iResolution.x / iResolution.y;
    vec2 circleCenter = vec2( iMouse.x / iResolution.x, iMouse.y / iResolution.y );
    circleCenter = vec2( 0.85, 0.5 );
    vec2 uv = fragCoord.xy / iResolution.xy;
    uv.x *= ratio;
    vec2 distanceVector = circleCenter - uv;
    float distanceValue = length( distanceVector );
    float mixStartPoint = 0.32;
    
    vec2 offsetValue = vec2( ( iGlobalTime / 1000.0 ) * 100.0, ( iGlobalTime / 1000.0 ) * 50.0 );
    
    if( distanceValue <= circleRadius )
    {
        if( distanceValue > mixStartPoint )
        {
            
            float mixValue = ( distanceValue - mixStartPoint ) / ( circleRadius - mixStartPoint );
            fragColor = mix( circleColor2, texture2D( iChannel1, vec2( uv.x - offsetValue.x, -uv.y + offsetValue.y ) ) / 4.0, mixValue );
        }
        else
            fragColor = texture2D( iChannel1, vec2( uv.x - offsetValue.x, -uv.y + offsetValue.y ) ) / 4.0;
    }
    
    if( distanceValue <= atmosphereRadiusOuter )
    {
        float mixValue = ( distanceValue ) / ( circleRadius );
        fragColor = mix( texture2D( iChannel1, vec2( uv.x - offsetValue.x, -uv.y + offsetValue.y ) ) / 4.0, circleColor2, mixValue );
        if( distanceValue > atmosphereRadiusInner )
        {
            float NieWiemJakToNazwac = atmosphereRadiusOuter - distanceValue;
            float fadeValue = NieWiemJakToNazwac / 0.05;
            fragColor *= fadeValue; 
        }
        
    }
    
}