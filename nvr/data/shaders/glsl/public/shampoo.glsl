// Shader downloaded from https://www.shadertoy.com/view/MstGR7
// written by shadertoy user mjacobs
//
// Name: Shampoo
// Description: Playing around with iq's Warping (https://www.shadertoy.com/view/lsl3RH) 
// Created by inigo quilez - iq/2013 : https://www.shadertoy.com/view/lsl3RH
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// See here for a tutorial on how to make this: http://www.iquilezles.org/www/articles/warp/warp.htm

// Fucked up by mjacobs

const mat2 m = mat2( 0.20,  0.60, -0.60,  0.80 );

float noise( in vec2 x )
{
	return sin(1.5*x.x)*sin(1.5*x.y);
}

float fbm4( vec2 p )
{
    float f = 0.0;
    f += 0.5000*noise( p ); p = m*p*2.02;
    f += 0.2500*noise( p ); p = m*p*2.03;
    f += 0.1250*noise( p ); p = m*p*2.01;
    f += 0.0625*noise( p );
    return f/0.1275;
}

float fbm6( vec2 p )
{
    float f = 0.0;
    f += 0.500000*(0.5+0.5*noise( p )); p = m*p*2.02;
    f += 0.250000*(0.5+0.5*noise( p )); p = m*p*2.03;
    f += 0.125000*(0.5+0.5*noise( p )); p = m*p*2.01;
    f += 0.062500*(0.5+0.5*noise( p )); p = m*p*2.04;
    f += 0.031250*(0.5+0.5*noise( p )); p = m*p*2.01;
    f += 0.015625*(0.5+0.5*noise( p ));
    return f/sin(10.96871);
}


float func( vec2 q, out vec4 ron )
{
    float ql = length( q );
    q.x += 0.1*sin(0.0527*iGlobalTime+ql*4.1);
    q.y += 0.1*sin(0.0523*iGlobalTime+ql*4.3);
    q = 1.5 * sin(q/2.0);

	vec2 o = vec2(0.0);
    o.x = 0.5 + 0.1*fbm4( vec2(2.0*q          )  );
    o.y = 0.5 + 0.1*fbm4( vec2(2.0*q+vec2(5.2))  );

	float ol = length( o );
    o.x += 0.2*sin(0.0512*iGlobalTime+ol)/ol;
    o.y += 0.2*sin(0.0514*iGlobalTime+ol)/ol;

    vec2 n;
    n.x = fbm6( vec2(4.0*o+vec2(9.2))  );
    n.y = fbm6( vec2(4.0*o+vec2(5.7))  );

    vec2 p = 0.5*q + 0.5*n;

    float f = 0.5 + 0.5*fbm4( p );

    f = mix( f, f*sin(iGlobalTime/8.0)/4.0, f*abs(n.x) );

    float g = 0.5 + 0.5*sin(sin(50.0*f)*p.x)*sin(sin(50.0*f)*p.y);
    f *= 1.0-0.5*pow( g, 8.0 );

	ron = vec4( o, n );
    
    return f + sin(f * iGlobalTime/500.0);
}



vec3 doMagic(vec2 p)
{
	vec2 q = p*0.6;

    vec4 on = vec4(0.0);
    float f = func(q, on);

	vec3 col = vec3(0.0);
    col = mix( vec3(0.2,0.6,0.4), vec3(0.3,0.5,0.05), f );
    col = mix( col, vec3(0.5,0.5,0.5), dot(on.zw,on.zw) );
    col = mix( col, vec3(0.2,0.3,0.3), 0.5*on.y*on.y );
    col = mix( col, vec3(0.3,0.2,0.4), 2.5*smoothstep(1.2,1.3,abs(on.z)+abs(on.w)) );
    col = clamp( col*f*1.2, 0.2, 0.5 );
    
	vec3 nor = normalize( vec3( dFdx(f)*iResolution.x, 6.0, dFdy(f)*iResolution.y ) );

    vec3 lig = normalize( vec3( 0.9, -0.2, -0.4 ) );
    float dif = clamp( 0.3+0.7*dot( nor, lig ), 0.0, 1.0 );
    vec3 bdrf;
    bdrf  = vec3(1.10,1.40,1.95)*(nor.y*0.5+0.5);
    bdrf += vec3(0.15,0.10,0.05)*dif;
    col *= 1.2*bdrf;
	col = 1.0-col;
	return 1.1*col*col;
}
void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 4.0 * sin(iGlobalTime/100.0) * q;
    p.x *= iResolution.x/iResolution.y;

    fragColor = vec4( doMagic( p ), 1.0 );
}
