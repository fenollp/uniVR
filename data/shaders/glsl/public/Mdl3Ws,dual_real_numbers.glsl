// Shader downloaded from https://www.shadertoy.com/view/Mdl3Ws
// written by shadertoy user iq
//
// Name: Dual Real Numbers
// Description: Raymarching an implicit 3D surface with distance estimation (distance field). Used to compare traditional central-difference based gradients, vs analytical dual-number based techniques. It works great :)
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

// Computing the distance field for the implicit function
//
// f(x,y,z) = z² - (y²-3x²)·(3y²-x²)·(1-x)
//
// which uses the f/|grad(f)| approximation (for more info on this, see this article:
// http://www.iquilezles.org/www/articles/distance/distance.htm). 
//
// The shader compares two techniques of computing gradients. The traditional way of using 
// central differences and evaluating the function multiple times per point, and the use of 
// dual-numbers to compute analytical derivatives automatically from the funcion definition 
// (see  http://jliszka.github.io/2013/10/24/exact-numeric-nth-derivatives.html),
// which requieres far less evaluations (faster!) and no epsilon tweaking whatsoever.

//#define DONT_USE_DUALS

const float precis = 0.001;

//==================================================================================
// some dual real numbers functions, for f : R3 -> R1

struct dualR3
{
    float x, y, z;
	float dx, dy, dz;
};

vec4 dSet( float a ) { return vec4( a, 0.0, 0.0, 0.0 ); }
vec4 getX( dualR3 n ) {	return vec4(n.x, n.dx, 0.0, 0.0 ); }
vec4 getY( dualR3 n ) {	return vec4(n.y, 0.0, n.dy, 0.0 ); }
vec4 getZ( dualR3 n ) {	return vec4(n.z, 0.0, 0.0, n.dz ); }

vec4 dSqrX( dualR3 a ) { return vec4( a.x*a.x, 2.0*a.x*a.dx, 0.0, 0.0 ); }
vec4 dSqrY( dualR3 a ) { return vec4( a.y*a.y, 0.0, 2.0*a.y*a.dy, 0.0 ); }
vec4 dSqrZ( dualR3 a ) { return vec4( a.z*a.z, 0.0, 0.0, 2.0*a.z*a.dz ); }

vec4 dMul( vec4 a, vec4 b ) { return vec4( a.x*b.x, a.y*b.x + a.x*b.y, a.z*b.x + a.x*b.z, a.w*b.x + a.x*b.w );
				
}


#ifdef DONT_USE_DUALS


//===========================================================================================
// traditional way: compute gradients (and distance estimation) by central differences
//===========================================================================================
float func( vec3 p )
{
    // f(x,y,z) = z² - (y²-3x²)·(3y²-x²)·(1-x)
	return p.z*p.z - (p.y*p.y-3.0*p.x*p.x)*(3.0*p.y*p.y - p.x*p.x)*(1.0-p.x);
}

vec3 grad( in vec3 pos )
{
    vec3 eps = vec3(precis,0.0,0.0);
	return vec3(
           func(pos+eps.xyz) - func(pos-eps.xyz),
           func(pos+eps.zxy) - func(pos-eps.zxy),
           func(pos+eps.yzx) - func(pos-eps.yzx) ) / (2.0*precis);
}

float dist( vec3 p )
{
	return func(p) / length(grad(p));
}

float map( vec3 p )
{
    return func( p );
}

#else

//===========================================================================================
// dual-numbers way: compute gradients (and distance estimation) analytically
//===========================================================================================

vec4 func( dualR3 p )
{
    // f(x,y,z) = z² - (y²-3x²)·(3y²-x²)·(1-x)
    return dSqrZ(p) - dMul( dMul( dSqrY(p) - 3.0*dSqrX(p), 3.0*dSqrY(p) - dSqrX(p)), dSet(1.0) - getX(p) );
}	
	
vec3 grad( in vec3 p )
{
	return func( dualR3(p.x,p.y,p.z,1.0,1.0,1.0) ).yzw;
}

float dist( vec3 p )
{
    vec4 f = func( dualR3(p.x,p.y,p.z,1.0,1.0,1.0) );	
	return f.x / length(f.yzw);
}	

float map( vec3 p )
{
	return func( dualR3(p.x,p.y,p.z,0.0,0.0,0.0) ).x;
}

#endif

//==================================================================================


vec2 intersect( in vec3 ro, in vec3 rd )
{
	float mind = precis*2.0;
	float maxd = 15.0;
	
	
	{
	float b = dot(ro,rd);
	float c = dot(ro,ro) - 1.5*1.5;
	float h = b*b - c;
	if( h<0.0 ) return vec2(-1.0,0.0);
	h = sqrt(h);
	mind = max( mind, -b - h );
	maxd = min( maxd, -b + h );
    }

    float h = 1.0;
	float t = mind;
    for( int i=0; i<150; i++ )
	{
        if( abs(h)<precis||t>maxd ) continue;
	    h = dist( ro+rd*t );
        t += 0.25*abs(h);
    }

    if( t>maxd ) t=-1.0;
    return vec2(t,sign(h));
}

