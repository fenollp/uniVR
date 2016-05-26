// Shader downloaded from https://www.shadertoy.com/view/ldcGWl
// written by shadertoy user nicoptere
//
// Name: 2D transition
// Description: test


vec2 project( vec2 p, vec2 a, vec2 b ){

    float A = p.x - a.x;
    float B = p.y - a.y;
    float C = b.x - a.x;
    float D = b.y - a.y;
    float dot = A * C + B * D;
    float len = C * C + D * D;
    float t = dot / len;
    return vec2( a.x + t * C, a.y + t * D );
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = ( fragCoord.xy / iResolution.xy );
    uv.y = 1. - uv.y;
    
    
    vec2 p0 = vec2( abs( cos( iGlobalTime * .1 ) ), 0.25 );
    vec2 p1 = vec2( 0.5,  .75 );
    p1 = iMouse.xy / iResolution.xy;
    p1.y = 1. - p1.y;
    vec2 n = normalize(  vec2( -( p1.y - p0.y ), ( p1.x - p0.x ) ) ) * .15;
    
    vec2 c = p0 + (p1 - p0 ) * .5;
    
    vec2 a = c + n * sign( p0.x - c.x );
    vec2 b = c + n * sign( p1.x -  c.x ) ;
    
    vec2 pp = project( uv, a, b ) - c;
    
    
    float d = pp.x - uv.x + pp.y - uv.y ;
    float s = sign( d );
    pp *= s * pow( d*.95, 2. );
    
    float len = length( pp ) / length( c );
    
    float t = sin( iGlobalTime ) * .5 + .5;
    //t = iMouse.x / iResolution.x;
    len = smoothstep( t-.001, t+.001, len );
    float blue = 0.;
    if( distance( uv, p0 )<.02 )
    {
        pp=vec2(0.,1.);
        blue = 1.;
    }
    if( distance( uv, p1 )<.02 )
    {
        pp=vec2(1.,0.);
        blue = .5;
    }
    if( distance( uv, a )<.01 )pp=vec2(0.,1.);
    if( distance( uv, b )<.01 )pp=vec2(1.,0.);
    if( distance( uv, c )<.01 )pp=vec2(1.,1.);
	fragColor = vec4( vec3(len)+vec3(pp.x, pp.y,blue) , 1.  );
}