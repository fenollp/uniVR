// Shader downloaded from https://www.shadertoy.com/view/Ms23Wm
// written by shadertoy user iq
//
// Name: SSAO (basic)
// Description: SSAO, without using normals for better sampling nor bilateral filtering for smoothing the noise out
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{

    // sample zbuffer (in linear eye space) at the current shading point	
	float zr = 1.0-texture2D( iChannel0, fragCoord.xy / iResolution.xy ).x;

    // sample neighbor pixels
	float ao = 0.0;
	for( int i=0; i<8; i++ )
	{
        // get a random 2D offset vector
        vec2 off = -1.0 + 2.0*texture2D( iChannel1, (fragCoord.xy + 23.71*float(i))/iChannelResolution[1].xy ).xz;	
        // sample the zbuffer at a neightbor pixel (in a 16 pixel radious)        		
        float z = 1.0-texture2D( iChannel0, (fragCoord.xy + floor(off*16.0))/iResolution.xy ).x;
        // accumulate occlusion if difference is less than 0.1 units		
		ao += clamp( (zr-z)/0.1, 0.0, 1.0);
	}
    // average down the occlusion	
    ao = clamp( 1.0 - ao/8.0, 0.0, 1.0 );
	
	vec3 col = vec3(ao);
	
    // uncomment this one out for seeing AO with actual image/zbuffer	
	//col *= texture2D( iChannel0, fragCoord.xy / iResolution.xy ).xyz;
	
	fragColor = vec4(col,1.0);
}