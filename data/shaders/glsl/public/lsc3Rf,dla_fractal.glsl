// Shader downloaded from https://www.shadertoy.com/view/lsc3Rf
// written by shadertoy user iq
//
// Name: DLA fractal
// Description: DLA fractal. You might remember this from the 90s. One of my first fractals ever. Totally misusing the GPU for this, this should be thousands of times faster. But, you know, Shadertoy...
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 cen = iChannelResolution[0].xy*0.5;
    
    vec2 p = texture2D( iChannel0, fragCoord.xy / iResolution.xy, -100.0 ).xy;

    vec3 col = p.x * (0.6+0.4*cos( 0.0025*p.y + vec3(0.0,0.5,1.0 )));

#if 1
    vec4 m = texture2D( iChannel0, (vec2(0.0,0.0)+0.5)/ iChannelResolution[0].xy, -100.0 );
    col = mix( col, vec3(1.0,1.0,0.0), 1.0-smoothstep( 2.0, 4.0, length(fragCoord-m.xy) ) );

    float r = texture2D( iChannel0, (vec2(1.0,0.0)+0.5)/ iChannelResolution[0].xy, -100.0 ).x;
    col = mix( col, vec3(0.5,0.3,0.0), 1.0-smoothstep( 0.0, 2.0, abs(length(fragCoord-cen) - r) ) );
#endif
    
	fragColor = vec4( col,1.0);
}