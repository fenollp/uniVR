// Shader downloaded from https://www.shadertoy.com/view/XtsSWj
// written by shadertoy user Alway_PanicButton
//
// Name: Hurrying To A Talk
// Description: A quick sketch of a familiar place.
float t;
#define HALF_PI 1.570796327

float cube( vec3 p, vec3 b )
{
    return length(max(abs(p)-b,0.));
}

float repeat( float p, float frequency )
{
    p = mod( p + frequency*.25, frequency );
    p = abs( p - frequency * .5 );
    return p;
}

float repeatfor( float p, float frequency, float n )
{
    if( abs(p) < frequency * n * .4999 )
    {
        p = mod( p + frequency*.25, frequency );
    	p = abs( p - frequency * .5 );
    }
    else
    {
        p = p - mod( frequency * n * .4999 + frequency*.25, frequency );
        p = abs(p) - frequency * n * .5;
    }
    return p;
}

float mirror( float p, float offset )
{
    p = abs( p );
    p -= offset;
    return p;
}

vec2 mirrorDiag( vec2 p, vec2 offset )
{
    p -= offset;
    if( p.x < p.y )
        p.xy = p.yx;
    p += offset;
    return p;
}

vec2 mirrorDiag2( vec2 p, vec2 offset )
{
    p -= offset;
    if( p.x > -p.y )
        p.xy = -p.yx;
    p += offset;
    return p;
}

vec2 rot2( vec2 p, float theta )
{
    float co = cos( theta );
    float si = sin( theta );
    return vec2( co * p.x + si * p.y,
                -si * p.x + co * p.y );
}

float sc( vec3 p )
{
    p.z -= 50.;
    vec3 pb = p;
    pb.z = repeatfor( pb.z, 16., 25. );
    pb.x += 25.0;
    vec3 pb8 = pb;
    pb8.x -= 19.5;
    pb8.y += 1.;
    pb8.y = mirror( pb8.y, 5. );
    float rail = cube( pb8, vec3( 0.1, 0.1, 8.0 ) );
    vec3 pb7 = pb;
    pb7.x -= 19.;
    float pillar = cube( pb7, vec3( 0.2, 10.0, 0.2 ) );
    vec3 pb6 = pb;
    pb6.x -= 27.0;
    float bar6 = cube( pb6, vec3( 8.0, 1.0, 8.0 ));
    vec3 pb5 = pb;
    pb5.x += 0.8;
    if( pb5.y > 10. )
    {
        float theta = atan( .75*(pb5.y - 10.)/ ( pb5.x - 20.));
        pb5.xy = rot2( pb5.xy, theta );
    }
    pb5.y -= 10.0;
    pb5.y = mirror(pb5.y, 0.0);
    pb5.y -= 10.0;
    pb5.y = mirror( pb5.y, 0.0 );
    pb5.z = mirror( pb5.z, 4.0 );
    pb5.z = mirror( pb5.z, 2.0 );
    pb5.z = abs(pb5.z);
    pb5.z = -pb5.z;
    pb5.y -= 3.0;
    pb5.y = repeatfor( pb5.y, 2.4, 4.0 );
    pb5.zy = mirrorDiag( pb5.zy, vec2(0.,1.2) );
    float bar5 = cube( pb5, vec3( 0.1, 2.0, 0.1 ));
    vec3 pb4 = pb;
    pb4.x += 1.5;
    pb4.y += 2.0;
    float bar4 = cube( pb4, vec3( 0.75, 1., 8.));
    vec3 pb3 = pb;
    pb3.y -= 10.0;
    float bar3 = cube( pb3, vec3( 1., 1., 8. ) );
    vec3 pb2 = pb;
    pb2.y = repeatfor( pb2.y, 2.0, 10. );
    float bar2 = cube( pb2, vec3( 0.5, 0.5, 0.1 ));
    vec3 pb1 = pb;
    pb1.x = mirror( pb1.x, 0.55 );
    float bar1 = cube( pb1, vec3( 0.25, 10.0, 0.25 ));
    float bars = min(min(min( bar1, bar2 ), min(bar3, bar4)), 
                     min(min(bar5, bar6), min(pillar, rail)));
    return bars;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy - .5;
    uv.y *= iResolution.y / iResolution.x;
    
  	t = iGlobalTime;
    
    vec3 dir = normalize(vec3(uv, 1.0) );
    vec3 p = vec3( -11., -4.75, -60. );
    
    p.xz = rot2( p.xz, 0. );
    	dir.xz = rot2( dir.xz, - .25 );
    if( iMouse.z > 0.0 )
    	dir.xz = rot2( dir.xz, iMouse.x / iResolution.x - .25 );
    
    p.y += sin(5. * t) * .2;
    p.z += mod(t * 10., 16.);
    
    float minDist = 0.;
    for( float i = 0.; i < 50.; i++ )
    {
        minDist = sc( p );
        p += dir * minDist;
    }
    
    vec3 col = vec3( 1. );
    if( minDist < .1 )
    {
        col = vec3(minDist * 10.0);
    }
	fragColor = vec4(col,1.0);
}