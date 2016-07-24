// Shader downloaded from https://www.shadertoy.com/view/4lsXDN
// written by shadertoy user iq
//
// Name: Ellipse - Distance II
// Description: Another way to compute the distance to an ellipse (see [url]https://www.shadertoy.com/view/4sS3zz[/url])
// Created by inigo quilez - iq/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Computing the distance to an ellipse using David Eberly's method instead of mine
//
// David's: http://www.geometrictools.com/Documentation/DistancePointEllipseEllipsoid.pdf
//
// Mine: http://iquilezles.org/www/articles/ellipsedist/ellipsedist.htm and https://www.shadertoy.com/view/4sS3zz

float rlength( vec2 v )
{
    //return length(v);
    
    v = abs( v );
    if( v.x > v.y ) return v.x * sqrt( 1.0 + (v.y/v.x)*(v.y/v.x) );
    else            return v.y * sqrt( 1.0 + (v.x/v.y)*(v.x/v.y) );
}

float GetRoot( float r0, float z0, float z1, float g )
{
    float n0 = r0*z0;
    float s0 = z1 - 1.0;
    float s1 = (g<0.0) ? 0.0 : rlength( vec2(n0, z1) ) - 1.0;
    float s = 0.0;
    for( int i=0; i<64; i++ )
    {
        s = 0.5*(s0+s1);
        //if( s==s0 || s==s1 ) break;
        vec2 ratio = vec2( n0 / (s + r0), z1 / (s + 1.0 ) );
        g = dot(ratio,ratio) - 1.0;
        //if( g>0.0 ) { s0=s; } else  if( g<0.0 ) { s1=s; } else break;
        if( g>0.0 ) s0=s; else s1=s;
    }
    return s;
}

float sdEllipse( vec2 p, vec2 e )
{
    p = abs( p );
    
    float dis = 0.0;

    //if( p.y>0.0 )
    //{
        //if( p.x>0.0 )
        //{
            vec2 z = p / e;
            float g = dot(z,z) - 1.0;
            //if( g !=0.0 )
            {
                float r0 = (e.x/e.y)*(e.x/e.y);
                float sbar = GetRoot( r0, z.x, z.y, g );
                vec2 r = p * vec2( r0/(sbar+r0), 1.0/(sbar+1.0) );
                dis = length( p - r ) * sign( p.y - r.y );
            }/*
            else
            {
                dis = 0.0;
            }
        }
        else
        {
            vec2 r = vec2( 0.0, e.y );
            dis = abs(p.y-e.y);
        }
    }
    else
    {
        float numer0 = e.x*p.x;
        float denom0 = e.x*e.x - e.y*e.y;
        if( numer0 < denom0 )
        {
            float xde0 = numer0 / denom0;
            vec2 r = e * vec2( xde0, sqrt( 1.0 - xde0*xde0 ) );
            dis = length( p - r );
        }
        else
        {
            vec2 r = vec2( e.x, 0.0 );
            dis = abs(p.x - e.x);
        }
    }
*/
    return dis ;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = -1.0 + 2.0 * fragCoord.xy/iResolution.xy;
	uv.x *= iResolution.x/iResolution.y;
	
    vec2 m = iMouse.xy/iResolution.xy;
	m.x *= iResolution.x/iResolution.y;
	
	float d = sdEllipse( uv, vec2(0.3,0.3)*m + vec2(1.0,0.5)  );
    vec3 col = vec3(1.0) - sign(d)*vec3(0.1,0.4,0.7);
	col *= 1.0 - exp(-2.0*abs(d));
	col *= 0.8 + 0.2*cos(120.0*d);
	col = mix( col, vec3(1.0), 1.0-smoothstep(0.0,0.02,abs(d)) );

	fragColor = vec4( col, 1.0 );;
}