// Shader downloaded from https://www.shadertoy.com/view/lsBSDm
// written by shadertoy user iq
//
// Name: Inverse Bilinear
// Description: Inverse bilinear interpolation: given a point p and a quad compute the bilinear coordinates of p in the quad. More info [url=http://www.iquilezles.org/www/articles/ibilinear/ibilinear.htm]in this article[/url].
// Created by inigo quilez - iq/2014
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Inverse bilienar interpolation: given four points defining a quadrilateral, compute the
// uv coordinates of any point in the plane that would give result to that point as a 
// bilinear interpolation of the four points.
//
// The problem resolves through a quadratic equation. More information in this article:
//
// http://www.iquilezles.org/www/articles/ibilinear/ibilinear.htm


float cross( in vec2 a, in vec2 b ) { return a.x*b.y - a.y*b.x; }

// given a point p and a quad defined by four points {a,b,c,d}, return the bilinear
// coordinates of p in the quad. Returns (-1,-1) if the point is outside of the quad.
vec2 invBilinear( in vec2 p, in vec2 a, in vec2 b, in vec2 c, in vec2 d )
{
    vec2 e = b-a;
    vec2 f = d-a;
    vec2 g = a-b+c-d;
    vec2 h = p-a;
        
    float k2 = cross( g, f );
    float k1 = cross( e, f ) + cross( h, g );
    float k0 = cross( h, e );
    
    float w = k1*k1 - 4.0*k0*k2;
    
    if( w<0.0 ) return vec2(-1.0);

    w = sqrt( w );
    
    float v1 = (-k1 - w)/(2.0*k2);
    float v2 = (-k1 + w)/(2.0*k2);
    float u1 = (h.x - f.x*v1)/(e.x + g.x*v1);
    float u2 = (h.x - f.x*v2)/(e.x + g.x*v2);
    bool  b1 = v1>0.0 && v1<1.0 && u1>0.0 && u1<1.0;
    bool  b2 = v2>0.0 && v2<1.0 && u2>0.0 && u2<1.0;
    
    vec2 res = vec2(-1.0);

    if(  b1 && !b2 ) res = vec2( u1, v1 );
    if( !b1 &&  b2 ) res = vec2( u2, v2 );
    
    return res;
}

float sdSegment( in vec2 p, in vec2 a, in vec2 b )
{
	vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
	return length( pa - ba*h );
}

vec3  hash3( float n ) { return fract(sin(vec3(n,n+1.0,n+2.0))*43758.5453123); }

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy)/iResolution.y;
    
    // background
    vec3 col = vec3( 0.35 + 0.1*p.y );

    // move points
    vec2 a = cos( 1.11*iGlobalTime + vec2(0.1,4.0) );
    vec2 b = cos( 1.13*iGlobalTime + vec2(1.0,3.0) );
    vec2 c = cos( 1.17*iGlobalTime + vec2(2.0,2.0) );
    vec2 d = cos( 1.15*iGlobalTime + vec2(3.0,1.0) );

    // area of the quad
    vec2 uv = invBilinear( p, a, b, c, d );
    if( uv.x>-0.5 )
    {
        col = texture2D( iChannel0, uv ).xyz;
    }
    
    // quad borders
    float h = 2.0/iResolution.y;
    col = mix( col, vec3(1.0,0.7,0.2), 1.0-smoothstep(h,2.0*h,sdSegment(p,a,b)));
    col = mix( col, vec3(1.0,0.7,0.2), 1.0-smoothstep(h,2.0*h,sdSegment(p,b,c)));
    col = mix( col, vec3(1.0,0.7,0.2), 1.0-smoothstep(h,2.0*h,sdSegment(p,c,d)));
    col = mix( col, vec3(1.0,0.7,0.2), 1.0-smoothstep(h,2.0*h,sdSegment(p,d,a)));
 
    col += (1.0/255.0)*hash3(p.x+13.0*p.y);

	fragColor = vec4( col, 1.0 );
}