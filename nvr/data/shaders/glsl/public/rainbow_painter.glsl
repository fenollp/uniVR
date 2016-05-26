// Shader downloaded from https://www.shadertoy.com/view/lt2XRD
// written by shadertoy user mrdoob
//
// Name: Rainbow Painter
// Description: Quick brush experiment.
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if ( iMouse.z < 0.01 ) discard; // ignore if user isn't clicking
    
    float distance = length( fragCoord.xy - iMouse.xy );
    if ( distance > 30.0 ) discard; // brush size

    float pulse = 0.75 + 0.25 * sin( iGlobalTime );
	fragColor = vec4( sin( distance * pulse ), cos( distance * pulse ), pulse, 1.0 );
}