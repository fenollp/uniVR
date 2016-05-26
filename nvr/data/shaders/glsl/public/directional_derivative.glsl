// Shader downloaded from https://www.shadertoy.com/view/Xl23Wy
// written by shadertoy user iq
//
// Name: Directional Derivative
// Description: Directional Derivatives for lighting. Much faster than gradients, see [url]https://www.shadertoy.com/view/XslGRr[/url] or [url]https://www.shadertoy.com/view/Xd23zh[/url]. More info: [url]http://iquilezles.org/www/articles/derivative/derivative.htm[/url]
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0

// Usign directional derivatives for lighting is much faster than computing 
// gradients/normals and doing lighting with it (if the number of lights is
// less than four). Mostly useful for volumetric effects.
//
// See 
//
//  http://iquilezles.org/www/articles/derivative/derivative.htm
//
// and also:
//
//  https://www.shadertoy.com/view/XslGRr
//  https://www.shadertoy.com/view/Xd23zh]Xd23zh
//  https://www.shadertoy.com/view/MsfGzM
//
// In the left haf of the screen, directional derivatives. On the right, the
// traditional gradient-based lighting. Move the mouse to compare.


float map( vec3 p )
{
	float d1 = p.y - 0.0;
    float d2 = length(p-vec3(0.0,0.0,0.0)) - 1.0;
    float d3 = length(p.xz-vec2(-3.0,0.0)) - 0.5;
    float d4 = length(p-vec3(1.0,1.0,1.0)) - 0.3;
    return min( min(d1,d2), min(d3,d4) );
}

float intersect( in vec3 ro, in vec3 rd, const float maxdist )
{
    float res = -1.0;
    float t = 0.1;
    for( int i=0; i<128; i++ )
    {
	    float h = map(ro + t*rd);
        res = t;
        if( h<(0.0001*t) || t>maxdist ) break;
        t += h;
    }
	return res;
}

vec3 calcNormal( in vec3 pos, in float eps )
{
    vec2 e = vec2(1.0,-1.0)*0.5773*eps;
    return normalize( e.xyy*map( pos + e.xyy ) + 
					  e.yyx*map( pos + e.yyx ) + 
					  e.yxy*map( pos + e.yxy ) + 
					  e.xxx*map( pos + e.xxx ) );
}

vec3 render( in vec3 ro, in vec3 rd, in float doAB )
{
    vec3 col = vec3(0.0);
    
    const float maxdist = 32.0;
    float t = intersect( ro, rd, maxdist );
    if( t < maxdist )
    {
        float eps = 0.001;
        vec3  pos = ro + t*rd;

        vec3 lig = normalize( vec3(2.0,1.0,0.2) );
        float dif = 0.0;

        // directional derivative
        if( doAB>0.0 )
        {
            dif = (map(pos+lig*eps) - map(pos)) / eps;
        }
        // gradient based lighting
		else
        {
            vec3 nor = calcNormal( pos, eps );
            dif = dot(nor,lig);
        }
        dif = clamp( dif, 0.0, 1.0 );
        
        col = vec3(1.0,0.9,0.8)*dif + vec3(0.1,0.15,0.2);
        
        col *= exp( -0.1*t );
    }
    
    return pow( col, vec3(0.45) );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{	
	vec2 p = (-iResolution.xy+2.0*fragCoord.xy)/iResolution.y;
    
	vec3  ro = vec3(0.0,1.0,7.0);
	vec3  ta = vec3(0.0,1.0,0.0);
    vec3  ww = normalize( ta - ro);
    vec3  uu = normalize( cross( vec3(0.0,1.0,0.0), ww ) );
    vec3  vv = normalize( cross(ww,uu) );
    vec3  rd = normalize( p.x*uu + p.y*vv + 3.0*ww );

    float im = iMouse.x; if( iMouse.z<=0.001 ) im = iResolution.x/2.0;
    float dm = im - fragCoord.x;

    vec3 col = render( ro, rd, dm );
    
	col = mix( vec3(0.0), col, smoothstep( 1.0, 2.0, abs(dm) ) );
    
	fragColor = vec4( col, 1.0 );
}
