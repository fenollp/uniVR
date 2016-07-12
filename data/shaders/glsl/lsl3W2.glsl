// Shader downloaded from https://www.shadertoy.com/view/lsl3W2
// written by shadertoy user iq
//
// Name: Cubic Julia
// Description: A cubic Julia set f(z) = z^3 + c, in quaternion space. I used the regular Hubbard-Douady potential based distance estimator d(z) = 0.5·log|z|·|z|/|dz| for the marcher, orbit traps for coloring, and a compact way to rise a quaterion to the cube power.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

vec3 hash3( float n )
{
    return fract(sin(vec3(n,n+1.0,n+2.0))*vec3(43758.5453123,22578.1459123,19642.3490423));
}

//--------------------------------------------------------------------------------
// quaternion manipulation
//--------------------------------------------------------------------------------

vec4 qSquare( vec4 a )
{
    return vec4( a.x*a.x - dot(a.yzw,a.yzw), 2.0*a.x*(a.yzw) );
}

vec4 qCube( vec4 a )
{
	return a * ( 4.0*a.x*a.x - dot(a,a)*vec4(3.0,1.0,1.0,1.0) );
}

//--------------------------------------------------------------------------------

float lengthSquared( vec4 z ) { return dot(z,z); }

// animation
vec4 c = vec4(-0.1,0.6,0.9,-0.3) + 0.1*sin( vec4(3.0,0.0,1.0,2.0) + 0.5*vec4(1.0,1.3,1.7,2.1)*iGlobalTime);

vec3 map( vec3 p )
{
    vec4 z = vec4( p, 0.2 );
	
	float m2 = 0.0;
	vec2  t = vec2( 1e10 );

	float dz2 = 1.0;
	for( int i=0; i<10; i++ ) 
	{
        // |dz|² = |3z²|²
		dz2 *= 9.0*lengthSquared(qSquare(z));
        
		// z = z^3 + c		
		z = qCube( z ) + c;
		
        // stop under divergence		
        m2 = dot(z, z);		
        if( m2>10000.0 ) break;				 

        // orbit trapping ( |z|² and z_x  )
		t = min( t, vec2( m2, abs(z.x)) );

	}

	// distance estimator: d(z) = 0.5·log|z|·|z|/|dz|   (see http://iquilezles.org/www/articles/distancefractals/distancefractals.htm)
	float d = 0.25 * log(m2) * sqrt(m2/dz2 );

	return vec3( d, t );
}

vec3 intersect( in vec3 ro, in vec3 rd )
{
	float maxd = 8.0;
	float precis = 0.002;
    float h = 1.0;
    float t = 0.0;
	float d = 0.0;
    float m = 1.0;
    for( int i=0; i<150; i++ )
	{
        if( h<precis||t>maxd ) break;
        t += h;
	    vec3 res = map( ro+rd*t );
        h = res.x;
		d = res.y;
		m = res.z;
    }

    if( t>maxd ) m=-1.0;
    return vec3( t, d, m );
}

vec3 calcNormal( in vec3 pos, float e )
{
    vec3 eps = vec3(e,0.0,0.0);

	return normalize( vec3(
           map(pos+eps.xyy).x - map(pos-eps.xyy).x,
           map(pos+eps.yxy).x - map(pos-eps.yxy).x,
           map(pos+eps.yyx).x - map(pos-eps.yyx).x ) );
}

vec3 calcPixel( in vec2 pi, in float time )
{
	vec2 q = pi / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.5);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;

    // camera
	float an = -2.4 + 0.2*time - 6.2*m.x;
    vec3 ro = 3.0*vec3(sin(an),0.25,cos(an));
    vec3 ta = vec3( 0.0, 0.0, 0.0 );
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    vec3 rd = normalize( p.x*uu + p.y*vv + 4.0*ww );

	// raymarch
    vec3 tmat = intersect(ro,rd);
	
	// shade
    vec3 col = vec3(0.0);
    if( tmat.z>-0.5 )
    {
        // geometry
        vec3 pos = ro + tmat.x*rd;
        vec3 nor = calcNormal(pos, 0.001);
        vec3 sor = calcNormal(pos, 0.01);

        // material		
		vec3 mate = 0.5 + 0.5*sin( tmat.z*4.0 + 4.0 + vec3(3.0,1.5,2.0)  + nor*0.2 ).xzy;
		
        // lighting		
		float occ = clamp( tmat.y*0.5 + 0.5*(tmat.y*tmat.y), 0.0, 1.0 ) * (1.0 + 0.1*nor.y);
		
        // diffuse		
		col = vec3(0.0);
		for( int i=0; i<32; i++ )
		{
			vec3 rr = normalize(-1.0 + 2.0*hash3(float(i)*123.5463));
			rr = normalize( nor + 8.0*rr );
			rr = rr * sign(dot(nor,rr));							  
            col += pow( textureCube( iChannel0, rr ).xyz, vec3(2.2) ) * dot(rr,nor);
		}
        col = 5.0 * occ * (col/32.0);

        // rim		
		col *= 1.0 + 1.0*pow(clamp(1.0+dot(rd,sor),0.0,1.0),1.0)*vec3(1.0);

        // specular		 
		float fre = pow( clamp(1.0+dot(rd,sor),0.0,1.0), 5.0 );
		vec3  ref = reflect( rd, nor );
		col *= 1.0 - 0.5*fre; 
		col += 1.5 * (0.5 + 0.5*fre) * pow( textureCube( iChannel0, ref ).xyz, vec3(2.0) ) * occ;

        col *= mate;
    }
	else
	{
        // background		
		col = pow( textureCube( iChannel0, rd ).xyz, vec3(2.2) );
	}

	// gamma
	col = pow( clamp( col, 0.0, 1.0 ), vec3(0.45) );
	
    return col;
}



void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	#if 0
    const int samples = 4;
	vec3 col = vec3(0.0);
	for( int i=0; i<samples; i++ )
	{
		float r = texture2D( iChannel1, fragCoord.xy/iChannelResolution[1].xy ).x;
		vec3  h = hash3( r + float(i) + iGlobalTime );
        vec2  p = fragCoord.xy + h.xy;
		float t = iGlobalTime + 0.5*h.z/24.0;
        col += calcPixel( p, t );
	}
    fragColor = vec4( col/float(samples), 1.0 );
	#else
	
    fragColor = vec4( calcPixel( fragCoord.xy, iGlobalTime ), 1.0 );
	
	#endif
}