vec3 calcNormal( in vec3 p )
{
	return normalize( grad(p) );
}

float softshadow( in vec3 ro, in vec3 rd, float k )
{
	float mind = precis*2.0;
	float maxd = 15.0;
	
	{
	float b = dot(ro,rd);
	float c = dot(ro,ro) - 1.5*1.5;
	float h = b*b - c;
	h = sqrt(h);
	maxd = min( maxd, -b + h );
	mind = max( mind, -b - h );
    }
	
    float res = 1.0;
    float t = mind;
    for( int i=0; i<32; i++ )
    {
        if( t>maxd ) continue;
        float h = map( ro + rd*t );
		h = abs(h);
        res = min( res, k*h/t );
        t += 0.1;
    }
    return clamp(res,0.0,1.0);
}

vec2 hash2( float n )
{
    return fract(sin(vec2(n,n+1.0))*vec2(43758.5453123,22578.1459123));
}

vec3 hash3( float n )
{
    return fract(sin(vec3(n,n+1.0,n+2.0))*vec3(43758.5453123,22578.1459123,19642.3490423));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 m = vec2(0.5);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;

    // animation	
	float time = iGlobalTime;
	
	vec3 tot = vec3(0.0);
	for( int a=0; a<10; a++ )
	{
		vec2 pof = texture2D( iChannel1, (0.5+13.0*float(a))/iChannelResolution[1].xy  ).xz;
				  
	
    vec2 p = -1.0 + 2.0 * (fragCoord.xy + pof)/iResolution.xy;
    p.x *= iResolution.x/iResolution.y;
		
    // camera
	float an = 0.3*time - 6.2*m.x;
	float cr = 0.15*sin(0.2*time);
    vec3 ro = 2.5*vec3(sin(an),0.0,cos(an));
    vec3 ta = vec3( 0.0, 0.0, 0.0 );
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(sin(cr),cos(cr),0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
    vec3 rd = normalize( p.x*uu + p.y*vv + 1.5*ww );

	// raymarch
    vec2 t = intersect(ro,rd);
	
	// shade
    vec3 col = vec3(0.0);
    if( t.x>0.0 )
    {
        // geometry
        vec3 pos = ro + t.x*rd;
        vec3 nor = calcNormal(pos);

		// diffuse
		col = vec3(0.0);
		float off = 1.0*texture2D( iChannel1, fragCoord.xy/iChannelResolution[1].xy, -100.0 ).x;
		vec3  uu  = normalize( cross( nor, vec3(0.0,1.0,1.0) ) );
		vec3  vv  = normalize( cross( uu, nor ) );
		for( int i=0; i<10; i++ )
		{
#if 0	
			vec3 rr = normalize(-1.0 + 2.0*hash3(off+float(i)*123.5463));
			rr = normalize( nor + 7.0*rr );
			rr = rr * sign(dot(nor,rr));							  
#else
			vec2  aa = hash2( off + float(i)*203.1 + float(a)*13.7 );
			//vec2 aa = texture2D( iChannel1, (vec2(37.0,31.0)*float(i)+fragCoord.xy)/iChannelResolution[1].xy, -100.0 ).xz;
			float ra = sqrt(aa.y);
			float rx = ra*cos(6.2831*aa.x); 
			float ry = ra*sin(6.2831*aa.x);
			float rz = sqrt( 1.0-aa.y );
			vec3  rr = vec3( rx*uu + ry*vv + rz*nor );
#endif			
			float ds = 1.0;//softshadow( pos, rr, 64.0 );
			
            col += ds*mix( 0.5*vec3(0.2,0.1,0.0), vec3(0.8,0.9,1.0), smoothstep(-0.1,0.1,rr.y) );
						  //vec3(0.1)*pow( textureCube( iChannel0, rr ).xyz, vec3(2.2) );
		}
        col /= 10.0;
		
		float ii = 0.5+0.5*t.y;
		
        // specular		
		float fre = pow( clamp(1.0+dot(rd,nor),0.0,1.0), 5.0 );
		vec3 ref = reflect( rd, nor );
		float rs = 1.0;//softshadow( pos, ref, 32.0 );
        col += ii * 1.0* (0.04 + 1.0*fre) * pow( textureCube( iChannel2, ref ).xyz, vec3(2.0) ) * rs;

        // color
		col *= mix( vec3(1.0,0.5,0.2), vec3(1.0,1.0,1.0), ii );
		//col *= 1.5;
    }
	else
	{
        // background		
		col =0.9* pow( textureCube( iChannel2, rd ).xyz, vec3(2.2) );
	}
	
		tot += col;
	}

	tot /= 10.0;
	
	// gamma
	tot = pow( clamp( tot, 0.0, 1.0 ), vec3(0.45) );
	
    fragColor = vec4( tot, 1.0 );
}