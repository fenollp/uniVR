// Shader downloaded from https://www.shadertoy.com/view/ldX3Ws
// written by shadertoy user iq
//
// Name: Balls and occlusion
// Description: A few spheres with raytraced ambient occlusion.
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

#define NUMSPHEREES 12

#define eps 0.001

vec2 hash2( float n )
{
    return fract(sin(vec2(n,n+1.0))*vec2(43758.5453123,22578.1459123));
}

vec3 hash3( float n )
{
    return fract(sin(vec3(n,n+1.0,n+2.0))*vec3(43758.5453123,22578.1459123,19642.3490423));
}

vec3 nSphere( in vec3 pos, in vec4 sph )
{
    return (pos-sph.xyz)/sph.w;
}

float iSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
	vec3 oc = ro - sph.xyz;
	float b = dot( oc, rd );
	float c = dot( oc, oc ) - sph.w*sph.w;
	float h = b*b - c;
	if( h<0.0 ) return -1.0;
	return -b - sqrt( h );
}

float sSphere( in vec3 ro, in vec3 rd, in vec4 sph )
{
    vec3 oc = ro - sph.xyz;
    float b = dot( oc, rd );
    float c = dot( oc, oc ) - sph.w*sph.w;
	
    return step( min( -b, min( c, b*b - c ) ), 0.0 );
}

vec4 sphere[NUMSPHEREES];

float intersect( in vec3 ro, in vec3 rd, out vec3 nor, out float id )
{
	float res = 1e20;
	float fou = -1.0;
	
	nor = vec3(0.0);

	for( int i=0; i<NUMSPHEREES; i++ )
	{
		vec4 sph = sphere[i];
	    float t = iSphere( ro, rd, sph ); 
		if( t>eps && t<res ) 
		{
			res = t;
			nor = nSphere( ro + t*rd, sph );
			fou = 1.0;
			id = float(i);
		}
	}
						  
    return fou * res;					  
}

float shadow( in vec3 ro, in vec3 rd )
{
	float res = 1.0;
	for( int i=0; i<NUMSPHEREES; i++ )
	{
		float id = float(i);
	    float t = sSphere( ro, rd, sphere[i] ); 
		res = min( t, res );
	}
    return res;					  
}

float getRad( float id )
{
	float rad = 0.0;
	if( id<12.5 ) rad = 1.0;
	if( id<9.5 )  rad = 0.5;
	if( id<6.5 )  rad = 0.0;
	return rad;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 q = fragCoord.xy / iResolution.xy;
    vec2 p = -1.0 + 2.0 * q;
    p.x *= iResolution.x/iResolution.y;
    vec2 m = vec2(0.5);
	if( iMouse.z>0.0 ) m = iMouse.xy/iResolution.xy;
	
    //-----------------------------------------------------
    // animate
    //-----------------------------------------------------
	float time = iGlobalTime - 11.6;
	
	float an = 0.3*time - 7.0*m.x;

	for( int i=0; i<NUMSPHEREES; i++ )
	{
		float id  = float(i);
		float rad = getRad( id );
	    vec3  pos = 1.0*cos( 6.2831*hash3(id*37.17) + 0.5*(1.0-0.7*rad)*hash3(id*31.3+4.7)*time );
		sphere[i] = vec4( pos, (0.3+0.7 *rad) );
    }
			
    //-----------------------------------------------------
    // camera
    //-----------------------------------------------------
	vec3 ro = vec3(2.5*sin(an),1.5*cos(0.5*an),2.5*cos(an));
    vec3 ta = vec3(0.0,0.0,0.0);
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	vec3 rd = normalize( p.x*uu + p.y*vv + 2.0*ww );

    //-----------------------------------------------------
	// render
    //-----------------------------------------------------
	vec3 col = vec3(1.0) * (0.98+0.1*rd.y);

	// raymarch
	vec3 nor;
	float id;
	float t = intersect(ro,rd,nor, id);
	if( t>0.0 )
	{
		vec3 pos = ro + t*rd;
		
		float occ = 0.0;

        #if 0
		vec3  uu  = normalize( cross( nor, vec3(0.0,1.0,1.0) ) );
		vec3  vv  = normalize( cross( uu, nor ) );
        #else
        // see http://orbit.dtu.dk/fedora/objects/orbit:113874/datastreams/file_75b66578-222e-4c7d-abdf-f7e255100209/content
        // (link provided by nimitz)
        vec3 tc = vec3( 1.0+nor.z-nor.xy*nor.xy, -nor.x*nor.y)/(1.0+nor.z);
        vec3 uu = vec3( tc.x, tc.z, -nor.x );
   	    vec3 vv = vec3( tc.z, tc.y, -nor.y );
        #endif
        
        float off = texture2D( iChannel0, fragCoord.xy/iChannelResolution[0].xy, -100.0 ).x;
		for( int j=0; j<48; j++ )
		{
			vec2  aa = hash2( off + float(j)*203.1 );
			float ra = sqrt(aa.y);
			float rx = ra*cos(6.2831*aa.x); 
			float ry = ra*sin(6.2831*aa.x);
			float rz = sqrt( 1.0-aa.y );
			vec3  rr = vec3( rx*uu + ry*vv + rz*nor );
			occ += shadow( pos, rr );
		}
		occ /= 48.0;
				
		vec3 mate = vec3(1.0);
		mate = vec3( 1.0, 1.0, 0.6 );
		mate = mix( mate, vec3(1.0,0.4,0.1), (1.0-smoothstep(0.7,0.71,getRad( id ))) );
		mate = mix( mate, vec3(1.0,0.7,0.1), (1.0-smoothstep(0.4,0.41,getRad( id ))) );
        mate += 0.10*sin( 5.0 + vec3(0.0,1.0,2.0) + id*20.0 );
		mate *= 0.25 + 0.75*mix( 1.0, smoothstep( -0.95,-0.8,sin(pos.y*40.0) ), 1.0-pow(abs(nor.y),8.0) );
		mate *= 1.00 + 0.10*nor*nor*nor;
		
		col = mate * (occ*0.25+0.75*sqrt(occ));
		
		col += 0.25*pow( 1.0+dot(rd,nor), 5.0 )*occ*occ;
	    col *= 0.90 + 0.10*nor.y;
	}
	
	// vigneting
    col *= 1.0 - 0.3*dot((q-0.5)*(q-0.5),(q-0.5)*(q-0.5));

	fragColor = vec4( col, 1.0 );
}
