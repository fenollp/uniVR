// Shader downloaded from https://www.shadertoy.com/view/XsSXDy
// written by shadertoy user iq
//
// Name: Bicubic - comparison
// Description: Comparison of BSpline, &quot;typical&quot; and  Catmull-Rom bicubic texture filtering. This is done the slow way (16 samples) instead of the optimized GPU bilinear based filtering. Bottom part shows derivatives of the above.
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

/*
Comparison of three bicubic filter kernels. B=Spline, Catmull-Rom and "recommended", as described
in this article: http://http.developer.nvidia.com/GPUGems/gpugems_ch24.html

Done the naive way with 16 samples rather than the smart way of performing bilinear filters. For
the fast way to do it, see Dave Hoskins' shader: https://www.shadertoy.com/view/4df3Dn


// Mitchell Netravali Reconstruction Filter
// B = 1,   C = 0   - cubic B-spline
// B = 1/3, C = 1/3 - recommended
// B = 0,   C = 1/2 - Catmull-Rom spline
//
// ca = {  12 - 9*B - 6*C,  -18 + 12*B + 6*C, 0, 6 - 2*B  } / 6;
// cb = {  -B - 6*C, 6*B + 30*C, -12*B - 48*C, 8*B + 24*C } / 6;
*/

//-----------------------------------------------------------------------------------------

vec4 BS_A = vec4(   3.0,  -6.0,   0.0,  4.0 ) /  6.0;
vec4 BS_B = vec4(  -1.0,   6.0, -12.0,  8.0 ) /  6.0;
vec4 RE_A = vec4(  21.0, -36.0,   0.0, 16.0 ) / 18.0;
vec4 RE_B = vec4(  -7.0,  36.0, -60.0, 32.0 ) / 18.0;
vec4 CR_A = vec4(   3.0,  -5.0,   0.0,  2.0 ) /  2.0;
vec4 CR_B = vec4(  -1.0,   5.0,  -8.0,  4.0 ) /  2.0;
        
vec4 powers( float x ) { return vec4(x*x*x, x*x, x, 1.0); }

vec4 ca, cb;

vec4 spline( float x, vec4 c0, vec4 c1, vec4 c2, vec4 c3 )
{
    // We could expand the powers and build a matrix instead (twice as many coefficients
    // would need to be stored, but it could be faster.
    return c0 * dot( cb, powers(x + 1.0)) + 
           c1 * dot( ca, powers(x      )) +
           c2 * dot( ca, powers(1.0 - x)) +
           c3 * dot( cb, powers(2.0 - x));
}

#define SAM(a,b)  texture2D(iChannel0, (i+vec2(float(a),float(b))+0.5)/res, -99.0)

vec4 texture2D_Bicubic( sampler2D tex, vec2 t )
{
    vec2 res = iChannelResolution[0].xy;
    vec2 p = res*t - 0.5;
    vec2 f = fract(p);
    vec2 i = floor(p);

    return spline( f.y, spline( f.x, SAM(-1,-1), SAM( 0,-1), SAM( 1,-1), SAM( 2,-1)),
                        spline( f.x, SAM(-1, 0), SAM( 0, 0), SAM( 1, 0), SAM( 2, 0)),
                        spline( f.x, SAM(-1, 1), SAM( 0, 1), SAM( 1, 1), SAM( 2, 1)),
                        spline( f.x, SAM(-1, 2), SAM( 0, 2), SAM( 1, 2), SAM( 2, 2)));
}

//-----------------------------------------------------------------------------------------

vec4 lerp( float x, vec4 a, vec4 b ) { return mix(a,b,x); }

vec4 texture2D_Bilinear( sampler2D tex, vec2 t )
{
    vec2 res = iChannelResolution[0].xy;
    vec2 p = res*t - 0.5;
    vec2 f = fract(p);
    vec2 i = floor(p);

    return lerp( f.y, lerp( f.x, SAM(0,0), SAM(1,0)),
                      lerp( f.x, SAM(0,1), SAM(1,1)) );
}

//-----------------------------------------------------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = fragCoord.xy/iResolution.x;
    vec2 q = fragCoord.xy/iResolution.xy;
    
    vec2 uv = vec2(0.0);

         if( q.x<0.33 ) { ca=BS_A; cb=BS_B; uv = p-vec2(0.00,0.0); }
    else if( q.x<0.66 ) { ca=RE_A; cb=RE_B; uv = p-vec2(0.33,0.0); }
    else                { ca=CR_A; cb=CR_B; uv = p-vec2(0.66,0.0); }

    uv = uv * 0.06 + 0.001*iGlobalTime;

  //vec3 cola = texture2D(          iChannel0, uv ).xyz;
    vec3 cola = texture2D_Bilinear( iChannel0, uv ).xyz;
    vec3 colb = texture2D_Bicubic(  iChannel0, uv ).xyz;
    
    vec3 col = mix( cola, colb, smoothstep( -0.1, 0.1, sin(2.0*iGlobalTime)) );

    float gre = dot(col,vec3(0.333));
    
    vec3 colc = 0.5 + 50.0*vec3( dFdx(gre), dFdy(gre), 0.0 );
    
    col = mix( col, colc, step(q.y,0.40) );
    
    col *= smoothstep( 0.0, 2.0/iResolution.x, abs(p.x-0.33) );
    col *= smoothstep( 0.0, 2.0/iResolution.x, abs(p.x-0.66) );
    col *= smoothstep( 0.0, 2.0/iResolution.y, abs(q.y-0.40) );
    
	fragColor = vec4( col, 1.0 );
}
