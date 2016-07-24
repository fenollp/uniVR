// Shader downloaded from https://www.shadertoy.com/view/Xdj3Rh
// written by shadertoy user iq
//
// Name: Binary gates
// Description: Binary gates
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// In electronics/logic, there are 16 possible gates that you can build with one output and 
// two inputs. Some of them have proper names, such as AND, OR, XOR, NAND or NOR (gates 1, 
// 7, 6, 15 and 8 respectivelly), but others don't.

// When these gates are made not digital/discrete but continuous in the interval 0..1, two
// dimensional gradients of values appear. Some of them have also proper names in image
// manipulation software, such as "screen" (which is a gate OR), "multiply" (which is
// gate AND) or "exclusion" (which is gate XOR).

// The behavior of the gates also matches that of the 16 posible bilinear interpolations
// of binary values in the corners of a quad.

float bilin( float u, float v, float a, float c, float b, float d )
{
    return mix( mix(a,b,u),
			    mix(c,d,u), v );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
	
	float c = 0.0;
	
	float r = floor(uv.y*4.0 )*4.0 + floor(uv.x*4.0 );
	
	float a = fract(uv.x*4.0);
	float b = fract(uv.y*4.0);
#if 1
                      /* 0011 = A         */
                      /* 0101 = B         */
                      /* ----   --------- */
         if( r< 0.5 ) /* 0000 = RESET     */ c = 0.0;
	else if( r< 1.5 ) /* 0001 = A AND B   */ c = a*b;
	else if( r< 2.5 ) /* 0010 = A AND !B  */ c = a - a*b;
	else if( r< 3.5 ) /* 0011 = A         */ c = a;
	else if( r< 4.5 ) /* 0100 = !A AND B  */ c = b - a*b;
	else if( r< 5.5 ) /* 0101 = B         */ c = b;
	else if( r< 6.5 ) /* 0110 = A XOR B   */ c = a + b - 2.0*a*b;
	else if( r< 7.5 ) /* 0111 = A OR B    */ c = a + b - a*b;
	else if( r< 8.5 ) /* 1000 = A NOR B   */ c = 1.0 - a - b + a*b;
	else if( r< 9.5 ) /* 1001 = A XNOR B  */ c = 1.0 - b - a + 2.0*a*b;
	else if( r<10.5 ) /* 1010 = !B        */ c = 1.0 - b;
	else if( r<11.5 ) /* 1011 = !A NAND B */ c = 1.0 - b + a*b;
	else if( r<12.5 ) /* 1100 = !A        */ c = 1.0 - a;
	else if( r<13.5 ) /* 1101 = A NAND !B */ c = 1.0 - a + a*b;
	else if( r<14.5 ) /* 1110 = A NAND B  */ c = 1.0 - a*b;
	else if( r<15.5 ) /* 1111 = SET       */ c = 1.0;
#else
                      /* 0011 = A         */
                      /* 0101 = B         */
                      /* ----   --------- */
         if( r< 0.5 ) /* 0000 = RESET     */ c = bilin( a, b, 0.,0.,0.,0. );
	else if( r< 1.5 ) /* 0001 = A AND B   */ c = bilin( a, b, 0.,0.,0.,1. );
	else if( r< 2.5 ) /* 0010 = A AND !B  */ c = bilin( a, b, 0.,0.,1.,0. );
	else if( r< 3.5 ) /* 0011 = A         */ c = bilin( a, b, 0.,0.,1.,1. );
	else if( r< 4.5 ) /* 0100 = !A AND B  */ c = bilin( a, b, 0.,1.,0.,0. );
	else if( r< 5.5 ) /* 0101 = B         */ c = bilin( a, b, 0.,1.,0.,1. );
	else if( r< 6.5 ) /* 0110 = A XOR B   */ c = bilin( a, b, 0.,1.,1.,0. );
	else if( r< 7.5 ) /* 0111 = A OR B    */ c = bilin( a, b, 0.,1.,1.,1. );
	else if( r< 8.5 ) /* 1000 = A NOR B   */ c = bilin( a, b, 1.,0.,0.,0. );
	else if( r< 9.5 ) /* 1001 = A XNOR B  */ c = bilin( a, b, 1.,0.,0.,1. );
	else if( r<10.5 ) /* 1010 = !B        */ c = bilin( a, b, 1.,0.,1.,0. );
	else if( r<11.5 ) /* 1011 = !A NAND B */ c = bilin( a, b, 1.,0.,1.,1. );
	else if( r<12.5 ) /* 1100 = !A        */ c = bilin( a, b, 1.,1.,0.,0. );
	else if( r<13.5 ) /* 1101 = A NAND !B */ c = bilin( a, b, 1.,1.,0.,1. );
	else if( r<14.5 ) /* 1110 = A NAND B  */ c = bilin( a, b, 1.,1.,1.,0. );
	else if( r<15.5 ) /* 1111 = SET       */ c = bilin( a, b, 1.,1.,1.,1. );
#endif		
		
	vec3 col = vec3(c);
		
	col = mix( col, vec3(0.9,0.5,0.3), smoothstep( 0.490, 0.495, abs(a-0.5) ) );
	col = mix( col, vec3(0.9,0.5,0.3), smoothstep( 0.485, 0.490, abs(b-0.5) ) );

	fragColor = vec4(col,1.0);
}