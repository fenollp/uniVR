// Shader downloaded from https://www.shadertoy.com/view/MdVGWR
// written by shadertoy user iq
//
// Name: Iterations - circles
// Description: One more to my collection &quot;Iterations&quot; ( ldl3W4, 4sXGDN, MssGW4, XdXGDS, MslXz8, Mdl3RH). Improvised doodling again.
// Created by inigo quilez - iq/2016
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord / iResolution.xy + 0.01*iGlobalTime;
    uv *= 0.75;
    
    vec2 gra = vec2(0.0);
    vec3 col = vec3(0.0);
    vec2 ouv = uv;
    for( int i=0; i<64; i++ )
    {
        uv += (0.1/64.0)*cos( 6.2831*cos(6.2831*uv.yx + 0.02*iGlobalTime*vec2(1.7,2.1)) + 0.1*iGlobalTime*vec2(2.1,1.3) );
        vec3 tex = texture2D( iChannel0, uv ).xyz;
        col += tex*(1.0/64.0);
        gra += vec2( tex.x - texture2D( iChannel0, uv+vec2(1.0/iChannelResolution[0].x,0.0) ).x,
                     tex.x - texture2D( iChannel0, uv+vec2(0.0,1.0/iChannelResolution[0].y) ).x );
    }
    
    col *= 12.0*length( uv - ouv );
    col += 0.08*(gra.x + gra.y);
    
	fragColor = vec4( col, 1.0 );
}