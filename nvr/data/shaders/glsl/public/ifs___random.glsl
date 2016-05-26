// Shader downloaded from https://www.shadertoy.com/view/4dXGWS
// written by shadertoy user iq
//
// Name: IFS - random
// Description: Random linear IFS fractal (4 affine transforms) inverted and twisted. Very noisy due to the low iteration count (rendering approach is brute force gathering). Some more info 
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float hash( in float n )
{
    return fract(sin(n)*43758.5453123);
}

float determinant( in mat2 m )
{
    return abs( m[0][0]*m[1][1] - m[0][1]*m[1][0] );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = -1.0 + 2.0*fragCoord.xy/iResolution.xy;
	uv *= 2.0;
	float t = 0.1*iGlobalTime - 1.0;
#if 0
	mat2 am = mat2( cos(t*1.71+0.18), cos(t*1.31+3.18), cos(t*1.13+3.29), cos(t*1.44+4.21) );
	mat2 bm = mat2( cos(t*2.57+1.66), cos(t*1.08+0.74), cos(t*2.25+2.78), cos(t*1.23+1.29) );
	mat2 cm = mat2( cos(t*1.15+6.33), cos(t*2.94+2.92), cos(t*1.78+0.82), cos(t*2.58+2.36) );
	mat2 dm = mat2( cos(t*1.42+4.89), cos(t*2.73+6.34), cos(t*1.82+5.91), cos(t*1.21+3.84) );
	vec2 at = vec2( cos(t*2.13+0.94), cos(t*1.19+0.29) )*0.8;
	vec2 bt = vec2( cos(t*1.09+5.25), cos(t*1.27+1.77) )*0.8;
	vec2 ct = vec2( cos(t*2.76+4.39), cos(t*2.35+2.04) )*0.8;
	vec2 dt = vec2( cos(t*1.42+4.71), cos(t*2.81+3.51) )*0.8;
#else
	mat2 am = mat2( cos(t*1.71+0.18), -cos(t*1.31+3.18), cos(t*1.31+3.18), cos(t*1.44+4.21) );
	mat2 bm = mat2( cos(t*2.57+1.66), -cos(t*1.08+0.74), cos(t*1.08+0.74), cos(t*1.23+1.29) );
	mat2 cm = mat2( cos(t*1.15+6.33), -cos(t*2.94+2.92), cos(t*2.94+2.92), cos(t*2.58+2.36) );
	mat2 dm = mat2( cos(t*1.42+4.89), -cos(t*2.73+6.34), cos(t*2.73+6.34), cos(t*1.21+3.84) );
	vec2 at = vec2( cos(t*2.13+0.94), cos(t*1.19+0.29) )*0.8;
	vec2 bt = vec2( cos(t*1.09+5.25), cos(t*1.27+1.77) )*0.8;
	vec2 ct = vec2( cos(t*2.76+4.39), cos(t*2.35+2.04) )*0.8;
	vec2 dt = vec2( cos(t*1.42+4.71), cos(t*2.81+3.51) )*0.8;
#endif
	
    // make sure all trasnforms are contracting, ie, |fi(x)| < 1 )
    am /= mix( 1.0, determinant(am), clamp(determinant(am)*3.0-2.0,0.0,1.0) );
    bm /= mix( 1.0, determinant(bm), clamp(determinant(bm)*3.0-2.0,0.0,1.0) );
    cm /= mix( 1.0, determinant(cm), clamp(determinant(cm)*3.0-2.0,0.0,1.0) );
    dm /= mix( 1.0, determinant(dm), clamp(determinant(dm)*3.0-2.0,0.0,1.0) );
	
	vec3  cola = vec3(0.0);
	vec3  colb = vec3(0.0);
	
	float cad = 0.0;

	float p = texture2D( iChannel0, (iGlobalTime+fragCoord.xy+0.5)/256.0, -100.0 ).x;

    vec2 z = vec2( 0.0 );
	
	for( int i=0; i<256; i++ ) 
    {
		p = fract( p*8.1 );

        cad *= 0.25;
             if( p < 0.25 ) { z = am*z + at; cad += 0.00; }
        else if( p < 0.50 ) { z = bm*z + bt; cad += 0.25; }
        else if( p < 0.75 ) { z = cm*z + ct; cad += 0.50; }
        else                { z = dm*z + dt; cad += 0.75; }

        // non linear transform
	    float zr = length(z);
		float ar = atan( z.y, z.x ) + zr*0.5;
		z = 2.0*vec2( cos(ar), sin(ar) )/zr;

        if( i>10 )
		{
        vec3  coh = 0.5 + 0.5*sin(2.*cad + vec3(0.0,1.2,2.0));
        float cok = dot(uv-z,uv-z);
        cola = mix( cola, coh, exp( -512.0*cok ) );
        colb = mix( colb, coh, exp(  -48.0*cok ) );
		}
	}
	
    vec3 col = cola + 0.5*colb;

	fragColor = vec4( col, 1.0 );
}