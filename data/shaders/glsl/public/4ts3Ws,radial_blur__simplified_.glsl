// Shader downloaded from https://www.shadertoy.com/view/4ts3Ws
// written by shadertoy user hunter
//
// Name: Radial Blur (simplified)
// Description: A GLSL version of the old school radial blur effect 
// A simplified version of: https://www.shadertoy.com/view/4sfGRn

const float amount = 80.0;
const vec2 start_pos = vec2(-0.25, -0.25); // -1.0 to 1.0 for x, y

vec3 deform( in vec2 p )
{
    vec2 uv;
    uv.x = sin( 0.0 + 1.0 ) + p.x;
    uv.y = sin( 0.0 + 1.0 ) + p.y;
    return texture2D( iChannel0, uv * 0.5 ).xyz;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 position = -1.0 + 2.0 * fragCoord.xy / iResolution.xy;
    vec2 current_step = position;
    
    vec2 direction = ( start_pos - position ) / amount; 
    
    vec3 total = vec3( 0.0 );
    for( int i = 0; i < int( amount ); i++ )
    {
        vec3 result = deform( current_step );
        result = smoothstep( 0.0, 1.0, result );
        total += result;
        current_step += direction;
    }
    
    total /= amount;
	fragColor = vec4( total, 1.0 );
}