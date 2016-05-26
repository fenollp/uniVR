// Shader downloaded from https://www.shadertoy.com/view/4lX3Rf
// written by shadertoy user iq
//
// Name: Van Damme
// Description: testing new video
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy / iResolution.xy;
    
    // background    
    vec3 r = vec3(-1.0 + 2.0*p,-0.6);
    if( iChannelTime[0]> 4.40) r = r.zyx; if( iChannelTime[0]>10.15) r = r.zyx;
    if( iChannelTime[0]>11.60) r = r.zyx; if( iChannelTime[0]>15.00) r = r.zyx;
    if( iChannelTime[0]>17.10) r = r.zyx; if( iChannelTime[0]>18.37) r = r.zyx;
    vec3 col = textureCube( iChannel2, r ).xyz;

    
    // add Jean-Claude Van Damme    
    vec3 fg = texture2D( iChannel0, p ).xyz;
    float maxrb = max( fg.r, fg.b );
    float k = clamp( (fg.g-maxrb)*3.0, 0.0, 1.0 );
    float dg = fg.g; 
    fg.g = min( fg.g, maxrb*0.8 ); 
    fg += dg - fg.g;
    col = mix(fg, col, k);

    
    fragColor = vec4( col, 1.0 );
}
