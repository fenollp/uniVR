// Shader downloaded from https://www.shadertoy.com/view/4dl3D7
// written by shadertoy user iq
//
// Name: Colorize
// Description: Colorizing a frame from a video
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Colorize an old black and white picture.
//
// Stop video at 1.9s, so the chroma matches with the luma


float brusha( in vec2 p, in vec3 c )
{
    float f = exp( -c.z*c.z*dot(p-c.xy,p-c.xy) );
    return f;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;

	vec3 col = vec3(1.0,1.0,1.0);
	
    col = mix( col, vec3(1.0,0.9,0.7), brusha(uv,vec3(0.645,0.75,3.0)) );

	col = mix( col, vec3(1.1,0.9,0.7), brusha(uv,vec3(0.645,0.80,15.0)) );
    col = mix( col, vec3(1.1,0.9,0.7), brusha(uv,vec3(0.645,0.70,15.0)) );

    // sofa
	col = mix( col, vec3(1.0,0.8,1.0), brusha(uv,vec3(0.7,0.25,15.0)) );
	col = mix( col, vec3(1.0,0.8,1.0), brusha(uv,vec3(0.8,0.25,15.0)) );
	col = mix( col, vec3(1.0,0.8,1.0), brusha(uv,vec3(0.9,0.25,15.0)) );
	col = mix( col, vec3(1.0,0.8,1.0), brusha(uv,vec3(0.8,0.39,15.0)) );
	col = mix( col, vec3(1.0,0.8,1.0), brusha(uv,vec3(0.9,0.37,15.0)) );

	// face
	col = mix( col, vec3(0.9,0.78,0.68), brusha(uv,vec3(0.47,0.78,15.0)) );
    col = mix( col, vec3(0.9,0.78,0.68), brusha(uv,vec3(0.48,0.69,15.0)) );
    col = mix( col, vec3(0.9,0.78,0.68), brusha(uv,vec3(0.48,0.65,15.0)) );

	// lips
    col = mix( col, vec3(1.0,0.7,0.7), brusha(uv,vec3(0.465,0.66,200.0)) );
    col = mix( col, vec3(1.0,0.7,0.7), brusha(uv,vec3(0.477,0.66,100.0)) );
    col = mix( col, vec3(1.0,0.7,0.7), brusha(uv,vec3(0.490,0.66,200.0)) );


	
	// hair
    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.47,0.85,35.0)) );
	col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.51,0.85,35.0)) );
    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.54,0.80,30.0)) );
    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.56,0.74,25.0)) );
    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.56,0.68,25.0)) );
    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.58,0.62,30.0)) );

    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.44,0.83,40.0)) );
    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.42,0.78,40.0)) );
    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.41,0.72,38.0)) );
    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.42,0.65,38.0)) );
    col = mix( col, 1.2*vec3(1.0,0.95,0.8), brusha(uv,vec3(0.42,0.60,38.0)) );


    // jersey
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.50,0.30,20.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.43,0.30,20.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.51,0.35,22.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.40,0.35,35.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.51,0.40,22.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.39,0.40,35.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.51,0.45,20.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.39,0.45,35.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.54,0.50,25.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.39,0.50,35.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.58,0.54,35.0)) );
	col = mix( col, vec3(1.0,0.8,0.9), brusha(uv,vec3(0.39,0.54,45.0)) );


	// table
	col = mix( col, vec3(1.0,0.9,0.8), brusha(uv,vec3(0.12,0.33,10.0)) );
	col = mix( col, vec3(1.0,0.9,0.8), brusha(uv,vec3(0.32,0.23,10.0)) );
	col = mix( col, vec3(1.0,0.9,0.8), brusha(uv,vec3(0.23,0.06,15.0)) );
	col = mix( col, vec3(1.0,0.9,0.8), brusha(uv,vec3(0.70,0.10,6.0)) );
	col = mix( col, vec3(1.0,0.9,0.8), brusha(uv,vec3(0.90,0.10,5.0)) );

	
	// hand
	col = mix( col, vec3(0.9,0.78,0.68), brusha(uv,vec3(0.57,0.18,25.0)) );


	col *= 1.2;
	
	col = mix( vec3(1.0), col, 1.0-smoothstep(0.4,0.6,abs(iChannelTime[0]-1.9) ) );
	
	
	col *= texture2D( iChannel0, uv ).xyz;
	
	fragColor = vec4(col,1.0);
}