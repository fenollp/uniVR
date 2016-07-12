// Shader downloaded from https://www.shadertoy.com/view/Xl2GWm
// written by shadertoy user HamzaHutchinson
//
// Name: 70s Dancing Wallpaper
// Description: Just a little bit of messing around with no specific goals or direction.
const float bgwidth = 0.2;
const float speed = 0.2;
const float size = 0.7;
const float thickness = 0.1;
const float spikiness = 0.3;
const float arms = 4.;
const float tiling = 5.;
const vec3 color1 = vec3( 0.9, 0.25, 0.4 );
const vec3 color2 = vec3( 0.3, 0.75, 0.2 );

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec3 col = vec3( 0. );
    
	vec2 uv = 2. * fragCoord.xy / iResolution.xy - vec2( 1. );
    uv.x *= iResolution.x / iResolution.y;
    
    float t = speed * iGlobalTime;
    
    vec2 l = normalize( vec2( cos( t ), sin( t ) ) );
    float d = length( uv - dot( uv, l ) * l );
    float m = ( 1.0 - bgwidth * d * d );
    
    uv = sin( tiling * uv );
    float f = atan( uv.y, uv.x ) + speed * iGlobalTime;
    
    float s = size;
    s += spikiness * sin( arms * f );
    s += texture2D( iChannel0, vec2( 1., 0. ) ).x;
    
    d = length( uv ) - s;
    bool inside = d < 0.;
    d = abs( d );
    
    if( inside ) col += m * color1;
    else col += m * color2;
    
	float w = fwidth( d );
	float a = mix( 1., 0., smoothstep( -w, w, d - thickness ) );
    col += a * vec3( 1. );
    
	fragColor = vec4( col, 1. );
}