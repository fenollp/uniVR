// Shader downloaded from https://www.shadertoy.com/view/4dlXR4
// written by shadertoy user iq
//
// Name: Clover Tree
// Description: Domain repetition. A (simple) clover shape is repeated over space. Clearly NOT the way to do it (super slow). I run out of instructions (and speed), so I couldn't add variation or detail or lighting really. But the basic technique is there.
//    
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Domain repetition. A (simple) clover shape is repeated over space.

// Clearly NOT the way to do it (super slow). I run out of instructions (and speed), so
// I couldn't add variation or detail or lighting really. But the basic technique is there.

float hash1( vec3 p )
{
    return fract(sin(dot(p,vec3(1.0,57.0,113.0)))*43758.5453);
}
vec3 hash3( float n )
{
    return fract(sin(vec3(n,n+1.0,n+2.0))*vec3(43758.5453123,22578.1459123,19642.3490423));
}
vec3 hash3( vec3 p )
{
    return fract(sin(vec3( dot(p,vec3(1.0,57.0,113.0)), 
				           dot(p,vec3(57.0,113.0,1.0)),
				           dot(p,vec3(113.0,1.0,57.0))))*43758.5453);
}

// simple clover shape
float shape( in vec3 p, in float s )
{
	float a = atan( p.x, p.y );
	float r = length( p.xy );
	
	float ra = 0.2 + 0.3*sqrt(0.5+0.5*sin( 3.0*a ));
	ra *= s;
    return min( max(length(p.xy)-0.04*(0.5+0.5*p.z),-p.z), max( length(p.xy)-ra, abs(p.z-0.2*r)-0.06*s*clamp(1.0-1.5*r,0.0,1.0) ) );
}

// df
vec4 map( vec3 p )
{
	p.x += 0.1*sin( 3.0*p.y );
	
	float rr = length(p.xz);
	float ma = 0.0;
	vec2 uv = vec2(0.0);
	
	float d1 = rr - 1.5;
    if( d1<1.8 )
	{
		
		float siz = 6.0;
		vec3 x = p*siz + 0.5;
		vec3 xi = floor( x );
		vec3 xf = fract( x );

		vec2 d3 = vec2( 1000.0, 0.0 );
		for( int k=-1; k<=1; k++ )
        for( int j=-1; j<=1; j++ )
        for( int i=-1; i<=1; i++ )
        {
            vec3 b = vec3( float(i), float(j), float(k) );
			vec3 c = xi + b;
			
			float ic = dot(c.xz,c.xz)/(siz*siz);
			
			float re = 1.5;
			
			if( ic>(1.0*1.0) && ic < (re*re) )
			{
            vec3 r = b - xf + 0.5 + 0.4*(-1.0+2.0*hash3( c ));
			//vec3 r = c + 0.5 - x;

			vec3 ww = normalize( vec3(c.x,0.0,c.z) );
			ww.y += 1.0; ww = normalize(ww);
            ww += 0.25 * (-1.0+2.0*hash3( c+123.123 ));
				
			vec3 uu = normalize( cross( ww, vec3(0.0,1.0,0.0) ) );
			vec3 vv = normalize( cross( uu, ww ) );
			r = mat3(  uu.x, vv.x, ww.x,
					   uu.y, vv.y, ww.y,
					   uu.z, vv.z, ww.z )*r;
            float s = 0.75 + 0.5*hash1( c+167.7 );				
			float d = shape(r,s)/siz;
            if( d < d3.x )
            {
                d3 = vec2( d, 1.0 );
				ma = hash1( c.yzx+712.1 );
				uv = r.xy;
            }
			}
        }
		d1 = mix( rr-1.5, d3.x, d3.y );
	}
	
	d1 = min( d1, rr - 1.0 );

    return vec4(d1, ma, uv );
	
}


vec4 intersect( in vec3 ro, in vec3 rd )
{
	const float maxd = 10.0;
	
    float h = 1.0;
    float t = 0.0;
    float m = -1.0;
	vec2  u = vec2(0.0);
    for( int i=0; i<50; i++ )
    {
        if( h<0.001||t>maxd ) continue;//break;
        t += h;
	    vec4 res = map( ro+rd*t );
        h = res.x;
	    m = res.y;
		u = res.zw;
    }

    if( t>maxd ) m=-1.0;
    return vec4( t, m, u );
}

vec3 calcNormal( in vec3 pos )
{
    vec2 eps = vec2(0.001,0.0);

	return normalize( vec3(
           map(pos+eps.xyy).x - map(pos-eps.xyy).x,
           map(pos+eps.yxy).x - map(pos-eps.yxy).x,
           map(pos+eps.yyx).x - map(pos-eps.yyx).x ) );
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = iMouse.xy/iResolution.xy;
	
    // camera
	float an = 20.0 + 0.15*iGlobalTime - 7.0*m.x;
    vec3  ro = 3.1*normalize(vec3(sin(an),0.5-0.4*m.y, cos(an)));
    vec3  ta = vec3( 0.0, 0.8, 0.0 );
	float rl = 0.5*sin(0.35*an);
    vec3  ww = normalize( ta - ro );
    vec3  uu = normalize( cross(ww,vec3(sin(rl),cos(rl),0.0) ) );
    vec3  vv = normalize( cross(uu,ww));
    vec3  rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

	// render
    vec3 col = textureCube( iChannel2, rd ).xyz; col = col*col;
	
	// raymarch
    vec4 tmat = intersect(ro,rd);
    if( tmat.y>-0.5 )
    {
        // geometry
        vec3 pos = ro + tmat.x*rd;
        vec3 nor = calcNormal(pos);
		vec3 ref = reflect( rd, nor );

        // material
		vec3 mate = vec3(0.3,0.5,0.1);
		mate = mix( mate, vec3(0.5,0.25,0.1), smoothstep( 0.9,0.91, tmat.y) );
	    mate += 0.1*sin( tmat.y*10.0  + vec3(0.0,2.0,2.0));
		mate *= 0.8+0.4*tmat.y;
	    vec2 uv = tmat.zw;
		float r = length(uv);
		float a = atan(uv.y,uv.x);
		mate += vec3(0.2,0.15,0.1)*smoothstep(0.8,1.0,-cos(3.0*a))*(1.0-1.5*r);
		mate *= 0.2+r;
		
		// lighting
        float amb = clamp(0.5+0.5*nor.y,0.0,1.0);
		amb *= 0.1 + 0.9*pow( clamp( (length(pos.xz)-1.0)/(1.5-1.0), 0.0, 1.0 ), 2.0 );
		vec3 snor = normalize( nor + normalize( vec3(pos.x,0.0,pos.y) ) );
		vec3 lin = 1.0*textureCube( iChannel1, snor ).xyz*amb;
		col = mate*lin;
		float kd = pow(clamp(1.0+dot(rd,nor),0.0,1.0),3.0);
		col += 0.2*kd*pow( textureCube( iChannel2, ref ).xyz, vec3(2.2) )*amb;
	}

	// gamma
	col = pow( col, vec3(0.45) );
	
	// vigneting
	col *= 0.5 + 0.5*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.15 );
	
    fragColor = vec4( col,1.0 );
}