// Shader downloaded from https://www.shadertoy.com/view/ldtSRr
// written by shadertoy user WojtaZam
//
// Name: Rgba to sepia in time
// Description: Rgba to sepia transformation in time.
//    Sepia matrix created using well known web search engine.
mat4 rgba2sepia = 
mat4
(
0.393, 0.349, 0.272, 0,
0.769, 0.686, 0.534, 0,
0.189, 0.168, 0.131, 0,
0,     0,     0,     1
);



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float timeFactor = ( 1.0 + sin( iGlobalTime ) ) * 0.5;
    vec4 color = texture2D( iChannel0, fragCoord/iResolution.xy );
    mat4 rgba2sepiaDiff = mat4( 1.0 ) + timeFactor * ( rgba2sepia - mat4( 1.0 ) );
    
    fragColor = rgba2sepiaDiff * color;
}