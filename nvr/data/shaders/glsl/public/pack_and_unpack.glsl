// Shader downloaded from https://www.shadertoy.com/view/ldj3zG
// written by shadertoy user iq
//
// Name: Pack and Unpack
// Description: The classic 32 bit float to 8 bit vec4 packing and unpacking functions that have been floating around the internet for 10 years now. Modified by me. Unkown source.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// the classic 1-32-bit-float to 4-8-bit-vec4 packing and unpacking functions that 
// have been floating around the internet for 10 years now. Unkown source, but
// common sense.

//-------------------------------------------------------------------------

const vec4 bitShL = vec4(16777216.0, 65536.0, 256.0, 1.0);
const vec4 bitShR = vec4(1.0/16777216.0, 1.0/65536.0, 1.0/256.0, 1.0);

vec4 pack_F1_UB4( in float value )
{
    vec4 res = fract( value*bitShL );
	res.yzw -= res.xyz/256.0;
	return res;
}

float unpack_F1_UB4( in vec4 value )
{
    return dot( value, bitShR );
}

//-------------------------------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	float signal = 0.5 + 0.5*sin(uv.x*50.0 + sin(uv.y*50.0) )*sin(uv.y*40.0 + sin(uv.x*40.0+iGlobalTime) );
	
	// pack float to 8 bit vec4
	vec4 pa = pack_F1_UB4( signal );

    // simulate that we are writing to a 8 bit color buffer	
	vec4 buff = floor( 256.0*pa );
	
	// simulate that we are reading from a 8 bit color buffer
	vec4 unpa = buff / 256.0;

    // unkack from an 8nit vec4, to a float	 
	float f = unpack_F1_UB4( unpa );
	
	fragColor = vec4(f,f,f,1.0);
}